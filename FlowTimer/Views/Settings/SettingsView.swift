import SwiftUI

/// Main settings window with tabbed layout.
struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem {
                    Label(
                        NSLocalizedString("settings.general", comment: "General"),
                        systemImage: "gearshape"
                    )
                }

            TimerSettingsTab()
                .tabItem {
                    Label(
                        NSLocalizedString("settings.timer", comment: "Timer"),
                        systemImage: "timer"
                    )
                }

            AppearanceSettingsTab()
                .tabItem {
                    Label(
                        NSLocalizedString("settings.appearance", comment: "Appearance"),
                        systemImage: "paintbrush"
                    )
                }

            NotificationSettingsTab()
                .tabItem {
                    Label(
                        NSLocalizedString("settings.notifications", comment: "Notifications"),
                        systemImage: "bell"
                    )
                }

            ShortcutSettingsTab()
                .tabItem {
                    Label(
                        NSLocalizedString("settings.shortcuts", comment: "Shortcuts"),
                        systemImage: "keyboard"
                    )
                }
        }
        .frame(width: 480, height: 360)
    }
}
