import SwiftUI

/// Appearance settings: accent color customization.
struct AppearanceSettingsTab: View {
    @EnvironmentObject var appSettings: AppSettings

    private let colorOptions: [(String, String)] = [
        ("#FF6B6B", "Red"),
        ("#FF8A65", "Orange"),
        ("#FFD54F", "Yellow"),
        ("#81C784", "Green"),
        ("#64B5F6", "Blue"),
        ("#CE93D8", "Purple"),
        ("#F48FB1", "Pink"),
        ("#4DD0E1", "Teal"),
    ]

    var body: some View {
        Form {
            Section {
                Toggle(
                    NSLocalizedString("settings.useSystemAccent", comment: "Use System Accent Color"),
                    isOn: $appSettings.useSystemAccentColor
                )

                if !appSettings.useSystemAccentColor {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(NSLocalizedString("settings.customColor", comment: "Custom Accent Color"))
                            .font(.callout)

                        HStack(spacing: 8) {
                            ForEach(colorOptions, id: \.0) { hex, name in
                                colorSwatch(hex: hex, name: name)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } header: {
                Text(NSLocalizedString("settings.accentColor", comment: "Accent Color"))
            }

            Section {
                previewCard
            } header: {
                Text(NSLocalizedString("settings.preview", comment: "Preview"))
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func colorSwatch(hex: String, name: String) -> some View {
        Button(action: {
            appSettings.customAccentColorHex = hex
        }) {
            Circle()
                .fill(Color(hex: hex) ?? .accentColor)
                .frame(width: 24, height: 24)
                .overlay(
                    Circle()
                        .strokeBorder(
                            appSettings.customAccentColorHex == hex
                                ? Color.primary
                                : Color.clear,
                            lineWidth: 2
                        )
                )
        }
        .buttonStyle(.plain)
        .help(name)
    }

    private var previewCard: some View {
        HStack {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    appSettings.accentColor,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 2) {
                Text("17:30")
                    .font(.system(size: 18, weight: .light, design: .monospaced))
                Text(NSLocalizedString("session.focus", comment: "Focus"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(i < 2 ? appSettings.accentColor : Color.primary.opacity(0.15))
                        .frame(width: 6, height: 6)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.primary.opacity(0.03))
        )
    }
}
