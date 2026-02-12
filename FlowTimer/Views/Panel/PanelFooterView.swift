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
            }

            Spacer()

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
    }

    private func presetChip(_ preset: Preset) -> some View {
        Button(action: {
            presetManager.selectPreset(preset)
            pomodoroManager.applyPreset(preset)
        }) {
            HStack(spacing: 4) {
                Image(systemName: preset.icon)
                    .font(.system(size: 9))
                Text(preset.name)
                    .font(.system(size: 10, weight: .medium))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        presetManager.activePresetId == preset.id
                            ? Color.accentColor.opacity(0.15)
                            : Color.primary.opacity(0.04)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
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
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        // Fallback for older macOS
        if #unavailable(macOS 14) {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
