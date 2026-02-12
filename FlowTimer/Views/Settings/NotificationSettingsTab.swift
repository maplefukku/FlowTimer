import SwiftUI

/// Notification preferences: sound, haptics, visual alerts.
struct NotificationSettingsTab: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        Form {
            Section {
                Toggle(
                    NSLocalizedString("settings.bannerNotification", comment: "Banner Notifications"),
                    isOn: $appSettings.bannerNotificationEnabled
                )

                Toggle(
                    NSLocalizedString("settings.visualPulse", comment: "Menu Bar Icon Pulse"),
                    isOn: $appSettings.visualNotificationEnabled
                )

                Toggle(
                    NSLocalizedString("settings.autoOpenPanel", comment: "Auto-open Panel on Complete"),
                    isOn: $appSettings.autoOpenPanelOnComplete
                )
            } header: {
                Text(NSLocalizedString("settings.visual", comment: "Visual"))
            }

            Section {
                Toggle(
                    NSLocalizedString("settings.soundEnabled", comment: "Sound"),
                    isOn: $appSettings.soundEnabled
                )

                if appSettings.soundEnabled {
                    Picker(
                        NSLocalizedString("settings.soundType", comment: "Sound"),
                        selection: $appSettings.notificationSoundRaw
                    ) {
                        ForEach(AppSettings.NotificationSound.allCases, id: \.rawValue) { sound in
                            Text(sound.displayName).tag(sound.rawValue)
                        }
                    }

                    HStack {
                        Text(NSLocalizedString("settings.volume", comment: "Volume"))
                        Slider(value: $appSettings.soundVolume, in: 0...1)
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.audio", comment: "Audio"))
            }

            Section {
                Toggle(
                    NSLocalizedString("settings.hapticEnabled", comment: "Haptic Feedback"),
                    isOn: $appSettings.hapticEnabled
                )

                if appSettings.hapticEnabled {
                    Text(NSLocalizedString("settings.hapticNote", comment: "Available on MacBooks with Taptic Engine"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(NSLocalizedString("settings.haptics", comment: "Haptics"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}
