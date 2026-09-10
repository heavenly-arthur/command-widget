@MainActor
public protocol PanelPresenting: AnyObject {
    var isVisible: Bool { get }

    func show()
    func hide()
}

@MainActor
public final class PanelCoordinator {
    private let presenter: any PanelPresenting

    public init(presenter: any PanelPresenting) {
        self.presenter = presenter
    }

    public var isVisible: Bool {
        presenter.isVisible
    }

    public func toggle() {
        if presenter.isVisible {
            presenter.hide()
        } else {
            presenter.show()
        }
    }
}
