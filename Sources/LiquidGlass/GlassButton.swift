import SwiftUI

// MARK: - Button shape variants

public enum GlassButtonVariant {
    case pill    // Capsule — primary CTAs
    case menu    // Rounded rect — toolbar / nav items
    case icon    // Circle — icon-only actions
}

// MARK: - Public button

/// A button with an animated liquid-glass treatment.
///
///     GlassButton("Unlock", icon: "lock.open") { /* action */ }
///     GlassButton("Settings", icon: "gear", variant: .menu) { /* action */ }
///     GlassButton("", icon: "plus", variant: .icon) { /* action */ }
public struct GlassButton: View {

    let label: String
    let icon: String?
    let config: GlassConfig
    let variant: GlassButtonVariant
    let action: () -> Void

    @State private var isHovered = false

    public init(
        _ label: String,
        icon: String? = nil,
        config: GlassConfig = GlassConfig(),
        variant: GlassButtonVariant = .pill,
        action: @escaping () -> Void
    ) {
        self.label  = label
        self.icon   = icon
        self.config  = config
        self.variant = variant
        self.action  = action
    }

    public var body: some View {
        Button(action: action) {
            buttonLabel
        }
        .buttonStyle(
            GlassButtonStyle(config: config, variant: variant, isHovered: isHovered)
        )
        .onHover { isHovered = $0 }
    }

    @ViewBuilder
    private var buttonLabel: some View {
        switch variant {
        case .icon:
            Group {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                }
            }
            .foregroundStyle(.white)
            .frame(width: 50, height: 50)

        default:
            HStack(spacing: 7) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }
                if !label.isEmpty {
                    Text(label)
                        .font(.system(
                            size: variant == .pill ? 16 : 14,
                            weight: .semibold,
                            design: .rounded
                        ))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, variant == .pill ? 26 : 16)
            .padding(.vertical,   variant == .pill ? 14 : 10)
        }
    }
}

// MARK: - ButtonStyle (handles press state)

private struct GlassButtonStyle: ButtonStyle {

    let config: GlassConfig
    let variant: GlassButtonVariant
    let isHovered: Bool

    func makeBody(configuration: Configuration) -> some View {
        let active = configuration.isPressed || isHovered

        ZStack {
            AnimatedGradient(config: config)
            overlayView(isActive: active)
            configuration.label
        }
        .clipShape(shape(for: variant))
        .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.65), value: configuration.isPressed)
        .shadow(
            color: (config.colors.first ?? .blue).opacity(active ? 0.50 : 0.22),
            radius: active ? 20 : 9,
            x: 0, y: 5
        )
        .animation(.easeInOut(duration: 0.20), value: isHovered)
    }

    @ViewBuilder
    private func overlayView(isActive: Bool) -> some View {
        switch variant {
        case .pill:
            GlassOverlay(shape: Capsule(), config: config, isActive: isActive)
        case .menu:
            GlassOverlay(
                shape: RoundedRectangle(cornerRadius: 12, style: .continuous),
                config: config, isActive: isActive
            )
        case .icon:
            GlassOverlay(shape: Circle(), config: config, isActive: isActive)
        }
    }

    private func shape(for variant: GlassButtonVariant) -> AnyShape {
        switch variant {
        case .pill: AnyShape(Capsule())
        case .menu: AnyShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .icon: AnyShape(Circle())
        }
    }
}
