import XCTest
@testable import CommandWidgetCore

@MainActor
final class PanelCoordinatorTests: XCTestCase {
    func testToggleShowsHiddenPanel() {
        let presenter = PanelPresenterSpy(isVisible: false)
        let coordinator = PanelCoordinator(presenter: presenter)

        coordinator.toggle()

        XCTAssertEqual(presenter.showCallCount, 1)
        XCTAssertEqual(presenter.hideCallCount, 0)
        XCTAssertTrue(coordinator.isVisible)
    }

    func testToggleHidesVisiblePanel() {
        let presenter = PanelPresenterSpy(isVisible: true)
        let coordinator = PanelCoordinator(presenter: presenter)

        coordinator.toggle()

        XCTAssertEqual(presenter.showCallCount, 0)
        XCTAssertEqual(presenter.hideCallCount, 1)
        XCTAssertFalse(coordinator.isVisible)
    }
}

@MainActor
private final class PanelPresenterSpy: PanelPresenting {
    private(set) var isVisible: Bool
    private(set) var showCallCount = 0
    private(set) var hideCallCount = 0

    init(isVisible: Bool) {
        self.isVisible = isVisible
    }

    func show() {
        showCallCount += 1
        isVisible = true
    }

    func hide() {
        hideCallCount += 1
        isVisible = false
    }
}
