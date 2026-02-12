import AppKit
import SwiftUI
import Combine

final class AppDelegate: NSObject, NSApplicationDelegate {
    let appSettings = AppSettings()
    let presetManager = PresetManager()
    let sessionStore = SessionStore()
    private(set) lazy var pomodoroManager = PomodoroManager(
        settings: appSettings,
        sessionStore: sessionStore
    )

    private var statusBarController: StatusBarController?
    private var hotKeyService: HotKeyService?
    private var notificationService: NotificationService?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(
            pomodoroManager: pomodoroManager,
            appSettings: appSettings,
            presetManager: presetManager,
            sessionStore: sessionStore
        )

        notificationService = NotificationService(
            pomodoroManager: pomodoroManager,
            appSettings: appSettings
        )
        notificationService?.requestPermission()

        hotKeyService = HotKeyService(
            pomodoroManager: pomodoroManager,
            statusBarController: statusBarController
        )
        hotKeyService?.registerHotKeys()

        if !appSettings.hasCompletedOnboarding {
            statusBarController?.showOnboarding()
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyService?.unregisterHotKeys()
        sessionStore.save()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
