import SwiftUI

/// Circular progress ring with centered time display.
struct TimerRingView: View {
    @EnvironmentObject var pomodoroManager: PomodoroManager
    @EnvironmentObject var appSettings: AppSettings

    private let lineWidth: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                // Track
                Circle()
                    .stroke(trackColor, lineWidth: lineWidth)

                // Progress arc
                Circle()
                    .trim(from: 0, to: pomodoroManager.timerEngine.progress)
                    .stroke(
                        progressGradient,
                        style: StrokeStyle(
                            lineWidth: lineWidth,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.3), value: pomodoroManager.timerEngine.progress)

                // Time display
                VStack(spacing: 4) {
                    Text(pomodoroManager.timerEngine.formattedTime)
                        .font(.system(size: size * 0.22, weight: .light, design: .monospaced))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.2), value: pomodoroManager.timerEngine.remainingSeconds)

                    stateIndicator
                }
            }
            .frame(width: size, height: size)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    private var trackColor: Color {
        Color.primary.opacity(0.08)
    }

    private var progressGradient: AngularGradient {
        let color = pomodoroManager.isOnBreak ? Color.green : appSettings.accentColor
        return AngularGradient(
            gradient: Gradient(colors: [color.opacity(0.6), color]),
            center: .center,
            startAngle: .degrees(0),
            endAngle: .degrees(360 * pomodoroManager.timerEngine.progress)
        )
    }

    @ViewBuilder
    private var stateIndicator: some View {
        switch pomodoroManager.timerEngine.state {
        case .idle:
            Text(NSLocalizedString("timer.ready", comment: "Ready"))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.tertiary)
        case .running:
            HStack(spacing: 3) {
                Circle()
                    .fill(pomodoroManager.isOnBreak ? Color.green : appSettings.accentColor)
                    .frame(width: 5, height: 5)
                    .pulseAnimation()

                Text(pomodoroManager.currentSession.localizedName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        case .paused:
            Text(NSLocalizedString("timer.paused", comment: "Paused"))
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Pulse Animation

struct PulseAnimationModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .opacity(isPulsing ? 0.4 : 1.0)
            .animation(
                .easeInOut(duration: 1.0).repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear { isPulsing = true }
    }
}

extension View {
    func pulseAnimation() -> some View {
        modifier(PulseAnimationModifier())
    }
}
