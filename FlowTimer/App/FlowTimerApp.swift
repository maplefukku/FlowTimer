import SwiftUI

@main
struct FlowTimerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            SettingsView()
                .environmentObject(appDelegate.pomodoroManager)
                .environmentObject(appDelegate.appSettings)
                .environmentObject(appDelegate.presetManager)
                .environmentObject(appDelegate.sessionStore)
        }
    }
}
