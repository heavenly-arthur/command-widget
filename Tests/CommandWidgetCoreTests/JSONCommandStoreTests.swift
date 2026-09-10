import Foundation
import XCTest
@testable import CommandWidgetCore

final class JSONCommandStoreTests: XCTestCase {
    func testStarterCatalogContainsEveryCategory() {
        let categories = Set(StarterCatalog.entries.map(\.category))
        XCTAssertEqual(categories, Set(CommandCategory.allCases))
    }

    func testNewCategoriesContainTwentyCommandsWithExamples() {
        let categories: [CommandCategory] = [.ollama, .crowdsec, .mattermost, .git]

        for category in categories {
            let entries = StarterCatalog.entries.filter { $0.category == category }
            XCTAssertGreaterThanOrEqual(entries.count, 20, "\(category.rawValue) must contain at least 20 commands")
            XCTAssertLessThanOrEqual(entries.count, 30, "\(category.rawValue) must contain no more than 30 commands")
            XCTAssertTrue(entries.allSatisfy { !$0.command.isEmpty && !$0.summary.isEmpty && !$0.details.isEmpty && !$0.examples.isEmpty })
        }
    }

    func testStarterCatalogHasUniqueIDs() {
        XCTAssertEqual(Set(StarterCatalog.entries.map(\.id)).count, StarterCatalog.entries.count)
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
            bundledVersion: 3
        )

        let versionThreeCount = StarterCatalog.entries.filter { ($0.bundledVersion ?? 1) <= 3 }.count
        XCTAssertEqual(upgraded.entries.count, versionThreeCount)
        XCTAssertEqual(upgraded.entries.first { $0.id == original[0].id }?.title, "Моё название")
        XCTAssertEqual(upgraded.bundledCatalogVersion, 3)
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

    func testVersionTwoUpgradeAddsSixLinuxEntriesOnceAndPreservesExistingOrder() throws {
        let fixture = try Fixture()
        var versionTwoEntries = StarterCatalog.entries.filter { ($0.bundledVersion ?? 1) <= 2 }
        versionTwoEntries = CommandOrdering.moving(
            versionTwoEntries,
            in: .linux,
            fromOffsets: IndexSet(integer: 7),
            toOffset: 0
        )
        let existingLinuxIDs = CommandOrdering.sorted(versionTwoEntries, in: .linux).map(\.id)
        try fixture.store.save(StoredCommandCatalog(
            bundledCatalogVersion: 2,
            entries: versionTwoEntries
        ))

        let upgraded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: 3
        )
        let upgradedLinux = CommandOrdering.sorted(upgraded.entries, in: .linux)

        XCTAssertEqual(upgraded.bundledCatalogVersion, 3)
        XCTAssertEqual(upgradedLinux.count, 14)
        XCTAssertEqual(Array(upgradedLinux.prefix(existingLinuxIDs.count)).map(\.id), existingLinuxIDs)
        XCTAssertEqual(upgradedLinux.suffix(6).map(\.bundledVersion), Array(repeating: 3, count: 6))

        let reloaded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: 3
        )
        XCTAssertEqual(reloaded.entries, upgraded.entries)
    }

    func testVersionThreeUpgradeAddsNewCategoriesWithoutChangingExistingEntries() throws {
        let fixture = try Fixture()
        let versionThreeEntries = StarterCatalog.entries.filter { ($0.bundledVersion ?? 1) <= 3 }
        try fixture.store.save(StoredCommandCatalog(
            bundledCatalogVersion: 3,
            entries: versionThreeEntries
        ))

        let upgraded = try fixture.store.loadOrSeed(
            with: StarterCatalog.entries,
            bundledVersion: StarterCatalog.currentVersion
        )

        XCTAssertEqual(upgraded.bundledCatalogVersion, 4)
        XCTAssertEqual(upgraded.entries.filter { ($0.bundledVersion ?? 1) == 4 }.count, 80)
        XCTAssertTrue(versionThreeEntries.allSatisfy { oldEntry in
            upgraded.entries.contains { $0 == oldEntry }
        })
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
