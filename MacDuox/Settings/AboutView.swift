import SwiftUI

struct AboutView: View {
    private var version: String {
        let marketing = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(marketing) (\(build))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SettingsPaneHeader(title: "About",
                                   systemImage: "info.circle.fill",
                                   tint: .gray)

                VStack(alignment: .leading, spacing: 8) {
                    Text("MacDuox")
                        .font(.title.weight(.semibold))
                    Text("Version \(version)")
                        .foregroundStyle(.secondary)
                    Text("Folds the desktop as the lid closes, rendered live with Metal. Frames are processed on this Mac and never recorded, saved, or uploaded.")
                        .padding(.top, 6)

                    Text("Includes MacDuox, MIT licensed, copyright (c) 2026 Mr Hafid.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 10)
                }
                .padding(18)
                .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
            }
            .padding(24)
        }
    }
}
