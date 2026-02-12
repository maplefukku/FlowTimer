import SwiftUI

/// The main expanded panel view shown when the menu bar is clicked.
struct TimerPanelView: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var presetManager: PresetManager
    @EnvironmentObject var sessionStore: SessionStore

    @State private var showingStatistics = false

    var body: some View {
        VStack(spacing: 0) {
            // Timer area
            timerSection
                .padding(.top, 20)
                .padding(.horizontal, 20)

            // Controls
            TimerControlsView()
                .padding(.top, 16)
                .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 16)

            // Quick stats
            QuickStatsView()
                .padding(.top, 12)
                .padding(.horizontal, 20)

            Divider()
                .padding(.horizontal, 16)
                .padding(.top, 12)

            // Footer
            PanelFooterView(showingStatistics: $showingStatistics)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
        }
        .frame(width: 300)
        .sheet(isPresented: $showingStatistics) {
            StatisticsView()
                .environmentObject(sessionStore)
                .frame(minWidth: 500, minHeight: 400)
        }
        .onKeyPress(.space) {
            pomodoroManager.startOrPause()
            return .handled
        }
        .onKeyPress(.escape) {
            // Close handled by popover
            return .ignored
        }
    }

    private var timerSection: some View {
        VStack(spacing: 12) {
            // Session label
            sessionLabel

            // Timer ring with time display
            TimerRingView()
                .frame(width: 180, height: 180)

            // Cycle indicator
            cycleIndicator
        }
    }

    private var sessionLabel: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(sessionColor)
                .frame(width: 8, height: 8)

            Text(pomodoroManager.currentSession.localizedName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }

    private var cycleIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<pomodoroManager.sessionsPerCycle, id: \.self) { index in
                Circle()
                    .fill(
                        index < pomodoroManager.completedSessionsInCycle
                            ? appSettings.accentColor
                            : Color.primary.opacity(0.15)
                    )
                    .frame(width: 8, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: pomodoroManager.completedSessionsInCycle)
            }
        }
    }

    private var sessionColor: Color {
        switch pomodoroManager.currentSession {
        case .focus: return appSettings.accentColor
        case .shortBreak, .longBreak: return .green
        }
    }
}
