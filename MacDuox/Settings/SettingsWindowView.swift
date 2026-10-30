import SwiftUI

enum SettingsPane: String, Hashable, CaseIterable, Identifiable {
    case general
    case appearance
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: return "General"
        case .appearance: return "Appearance"
        case .about: return "About"
        }
    }

    var systemImage: String {
        switch self {
        case .general: return "gearshape.fill"
        case .appearance: return "circle.lefthalf.filled"
        case .about: return "info.circle.fill"
        }
    }
}

struct SettingsWindowView: View {
    let settings: SettingsStore
    let lidAngleState: LidAngleState

    @State private var selection: SettingsPane = .appearance

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                NavigationLink(value: SettingsPane.general) {
                    Label(SettingsPane.general.title, systemImage: SettingsPane.general.systemImage)
                }

                Section("Settings") {
                    NavigationLink(value: SettingsPane.appearance) {
                        Label(SettingsPane.appearance.title, systemImage: SettingsPane.appearance.systemImage)
                    }
                }

                Section("MacDuox") {
                    NavigationLink(value: SettingsPane.about) {
                        Label(SettingsPane.about.title, systemImage: SettingsPane.about.systemImage)
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 190, ideal: 210, max: 250)
        } detail: {
            switch selection {
            case .general:
                GeneralSettingsView(settings: settings)
            case .appearance:
                AppearanceSettingsView(settings: settings, lidAngleState: lidAngleState)
            case .about:
                AboutView()
            }
        }
        .frame(minWidth: 820, minHeight: 620)
    }
}
