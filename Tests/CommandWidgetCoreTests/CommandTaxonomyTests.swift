import XCTest
@testable import CommandWidgetCore

final class CommandTaxonomyTests: XCTestCase {
    func testTaxonomyContainsExpectedNumberOfSelectableTools() {
        XCTAssertEqual(CommandSubcategory.all.count, 66)
        XCTAssertEqual(Set(CommandSubcategory.all).count, 66)
    }

    func testEveryCategoryHasSelectableSubcategories() {
        for category in CommandCategory.allCases {
            XCTAssertFalse(CommandSubcategory.all(in: category).isEmpty, category.rawValue)
        }
    }

    func testEveryBundledEntryMapsToSubcategoryInsideItsCategory() {
        for entry in StarterCatalog.entries {
            XCTAssertEqual(entry.subcategory.category, entry.category, entry.title)
        }
    }

    func testEverySubcategoryContainsBundledCommands() {
        let usedSubcategories = Set(StarterCatalog.entries.map(\.subcategory))
        XCTAssertEqual(usedSubcategories, Set(CommandSubcategory.all))
    }

    func testDatabaseCommandsAreSplitByEngine() {
        let databaseEntries = StarterCatalog.entries.filter { $0.category == .databases }
        let grouped = Dictionary(grouping: databaseEntries, by: \.subcategory)

        XCTAssertEqual(Set(grouped.keys), [.postgresql, .mysql, .sqlite, .redis, .mongodb])
        XCTAssertEqual(grouped[.postgresql]?.count, 4)
    }
}
