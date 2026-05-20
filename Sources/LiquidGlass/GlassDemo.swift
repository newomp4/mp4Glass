import SwiftUI

#if DEBUG

public struct GlassDemo: View {

    public init() {}

    public var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.05, blue: 0.08).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {

                    VStack(spacing: 6) {
                        Text("LiquidGlass Buttons")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Press each button — the glow reacts")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.35))
                    }
                    .padding(.bottom, 40)

                    VStack(spacing: 30) {

                        row("01", "Pulse Out",
                            "glow explodes outward then springs back") {
                            GlassPillV1("Pulse Out") {}
                        }

                        row("02", "Chromatic Pulse",
                            "glow blooms while hue sweeps the spectrum — prismatic dispersion") {
                            GlassPillV2("Chromatic Pulse") {}
                        }

                        row("03", "Squeeze Burst",
                            "glow compresses to a point, bouncy spring pushes it back past 1×") {
                            GlassPillV3("Squeeze Burst") {}
                        }

                        row("04", "Liquid Surge",
                            "saturation floods the center — jewel-vivid colors surge then slowly cool") {
                            GlassPillV4("Liquid Surge") {}
                        }

                        row("05", "Clarity Flash",
                            "frosted glass momentarily clears — raw vivid blobs, then re-frosts") {
                            GlassPillV5("Clarity Flash") {}
                        }

                        row("06", "Glass Refract",
                            "two glow layers split at different rates — chromatic aberration through glass") {
                            GlassPillV6("Glass Refract") {}
                        }
                    }
                }
                .frame(maxWidth: 360)
                .padding(.horizontal, 32)
                .padding(.vertical, 48)
                .frame(maxWidth: .infinity)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func row<B: View>(
        _ number: String, _ name: String, _ note: String,
        @ViewBuilder button: () -> B
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(number)
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.20))
                Text(name)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.65))
            }
            button()
                .frame(maxWidth: .infinity, minHeight: 52)
            Text(note)
                .font(.system(size: 11))
                .foregroundStyle(.white.opacity(0.25))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct GlassDemo_Previews: PreviewProvider {
    static var previews: some View {
        GlassDemo()
            .frame(width: 440, height: 960)
    }
}

#endif
