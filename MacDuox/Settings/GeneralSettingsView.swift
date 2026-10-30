import SwiftUI
import ServiceManagement

struct GeneralSettingsView: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SettingsPaneHeader(title: "General",
                                   systemImage: "gearshape.fill",
                                   tint: .gray)

                VStack(alignment: .leading, spacing: 14) {
                    Toggle("Launch at login", isOn: $settings.launchesAtLogin)
                        .onChange(of: settings.launchesAtLogin) { _, newValue in
                            updateLaunchAtLogin(newValue)
                        }

                    Toggle("Play a click when the lid opens", isOn: $settings.playsOpenSound)

                    Text("Press Escape to pause or resume. This needs Accessibility permission; without it the menu bar item stays the working control.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(18)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
        }
    }

    private func updateLaunchAtLogin(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            settings.launchesAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}
