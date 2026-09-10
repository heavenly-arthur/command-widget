import AppKit
import SwiftUI

@main
struct CommandWidgetApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Command Widget", systemImage: "terminal") {
            Button("Показать / скрыть") {
                appDelegate.togglePanel()
            }

            Divider()

            Button("Завершить Command Widget") {
                NSApplication.shared.terminate(nil)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
