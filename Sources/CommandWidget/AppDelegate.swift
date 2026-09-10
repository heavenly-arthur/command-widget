import AppKit
import CommandWidgetCore
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelPresenter: FloatingPanelPresenter?
    private var panelCoordinator: PanelCoordinator?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)

        let presenter = FloatingPanelPresenter()
        panelPresenter = presenter
        panelCoordinator = PanelCoordinator(presenter: presenter)
        presenter.show()
    }

    func togglePanel() {
        panelCoordinator?.toggle()
    }
}

@MainActor
private final class FloatingPanelPresenter: PanelPresenting {
    private let panel: FloatingPanel

    var isVisible: Bool {
        panel.isVisible
    }

    init() {
        let applicationSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first ?? FileManager.default.temporaryDirectory
        let store = JSONCommandStore(
            fileURL: applicationSupport
                .appendingPathComponent("CommandWidget", isDirectory: true)
                .appendingPathComponent("commands.json")
        )
        let viewModel = CommandLibraryViewModel(store: store)

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
            styleMask: [.titled, .closable, .resizable, .utilityWindow, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.title = "Command Widget"
        panel.level = .floating
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.minSize = NSSize(width: 600, height: 420)
        panel.contentViewController = NSHostingController(
            rootView: CommandLibraryView(viewModel: viewModel)
        )
        panel.center()
    }

    func show() {
        panel.makeKeyAndOrderFront(nil)
    }

    func hide() {
        panel.orderOut(nil)
    }
}

private final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}
