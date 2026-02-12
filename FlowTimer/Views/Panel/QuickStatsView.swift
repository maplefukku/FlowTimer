import SwiftUI

/// Quick statistics shown at the bottom of the timer panel.
struct QuickStatsView: View {
    @EnvironmentObject var sessionStore: SessionStore

    var body: some View {
        HStack(spacing: 0) {
            statItem(
                icon: "checkmark.circle",
                value: "\(sessionStore.todaySessionCount)",
                label: NSLocalizedString("stats.sessions", comment: "Sessions")
            )

            Spacer()

            divider

            Spacer()

            statItem(
                icon: "clock",
                value: formatMinutes(sessionStore.todayFocusMinutes),
                label: NSLocalizedString("stats.focusTime", comment: "Focus Time")
            )

            Spacer()

            divider

            Spacer()

            statItem(
                icon: "flame",
                value: "\(sessionStore.currentStreak)",
                label: NSLocalizedString("stats.streak", comment: "Streak")
            )
        }
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundStyle(.primary)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.primary.opacity(0.06))
            .frame(width: 1, height: 30)
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes >= 60 {
            let h = minutes / 60
            let m = minutes % 60
            return m > 0 ? "\(h)h\(m)m" : "\(h)h"
        }
        return "\(minutes)m"
    }
}
