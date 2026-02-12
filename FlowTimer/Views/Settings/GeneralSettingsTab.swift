import SwiftUI
import ServiceManagement

/// General settings: launch at login, language, menu bar display level.
struct GeneralSettingsTab: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        Form {
            Section {
                Toggle(
                    NSLocalizedString("settings.launchAtLogin", comment: "Launch at Login"),
                    isOn: $appSettings.launchAtLogin
                )
                .onChange(of: appSettings.launchAtLogin) { _, newValue in
                    setLaunchAtLogin(newValue)
                }
            } header: {
                Text(NSLocalizedString("settings.startup", comment: "Startup"))
            }

            Section {
                Picker(
                    NSLocalizedString("settings.menuBarDisplay", comment: "Menu Bar Display"),
                    selection: $appSettings.menuBarDisplayLevelRaw
                ) {
                    ForEach(AppSettings.MenuBarDisplayLevel.allCases, id: \.rawValue) { level in
                        Text(level.localizedName).tag(level.rawValue)
                    }
                }
                .pickerStyle(.segmented)

                VStack(alignment: .leading, spacing: 4) {
                    switch appSettings.menuBarDisplayLevel {
                    case .minimal:
                        Text(NSLocalizedString("settings.display.minimalDesc", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    case .standard:
                        Text(NSLocalizedString("settings.display.standardDesc", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    case .full:
                        Text(NSLocalizedString("settings.display.fullDesc", comment: ""))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.menuBar", comment: "Menu Bar"))
            }

            Section {
                Button(NSLocalizedString("settings.resetOnboarding", comment: "Show Onboarding Again")) {
                    appSettings.hasCompletedOnboarding = false
                }
                .foregroundStyle(.secondary)
            } header: {
                Text(NSLocalizedString("settings.other", comment: "Other"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                // Silently handle - user may need to grant permission
            }
        }
    }
}
