import Foundation

protocol LidAngleSource: AnyObject {
    static var isAvailable: Bool { get }
    var onAngleChange: ((Double) -> Void)? { get set }
    func start()
    func stop()
}

enum LidAngleRange {
    static let closed: Double = 0
    static let fullyOpen: Double = 135
}
