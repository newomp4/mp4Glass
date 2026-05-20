import SwiftUI

// MARK: - Generic glass card modifier

/// Wraps any view in the animated-gradient + frosted-glass treatment.
/// Great for cards, panels, modals, or anything that isn't a button.
///
///     Text("Hello")
///         .padding(24)
///         .glassCard(cornerRadius: 20)
public struct GlassCardModifier: ViewModifier {

    let cornerRadius: CGFloat
    let config: GlassConfig

    public func body(content: Content) -> some View {
        content
            .background {
                let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                ZStack {
                    AnimatedGradient(config: config)
                    GlassOverlay(shape: shape, config: config, isActive: false)
                }
                .clipShape(shape)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(
                color: (config.colors.first ?? .blue).opacity(0.20),
                radius: 12, x: 0, y: 6
            )
    }
}

public extension View {

    /// Applies the animated liquid-glass card treatment.
    func glassCard(
        cornerRadius: CGFloat = 20,
        config: GlassConfig = GlassConfig()
    ) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, config: config))
    }
}
