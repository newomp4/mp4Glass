import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// Six pill buttons — same frosted-glass shell, different tap-glow reaction.
// V1, V3, V5 are originals (pacing slowed). V2, V4, V6 are chromatic / liquid.
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - Tap trigger helper

private func triggerTap(_ tap: Binding<CGFloat>, duration: Double) {
    tap.wrappedValue = 1.0
    // Defer to next run loop so SwiftUI renders tap=1 before dispersing
    DispatchQueue.main.async {
        withAnimation(.easeOut(duration: duration)) {
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

// MARK: - Glass shell
// Layers (bottom → top): dark base → underlay → material → overlay → label → border

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
            Capsule().fill(Color(red: 0.06, green: 0.06, blue: 0.10))
            underlay
            Capsule().fill(.ultraThinMaterial)
            overlay
            Text(label)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
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
// V1 — Glow Fill
// Tap floods the blobs outward + lifts brightness. Glow slowly recedes.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV1: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.0)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 8)
                    .scaleEffect(1 + tap * 3.5)
                    .brightness(Double(tap) * 0.30)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V2 — Chromatic Fill
// Blobs swell while hue slowly drifts — colors flood in and gradually return.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV2: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.2)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 8)
                    .scaleEffect(1 + tap * 3.0)
                    .hueRotation(.degrees(Double(tap) * 60))
                    .brightness(Double(tap) * 0.25)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V3 — Deep Compress
// Energy concentrates to a bright dense point, then slowly expands back out.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV3: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.4)
            action()
        } label: {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: max(2, 14 - tap * 10))
                    .scaleEffect(max(0.15, 1 - tap * 0.82))
                    .brightness(Double(tap) * 0.50)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V4 — Saturation Surge
// Colors flood to jewel-vivid as glass nearly clears, then slowly re-frosts.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV4: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.0)
            action()
        } label: {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(0, 16 - tap * 15))
                    .saturation(1.0 + Double(tap) * 5.0)
                    .brightness(Double(tap) * 0.40)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V5 — Clarity Fill
// Glass fully clears on tap — raw vivid blobs visible — then slowly re-frosts.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV5: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.6)
            action()
        } label: {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(0, 16 - tap * 16))
                    .saturation(1.0 + Double(tap) * 2.5)
                    .brightness(Double(tap) * 0.55)
            }
        }
        .buttonStyle(.plain)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// V6 — Glass Refract
// Two glow layers fill and spread apart chromatically, then slowly converge.
// ─────────────────────────────────────────────────────────────────────────────

public struct GlassPillV6: View {
    public var label: String; public var action: () -> Void
    @State private var tap: CGFloat = 0
    public init(_ label: String, action: @escaping () -> Void) { self.label = label; self.action = action }

    public var body: some View {
        Button {
            triggerTap($tap, duration: 2.2)
            action()
        } label: {
            GlassPill(label) {
                ZStack {
                    BlobCanvas()
                        .blur(radius: 12)
                        .scaleEffect(1 + tap * 2.0)
                        .hueRotation(.degrees(Double(tap) * -45))

                    BlobCanvas()
                        .blur(radius: 6)
                        .scaleEffect(1 + tap * 4.0)
                        .hueRotation(.degrees(Double(tap) * 45))
                        .opacity(0.80)
                        .blendMode(.screen)
                }
            }
        }
        .buttonStyle(.plain)
    }
}
