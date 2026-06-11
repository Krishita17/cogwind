import WatchKit
import Foundation

final class HapticEngine {
    static let shared = HapticEngine()
    private let device = WKInterfaceDevice.current()

    func notch() {
        device.play(.click)
    }

    func ringSnap() {
        device.play(.directionUp)
    }

    func solvedCelebration() {
        Task {
            device.play(.success)
            try? await Task.sleep(nanoseconds: 200_000_000)
            device.play(.success)
            try? await Task.sleep(nanoseconds: 200_000_000)
            device.play(.notification)
        }
    }

    func timeWarning() {
        device.play(.retry)
    }

    func failure() {
        device.play(.failure)
    }

    func selectionTick() {
        device.play(.click)
    }

    func levelUp() {
        Task {
            device.play(.directionUp)
            try? await Task.sleep(nanoseconds: 150_000_000)
            device.play(.directionUp)
            try? await Task.sleep(nanoseconds: 150_000_000)
            device.play(.success)
        }
    }

    func hintPulse() {
        device.play(.start)
    }

    func combo() {
        Task {
            device.play(.directionUp)
            try? await Task.sleep(nanoseconds: 100_000_000)
            device.play(.click)
        }
    }

    func undo() {
        device.play(.directionDown)
    }

    func proximityWarm() {
        device.play(.stop)
    }
}
