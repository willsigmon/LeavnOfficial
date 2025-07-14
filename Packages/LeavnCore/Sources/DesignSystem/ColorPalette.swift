import SwiftUI

// MARK: - Enhanced Color Palette
public extension LeavnTheme.Colors {
    
    // MARK: - Dynamic Colors
    static func dynamicBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.background : Light.background
    }
    
    static func dynamicText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.primaryText : Light.primaryText
    }
    
    static func dynamicSecondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.secondaryText : Light.secondaryText
    }
    
    static func dynamicSurface(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.surface : Light.surface
    }
    
    static func dynamicSeparator(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Dark.separator : Light.separator
    }
    
    // MARK: - Light Mode Colors
    struct Light {
        // Backgrounds
        static let background = Color(hex: "FFFFFF")
        static let secondaryBackground = Color(hex: "F2F2F7")
        static let tertiaryBackground = Color(hex: "FFFFFF")
        static let groupedBackground = Color(hex: "F2F2F7")
        
        // Surface colors
        static let surface = Color(hex: "FFFFFF")
        static let elevatedSurface = Color(hex: "FFFFFF")
        
        // Text colors
        static let primaryText = Color(hex: "000000")
        static let secondaryText = Color(hex: "3C3C43").opacity(0.6)
        static let tertiaryText = Color(hex: "3C3C43").opacity(0.3)
        static let disabledText = Color(hex: "3C3C43").opacity(0.2)
        
        // Accent variations
        static let accentLight = Color(hex: "E8E0FF")
        static let accentMedium = Color(hex: "A37AEB")
        static let accentDark = Color(hex: "825DC8")
        
        // Semantic colors
        static let success = Color(hex: "34C759")
        static let warning = Color(hex: "FF9500")
        static let error = Color(hex: "FF3B30")
        static let info = Color(hex: "007AFF")
        
        // Special purpose
        static let jesusWords = Color(hex: "DC143C")
        static let separator = Color(hex: "3C3C43").opacity(0.29)
        static let overlay = Color.black.opacity(0.04)
    }
    
    // MARK: - Dark Mode Colors
    struct Dark {
        // Backgrounds
        static let background = Color(hex: "000000")
        static let secondaryBackground = Color(hex: "1C1C1E")
        static let tertiaryBackground = Color(hex: "2C2C2E")
        static let groupedBackground = Color(hex: "000000")
        
        // Surface colors
        static let surface = Color(hex: "1C1C1E")
        static let elevatedSurface = Color(hex: "2C2C2E")
        
        // Text colors
        static let primaryText = Color(hex: "FFFFFF")
        static let secondaryText = Color(hex: "EBEBF5").opacity(0.6)
        static let tertiaryText = Color(hex: "EBEBF5").opacity(0.3)
        static let disabledText = Color(hex: "EBEBF5").opacity(0.2)
        
        // Accent variations
        static let accentLight = Color(hex: "C7B4F2")
        static let accentMedium = Color(hex: "A37AEB")
        static let accentDark = Color(hex: "7A4FC1")
        
        // Semantic colors
        static let success = Color(hex: "32D74B")
        static let warning = Color(hex: "FF9F0A")
        static let error = Color(hex: "FF453A")
        static let info = Color(hex: "0A84FF")
        
        // Special purpose
        static let jesusWords = Color(hex: "FF6B6B")
        static let separator = Color(hex: "545458").opacity(0.65)
        static let overlay = Color.white.opacity(0.04)
    }
    
    // MARK: - Adaptive Colors
    /// Returns appropriate color based on color scheme
    static func adaptive(
        light lightColor: Color,
        dark darkColor: Color,
        for colorScheme: ColorScheme
    ) -> Color {
        colorScheme == .dark ? darkColor : lightColor
    }
    
    // MARK: - Gradient Definitions
    struct Gradients {
        static func primary(for colorScheme: ColorScheme) -> LinearGradient {
            let colors = colorScheme == .dark ?
                [Dark.accentLight, Dark.accentMedium] :
                [Light.accentMedium, Light.accentDark]
            
            return LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        
        static func secondary(for colorScheme: ColorScheme) -> LinearGradient {
            let colors = colorScheme == .dark ?
                [Color(hex: "434343"), Color(hex: "2C2C2C")] :
                [Color(hex: "F5F5F5"), Color(hex: "E5E5E5")]
            
            return LinearGradient(
                colors: colors,
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        static func vibrant(for colorScheme: ColorScheme) -> LinearGradient {
            let colors = colorScheme == .dark ?
                [Color(hex: "FF6B6B"), Color(hex: "4ECDC4"), Color(hex: "45B7D1")] :
                [Color(hex: "667EEA"), Color(hex: "764BA2"), Color(hex: "F093FB")]
            
            return LinearGradient(
                colors: colors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Color Scheme Environment
public struct ColorSchemeAware: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    public func body(content: Content) -> some View {
        content
            .environment(\.colorScheme, colorScheme)
    }
}

// MARK: - Convenience Extensions
public extension Color {
    static var adaptiveBackground: Color {
        Color(.systemBackground)
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    static var adaptiveLabel: Color {
        Color(.label)
    }
    
    static var adaptiveSecondaryLabel: Color {
        Color(.secondaryLabel)
    }
    
    static var adaptiveSeparator: Color {
        Color(.separator)
    }
    
    static var adaptiveFill: Color {
        Color(.systemFill)
    }
}

// MARK: - Bible-Specific Colors
public extension LeavnTheme.Colors {
    struct Bible {
        // Text highlighting colors
        static func highlightColor(
            for type: HighlightType,
            in colorScheme: ColorScheme
        ) -> Color {
            switch type {
            case .yellow:
                return colorScheme == .dark ?
                    Color(hex: "FFD60A").opacity(0.3) :
                    Color(hex: "FFCC00").opacity(0.3)
            case .green:
                return colorScheme == .dark ?
                    Color(hex: "32D74B").opacity(0.3) :
                    Color(hex: "34C759").opacity(0.3)
            case .blue:
                return colorScheme == .dark ?
                    Color(hex: "0A84FF").opacity(0.3) :
                    Color(hex: "007AFF").opacity(0.3)
            case .pink:
                return colorScheme == .dark ?
                    Color(hex: "FF375F").opacity(0.3) :
                    Color(hex: "FF3B30").opacity(0.3)
            case .purple:
                return colorScheme == .dark ?
                    Color(hex: "BF5AF2").opacity(0.3) :
                    Color(hex: "AF52DE").opacity(0.3)
            }
        }
        
        enum HighlightType {
            case yellow, green, blue, pink, purple
        }
    }
}

// MARK: - Preview Helpers
#if DEBUG
struct ColorPalettePreview: PreviewProvider {
    static var previews: some View {
        VStack {
            // Light mode preview
            VStack(spacing: 10) {
                Text("Light Mode").font(.headline)
                HStack {
                    ColorSwatch(color: LeavnTheme.Colors.Light.background, name: "Background")
                    ColorSwatch(color: LeavnTheme.Colors.Light.accentMedium, name: "Accent")
                    ColorSwatch(color: LeavnTheme.Colors.Light.success, name: "Success")
                }
            }
            .padding()
            .environment(\.colorScheme, .light)
            
            // Dark mode preview
            VStack(spacing: 10) {
                Text("Dark Mode").font(.headline)
                HStack {
                    ColorSwatch(color: LeavnTheme.Colors.Dark.background, name: "Background")
                    ColorSwatch(color: LeavnTheme.Colors.Dark.accentMedium, name: "Accent")
                    ColorSwatch(color: LeavnTheme.Colors.Dark.success, name: "Success")
                }
            }
            .padding()
            .background(Color.black)
            .environment(\.colorScheme, .dark)
        }
    }
}

struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
            Text(name)
                .font(.caption)
        }
    }
}
#endif
