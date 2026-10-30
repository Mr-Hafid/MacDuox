import Foundation

final class SimulatedLidAngleSource: LidAngleSource {
    static var isAvailable: Bool { true }

    var onAngleChange: ((Double) -> Void)?

    private var isRunning = false
    private var currentAngle = LidAngleRange.fullyOpen

    func start() {
        isRunning = true
        onAngleChange?(currentAngle)
    }

    func stop() {
        isRunning = false
    }

    func setAngle(_ angle: Double) {
        currentAngle = min(max(angle, LidAngleRange.closed), LidAngleRange.fullyOpen)
        guard isRunning else { return }
        onAngleChange?(currentAngle)
    }
}
