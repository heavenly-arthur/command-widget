import Foundation
import XCTest
@testable import CommandWidgetCore

final class JSONCommandStoreTests: XCTestCase {
    func testStarterCatalogContainsEveryCategory() {
        let categories = Set(StarterCatalog.entries.map(\.category))
        XCTAssertEqual(categories, Set(CommandCategory.allCases))
    }

    func testFirstLoadCreatesCatalog() throws {
        let fixture = try Fixture()
        let catalog = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )

        XCTAssertEqual(catalog.entries, StarterCatalog.entries)
        XCTAssertTrue(FileManager.default.fileExists(atPath: fixture.fileURL.path))
    }

    func testExistingCatalogIsNotOverwrittenBySeeds() throws {
        let fixture = try Fixture()
        var catalog = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )
        catalog.entries[0].title = "Моя изменённая команда"
        try fixture.store.save(catalog)

        let reloaded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )

        XCTAssertEqual(reloaded.entries[0].title, "Моя изменённая команда")
    }

    func testMultilineUnicodeAndEscapesRoundTrip() throws {
        let fixture = try Fixture()
        let entry = CommandEntry(
            title: "Проверка 🧪",
            command: "printf \\\"строка 1\\nстрока 2\\\\path\\\"",
            category: .linux,
            summary: "Кавычки и Unicode",
            details: "Подробности",
            examples: ["echo 'готово'"]
        )
        try fixture.store.save(StoredCommandCatalog(entries: [entry]))

        XCTAssertEqual(try fixture.store.load().entries, [entry])
    }

    func testMalformedCatalogIsNotOverwritten() throws {
        let fixture = try Fixture()
        let malformed = Data("{not-json".utf8)
        try malformed.write(to: fixture.fileURL)

        XCTAssertThrowsError(try fixture.store.loadOrSeed(with: StarterCatalog.entries))
        XCTAssertEqual(try Data(contentsOf: fixture.fileURL), malformed)
    }

    func testUpgradeAddsOnlyNewBundledEntriesAndPreservesExistingValues() throws {
        let fixture = try Fixture()
        var original = StarterCatalog.entries.filter { $0.bundledVersion == 1 }
        original[0].title = "Моё название"
        original[0].order = 9
        try fixture.store.save(StoredCommandCatalog(
            schemaVersion: 1,
            bundledCatalogVersion: 1,
            entries: original
        ))

        let upgraded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )

        XCTAssertEqual(upgraded.entries.count, StarterCatalog.entries.count)
        XCTAssertEqual(upgraded.entries.first { $0.id == original[0].id }?.title, "Моё название")
        XCTAssertEqual(upgraded.bundledCatalogVersion, StarterCatalog.currentVersion)
    }

    func testCurrentVersionDoesNotRestoreDeletedBundledEntry() throws {
        let fixture = try Fixture()
        var catalog = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )
        let removedID = catalog.entries.removeFirst().id
        try fixture.store.save(catalog)

        let reloaded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )

        XCTAssertFalse(reloaded.entries.contains { $0.id == removedID })
    }
}

private struct Fixture {
    let directoryURL: URL
    let fileURL: URL
    let store: JSONCommandStore

    init() throws {
        directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandWidgetTests-\(UUID().uuidString)", isDirectory: true)
        fileURL = directoryURL.appendingPathComponent("commands.json")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        store = JSONCommandStore(fileURL: fileURL)
    }
}
