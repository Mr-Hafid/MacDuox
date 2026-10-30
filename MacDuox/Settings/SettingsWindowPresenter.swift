import AppKit
import SwiftUI

final class SettingsWindowPresenter {
    static let shared = SettingsWindowPresenter()

    let settings = SettingsStore()
    let lidAngleState = LidAngleState()

    private var window: NSWindow?

    func show() {
        NSApp.activate(ignoringOtherApps: true)

        if let window {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let hostingController = NSHostingController(
            rootView: SettingsWindowView(settings: settings, lidAngleState: lidAngleState)
        )

        let window = NSWindow(contentViewController: hostingController)
        window.title = "MacDuox Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 880, height: 660))
        window.isReleasedWhenClosed = false
        window.center()
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
}
