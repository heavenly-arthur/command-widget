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
        let dataDirectory = applicationSupport
            .appendingPathComponent("CommandWidget", isDirectory: true)
        let store = JSONCommandStore(
            fileURL: dataDirectory.appendingPathComponent("commands.json")
        )
        let preferencesStore = JSONLibraryPreferencesStore(
            fileURL: dataDirectory.appendingPathComponent("preferences.json")
        )
        let customTaxonomyStore = JSONCustomTaxonomyStore(
            fileURL: dataDirectory.appendingPathComponent("custom-taxonomy.json")
        )
        let viewModel = CommandLibraryViewModel(
            store: store,
            preferencesStore: preferencesStore,
            customTaxonomyStore: customTaxonomyStore
        )

        panel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
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
        panel.minSize = NSSize(width: 700, height: 560)
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
