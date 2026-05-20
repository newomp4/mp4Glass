import SwiftUI

// MARK: - Animated gradient (internal)

/// Renders a pulsing, color-cycling glow concentrated at the center of the component.
/// The three primary colors take turns brightening and fading in 120° phase offset
/// (aurora-style), while a dark vignette keeps the edges deep.
/// The glass material above frosts the result into a "light source behind glass" look.
struct AnimatedGradient: View {

    let config: GlassConfig

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate * config.animationSpeed
            GlowCanvas(t: t, colors: config.colors)
        }
        .blur(radius: config.blurRadius)
    }
}

// MARK: - Canvas (separated from TimelineView to minimise layout work each frame)

private struct GlowCanvas: View {

    let t: Double
    let colors: [Color]

    var body: some View {
        Canvas { ctx, size in
            let cx      = size.width  / 2
            let cy      = size.height / 2
            let minD    = min(size.width, size.height)
            let diagR   = sqrt(size.width * size.width + size.height * size.height) / 2
            let full    = CGRect(origin: .zero, size: size)
            let base    = colors.last ?? Color(red: 0.04, green: 0.05, blue: 0.10)

            // ─── 1. Near-black tinted base ───────────────────────────────────────
            ctx.fill(Path(full), with: .color(base))

            // ─── 2. Aurora color cycling ─────────────────────────────────────────
            // Three main colors phase-separated by 120°.
            // Each one oscillates 0.08 → 0.96 opacity so two colors are always
            // partially visible — the result feels like a living aurora.
            let cycleCount = min(colors.count - 1, 3)
            let pulsedR    = minD * (0.50 + 0.14 * sin(t * 1.30))   // ~24 s period

            for i in 0..<cycleCount {
                let phase  = t * 0.90 + Double(i) * (2.0 * .pi / 3.0) // ~35 s full cycle
                let alpha  = 0.08 + 0.88 * (0.5 + 0.5 * sin(phase))   // 0.08 … 0.96

                // Slow independent orbit so colours feel spatially distinct
                let orbitR = minD * 0.10
                let oAngle = t * 1.00 + Double(i) * (2.0 * .pi / 3.0) // ~31 s orbit
                let ox     = cx + orbitR * cos(oAngle)
                let oy     = cy + orbitR * sin(oAngle * 0.83)          // slight ellipse

                let glowR  = i == 0 ? pulsedR : minD * (0.38 + 0.10 * cos(t * 0.95 + Double(i)))

                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [colors[i].opacity(alpha), .clear]),
                        center: CGPoint(x: ox, y: oy),
                        startRadius: 0,
                        endRadius: glowR
                    ))
                }
            }

            // ─── 3. Dark vignette — keeps edges near-black ───────────────────────
            // Glow is confined to the central ~33 % of the diagonal; everything
            // beyond that ramps to near-black, creating the "lantern" effect.
            ctx.fill(Path(full), with: .radialGradient(
                Gradient(stops: [
                    .init(color: .clear,                    location: 0.00),
                    .init(color: .clear,                    location: 0.33),
                    .init(color: Color.black.opacity(0.80), location: 1.00),
                ]),
                center: CGPoint(x: cx, y: cy),
                startRadius: 0,
                endRadius: diagR * 1.10
            ))
        }
    }
}
