import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// Six pill buttons — same frosted-glass shell, different tap-glow reaction.
// V1, V3, V5 are originals (pacing slowed). V2, V4, V6 are chromatic / liquid.
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - Tap trigger helper

private func triggerTap(_ tap: Binding<CGFloat>, response: Double, damping: Double) {
    tap.wrappedValue = 1.0
    // Defer animation to next run loop so SwiftUI renders the 1.0 state first
    DispatchQueue.main.async {
        withAnimation(.spring(response: response, dampingFraction: damping)) {
            tap.wrappedValue = 0
        }
    }
}

// MARK: - Shared blob colors + parameters

private let _colors: [Color] = [
    Color(hue: 0.620, saturation: 1.0, brightness: 1.00),  // electric blue
    Color(hue: 0.780, saturation: 1.0, brightness: 0.95),  // vivid violet
    Color(hue: 0.060, saturation: 1.0, brightness: 1.00),  // hot orange
]

private let _blobParams: [(Double, Double, Double, Double)] = [
    (0.37, 0.29, 0.00, 0.00),
    (0.23, 0.41, 2.10, 1.70),
    (0.51, 0.17, 4.30, 3.10),
]

// MARK: - Blob views

private struct BlobCanvas: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30)) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate * 0.40
            Canvas { ctx, size in
                let cx = size.width / 2, cy = size.height / 2
                let minD = min(size.width, size.height)
                let full = CGRect(origin: .zero, size: size)

                for (i, p) in _blobParams.enumerated() {
                    let ox = cx + minD * 0.38 * cos(t * p.0 + p.2)
                    let oy = cy + minD * 0.32 * sin(t * p.1 + p.3)
                    ctx.drawLayer { inner in
                        inner.blendMode = .screen
                        inner.fill(Path(full), with: .radialGradient(
                            Gradient(colors: [_colors[i], .clear]),
                            center: CGPoint(x: ox, y: oy),
                            startRadius: 0,
                            endRadius: minD * 0.55
                        ))
                    }
                }

                // White hot-core — center feels lit from within
                ctx.drawLayer { inner in
                    inner.blendMode = .screen
                    inner.fill(Path(full), with: .radialGradient(
                        Gradient(colors: [Color.white.opacity(0.50), .clear]),
                        center: CGPoint(x: cx, y: cy),
                        startRadius: 0,
                        endRadius: minD * 0.18
                    ))
                }
            }
        }
    }
}

private struct CircleBlobs: View {
    @State private var c1x: CGFloat = 0; @State private var c1y: CGFloat = 0
    @State private var c2x: CGFloat = 0; @State private var c2y: CGFloat = 0
    @State private var c3x: CGFloat = 0; @State private var c3y: CGFloat = 0

    var body: some View {
        ZStack {
            Circle().fill(_colors[0]).frame(width: 48, height: 48).offset(x: c1x, y: c1y)
            Circle().fill(_colors[1]).frame(width: 40, height: 40).offset(x: c2x, y: c2y)
            Circle().fill(_colors[2]).frame(width: 36, height: 36).offset(x: c3x, y: c3y)
            // White hot-core
            Circle()
                .fill(Color.white.opacity(0.55))
                .frame(width: 20, height: 20)
                .blur(radius: 5)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) { c1x =  20 }
            withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true)) { c1y =   8 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeInOut(duration: 2.7).repeatForever(autoreverses: true)) { c2x = -16 }
                withAnimation(.easeInOut(duration: 3.3).repeatForever(autoreverses: true)) { c2y =  -7 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.9) {
                withAnimation(.easeInOut(duration: 3.5).repeatForever(autoreverses: true)) { c3x =  10 }
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { c3y = -10 }
            }
        }
    }
}

// MARK: - Shimmer

/// A narrow diagonal light band that sweeps across the glass surface every ~4 s,
/// like a beam of light catching real frosted glass.
private struct ShimmerLayer: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60)) { tl in
            let t       = tl.date.timeIntervalSinceReferenceDate
            let period  = 4.0    // full cycle length in seconds
            let sweep   = 0.50   // time the band takes to cross the button
            let raw     = t.truncatingRemainder(dividingBy: period)
            let prog    = CGFloat(min(1.0, raw / sweep))

