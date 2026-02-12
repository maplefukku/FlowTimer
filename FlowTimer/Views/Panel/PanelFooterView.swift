import SwiftUI

/// Footer with preset selector and settings gear.
struct PanelFooterView: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager
    @EnvironmentObject var presetManager: PresetManager
    @Binding var showingStatistics: Bool

    var body: some View {
        HStack(spacing: 8) {
            // Preset chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(presetManager.presets) { preset in
                        presetChip(preset)
                    }
                }
                .padding(.vertical, 2)
            }
            .frame(height: 30)

            Spacer(minLength: 8)

            // Statistics button
            Button(action: { showingStatistics.toggle() }) {
                Image(systemName: "chart.bar")
                    .font(.system(size: 12))
            }
            .buttonStyle(GlassIconButtonStyle(size: 26))
            .help(NSLocalizedString("footer.statistics", comment: "Statistics"))

            // Settings button
            Button(action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12))
            }
            .buttonStyle(GlassIconButtonStyle(size: 26))
            .help(NSLocalizedString("footer.settings", comment: "Settings"))
        }
        .frame(height: 34)
    }

    private func presetChip(_ preset: Preset) -> some View {
        Button(action: {
            presetManager.selectPreset(preset)
            pomodoroManager.applyPreset(preset)
        }) {
            HStack(spacing: 3) {
                Image(systemName: preset.icon)
                    .font(.system(size: 8))
                    .fixedSize()
                Text(preset.name)
                    .font(.system(size: 9, weight: .medium))
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        presetManager.activePresetId == preset.id
                            ? Color.accentColor.opacity(0.15)
                            : Color.primary.opacity(0.04)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .strokeBorder(
                        presetManager.activePresetId == preset.id
                            ? Color.accentColor.opacity(0.3)
                            : Color.clear,
                        lineWidth: 0.5
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private func openSettings() {
        // Open the Settings window via AppDelegate
        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.showSettings()
        }
    }
}
