import Foundation
import XCTest
@testable import CommandWidgetCore

final class LibraryPreferencesTests: XCTestCase {
    func testEveryRoleHasRecommendedCategories() {
        for role in CommandRole.allCases {
            XCTAssertFalse(role.recommendedCategories.isEmpty, "\(role.rawValue) must have recommendations")
        }
    }

    func testEveryVersionFiveCategoryBelongsToAProductRole() {
        let versionFiveCategories = Set(CommandCategory.allCases.filter { $0.bundledVersion == 5 })
        let roleCategories = CommandRole.frontend.recommendedCategories
            .union(CommandRole.backend.recommendedCategories)
            .union(CommandRole.qa.recommendedCategories)

        XCTAssertEqual(versionFiveCategories, roleCategories.intersection(versionFiveCategories))
    }

    func testCombinedRecommendationsContainCategoriesFromEverySelectedRole() {
        let roles: Set<CommandRole> = [.backend, .qa]
        let expected = CommandRole.backend.recommendedCategories
            .union(CommandRole.qa.recommendedCategories)

        XCTAssertEqual(LibraryPreferences.recommended(for: roles), expected)
    }

    func testSelectingRoleAddsItsRecommendedCategories() {
        var preferences = LibraryPreferences(
            selectedRoles: [],
            selectedCategories: [.terraform]
        )

        preferences.setRole(.frontend, isSelected: true)

        XCTAssertEqual(preferences.selectedRoles, [.frontend])
        XCTAssertTrue(preferences.selectedCategories.isSuperset(of: CommandRole.frontend.recommendedCategories))
        XCTAssertTrue(preferences.selectedCategories.contains(.terraform))
    }

    func testDeselectingRoleRemovesItsExclusiveCategoriesAndKeepsSharedOnes() {
        let roles: Set<CommandRole> = [.frontend, .backend]
        var preferences = LibraryPreferences(
            selectedRoles: roles,
            selectedCategories: LibraryPreferences.recommended(for: roles).union([.terraform])
        )

        preferences.setRole(.frontend, isSelected: false)

        XCTAssertEqual(preferences.selectedRoles, [.backend])
        XCTAssertFalse(preferences.selectedCategories.contains(.nodeJS))
        XCTAssertFalse(preferences.selectedCategories.contains(.typescript))
        XCTAssertFalse(preferences.selectedCategories.contains(.frontendTooling))
        XCTAssertFalse(preferences.selectedCategories.contains(.frontendTesting))
        XCTAssertTrue(preferences.selectedCategories.contains(.git), "Git is shared with Backend")
        XCTAssertTrue(preferences.selectedCategories.contains(.terraform), "Unrelated manual choice must remain")
    }

    func testDeselectingLastRoleRemovesAllItsRecommendedCategories() {
        var preferences = LibraryPreferences(
            selectedRoles: [.qa],
            selectedCategories: CommandRole.qa.recommendedCategories.union([.terraform])
        )

        preferences.setRole(.qa, isSelected: false)

        XCTAssertTrue(preferences.selectedRoles.isEmpty)
        XCTAssertTrue(preferences.selectedCategories.isDisjoint(with: CommandRole.qa.recommendedCategories))
        XCTAssertEqual(preferences.selectedCategories, [.terraform])
    }

    func testDeselectingOneDatabaseKeepsCategorySelected() {
        var preferences = LibraryPreferences(
            selectedRoles: [.backend],
            selectedCategories: [.databases],
            selectedSubcategories: Set(CommandSubcategory.all(in: .databases))
        )

        preferences.setSubcategory(.mysql, isSelected: false)

        XCTAssertTrue(preferences.selectedCategories.contains(.databases))
        XCTAssertFalse(preferences.effectiveSelectedSubcategories.contains(.mysql))
        XCTAssertTrue(preferences.effectiveSelectedSubcategories.contains(.postgresql))
    }

    func testDeselectingEveryDatabaseRemovesParentCategory() {
        var preferences = LibraryPreferences(
            selectedRoles: [.backend],
            selectedCategories: [.databases],
            selectedSubcategories: Set(CommandSubcategory.all(in: .databases))
        )

        for subcategory in CommandSubcategory.all(in: .databases) {
            preferences.setSubcategory(subcategory, isSelected: false)
        }

        XCTAssertFalse(preferences.selectedCategories.contains(.databases))
        XCTAssertTrue(preferences.effectiveSelectedSubcategories.isEmpty)
    }

    func testLegacyPreferencesEnableAllSubcategoriesInSelectedCategories() {
        let legacy = LibraryPreferences(
            selectedRoles: [.backend],
            selectedCategories: [.databases, .apiAndGRPC],
            selectedSubcategories: nil
        )

        let migrated = legacy.migratedTaxonomy()

        XCTAssertNotNil(migrated.selectedSubcategories)
        XCTAssertEqual(
            migrated.effectiveSelectedSubcategories,
            LibraryPreferences.subcategories(for: [.databases, .apiAndGRPC])
        )
    }

    func testPreferencesFilterEntriesBySubcategory() {
        let preferences = LibraryPreferences(
            selectedRoles: [.backend],
            selectedCategories: [.databases],
            selectedSubcategories: [.postgresql]
        )
        let databaseEntries = StarterCatalog.entries.filter { $0.category == .databases }

        XCTAssertTrue(databaseEntries.filter(preferences.includes).allSatisfy { $0.subcategory == .postgresql })
        XCTAssertEqual(databaseEntries.filter(preferences.includes).count, 4)
    }

    func testPreferencesRoundTrip() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandWidgetPreferencesTests-\(UUID().uuidString)", isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("preferences.json")
        let store = JSONLibraryPreferencesStore(fileURL: fileURL)
        let preferences = LibraryPreferences(
            selectedRoles: [.frontend, .qa],
            selectedCategories: [.git, .linux, .kubernetes],
            selectedSubcategories: [.gitChanges, .linuxNetwork, .kubectl]
        )

        XCTAssertNil(try store.load())
        try store.save(preferences)
        XCTAssertEqual(try store.load(), preferences)
    }

    func testLegacyPreferencesDecodeAndAddOnlyNewCategoriesForSelectedRoles() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandWidgetPreferencesTests-\(UUID().uuidString)", isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("preferences.json")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let legacyJSON = Data("""
        {
          "selectedRoles": ["Frontend"],
          "selectedCategories": ["Git"]
        }
        """.utf8)
        try legacyJSON.write(to: fileURL)
        let store = JSONLibraryPreferencesStore(fileURL: fileURL)

        let legacy = try XCTUnwrap(store.load())
        XCTAssertNil(legacy.bundledCatalogVersion)

        let migrated = legacy.migrated(to: StarterCatalog.currentVersion)
        XCTAssertEqual(migrated.bundledCatalogVersion, 5)
        XCTAssertTrue(migrated.selectedCategories.contains(.git))
        XCTAssertTrue(migrated.selectedCategories.isSuperset(of: [
            .nodeJS, .typescript, .frontendTooling, .frontendTesting
        ]))
        XCTAssertFalse(migrated.selectedCategories.contains(.python))
    }

    func testMalformedPreferencesAreNotOverwritten() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("CommandWidgetPreferencesTests-\(UUID().uuidString)", isDirectory: true)
        let fileURL = directoryURL.appendingPathComponent("preferences.json")
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        let malformed = Data("{not-json".utf8)
        try malformed.write(to: fileURL)
        let store = JSONLibraryPreferencesStore(fileURL: fileURL)

        XCTAssertThrowsError(try store.load())
        XCTAssertEqual(try Data(contentsOf: fileURL), malformed)
    }
}
