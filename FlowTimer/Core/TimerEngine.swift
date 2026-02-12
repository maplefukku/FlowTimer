import Foundation
import Combine

/// Low-level timer engine using DispatchSourceTimer for precision.
/// Fires every second and publishes remaining time.
final class TimerEngine: ObservableObject {
    enum State: Equatable {
        case idle
        case running
        case paused
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var remainingSeconds: Int = 0
    @Published private(set) var totalSeconds: Int = 0
    @Published private(set) var progress: Double = 0.0

    var onComplete: (() -> Void)?

    private var timer: DispatchSourceTimer?
    private var endDate: Date?
    private var pausedRemaining: TimeInterval = 0
    private let queue = DispatchQueue(label: "com.flowtimer.timer", qos: .userInteractive)

    var formattedTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func configure(seconds: Int) {
        stop()
        totalSeconds = seconds
        remainingSeconds = seconds
        progress = 0.0
    }

    func start() {
        guard state != .running else { return }

        if state == .paused {
            endDate = Date().addingTimeInterval(pausedRemaining)
        } else {
            endDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        }

        state = .running
        startDispatchTimer()
    }

    func pause() {
        guard state == .running else { return }
        pausedRemaining = endDate?.timeIntervalSince(Date()) ?? 0
        cancelDispatchTimer()
        state = .paused
    }

    func stop() {
        cancelDispatchTimer()
        state = .idle
        endDate = nil
        pausedRemaining = 0
    }

    func reset(seconds: Int) {
        stop()
        totalSeconds = seconds
        remainingSeconds = seconds
        progress = 0.0
    }

    // MARK: - Private

    private func startDispatchTimer() {
        cancelDispatchTimer()

        let source = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
        source.schedule(deadline: .now(), repeating: .milliseconds(250), leeway: .milliseconds(50))
        source.setEventHandler { [weak self] in
            self?.tick()
        }
        source.resume()
        timer = source
    }

    private func cancelDispatchTimer() {
        timer?.cancel()
        timer = nil
    }

    private func tick() {
        guard let endDate = endDate else { return }

        let remaining = endDate.timeIntervalSince(Date())

        if remaining <= 0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.remainingSeconds = 0
                self.progress = 1.0
                self.cancelDispatchTimer()
                self.state = .idle
                self.endDate = nil
                self.onComplete?()
            }
        } else {
            let newRemaining = Int(ceil(remaining))
            let newProgress = totalSeconds > 0
                ? 1.0 - (remaining / TimeInterval(totalSeconds))
                : 0.0

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.remainingSeconds != newRemaining {
                    self.remainingSeconds = newRemaining
                }
                self.progress = min(max(newProgress, 0), 1)
            }
        }
    }

    deinit {
        cancelDispatchTimer()
    }
}
