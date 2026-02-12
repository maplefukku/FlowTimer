import AppKit
import Combine

/// Renders the menu bar icon with progress arc animation.
final class MenuBarIconRenderer {
    private let pomodoroManager: PomodoroManager
    private let appSettings: AppSettings

    private let iconSize: CGFloat = 18

    init(pomodoroManager: PomodoroManager, appSettings: AppSettings) {
        self.pomodoroManager = pomodoroManager
        self.appSettings = appSettings
    }

    func renderIcon() -> NSImage {
        let image = NSImage(size: NSSize(width: iconSize, height: iconSize), flipped: false) { rect in
            self.drawIcon(in: rect)
            return true
        }
        image.isTemplate = true
        return image
    }

    private func drawIcon(in rect: NSRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = (iconSize - 4) / 2
        let lineWidth: CGFloat = 1.8

        let isRunning = pomodoroManager.timerEngine.state == .running
        let isPaused = pomodoroManager.timerEngine.state == .paused
        let progress = pomodoroManager.timerEngine.progress
        let isOnBreak = pomodoroManager.isOnBreak

        // Draw background circle (track)
        let trackColor = NSColor.tertiaryLabelColor
        trackColor.setStroke()

        let trackPath = NSBezierPath()
        trackPath.appendArc(
            withCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: 360
        )
        trackPath.lineWidth = lineWidth * 0.5
        trackPath.stroke()

        if isRunning || isPaused {
            // Draw progress arc
            let progressColor = isOnBreak
                ? NSColor.systemGreen
                : NSColor.labelColor

            progressColor.setStroke()

            let startAngle: CGFloat = 90
            let endAngle: CGFloat = 90 - (360 * CGFloat(progress))

            let arcPath = NSBezierPath()
            arcPath.appendArc(
                withCenter: center,
                radius: radius,
                startAngle: startAngle,
                endAngle: endAngle,
                clockwise: true
            )
            arcPath.lineWidth = lineWidth
            arcPath.lineCapStyle = .round
            arcPath.stroke()

            // Draw center dot when paused
            if isPaused {
                NSColor.labelColor.setFill()
                let dotSize: CGFloat = 3
                let dotRect = NSRect(
                    x: center.x - dotSize / 2,
                    y: center.y - dotSize / 2,
                    width: dotSize,
                    height: dotSize
                )
                NSBezierPath(ovalIn: dotRect).fill()
            }
        } else {
            // Draw static timer icon (clock hands)
            NSColor.labelColor.setStroke()

            // Minute hand
            let minuteHandPath = NSBezierPath()
            minuteHandPath.move(to: center)
            minuteHandPath.line(to: CGPoint(x: center.x, y: center.y + radius * 0.6))
            minuteHandPath.lineWidth = lineWidth
            minuteHandPath.lineCapStyle = .round
            minuteHandPath.stroke()

            // Hour hand
            let hourHandPath = NSBezierPath()
            hourHandPath.move(to: center)
            hourHandPath.line(to: CGPoint(x: center.x + radius * 0.4, y: center.y))
            hourHandPath.lineWidth = lineWidth
            hourHandPath.lineCapStyle = .round
            hourHandPath.stroke()
        }
    }
}
