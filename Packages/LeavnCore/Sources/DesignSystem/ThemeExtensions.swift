import SwiftUI

// MARK: - Dynamic Color System
public extension LeavnTheme.Colors {
    
    // MARK: - Semantic Colors for Light/Dark Mode
    struct Dynamic {
        @Environment(\.colorScheme) private var colorScheme
        
        // Background colors that adapt to color scheme
        public static var background: Color {
            Color(.systemBackground)
        }
        
        public static var secondaryBackground: Color {
            Color(.secondarySystemBackground)
        }
        
        public static var tertiaryBackground: Color {
            Color(.tertiarySystemBackground)
        }
        
        // Grouped backgrounds
        public static var groupedBackground: Color {
            Color(.systemGroupedBackground)
        }
        
        public static var secondaryGroupedBackground: Color {
            Color(.secondarySystemGroupedBackground)
        }
        
        // Fill colors
        public static var fill: Color {
            Color(.systemFill)
        }
        
        public static var secondaryFill: Color {
            Color(.secondarySystemFill)
        }
        
        public static var tertiaryFill: Color {
            Color(.tertiarySystemFill)
        }
        
        public static var quaternaryFill: Color {
            Color(.quaternarySystemFill)
        }
        
        // Text colors
        public static var label: Color {
            Color(.label)
        }
        
        public static var secondaryLabel: Color {
            Color(.secondaryLabel)
        }
        
        public static var tertiaryLabel: Color {
            Color(.tertiaryLabel)
        }
        
        public static var quaternaryLabel: Color {
            Color(.quaternaryLabel)
        }
        
        // Separator
        public static var separator: Color {
            Color(.separator)
        }
        
        public static var opaqueSeparator: Color {
            Color(.opaqueSeparator)
        }
        
        // Custom semantic colors with light/dark variants
        public static func adaptiveAccent(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? accentDark : accent
        }
        
        public static func cardBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ? 
                Color(red: 0.11, green: 0.11, blue: 0.118) : 
                Color(red: 0.949, green: 0.949, blue: 0.969)
        }
        
        public static func elevatedBackground(for colorScheme: ColorScheme) -> Color {
            colorScheme == .dark ?
                Color(red: 0.16, green: 0.16, blue: 0.18) :
                Color.white
        }
    }
}

// MARK: - Material Effects
public extension View {
    /// Applies an adaptive material background
    func adaptiveMaterial(
        style: Material = .regular,
        cornerRadius: CGFloat = 12
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(style)
            )
    }
    
    /// Applies theme-aware card styling
    func themeCard(
        cornerRadius: CGFloat = 16,
        shadow: Bool = true
    ) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: shadow ? Color.black.opacity(0.1) : .clear,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }
}

// MARK: - Accessibility & Contrast
public struct AccessibilityColors {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    @Environment(\.accessibilityInvertColors) private var invertColors
    
    /// Returns an appropriate background considering accessibility settings
    public static func adaptiveBackground(
        base: Color,
        reduceTransparency: Bool
    ) -> Color {
        reduceTransparency ? base.opacity(1.0) : base.opacity(0.9)
    }
    
    /// High contrast text color
    public static func highContrastText(for background: Color) -> Color {
        // This is a simplified version - in production, you'd calculate actual contrast ratios
        return Color(.label)
    }
}

// MARK: - Theme-Aware Components
public struct ThemedButton: View {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    public enum ButtonStyle {
        case primary
        case secondary
        case destructive
        case ghost
    }
    
    public init(
        _ title: String,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(foregroundColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(backgroundView)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 12)
                .fill(LeavnTheme.Colors.primaryGradient)
        case .secondary:
            RoundedRectangle(cornerRadius: 12)
                .stroke(LeavnTheme.Colors.accent, lineWidth: 2)
        case .destructive:
            RoundedRectangle(cornerRadius: 12)
                .fill(LeavnTheme.Colors.error)
        case .ghost:
            Color.clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return LeavnTheme.Colors.accent
        case .ghost:
            return .primary
        }
    }
}

// MARK: - Dark Mode Preview Helper
public struct ThemePreview<Content: View>: View {
    let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            content()
                .environment(\.colorScheme, .light)
                .previewDisplayName("Light Mode")
            
            content()
                .environment(\.colorScheme, .dark)
                .previewDisplayName("Dark Mode")
        }
    }
}

// MARK: - Conditional Theme Modifiers
public extension View {
    @ViewBuilder
    func themeAware<T: View>(
        light lightContent: @escaping (Self) -> T,
        dark darkContent: @escaping (Self) -> T
    ) -> some View {
        self.modifier(ThemeAwareModifier<Self, T>(
            lightContent: lightContent,
            darkContent: darkContent
        ))
    }
}

private struct ThemeAwareModifier<C: View, T: View>: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let lightContent: (C) -> T
    let darkContent: (C) -> T
    
    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                // Safe due to modifier usage with Self
                darkContent(content as! C)
            } else {
                // Safe due to modifier usage with Self
                lightContent(content as! C)
            }
        }
    }
}
