import Foundation
import Observation

@Observable
final class SettingsStore {
    private enum Key {
        static let style = "style"
        static let perspective = "perspective"
        static let variableBlur = "variableBlur"
        static let shadow = "shadow"
        static let clearAngle = "clearAngle"
        static let manualAngle = "manualAngle"
        static let followsLid = "followsLid"
        static let playsOpenSound = "playsOpenSound"
        static let launchesAtLogin = "launchesAtLogin"
    }

    @ObservationIgnored private let defaults: UserDefaults

    var style: StylePreset {
        didSet {
            defaults.set(style.rawValue, forKey: Key.style)
            applyPreset(style)
        }
    }

    var perspective: Double { didSet { defaults.set(perspective, forKey: Key.perspective) } }
    var variableBlur: Double { didSet { defaults.set(variableBlur, forKey: Key.variableBlur) } }
    var shadow: Double { didSet { defaults.set(shadow, forKey: Key.shadow) } }
    var clearAngle: Double { didSet { defaults.set(clearAngle, forKey: Key.clearAngle) } }
    var manualAngle: Double { didSet { defaults.set(manualAngle, forKey: Key.manualAngle) } }
    var followsLid: Bool { didSet { defaults.set(followsLid, forKey: Key.followsLid) } }
    var playsOpenSound: Bool { didSet { defaults.set(playsOpenSound, forKey: Key.playsOpenSound) } }
    var launchesAtLogin: Bool { didSet { defaults.set(launchesAtLogin, forKey: Key.launchesAtLogin) } }

    var isPaused = false

    var foldParameters: FoldParameters {
        FoldParameters(perspective: perspective,
                       variableBlur: variableBlur,
                       shadow: shadow,
                       tint: style.parameters.tint)
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedStyle = (defaults.string(forKey: Key.style).flatMap(StylePreset.init(rawValue:))) ?? .silk
        let fallback = storedStyle.parameters

        style = storedStyle
        perspective = defaults.object(forKey: Key.perspective) as? Double ?? fallback.perspective
        variableBlur = defaults.object(forKey: Key.variableBlur) as? Double ?? fallback.variableBlur
        shadow = defaults.object(forKey: Key.shadow) as? Double ?? fallback.shadow
        clearAngle = defaults.object(forKey: Key.clearAngle) as? Double ?? 90
        manualAngle = defaults.object(forKey: Key.manualAngle) as? Double ?? LidAngleRange.fullyOpen
        followsLid = defaults.object(forKey: Key.followsLid) as? Bool ?? false
        playsOpenSound = defaults.object(forKey: Key.playsOpenSound) as? Bool ?? true
        launchesAtLogin = defaults.object(forKey: Key.launchesAtLogin) as? Bool ?? false
    }

    private func applyPreset(_ preset: StylePreset) {
        let parameters = preset.parameters
        perspective = parameters.perspective
        variableBlur = parameters.variableBlur
        shadow = parameters.shadow
    }
}
