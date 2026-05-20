import SwiftUI

// MARK: - Caustic surface shimmer (internal)

/// Tiny bright hot-spots that drift across the glass surface.
/// Simulates the light-concentration caustic patterns you see on surfaces
/// behind or beneath real glass.  Very subtle — blend mode overlay at low opacity.
private struct CausticLayer: View {

    let t: Double   // pre-scaled time from parent

    // (xFreq, yFreq, xPhase, yPhase)  — irrational-ish ratios so spots never sync
    private static let params: [(Double, Double, Double, Double)] = [
        (0.41, 0.37, 0.00, 0.00),
        (0.27, 0.53, 2.10, 1.30),
        (0.63, 0.29, 4.20, 3.70),
        (0.19, 0.47, 1.80, 5.10),
    ]

    var body: some View {
        Canvas { ctx, size in
            let minD = min(size.width, size.height)
            let full = CGRect(origin: .zero, size: size)

            for (xf, yf, xp, yp) in Self.params {
                let x = size.width  * (0.50 + 0.34 * cos(t * xf + xp))
                let y = size.height * (0.50 + 0.28 * sin(t * yf + yp))
                let r = minD * (0.055 + 0.030 * abs(sin(t * 0.70 + xp)))

                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.60), .clear]),
                        center: CGPoint(x: x, y: y),
                        startRadius: 0,
                        endRadius: r
                    ))
                }
            }
        }
        .blendMode(.overlay)
        .opacity(0.20)
    }
}

// MARK: - Glass overlay (internal)

/// Four-layer glass surface applied on top of the animated gradient:
///   1. Frosted material (ultra-thin — lets the gradient glow through)
///   2. Caustic shimmer (tiny drifting hot-spots above the material)
///   3. Soft inner glow — brightens on active
///   4. Specular border — bright top-left edge, dim bottom-right
struct GlassOverlay<S: Shape>: View {

    let shape: S
    let config: GlassConfig
    let isActive: Bool

    var body: some View {
        ZStack {
            // 1 ── Frosted material
            shape.fill(.ultraThinMaterial)

            // 2 ── Caustic surface shimmer (above the material)
            TimelineView(.animation(minimumInterval: 1.0 / 30)) { tl in
                let t = tl.date.timeIntervalSinceReferenceDate * 0.10
                CausticLayer(t: t)
            }
            .clipShape(shape)

            // 3 ── Soft inner glow
            shape.fill(
                RadialGradient(
                    colors: [
                        Color.white.opacity(isActive ? config.glowActiveOpacity : config.glowOpacity),
                        Color.clear,
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: 130
                )
            )
            .animation(.easeInOut(duration: 0.22), value: isActive)

            // 4 ── Specular glass edge (bright top-left, dim bottom-right)
            shape.stroke(
                LinearGradient(
                    stops: [
                        .init(color: .white.opacity(config.borderOpacity * 1.30), location: 0.00),
                        .init(color: .white.opacity(config.borderOpacity * 0.45), location: 0.42),
                        .init(color: .white.opacity(config.borderOpacity * 0.10), location: 0.58),
                        .init(color: .white.opacity(config.borderOpacity * 0.75), location: 1.00),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 0.75
            )
        }
    }
}