            Canvas { ctx, size in
                // Band travels from off-left to off-right during 0→1
                let x    = prog * (size.width + 60) - 30
                let half = CGFloat(22)           // half-width of the streak
                let full = CGRect(origin: .zero, size: size)

                ctx.drawLayer { inner in
                    inner.blendMode = .overlay
                    inner.fill(Path(full), with: .linearGradient(
                        Gradient(stops: [
                            .init(color: .clear,                location: 0.00),
                            .init(color: .white.opacity(0.55),  location: 0.42),
                            .init(color: .white.opacity(0.55),  location: 0.58),
                            .init(color: .clear,                location: 1.00),
                        ]),
                        // Slight diagonal: start top-left of band, end bottom-right
                        startPoint: CGPoint(x: x - half, y: -4),
                        endPoint:   CGPoint(x: x + half, y: size.height + 4)
                    ))
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Glass shell
// Layers (bottom → top):
//   dark base → underlay → material → shimmer → overlay → label → specular rim

private struct GlassPill<U: View, O: View>: View {
    let label: String
    let underlay: U
    let overlay: O

    init(_ label: String, @ViewBuilder underlay: () -> U, @ViewBuilder overlay: () -> O) {
        self.label    = label
        self.underlay = underlay()
        self.overlay  = overlay()
    }

    var body: some View {
        ZStack {
            // 1. Dark base
            Capsule().fill(Color(red: 0.06, green: 0.06, blue: 0.10))

            // 2. Animated glow underlay
            underlay

            // 3. Frosted material
            Capsule().fill(.ultraThinMaterial)

            // 4. Shimmer — sits on top of the glass surface
            ShimmerLayer()

            // 5. Per-variant overlay (ripple ring, etc.)
            overlay

            // 6. Label
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)

            // 7. Specular border
            Capsule()
                .stroke(Color.white.opacity(0.18), lineWidth: 0.75)
        }
        .clipShape(Capsule())
    }
}

extension GlassPill where O == EmptyView {
    init(_ label: String, @ViewBuilder underlay: () -> U) {
        self.init(label, underlay: underlay, overlay: { EmptyView() })
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V1 — Pulse Out
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV1: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 0.80, damping: 0.52)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 8)
                    .scaleEffect(1 + tap * 4.0)
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(1 + tap * 0.07)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V2 — Chromatic Pulse
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV2: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 0.85, damping: 0.58)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 8)
                    .scaleEffect(1 + tap * 3.5)
                    .hueRotation(.degrees(Double(tap) * 65))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(1 + tap * 0.07)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V3 — Squeeze Burst
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV3: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 0.60, damping: 0.22)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 8)
                    .scaleEffect(max(0.02, 1 - tap * 0.96))
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(max(0.88, 1 - tap * 0.12))
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V4 — Liquid Surge
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV4: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 0.95, damping: 0.65)
            action()
        } label: {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(0, 16 - tap * 15))
                    .saturation(1.0 + Double(tap) * 5.5)
                    .brightness(Double(tap) * 0.45)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V5 — Clarity Flash
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV5: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 1.10, damping: 0.70)
            action()
        } label: {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(0, 16 - tap * 16))
                    .saturation(1.0 + Double(tap) * 2.5)
                    .brightness(Double(tap) * 0.65)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V6 — Glass Refract
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV6: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, response: 1.00, damping: 0.68)
            action()
        } label: {
            GlassPill(label) {
                ZStack {
                    BlobCanvas()
                        .blur(radius: 12)
                        .scaleEffect(1 + tap * 1.8)
                        .hueRotation(.degrees(Double(tap) * -45))

                    BlobCanvas()
                        .blur(radius: 6)
                        .scaleEffect(1 + tap * 4.5)
                        .hueRotation(.degrees(Double(tap) * 45))
                        .opacity(0.80)
                        .blendMode(.screen)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
