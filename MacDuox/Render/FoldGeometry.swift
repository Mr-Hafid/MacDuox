import Foundation

struct FoldGeometry {
    static let maximumFoldAngleDegrees: Double = 70
    static let panelHalfHeight: Double = 0.5

    static func foldProgress(lidAngle: Double, clearAngle: Double) -> Double {
        let span = clearAngle - LidAngleRange.closed
        guard span > 0 else { return 0 }
        return min(max((clearAngle - lidAngle) / span, 0), 1)
    }

    static func foldAngleRadians(lidAngle: Double, clearAngle: Double) -> Double {
        foldProgress(lidAngle: lidAngle, clearAngle: clearAngle)
            * maximumFoldAngleDegrees * .pi / 180
    }

    let foldAngleRadians: Double
    let perspective: Double

    func sourceDistance(screenDistance: Double) -> Double? {
        let denominator = cos(foldAngleRadians)
            - screenDistance * perspective * sin(foldAngleRadians)
        guard denominator > 0.0001 else { return nil }
        let distance = screenDistance / denominator
        guard distance <= Self.panelHalfHeight else { return nil }
        return distance
    }

    func perspectiveScale(sourceDistance: Double) -> Double {
        1 / (1 + perspective * sourceDistance * sin(foldAngleRadians))
    }
}
