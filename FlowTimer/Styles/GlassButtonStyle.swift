import SwiftUI

/// A button style that matches the Liquid Glass design system.
struct GlassButtonStyle: ButtonStyle {
    var isProminent: Bool = false
    var size: ControlSize = .regular

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(fontSize)
            .fontWeight(isProminent ? .semibold : .medium)
            .foregroundStyle(foregroundColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(background(isPressed: configuration.isPressed))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(strokeColor, lineWidth: 0.5)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }

    private var fontSize: Font {
        switch size {
        case .small: return .caption
        case .large: return .body
        default: return .callout
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .small: return 8
        case .large: return 20
        default: return 14
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .small: return 4
        case .large: return 10
        default: return 7
        }
    }

    private var cornerRadius: CGFloat {
        switch size {
        case .small: return 6
        case .large: return 12
        default: return 8
        }
    }

    private var foregroundColor: Color {
        if isProminent {
            return .white
        }
        return .primary
    }

    private var strokeColor: Color {
        if isProminent { return .clear }
        return colorScheme == .dark
            ? Color(white: 1.0, opacity: 0.1)
            : Color(white: 0.0, opacity: 0.06)
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        if isProminent {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(Color.accentColor.opacity(isPressed ? 0.8 : 1.0))
        } else {
            ZStack {
                VisualEffectBlur(material: .popover, blendingMode: .withinWindow)
                Color.primary.opacity(isPressed ? 0.08 : 0.04)
            }
        }
    }
}

/// Icon button for toolbar-style controls.
struct GlassIconButtonStyle: ButtonStyle {
    var size: CGFloat = 32

    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4, weight: .medium))
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(Color.primary.opacity(configuration.isPressed ? 0.1 : 0.05))
            )
            .overlay(
                Circle()
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color(white: 1.0, opacity: 0.08)
                            : Color(white: 0.0, opacity: 0.05),
                        lineWidth: 0.5
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
