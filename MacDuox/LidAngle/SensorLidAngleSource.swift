import Foundation

final class SensorLidAngleSource: LidAngleSource {
    static var isAvailable: Bool {
        LidSensor().read() != nil
    }

    var onAngleChange: ((Double) -> Void)?

    private let sensor = LidSensor()
    private var timer: Timer?

    var diagnostic: String { sensor.diagnostic }

    func start() {
        guard timer == nil else { return }
        let timer = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self, let angle = self.sensor.read() else { return }
            self.onAngleChange?(angle)
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
