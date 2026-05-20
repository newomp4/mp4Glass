import SwiftUI

// MARK: - Enums

public enum GlowStyle: CaseIterable {
    case softCenter, wanderingBlobs, floatingCircles, auroraWave, comet

    public var name: String {
        switch self {
        case .softCenter:      "Soft Center"
        case .wanderingBlobs:  "Wandering Blobs"
        case .floatingCircles: "Floating Circles"
        case .auroraWave:      "Aurora Wave"
        case .comet:           "Comet"
        }
    }
}

public enum TapEffect: CaseIterable {
    case slowSwell, rippleWave, deepBreath, mercuryPool, warpBloom

    public var name: String {
        switch self {
        case .slowSwell:   "Slow Swell"
        case .rippleWave:  "Ripple Wave"
        case .deepBreath:  "Deep Breath"
        case .mercuryPool: "Mercury Pool"
        case .warpBloom:   "Warp Bloom"
        }
    }

    // Slow, liquid animations — no aggressive snapping
    var animation: Animation {
        switch self {
        case .slowSwell:   .easeInOut(duration: 1.40)
        case .rippleWave:  .easeOut(duration: 1.80)
        case .deepBreath:  .easeInOut(duration: 2.20)
        case .mercuryPool: .spring(response: 1.20, dampingFraction: 0.82)
        case .warpBloom:   .spring(response: 0.95, dampingFraction: 0.74)
        }
    }
}

// MARK: - Press style (fires on touch-down)

private struct LiquidPressStyle: ButtonStyle {
    let onPress: () -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                if pressed { onPress() }
            }
    }
}

// MARK: - Shared palette

private let _c: [Color] = [
    Color(hue: 0.620, saturation: 1.0, brightness: 1.00),   // electric blue
    Color(hue: 0.780, saturation: 1.0, brightness: 0.95),   // vivid violet
    Color(hue: 0.060, saturation: 1.0, brightness: 1.00),   // hot orange
]

// MARK: - Five glow styles

/// Single radial glow that slowly breathes — like a lamp behind the glass.
private struct SoftCenterGlow: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/30)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                let cx = size.width/2, cy = size.height/2
                let minD = min(size.width, size.height)
                let full = CGRect(origin: .zero, size: size)
                let r = minD * CGFloat(0.46 + 0.13 * sin(t * 0.60))
                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [_c[0].opacity(0.90), _c[1].opacity(0.50), .clear]),
                        center: CGPoint(x: cx, y: cy), startRadius: 0, endRadius: r
                    ))
                }
            }
        }
    }
}

/// Three blobs on independent sin/cos paths — the AE wiggle-expression approach.
private struct WanderingBlobGlow: View {
    private static let p: [(Double,Double,Double,Double)] = [
        (0.37,0.29,0.00,0.00),(0.23,0.41,2.10,1.70),(0.51,0.17,4.30,3.10)
    ]
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/30)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate * 0.35
            Canvas { ctx, size in
                let cx = size.width/2, cy = size.height/2
                let minD = min(size.width, size.height)
                let full = CGRect(origin: .zero, size: size)
                for (i, p) in Self.p.enumerated() {
                    let ox = cx + minD*0.38*cos(t*p.0+p.2)
                    let oy = cy + minD*0.32*sin(t*p.1+p.3)
                    ctx.drawLayer { inner in
                        inner.blendMode = .screen
                        inner.fill(Path(full), with: .radialGradient(
                            Gradient(colors: [_c[i].opacity(0.88), .clear]),
                            center: CGPoint(x: ox, y: oy), startRadius: 0, endRadius: minD*0.52
                        ))
                    }
                }
            }
        }
    }
}

/// Three SwiftUI Circle views on lissajous paths (x/y animate on different periods).
private struct FloatingCircleGlow: View {
    @State private var x1: CGFloat=0; @State private var y1: CGFloat=0
    @State private var x2: CGFloat=0; @State private var y2: CGFloat=0
    @State private var x3: CGFloat=0; @State private var y3: CGFloat=0
    var body: some View {
        ZStack {
            Circle().fill(_c[0]).frame(width:44,height:44).offset(x:x1,y:y1)
            Circle().fill(_c[1]).frame(width:36,height:36).offset(x:x2,y:y2)
            Circle().fill(_c[2]).frame(width:32,height:32).offset(x:x3,y:y3)
        }
        .onAppear {
            withAnimation(.easeInOut(duration:3.0).repeatForever(autoreverses:true)) { x1 = 18 }
            withAnimation(.easeInOut(duration:2.4).repeatForever(autoreverses:true)) { y1 = 7  }
            DispatchQueue.main.asyncAfter(deadline:.now()+1.0) {
                withAnimation(.easeInOut(duration:2.7).repeatForever(autoreverses:true)) { x2 = -14}
                withAnimation(.easeInOut(duration:3.3).repeatForever(autoreverses:true)) { y2 = -6 }
            }
            DispatchQueue.main.asyncAfter(deadline:.now()+1.9) {
                withAnimation(.easeInOut(duration:3.5).repeatForever(autoreverses:true)) { x3 = 9  }
                withAnimation(.easeInOut(duration:2.0).repeatForever(autoreverses:true)) { y3 = -9 }
            }
        }
    }
}

