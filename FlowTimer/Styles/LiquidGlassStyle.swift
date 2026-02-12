import SwiftUI

/// Liquid Glass visual effect container.
/// Uses NSVisualEffectView blur + custom edge strokes + drop shadows
/// to achieve a glass-like appearance that remains visible on any background.
struct LiquidGlassBackground: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Layer 1: Background blur (via VisualEffectBlur)
                    VisualEffectBlur(material: .hudWindow, blendingMode: .behindWindow)

                    // Layer 2: Tint layer
                    tintLayer
                }
            )
            // Layer 3: Edge stroke
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(edgeStrokeColor, lineWidth: 0.5)
            )
            // Layer 4: Drop shadow
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowYOffset
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var tintLayer: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(tintColor)
    }

    private var tintColor: Color {
        colorScheme == .dark
            ? Color(white: 0.16, opacity: 0.25)
            : Color(white: 1.0, opacity: 0.15)
    }

    private var edgeStrokeColor: Color {
        colorScheme == .dark
            ? Color(white: 1.0, opacity: 0.12)
            : Color(white: 0.0, opacity: 0.08)
    }

    private var shadowColor: Color {
        Color(white: 0.0, opacity: 0.12)
    }

    private var shadowRadius: CGFloat { 12 }
    private var shadowYOffset: CGFloat { 2 }
}

extension View {
    func liquidGlassBackground() -> some View {
        modifier(LiquidGlassBackground())
    }
}

// MARK: - NSVisualEffectView Bridge

struct VisualEffectBlur: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        view.isEmphasized = true
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
