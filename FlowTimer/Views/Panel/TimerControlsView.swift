import SwiftUI

/// Timer control buttons: Start/Pause, Skip, Reset.
struct TimerControlsView: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager

    var body: some View {
        HStack(spacing: 16) {
            // Reset button
            Button(action: { pomodoroManager.reset() }) {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(GlassIconButtonStyle(size: 36))
            .help(NSLocalizedString("control.reset", comment: "Reset"))
            .disabled(pomodoroManager.timerEngine.state == .idle && pomodoroManager.completedSessionsInCycle == 0)

            // Main Start/Pause button
            Button(action: { pomodoroManager.startOrPause() }) {
                HStack(spacing: 6) {
                    Image(systemName: startPauseIcon)
                        .font(.system(size: 14, weight: .semibold))
                    Text(startPauseLabel)
                        .font(.system(size: 13, weight: .semibold))
                }
                .frame(minWidth: 100)
            }
            .buttonStyle(GlassButtonStyle(isProminent: true, size: .large))
            .keyboardShortcut(.space, modifiers: [])

            // Skip button
            Button(action: { pomodoroManager.skipToNext() }) {
                Image(systemName: "forward.end")
            }
            .buttonStyle(GlassIconButtonStyle(size: 36))
            .help(NSLocalizedString("control.skip", comment: "Skip"))
        }
    }

    private var startPauseIcon: String {
        switch pomodoroManager.timerEngine.state {
        case .idle: return "play.fill"
        case .running: return "pause.fill"
        case .paused: return "play.fill"
        }
    }

    private var startPauseLabel: String {
        switch pomodoroManager.timerEngine.state {
        case .idle:
            return NSLocalizedString("control.start", comment: "Start")
        case .running:
            return NSLocalizedString("control.pause", comment: "Pause")
        case .paused:
            return NSLocalizedString("control.resume", comment: "Resume")
        }
    }
}
