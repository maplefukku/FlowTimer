import Foundation
import Combine

/// Manages the Pomodoro cycle: Focus → Short Break → Focus → ... → Long Break → repeat.
final class PomodoroManager: ObservableObject {
    enum SessionType: String, Codable {
        case focus
        case shortBreak
        case longBreak

        var localizedName: String {
            switch self {
            case .focus: return NSLocalizedString("session.focus", comment: "Focus")
            case .shortBreak: return NSLocalizedString("session.shortBreak", comment: "Short Break")
            case .longBreak: return NSLocalizedString("session.longBreak", comment: "Long Break")
            }
        }
    }

    @Published private(set) var currentSession: SessionType = .focus
    @Published private(set) var completedSessionsInCycle: Int = 0
    @Published private(set) var totalCompletedSessions: Int = 0
    @Published private(set) var isTimerActive: Bool = false

    let timerEngine = TimerEngine()

    private let settings: AppSettings
    private let sessionStore: SessionStore
    private var cancellables = Set<AnyCancellable>()
    private var sessionStartDate: Date?

    var sessionsPerCycle: Int { settings.sessionsPerCycle }

    var cycleProgress: [Bool] {
        (0..<settings.sessionsPerCycle).map { $0 < completedSessionsInCycle }
    }

    var isOnBreak: Bool {
        currentSession == .shortBreak || currentSession == .longBreak
    }

    init(settings: AppSettings, sessionStore: SessionStore) {
        self.settings = settings
        self.sessionStore = sessionStore

        timerEngine.configure(seconds: settings.focusDuration * 60)

        timerEngine.onComplete = { [weak self] in
            self?.handleSessionComplete()
        }

        timerEngine.$state
            .map { $0 == .running }
            .assign(to: &$isTimerActive)

        settings.$focusDuration
            .dropFirst()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.timerEngine.state == .idle {
                    self.configureCurrentSession()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Controls

    func startOrPause() {
        switch timerEngine.state {
        case .idle:
            configureCurrentSession()
            sessionStartDate = Date()
            timerEngine.start()
        case .running:
            timerEngine.pause()
        case .paused:
            timerEngine.start()
        }
    }

    func stop() {
        timerEngine.stop()
        configureCurrentSession()
    }

    func reset() {
        timerEngine.stop()
        completedSessionsInCycle = 0
        currentSession = .focus
        configureCurrentSession()
    }

    func skipToNext() {
        timerEngine.stop()
        advanceToNextSession()
        configureCurrentSession()
    }

    func applyPreset(_ preset: Preset) {
        timerEngine.stop()
        settings.focusDuration = preset.focusMinutes
        settings.shortBreakDuration = preset.shortBreakMinutes
        settings.longBreakDuration = preset.longBreakMinutes
        completedSessionsInCycle = 0
        currentSession = .focus
        configureCurrentSession()
    }

    // MARK: - Private

    private func configureCurrentSession() {
        let minutes: Int
        switch currentSession {
        case .focus:
            minutes = settings.focusDuration
        case .shortBreak:
            minutes = settings.shortBreakDuration
        case .longBreak:
            minutes = settings.longBreakDuration
        }
        timerEngine.configure(seconds: minutes * 60)
    }

    private func handleSessionComplete() {
        if currentSession == .focus {
            completedSessionsInCycle += 1
            totalCompletedSessions += 1

            // Record session
            if let start = sessionStartDate {
                let session = TimerSession(
                    startDate: start,
                    endDate: Date(),
                    durationMinutes: settings.focusDuration,
                    type: .focus,
                    completed: true
                )
                sessionStore.addSession(session)
            }
        }

        advanceToNextSession()

        if settings.autoStartBreaks && isOnBreak {
            configureCurrentSession()
            sessionStartDate = Date()
            timerEngine.start()
        } else if settings.autoStartFocus && !isOnBreak {
            configureCurrentSession()
            sessionStartDate = Date()
            timerEngine.start()
        } else {
            configureCurrentSession()
        }
    }

    private func advanceToNextSession() {
        switch currentSession {
        case .focus:
            if completedSessionsInCycle >= settings.sessionsPerCycle {
                currentSession = .longBreak
                completedSessionsInCycle = 0
            } else {
                currentSession = .shortBreak
            }
        case .shortBreak, .longBreak:
            currentSession = .focus
        }
    }
}
