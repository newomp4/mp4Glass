import SwiftUI

// MARK: - Menu / tab bar item

/// A single tab item for `GlassMenuBar`.
public struct GlassMenuItem: Identifiable {
    public let id: String
    public let label: String
    public let icon: String?

    public init(id: String, label: String, icon: String? = nil) {
        self.id    = id
        self.label = label
        self.icon  = icon
    }
}

// MARK: - Menu bar

/// A horizontal navigation / tab bar.  The selected item gets a frosted pill
/// indicator that slides smoothly between tabs via `matchedGeometryEffect`.
///
///     GlassMenuBar(items: tabs, selection: $currentTab)
public struct GlassMenuBar: View {

    let items: [GlassMenuItem]
    @Binding var selection: String
    let config: GlassConfig

    @Namespace private var pill
    @State private var isHovered: String? = nil

    public init(
        items: [GlassMenuItem],
        selection: Binding<String>,
        config: GlassConfig = GlassConfig()
    ) {
        self.items     = items
        self._selection = selection
        self.config    = config
    }

    public var body: some View {
        ZStack {
            // Bar gradient + glass
            AnimatedGradient(config: config)
            GlassOverlay(
                shape: RoundedRectangle(cornerRadius: 18, style: .continuous),
                config: config,
                isActive: false
            )

            // Items row
            HStack(spacing: 0) {
                ForEach(items) { item in
                    tabButton(for: item)
                }
            }
            .padding(5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: Single tab item

    private func tabButton(for item: GlassMenuItem) -> some View {
        let selected = selection == item.id
        let hovered  = isHovered == item.id

        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.78)) {
                selection = item.id
            }
        } label: {
            HStack(spacing: 5) {
                if let icon = item.icon {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .medium))
                }
                Text(item.label)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(selected ? .white : .white.opacity(hovered ? 0.75 : 0.45))
            .padding(.horizontal, 16)
            .padding(.vertical,   9)
            .frame(maxWidth: .infinity)
            .background {
                if selected {
                    Capsule()
                        .fill(.white.opacity(0.16))
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.30), lineWidth: 0.5)
                        )
                        .shadow(
                            color: (config.colors.first ?? .blue).opacity(0.40),
                            radius: 8, x: 0, y: 2
                        )
                        .matchedGeometryEffect(id: "pill", in: pill)
                }
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 ? item.id : nil }
        .animation(.easeInOut(duration: 0.18), value: hovered)
    }
}
