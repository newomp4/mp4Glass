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

                        row("01", "Glow Fill",
                            "blobs flood outward then slowly recede") {
                            GlassPillV1("Glow Fill") {}
                        }

                        row("02", "Chromatic Fill",
                            "blobs swell while hue drifts, slowly returns") {
                            GlassPillV2("Chromatic Fill") {}
                        }

                        row("03", "Deep Compress",
                            "energy concentrates to a bright point, slowly re-expands") {
                            GlassPillV3("Deep Compress") {}
                        }

                        row("04", "Saturation Surge",
                            "colors flood to jewel-vivid, glass slowly re-frosts") {
                            GlassPillV4("Saturation Surge") {}
                        }

                        row("05", "Clarity Fill",
                            "glass fully clears showing raw blobs, slowly re-frosts") {
                            GlassPillV5("Clarity Fill") {}
                        }

                        row("06", "Glass Refract",
                            "two glow layers spread apart chromatically, slowly converge") {
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
