import XCTest
@testable import CommandWidgetCore

final class CommandSearchTests: XCTestCase {
    private let entries = StarterCatalog.entries

    func testEmptyAndWhitespaceQueryReturnsAllEntries() {
        XCTAssertEqual(CommandSearch.filter(entries, query: ""), entries)
        XCTAssertEqual(CommandSearch.filter(entries, query: "  \n"), entries)
    }

    func testSearchesTitleCommandCategoryTagsAndDetailsCaseInsensitively() {
        XCTAssertEqual(CommandSearch.filter(entries, query: "ПОДЫ").map(\.category), [.kubernetes])
        XCTAssertTrue(CommandSearch.filter(entries, query: "--WITH-SOURCE").contains { $0.category == .flux })
        XCTAssertTrue(CommandSearch.filter(entries, query: "terraform").allSatisfy { $0.category == .terraform })
        XCTAssertTrue(CommandSearch.filter(entries, query: "dry-run").contains { $0.category == .ansible })
        XCTAssertTrue(CommandSearch.filter(entries, query: "канонический").contains { $0.category == .terraform })
    }

    func testUnknownQueryReturnsNoEntries() {
        XCTAssertTrue(CommandSearch.filter(entries, query: "нет-такой-команды-123").isEmpty)
    }
}
