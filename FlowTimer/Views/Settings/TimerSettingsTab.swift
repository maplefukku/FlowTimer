import SwiftUI

/// Timer duration and cycle settings.
struct TimerSettingsTab: View {
    @EnvironmentObject var appSettings: AppSettings

    var body: some View {
        Form {
            Section {
                durationPicker(
                    label: NSLocalizedString("settings.focusDuration", comment: "Focus Duration"),
                    value: $appSettings.focusDuration,
                    range: 1...120,
                    unit: NSLocalizedString("settings.minutes", comment: "min")
                )

                durationPicker(
                    label: NSLocalizedString("settings.shortBreakDuration", comment: "Short Break"),
                    value: $appSettings.shortBreakDuration,
                    range: 1...30,
                    unit: NSLocalizedString("settings.minutes", comment: "min")
                )

                durationPicker(
                    label: NSLocalizedString("settings.longBreakDuration", comment: "Long Break"),
                    value: $appSettings.longBreakDuration,
                    range: 5...60,
                    unit: NSLocalizedString("settings.minutes", comment: "min")
                )
            } header: {
                Text(NSLocalizedString("settings.durations", comment: "Durations"))
            }

            Section {
                Stepper(
                    value: $appSettings.sessionsPerCycle,
                    in: 2...8
                ) {
                    HStack {
                        Text(NSLocalizedString("settings.sessionsPerCycle", comment: "Sessions per Cycle"))
                        Spacer()
                        Text("\(appSettings.sessionsPerCycle)")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text(NSLocalizedString("settings.cycle", comment: "Cycle"))
            }

            Section {
                Toggle(
                    NSLocalizedString("settings.autoStartBreaks", comment: "Auto-start Breaks"),
                    isOn: $appSettings.autoStartBreaks
                )

                Toggle(
                    NSLocalizedString("settings.autoStartFocus", comment: "Auto-start Focus"),
                    isOn: $appSettings.autoStartFocus
                )
            } header: {
                Text(NSLocalizedString("settings.automation", comment: "Automation"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func durationPicker(
        label: String,
        value: Binding<Int>,
        range: ClosedRange<Int>,
        unit: String
    ) -> some View {
        HStack {
            Text(label)
            Spacer()
            Stepper(
                "\(value.wrappedValue) \(unit)",
                value: value,
                in: range
            )
            .frame(width: 140)
        }
    }
}
