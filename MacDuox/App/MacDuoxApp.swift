import AppKit
import Observation

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let engine = MenuBarApp()

    func applicationDidFinishLaunching(_ notification: Notification) {
        engine.applicationDidFinishLaunching(notification)

        let presenter = SettingsWindowPresenter.shared
        presenter.lidAngleState.isFollowingLid =
            presenter.settings.followsLid && presenter.lidAngleState.sensorIsAvailable
        presenter.lidAngleState.start()
        presenter.lidAngleState.setManualAngle(presenter.settings.manualAngle)

        observeAppearance()
    }

    private func observeAppearance() {
        let settings = SettingsWindowPresenter.shared.settings
        withObservationTracking {
            engine.applyAppearance(perspective: settings.perspective,
                                   variableBlur: settings.variableBlur,
                                   shadow: settings.shadow)
        } onChange: {
            DispatchQueue.main.async { [weak self] in self?.observeAppearance() }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        SettingsWindowPresenter.shared.lidAngleState.stop()
        engine.applicationWillTerminate(notification)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

@main
enum MacDuoxMain {
    static func main() {
        let application = NSApplication.shared
        application.setActivationPolicy(.accessory)
        let delegate = AppDelegate()
        application.delegate = delegate
        application.run()
    }
}
