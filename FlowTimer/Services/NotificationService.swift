import Foundation
import UserNotifications
import Combine

/// Manages macOS notifications for timer completion events.
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    private let pomodoroManager: PomodoroManager
    private let appSettings: AppSettings
    private let soundService = SoundService()
    private let hapticService = HapticService()
    private var cancellables = Set<AnyCancellable>()

    init(pomodoroManager: PomodoroManager, appSettings: AppSettings) {
        self.pomodoroManager = pomodoroManager
        self.appSettings = appSettings
        super.init()

        UNUserNotificationCenter.current().delegate = self
        observeTimerCompletion()
    }

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }

    private func observeTimerCompletion() {
        // Observe when timer completes (state goes from running to idle)
        var wasRunning = false

        pomodoroManager.timerEngine.$state
            .receive(on: RunLoop.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                if wasRunning && state == .idle {
                    self.handleTimerComplete()
                }
                wasRunning = (state == .running)
            }
            .store(in: &cancellables)
    }

    private func handleTimerComplete() {
        // Banner notification
        if appSettings.bannerNotificationEnabled {
            sendBannerNotification()
        }

        // Sound
        if appSettings.soundEnabled {
            soundService.playCompletionSound(
                sound: appSettings.notificationSound,
                volume: Float(appSettings.soundVolume)
            )
        }

        // Haptics
        if appSettings.hapticEnabled {
            hapticService.playCompletion()
        }
    }

    private func sendBannerNotification() {
        let content = UNMutableNotificationContent()

        // At the moment this fires, the session type reflects what just completed
        // (before PomodoroManager advances to the next session).
        let focusJustCompleted = (pomodoroManager.currentSession == .focus)

        if focusJustCompleted {
            content.title = NSLocalizedString("notification.focusComplete.title", comment: "Session Complete!")
            let sessions = pomodoroManager.completedSessionsInCycle
            let total = pomodoroManager.sessionsPerCycle
            content.body = String(
                format: NSLocalizedString("notification.focusComplete.body", comment: ""),
                sessions, total
            )
        } else {
            content.title = NSLocalizedString("notification.breakComplete.title", comment: "Break's Over!")
            content.body = NSLocalizedString("notification.breakComplete.body", comment: "Time to focus. Let's get back to work.")
        }

        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - UNUserNotificationCenterDelegate

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
