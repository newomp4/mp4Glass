import SwiftUI

// MARK: - Progress / loading bar

/// A horizontal bar with an animated liquid-glass fill.
///
///     GlassProgressBar(value: 0.65)
///         .frame(height: 12)
///
/// The fill clip animates smoothly when `value` changes.
/// Set `value` to `nil` for an indeterminate / pulse animation.
public struct GlassProgressBar: View {

    let value: Double?       // 0…1, or nil for indeterminate
    let config: GlassConfig
    let showPercent: Bool

    @State private var pulseOffset: CGFloat = -1.0   // indeterminate sweep

    public init(
        value: Double?,
        config: GlassConfig = GlassConfig(),
        showPercent: Bool = false
    ) {
        self.value       = value.map { max(0, min(1, $0)) }
        self.config      = config
        self.showPercent = showPercent
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                track
                fill(geo: geo)
            }
        }
        .frame(height: 12)
        .onAppear {
            if value == nil { startPulse() }
        }
        .onChange(of: value == nil) { _, nowIndeterminate in
            if nowIndeterminate { startPulse() }
        }
    }

    // MARK: Track

    private var track: some View {
        ZStack {
            Capsule()
                .fill(Color.black.opacity(0.38))
            Capsule()
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.22), .white.opacity(0.06)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        }
    }

    // MARK: Fill

    @ViewBuilder
    private func fill(geo: GeometryProxy) -> some View {
        if let v = value {
            // Determinate fill
            ZStack {
                AnimatedGradient(config: config)
                GlassOverlay(shape: Capsule(), config: config, isActive: false)
                    .opacity(0.55)

                if showPercent {
                    Text("\(Int(v * 100))%")
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .clipShape(Capsule())
            .frame(width: max(geo.size.height, geo.size.width * v))
            .animation(.spring(response: 0.55, dampingFraction: 0.88), value: v)
            .shadow(
                color: (config.colors.first ?? .blue).opacity(0.45),
                radius: 5, x: 0, y: 0
            )

        } else {
            // Indeterminate — a glowing pill sweeping across
            let barH   = geo.size.height
            let barW   = geo.size.width
            let pillW  = barW * 0.35

            ZStack {
                AnimatedGradient(config: config)
                GlassOverlay(shape: Capsule(), config: config, isActive: true)
                    .opacity(0.6)
            }
            .clipShape(Capsule())
            .frame(width: pillW, height: barH)
            .offset(x: (pulseOffset + 1) / 2 * (barW - pillW))
            .shadow(
                color: (config.colors.first ?? .blue).opacity(0.55),
                radius: 7, x: 0, y: 0
            )
        }
    }

    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 1.4)
            .repeatForever(autoreverses: true)
        ) {
            pulseOffset = 1.0
        }
    }
}
