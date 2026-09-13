import Foundation
import XCTest
@testable import CommandWidgetCore

final class CustomCommandTaxonomyTests: XCTestCase {
    func testCategoryAndSubcategoryTitlesAreNormalized() throws {
        var taxonomy = CustomCommandTaxonomy()

        let categoryID = try taxonomy.addCategory(title: "  Мои   сервисы  ")
        let subcategoryID = try taxonomy.addSubcategory(
            categoryID: categoryID,
            title: "  Внутренние   CLI  "
        )

        XCTAssertEqual(taxonomy.categories[0].title, "Мои сервисы")
        XCTAssertEqual(taxonomy.categories[0].subcategories[0].title, "Внутренние CLI")
        XCTAssertEqual(taxonomy.categories[0].subcategories[0].id, subcategoryID)
    }

    func testDuplicateAndBuiltInCategoryNamesAreRejectedCaseInsensitively() throws {
        var taxonomy = CustomCommandTaxonomy()
        _ = try taxonomy.addCategory(title: "Internal Tools")

        XCTAssertThrowsError(try taxonomy.addCategory(title: "internal tools")) { error in
            XCTAssertEqual(error as? CustomTaxonomyError, .duplicateCategory)
        }
        XCTAssertThrowsError(try taxonomy.addCategory(title: "kubernetes")) { error in
            XCTAssertEqual(error as? CustomTaxonomyError, .duplicateBuiltInCategory)
        }
    }

    func testDuplicateSubcategoryNamesAreScopedToParentCategory() throws {
        var taxonomy = CustomCommandTaxonomy()
        let first = try taxonomy.addCategory(title: "First")
        let second = try taxonomy.addCategory(title: "Second")
        _ = try taxonomy.addSubcategory(categoryID: first, title: "Deploy")

        XCTAssertThrowsError(try taxonomy.addSubcategory(categoryID: first, title: "deploy")) { error in
            XCTAssertEqual(error as? CustomTaxonomyError, .duplicateSubcategory)
        }
        XCTAssertNoThrow(try taxonomy.addSubcategory(categoryID: second, title: "Deploy"))
    }

    func testRenamePreservesStableIdentifiers() throws {
        var taxonomy = CustomCommandTaxonomy()
        let categoryID = try taxonomy.addCategory(title: "Old category")
        let subcategoryID = try taxonomy.addSubcategory(categoryID: categoryID, title: "Old tool")

        try taxonomy.renameCategory(id: categoryID, title: "New category")
        try taxonomy.renameSubcategory(
            categoryID: categoryID,
            subcategoryID: subcategoryID,
            title: "New tool"
        )

        XCTAssertEqual(taxonomy.categories[0].id, categoryID)
        XCTAssertEqual(taxonomy.categories[0].subcategories[0].id, subcategoryID)
        XCTAssertEqual(taxonomy.categories[0].title, "New category")
        XCTAssertEqual(taxonomy.categories[0].subcategories[0].title, "New tool")
    }

    func testRemovingCategoryAlsoRemovesItsSubcategories() throws {
        var taxonomy = CustomCommandTaxonomy()
        let categoryID = try taxonomy.addCategory(title: "Temporary")
        _ = try taxonomy.addSubcategory(categoryID: categoryID, title: "Nested")

        try taxonomy.removeCategory(id: categoryID)

        XCTAssertTrue(taxonomy.categories.isEmpty)
    }

    func testStoreRoundTripsUnicodeAndEnabledState() throws {
        let fixture = try Fixture()
        var taxonomy = CustomCommandTaxonomy()
        let categoryID = try taxonomy.addCategory(title: "Личные 🧰")
        let subcategoryID = try taxonomy.addSubcategory(categoryID: categoryID, title: "Скрипты")
        try taxonomy.setSubcategoryEnabled(
            categoryID: categoryID,
            subcategoryID: subcategoryID,
            isEnabled: false
        )

        XCTAssertNil(try fixture.store.load())
        try fixture.store.save(taxonomy)

        XCTAssertEqual(try fixture.store.load(), taxonomy)
    }

    func testMalformedStoreIsNotOverwritten() throws {
        let fixture = try Fixture()
        let malformed = Data("{broken-json".utf8)
        try malformed.write(to: fixture.fileURL)

        XCTAssertThrowsError(try fixture.store.load())
        XCTAssertEqual(try Data(contentsOf: fixture.fileURL), malformed)
    }
}

private struct Fixture {
    let fileURL: URL
    let store: JSONCustomTaxonomyStore

    init() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CustomTaxonomyTests-\(UUID().uuidString)", isDirectory: true)
        fileURL = directoryURL.appendingPathComponent("custom-taxonomy.json")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        store = JSONCustomTaxonomyStore(fileURL: fileURL)
    }
}
