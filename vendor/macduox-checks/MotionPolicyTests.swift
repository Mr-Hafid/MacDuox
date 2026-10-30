import Foundation
import MacDuoxCore

enum MotionPolicyTests {
    static func run() {
        // Absolute threshold, including the exact limit and raw-angle cutoff.
        precondition(AngleActivation.allows(angle: 90, limit: 90, enabled: true))
        precondition(AngleActivation.allows(angle: 45, limit: 90, enabled: true))
        precondition(!AngleActivation.allows(angle: 90.01, limit: 90, enabled: true))
        precondition(AngleActivation.allows(angle: 120, limit: 90, enabled: false))
        precondition(!AngleActivation.allows(angle: .nan, limit: 90, enabled: false))
        var filter = LidMotionFilter()
        filter.reset(to: 110)
        for value in [109.0, 111, 108, 112, 109, 111] {
            XCTAssertEqual(filter.update(value, tolerance: 2), 110)
        }
        // Accumulated slow movement is accepted, not permanently swallowed.
        XCTAssertEqual(filter.update(107, tolerance: 2), 107)
        XCTAssertEqual(filter.update(106, tolerance: 1), 107)
        XCTAssertEqual(filter.update(105, tolerance: 1), 105)
        XCTAssertEqual(filter.update(104.5, tolerance: 0), 104.5)
        // Repeated jitter below the absolute boundary remains visually aligned.
        filter.reset(to: 90)
        for value in [90.0, 89, 90, 88, 89] {
            XCTAssertEqual(filter.update(value, tolerance: 2), 90)
        }
        XCTAssertEqual(filter.update(87, tolerance: 2), 87)
        // A stale filtered value cannot bypass the raw >90° cut-off.
        precondition(!AngleActivation.allows(angle: 91, limit: 90, enabled: true))

        var safety = DisplaySafetyGate()
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 0))
        precondition(safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 0.51))
        precondition(!safety.update(lidClosed: true, builtInAvailable: true, sensorAvailable: true, now: 1))
        precondition(safety.state == .closed) // Closed overrides all other inputs.
        precondition(!safety.update(lidClosed: false, builtInAvailable: false, sensorAvailable: true, now: 2))
        precondition(safety.state == .noDisplay) // External-only is never a fallback.
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: false, now: 3))
        precondition(safety.state == .noSensor)
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 4))
        precondition(!safety.update(lidClosed: false, builtInAvailable: false, sensorAvailable: true, now: 4.3))
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 4.4))
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 4.8))
        precondition(safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 4.91))
        safety.reset()
        precondition(!safety.update(lidClosed: false, builtInAvailable: true, sensorAvailable: true, now: 5))
        print("PASS: absolute activation, 0–2° jitter, slow movement, lid-close, external-only, sensor loss and stable recovery")
    }
}
