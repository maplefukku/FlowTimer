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
    private(set) var settingsWindowController: SettingsWindowController?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController(
            pomodoroManager: pomodoroManager,
            appSettings: appSettings,
            presetManager: presetManager,
            sessionStore: sessionStore
        )

        settingsWindowController = SettingsWindowController(
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

    @objc func showSettings() {
        settingsWindowController?.showSettings()
    }

    func applicationWillTerminate(_ notification: Notification) {
        hotKeyService?.unregisterHotKeys()
        sessionStore.save()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

/// Manages the settings window for the menu bar app.
final class SettingsWindowController {
    private var settingsWindow: NSWindow?

    private let pomodoroManager: PomodoroManager
    private let appSettings: AppSettings
    private let presetManager: PresetManager
    private let sessionStore: SessionStore

    init(
        pomodoroManager: PomodoroManager,
        appSettings: AppSettings,
        presetManager: PresetManager,
        sessionStore: SessionStore
    ) {
        self.pomodoroManager = pomodoroManager
        self.appSettings = appSettings
        self.presetManager = presetManager
        self.sessionStore = sessionStore
    }

    func showSettings() {
        if let window = settingsWindow {
            // Window already exists, just show it
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        } else {
            // Create new settings window
            let settingsView = SettingsView()
                .environmentObject(pomodoroManager)
                .environmentObject(appSettings)
                .environmentObject(presetManager)
                .environmentObject(sessionStore)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 360),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )

            window.title = "Settings"
            window.center()
            window.contentView = NSHostingView(rootView: settingsView)
            window.isReleasedWhenClosed = false
            window.level = .normal

            settingsWindow = window

            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
