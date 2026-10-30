import Observation

@Observable
final class LidAngleState {
    let sensorIsAvailable = SensorLidAngleSource.isAvailable

    private(set) var angle: Double = LidAngleRange.fullyOpen

    var isFollowingLid = false {
        didSet {
            guard oldValue != isFollowingLid else { return }
            activateSelectedSource()
        }
    }

    @ObservationIgnored private let simulatedSource = SimulatedLidAngleSource()
    @ObservationIgnored private lazy var hidSource = SensorLidAngleSource()
    @ObservationIgnored private var activeSource: (any LidAngleSource)?

    init() {
        simulatedSource.onAngleChange = { [weak self] angle in self?.angle = angle }
        hidSource.onAngleChange = { [weak self] angle in self?.angle = angle }
    }

    func start() {
        activateSelectedSource()
    }

    func stop() {
        activeSource?.stop()
        activeSource = nil
    }

    func setManualAngle(_ angle: Double) {
        simulatedSource.setAngle(angle)
    }

    private func activateSelectedSource() {
        activeSource?.stop()
        let selected: any LidAngleSource = (isFollowingLid && sensorIsAvailable) ? hidSource : simulatedSource
        selected.start()
        activeSource = selected
    }
}