/// Three horizontal color bands drifting and cycling in/out — like aurora borealis.
private struct AuroraWaveGlow: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/30)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate * 0.18
            Canvas { ctx, size in
                let full = CGRect(origin: .zero, size: size)
                for (i, color) in _c.enumerated() {
                    let phase  = t * 0.65 + Double(i) * (2.0 * .pi / 3.0)
                    let alpha  = max(0.0, 0.5 + 0.5 * sin(phase))
                    let cx     = size.width * CGFloat(0.5 + 0.28 * cos(t*0.28 + Double(i)*1.3))
                    let bw     = size.width * 0.45
                    ctx.drawLayer { inner in
                        inner.blendMode = .screen
                        inner.fill(Path(full), with: .linearGradient(
                            Gradient(colors: [.clear, color.opacity(alpha), .clear]),
                            startPoint: CGPoint(x: cx - bw, y: size.height/2),
                            endPoint:   CGPoint(x: cx + bw, y: size.height/2)
                        ))
                    }
                }
            }
        }
    }
}

/// Single bright spot orbiting in an ellipse — shows movement through glass.
private struct CometGlow: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0/60)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate * 1.3
            Canvas { ctx, size in
                let cx = size.width/2, cy = size.height/2
                let full = CGRect(origin: .zero, size: size)
                let ox = cx + size.width  * 0.30 * CGFloat(cos(t))
                let oy = cy + size.height * 0.22 * CGFloat(sin(t))
                let minD = min(size.width, size.height)
                // Ambient background glow so the button isn't dark when comet is at edge
                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [_c[1].opacity(0.28), .clear]),
                        center: CGPoint(x:cx,y:cy), startRadius: 0, endRadius: minD*0.50
                    ))
                }
                // The comet head
                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.88), _c[0].opacity(0.70), .clear]),
                        center: CGPoint(x:ox,y:oy), startRadius: 0, endRadius: minD*0.24
                    ))
                }
            }
        }
    }
}

// MARK: - GlassPillButton

/// A single button that combines any GlowStyle with any TapEffect.
/// No dark base — the button is fully transparent so frosted glass interacts
/// with whatever content is behind it.
public struct GlassPillButton: View {

    public let glowStyle:  GlowStyle
    public let tapEffect:  TapEffect
    public let action:     () -> Void

    @State private var tap: CGFloat = 0

    public init(style: GlowStyle, effect: TapEffect, action: @escaping () -> Void = {}) {
        self.glowStyle = style
        self.tapEffect = effect
        self.action    = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                // Glow layer — no opaque base so background shows through the material
                glowView
                    .blur(radius: effectBlur)
                    .brightness(effectBrightness)
                    .scaleEffect(effectScale)
                    .clipShape(Capsule())

                // Frosted glass — frosts the glow AND whatever is behind the button
                Capsule().fill(.ultraThinMaterial)

                // Ripple ring sits above the material for a crisp, surface-level look
                if case .rippleWave = tapEffect { rippleRing }

                // Subtle specular border
                Capsule().stroke(Color.white.opacity(0.20), lineWidth: 0.75)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(LiquidPressStyle { triggerTap() })
    }

    // MARK: Glow layer switch

    @ViewBuilder
    private var glowView: some View {
        switch glowStyle {
        case .softCenter:      SoftCenterGlow()
        case .wanderingBlobs:  WanderingBlobGlow()
        case .floatingCircles: FloatingCircleGlow()
        case .auroraWave:      AuroraWaveGlow()
        case .comet:           CometGlow()
        }
    }

    // MARK: Tap effect modifiers
    // All applied unconditionally — unused ones compute to neutral values.

    private var effectScale: CGFloat {
        switch tapEffect {
        case .slowSwell:   return 1.0 + tap * 0.68        // swells gently outward
        case .mercuryPool: return max(0.10, 1.0-tap*0.84) // collapses inward, spring back
        case .warpBloom:   return 1.0 + tap * 0.22        // slight bloom with the blur
        default:           return 1.0
        }
    }

    private var effectBrightness: Double {
        switch tapEffect {
        case .rippleWave:  return Double(tap) * 0.40   // glow underneath the ring
        case .deepBreath:  return Double(tap) * 0.60   // pure luminosity flood
        case .warpBloom:   return Double(tap) * 0.25
        default:           return 0.0
        }
    }

    private var effectBlur: CGFloat {
        // warpBloom: blur briefly tightens (glass deforms), then re-softens
        if case .warpBloom = tapEffect { return max(2.0, 14.0 - tap * 11.0) }
        return 14.0
    }

    // MARK: Ripple ring (rippleWave only)

    private var rippleRing: some View {
        // tap=1 → tiny, opaque ring  |  tap=0 → large, invisible ring
        Capsule()
            .stroke(
                Color.white.opacity(Double(tap) * 0.70),
                lineWidth: max(0.3, 2.0 - tap * 1.8)
            )
            .scaleEffect(1.96 - tap * 1.86)
    }

    // MARK: Trigger

    private func triggerTap() {
        tap = 1.0
        withAnimation(tapEffect.animation) { tap = 0 }
    }
}
