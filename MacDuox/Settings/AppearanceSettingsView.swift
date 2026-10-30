import SwiftUI

struct AppearanceSettingsView: View {
    @Bindable var settings: SettingsStore
    let lidAngleState: LidAngleState

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                SettingsPaneHeader(title: "Appearance",
                                   systemImage: "circle.lefthalf.filled",
                                   tint: .blue)

                if !ScreenRecordingPermission.isGranted {
                    ScreenRecordingWarning()
                }

                MacBookMockup {
                    FoldPreviewView(parameters: settings.foldParameters,
                                    lidAngle: previewAngle,
                                    clearAngle: settings.clearAngle)
                }

                angleRow
                stylePicker
                parameterCard
            }
            .padding(24)
        }
    }

    private var previewAngle: Double {
        settings.followsLid && lidAngleState.sensorIsAvailable ? lidAngleState.angle : settings.manualAngle
    }

    private var angleRow: some View {
        HStack(spacing: 14) {
            Text("\(Int(settings.manualAngle))°")
                .monospacedDigit()
                .frame(width: 48, alignment: .leading)

            Slider(value: $settings.manualAngle,
                   in: LidAngleRange.closed...LidAngleRange.fullyOpen) { _ in
                lidAngleState.setManualAngle(settings.manualAngle)
            }
            .disabled(settings.followsLid && lidAngleState.sensorIsAvailable)
            .onChange(of: settings.manualAngle) { _, newValue in
                lidAngleState.setManualAngle(newValue)
            }

            Text("Follow lid")
            Toggle("Follow lid", isOn: $settings.followsLid)
                .labelsHidden()
                .disabled(!lidAngleState.sensorIsAvailable)
                .onChange(of: settings.followsLid) { _, newValue in
                    lidAngleState.isFollowingLid = newValue
                }
        }
        .overlay(alignment: .bottomTrailing) {
            if !lidAngleState.sensorIsAvailable {
                Text("This Mac has no lid angle sensor.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .offset(y: 18)
            }
        }
        .padding(.bottom, lidAngleState.sensorIsAvailable ? 0 : 16)
    }

    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Style")
                .font(.title3.weight(.semibold))

            HStack(spacing: 14) {
                ForEach(StylePreset.allCases) { preset in
                    StyleThumbnail(preset: preset,
                                   isSelected: settings.style == preset,
                                   lidAngle: previewAngle,
                                   clearAngle: settings.clearAngle)
                    .onTapGesture { settings.style = preset }
                }
            }
        }
    }

    private var parameterCard: some View {
        VStack(spacing: 16) {
            ParameterSlider(title: "Perspective", value: $settings.perspective)
            ParameterSlider(title: "Variable blur", value: $settings.variableBlur)
            ParameterSlider(title: "Shadow", value: $settings.shadow)

            HStack {
                Text("Clears above")
                Slider(value: $settings.clearAngle,
                       in: 30...LidAngleRange.fullyOpen)
                Text("\(Int(settings.clearAngle))°")
                    .monospacedDigit()
                    .frame(width: 52, alignment: .trailing)
            }
        }
        .padding(18)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 12))
    }
}

private struct ParameterSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        HStack {
            Text(title)
                .frame(width: 130, alignment: .leading)
            Slider(value: $value, in: 0...1)
            Text("\(Int(value * 100))%")
                .monospacedDigit()
                .frame(width: 52, alignment: .trailing)
        }
    }
}

private struct StyleThumbnail: View {
    let preset: StylePreset
    let isSelected: Bool
    let lidAngle: Double
    let clearAngle: Double

    var body: some View {
        VStack(spacing: 8) {
            FoldPreviewView(parameters: preset.parameters,
                            lidAngle: lidAngle,
                            clearAngle: clearAngle)
            .frame(width: 150, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? Color.accentColor : .clear, lineWidth: 3)
            }

            HStack(spacing: 5) {
                Text(preset.displayName)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
    }
}

private struct MacBookMockup<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
                .frame(height: 210)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(8)
                .background(.black, in: RoundedRectangle(cornerRadius: 12))
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(.black)
                        .frame(width: 120, height: 14)
                }

            RoundedRectangle(cornerRadius: 3)
                .fill(.secondary.opacity(0.55))
                .frame(height: 9)
                .padding(.horizontal, -26)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ScreenRecordingWarning: View {
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.orange)
            Text("Screen Recording permission is required before the effect can appear.")
            Spacer()
            Button("Open Settings") {
                ScreenRecordingPermission.openPrivacySettings()
            }
        }
        .padding(12)
        .background(.orange.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
    }
}

struct SettingsPaneHeader: View {
    let title: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(tint, in: RoundedRectangle(cornerRadius: 7))
            Text(title)
                .font(.title2.weight(.semibold))
        }
    }
}
