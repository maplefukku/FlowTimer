import SwiftUI

/// Keyboard shortcut reference and customization.
struct ShortcutSettingsTab: View {
    var body: some View {
        Form {
            Section {
                shortcutRow(
                    label: NSLocalizedString("shortcut.togglePanel", comment: "Toggle Panel"),
                    keys: "⌘⇧P"
                )
                shortcutRow(
                    label: NSLocalizedString("shortcut.startStop", comment: "Start / Stop Timer"),
                    keys: "⌘⇧S"
                )
                shortcutRow(
                    label: NSLocalizedString("shortcut.reset", comment: "Reset Timer"),
                    keys: "⌘⇧R"
                )
                shortcutRow(
                    label: NSLocalizedString("shortcut.skipBreak", comment: "Skip Break"),
                    keys: "⌘⇧K"
                )
            } header: {
                Text(NSLocalizedString("settings.globalShortcuts", comment: "Global Shortcuts"))
            } footer: {
                Text(NSLocalizedString("settings.globalShortcutsNote", comment: "Global shortcuts work even when the panel is closed."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                shortcutRow(
                    label: NSLocalizedString("preset.deepFocus", comment: "Deep Focus"),
                    keys: "⌘⇧1"
                )
                shortcutRow(
                    label: NSLocalizedString("preset.standard", comment: "Standard"),
                    keys: "⌘⇧2"
                )
                shortcutRow(
                    label: NSLocalizedString("preset.quickSprint", comment: "Quick Sprint"),
                    keys: "⌘⇧3"
                )
                shortcutRow(
                    label: NSLocalizedString("preset.creativeFlow", comment: "Creative Flow"),
                    keys: "⌘⇧4"
                )
            } header: {
                Text(NSLocalizedString("settings.presetShortcuts", comment: "Preset Shortcuts"))
            }

            Section {
                shortcutRow(
                    label: NSLocalizedString("shortcut.startPauseLocal", comment: "Start / Pause"),
                    keys: "Space"
                )
                shortcutRow(
                    label: NSLocalizedString("shortcut.closePanel", comment: "Close Panel"),
                    keys: "Esc"
                )
            } header: {
                Text(NSLocalizedString("settings.panelShortcuts", comment: "Panel Shortcuts"))
            } footer: {
                Text(NSLocalizedString("settings.panelShortcutsNote", comment: "Panel shortcuts work only when the panel is open."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private func shortcutRow(label: String, keys: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(keys)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.primary.opacity(0.06))
                )
                .foregroundStyle(.secondary)
        }
    }
}
