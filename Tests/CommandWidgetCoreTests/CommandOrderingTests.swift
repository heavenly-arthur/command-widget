import Foundation
import XCTest
@testable import CommandWidgetCore

final class CommandOrderingTests: XCTestCase {
    func testStarterCatalogContainsExpectedRoleExpansion() {
        XCTAssertEqual(CommandCategory.allCases.count, 22)
        XCTAssertEqual(StarterCatalog.entries.count, 230)
    }

    func testEveryCategoryHasAtLeastEightDetailedEntries() {
        for category in CommandCategory.allCases {
            let entries = StarterCatalog.entries.filter { $0.category == category }
            XCTAssertGreaterThanOrEqual(entries.count, 8, category.rawValue)
            XCTAssertTrue(entries.allSatisfy { !$0.details.isEmpty && !$0.examples.isEmpty })
        }
    }

    func testBundledEntriesHaveUniqueStableIDs() {
        XCTAssertEqual(Set(StarterCatalog.entries.map(\.id)).count, StarterCatalog.entries.count)
    }

    func testMoveChangesOnlyRequestedCategoryAndNormalizesOrder() {
        let original = StarterCatalog.entries
        let otherCategories = original.filter { $0.category != .kubernetes }

        let moved = CommandOrdering.moving(
            original,
            in: .kubernetes,
            fromOffsets: IndexSet(integer: 0),
            toOffset: 3
        )
        let kubernetes = CommandOrdering.sorted(moved, in: .kubernetes)

        XCTAssertEqual(kubernetes.map(\.order), Array(0..<kubernetes.count).map(Optional.some))
        XCTAssertEqual(kubernetes[2].id, CommandOrdering.sorted(original, in: .kubernetes)[0].id)
        XCTAssertEqual(moved.filter { $0.category != .kubernetes }, otherCategories)
    }

    func testMoveInsideSubcategoryKeepsSiblingToolsInPlace() {
        let original = StarterCatalog.entries
        let originalDatabases = CommandOrdering.sorted(original, in: .databases)
        let originalPostgreSQL = originalDatabases.filter { $0.subcategory == .postgresql }
        let originalOtherDatabases = originalDatabases.filter { $0.subcategory != .postgresql }

        let moved = CommandOrdering.moving(
            original,
            within: .postgresql,
            fromOffsets: IndexSet(integer: 0),
            toOffset: 3
        )
        let movedDatabases = CommandOrdering.sorted(moved, in: .databases)
        let movedPostgreSQL = movedDatabases.filter { $0.subcategory == .postgresql }

        XCTAssertEqual(movedPostgreSQL[2].id, originalPostgreSQL[0].id)
        XCTAssertEqual(
            movedDatabases.filter { $0.subcategory != .postgresql }.map(\.id),
            originalOtherDatabases.map(\.id)
        )
        XCTAssertEqual(
            moved.filter { $0.category != .databases },
            original.filter { $0.category != .databases }
        )
        XCTAssertEqual(
            movedDatabases.map(\.order),
            Array(0..<movedDatabases.count).map(Optional.some)
        )
    }

    func testSavedOrderSurvivesReload() throws {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandOrderingTests-\(UUID().uuidString)", isDirectory: true)
        let store = JSONCommandStore(fileURL: directory.appendingPathComponent("commands.json"))
        let moved = CommandOrdering.moving(
            StarterCatalog.entries,
            in: .helm,
            fromOffsets: IndexSet(integer: 7),
            toOffset: 0
        )
        try store.save(StoredCommandCatalog(
            bundledCatalogVersion: StarterCatalog.currentVersion,
            entries: moved
        ))

        let reloaded = try store.load()
        XCTAssertEqual(
            CommandOrdering.sorted(reloaded.entries, in: .helm).map(\.id),
            CommandOrdering.sorted(moved, in: .helm).map(\.id)
        )
    }
}
