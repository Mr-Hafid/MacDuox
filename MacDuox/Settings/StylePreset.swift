import simd

enum StylePreset: String, CaseIterable, Identifiable {
    case silk
    case shade
    case frost

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .silk: return "Silk"
        case .shade: return "Shade"
        case .frost: return "Frost"
        }
    }

    var parameters: FoldParameters {
        switch self {
        case .silk:
            return FoldParameters(perspective: 1.00, variableBlur: 0.35, shadow: 0.30,
                                  tint: SIMD4(1.00, 1.00, 1.00, 0.00))
        case .shade:
            return FoldParameters(perspective: 0.70, variableBlur: 0.20, shadow: 0.85,
                                  tint: SIMD4(1.00, 0.94, 0.86, 0.35))
        case .frost:
            return FoldParameters(perspective: 0.85, variableBlur: 0.90, shadow: 0.35,
                                  tint: SIMD4(0.86, 0.92, 1.00, 0.45))
        }
    }
}
