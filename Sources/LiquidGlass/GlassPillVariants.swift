import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// Six pill buttons — same frosted-glass shell, different tap-glow reaction.
// V1, V3, V5 are originals (pacing slowed). V2, V4, V6 are chromatic / liquid.
// ─────────────────────────────────────────────────────────────────────────────

// MARK: - Tap style

private struct GlowTapStyle: ButtonStyle {
    @Binding var tapAnim: CGFloat
    var response: Double
    var damping:  Double

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, pressed in
                guard pressed else { return }
                tapAnim = 1.0
                withAnimation(.spring(response: response, dampingFraction: damping)) {
                    tapAnim = 0
                }
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
// Layers (bottom → top):
//   dark base → underlay → material → inner face glow → overlay → label → specular rim
// Then outer glow via .shadow() after the clip.

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

            // 3. Frosted material — frosts both the blobs and whatever is behind the button
            Capsule().fill(.ultraThinMaterial)

            // 4. Inner face glow — top of the glass face is brightest, fades toward center
            Capsule()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.22), location: 0.00),
                            .init(color: .white.opacity(0.07), location: 0.42),
                            .init(color: .clear,               location: 0.78),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // 5. Per-variant overlay (ripple ring, etc.)
            overlay

            // 6. Label — airy tracking, white glow for glassy depth
            Text(label)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.92))
                .shadow(color: .white.opacity(0.65), radius: 6, x: 0, y: 0)
                .shadow(color: .black.opacity(0.22), radius: 2, x: 0, y: 1)

            // 7. Specular rim — bright top-leading, dims to almost invisible, slight lift at bottom
            Capsule()
                .stroke(
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.82), location: 0.00),
                            .init(color: .white.opacity(0.24), location: 0.32),
                            .init(color: .white.opacity(0.04), location: 0.56),
                            .init(color: .white.opacity(0.36), location: 1.00),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.0
                )
                .blur(radius: 0.8)
        }
        .clipShape(Capsule())
        // Outer glow: coloured bloom (blue-violet) + tight white rim light
        .shadow(color: Color(hue: 0.68, saturation: 0.88, brightness: 1.0).opacity(0.26), radius: 16, x: 0, y: 2)
        .shadow(color: .white.opacity(0.13), radius: 3, x: 0, y: 0)
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
        Button(action: action) {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 14)
                    .scaleEffect(1 + tap * 1.8)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 0.80, damping: 0.58))
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
        Button(action: action) {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 14)
                    .scaleEffect(1 + tap * 1.6)
                    .hueRotation(.degrees(Double(tap) * 40))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 0.85, damping: 0.62))
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
        Button(action: action) {
            GlassPill(label) {
                BlobCanvas()
                    .blur(radius: 14)
                    .scaleEffect(max(0.05, 1 - tap * 0.90))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 0.65, damping: 0.30))
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
        Button(action: action) {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(3, 16 - tap * 10))
                    .saturation(1.0 + Double(tap) * 3.0)
                    .brightness(Double(tap) * 0.20)
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 0.95, damping: 0.68))
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
        Button(action: action) {
            GlassPill(label) {
                CircleBlobs()
                    .blur(radius: max(0, 16 - tap * 16))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 1.10, damping: 0.72))
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
        Button(action: action) {
            GlassPill(label) {
                ZStack {
                    BlobCanvas()
                        .blur(radius: 16)
                        .scaleEffect(1 + tap * 1.0)
                        .hueRotation(.degrees(Double(tap) * -25))

                    BlobCanvas()
                        .blur(radius: 10)
                        .scaleEffect(1 + tap * 1.9)
                        .hueRotation(.degrees(Double(tap) * 25))
                        .opacity(0.75)
                        .blendMode(.screen)
                }
                .clipShape(Capsule())
            }
        }
        .buttonStyle(GlowTapStyle(tapAnim: $tap, response: 1.00, damping: 0.70))
    }
}
