import SwiftUI

// MARK: - Configuration

/// Controls appearance and animation of every LiquidGlass component.
public struct GlassConfig {

    /// Colors that cycle beneath the glass. Last color is the near-black base.
    public var colors: [Color]

    /// Global time multiplier — scales all animation rates together.
    public var animationSpeed: Double

    /// Gaussian blur on the raw gradient before the material is applied.
    /// Kept low (2–3) so the concentrated glow reads clearly through the frost.
    public var blurRadius: CGFloat

    /// Inner glow brightness at rest.
    public var glowOpacity: Double

    /// Inner glow brightness when hovered or pressed.
    public var glowActiveOpacity: Double

    /// Glass edge specular brightness.
    public var borderOpacity: Double

    public init(
        colors: [Color] = GlassConfig.runlock,
        animationSpeed: Double = 0.20,
        blurRadius: CGFloat = 2.5,
        glowOpacity: Double = 0.08,
        glowActiveOpacity: Double = 0.28,
        borderOpacity: Double = 0.40
    ) {
        self.colors            = colors
        self.animationSpeed    = animationSpeed
        self.blurRadius        = blurRadius
        self.glowOpacity       = glowOpacity
        self.glowActiveOpacity = glowActiveOpacity
        self.borderOpacity     = borderOpacity
    }
}

// MARK: - Vivid palettes

public extension GlassConfig {

    /// Deep electric blue → vivid purple → hot amber → crimson
    /// (Runlock brand, re-tuned for maximum saturation)
    static let runlock: [Color] = [
        Color(hue: 0.620, saturation: 0.95, brightness: 1.00),  // electric blue
        Color(hue: 0.760, saturation: 0.98, brightness: 0.90),  // vivid purple
        Color(hue: 0.075, saturation: 1.00, brightness: 0.95),  // hot amber-orange
        Color(hue: 0.620, saturation: 0.90, brightness: 0.08),  // near-black base
    ]

    /// Hot orange → vivid scarlet → gold
    static let ember: [Color] = [
        Color(hue: 0.060, saturation: 1.00, brightness: 1.00),  // vivid orange
        Color(hue: 0.010, saturation: 1.00, brightness: 0.95),  // hot red
        Color(hue: 0.115, saturation: 0.95, brightness: 0.90),  // molten gold
        Color(hue: 0.035, saturation: 0.90, brightness: 0.07),  // near-black base
    ]

    /// Vivid cyan → electric teal → cobalt
    static let electric: [Color] = [
        Color(hue: 0.525, saturation: 1.00, brightness: 1.00),  // vivid cyan
        Color(hue: 0.580, saturation: 0.95, brightness: 1.00),  // sky blue
        Color(hue: 0.470, saturation: 0.90, brightness: 0.90),  // electric teal
        Color(hue: 0.540, saturation: 0.90, brightness: 0.07),  // near-black base
    ]

    /// Bright violet → hot magenta → electric purple
    static let amethyst: [Color] = [
        Color(hue: 0.780, saturation: 1.00, brightness: 1.00),  // vivid violet
        Color(hue: 0.850, saturation: 0.95, brightness: 0.95),  // bright magenta
        Color(hue: 0.710, saturation: 0.95, brightness: 0.90),  // electric indigo
        Color(hue: 0.790, saturation: 0.88, brightness: 0.07),  // near-black base
    ]

    /// Hot pink → fuchsia → neon rose
    static let rose: [Color] = [
        Color(hue: 0.950, saturation: 1.00, brightness: 1.00),  // hot pink
        Color(hue: 0.880, saturation: 1.00, brightness: 0.95),  // vivid fuchsia
        Color(hue: 0.005, saturation: 0.95, brightness: 0.90),  // neon red-rose
        Color(hue: 0.940, saturation: 0.85, brightness: 0.07),  // near-black base
    ]

    /// Vivid emerald → neon green → electric lime
    static let jade: [Color] = [
        Color(hue: 0.420, saturation: 1.00, brightness: 0.95),  // vivid emerald
        Color(hue: 0.360, saturation: 0.95, brightness: 0.90),  // electric green
        Color(hue: 0.480, saturation: 0.90, brightness: 0.90),  // neon teal-green
        Color(hue: 0.430, saturation: 0.85, brightness: 0.07),  // near-black base
    ]

    /// All-hue aurora: green → cyan → violet (shifts through spectrum)
    static let aurora: [Color] = [
        Color(hue: 0.400, saturation: 0.95, brightness: 0.95),  // vivid green
        Color(hue: 0.530, saturation: 1.00, brightness: 1.00),  // electric cyan
        Color(hue: 0.760, saturation: 0.98, brightness: 0.95),  // violet
        Color(hue: 0.500, saturation: 0.85, brightness: 0.07),  // near-black base
    ]

    /// Quick shorthand.
    static func palette(_ colors: [Color], speed: Double = 0.20) -> GlassConfig {
        GlassConfig(colors: colors, animationSpeed: speed)
    }
}
