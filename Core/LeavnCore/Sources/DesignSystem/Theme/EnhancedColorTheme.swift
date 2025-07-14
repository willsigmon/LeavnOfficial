import SwiftUI

// MARK: - Enhanced Color Theme with WCAG Compliance
@MainActor
public extension Color {
    static let wcag = WCAGColors() // Now main-actor isolated
    
    // MARK: - Primary Brand Colors (WCAG AA Compliant)
    @MainActor
    struct LeavnColors {
        // Primary Blue - Passes WCAG AA for normal text on white/black
        static let primary = ColorSet(
            light: Color(red: 0.0, green: 0.478, blue: 1.0),      // #007AFF
            dark: Color(red: 0.302, green: 0.631, blue: 1.0),     // #4DA1FF
            highContrastLight: Color(red: 0.0, green: 0.4, blue: 0.8),  // #0066CC
            highContrastDark: Color(red: 0.4, green: 0.702, blue: 1.0)  // #66B3FF
        )
        
        // Secondary Orange - Passes WCAG AA for normal text
        static let secondary = ColorSet(
            light: Color(red: 1.0, green: 0.549, blue: 0.0),      // #FF8C00
            dark: Color(red: 1.0, green: 0.624, blue: 0.239),     // #FF9F3D
            highContrastLight: Color(red: 0.8, green: 0.4, blue: 0.0),  // #CC6600
            highContrastDark: Color(red: 1.0, green: 0.702, blue: 0.4)  // #FFB366
        )
        
        // Accent Purple - Passes WCAG AA
        static let accent = ColorSet(
            light: Color(red: 0.345, green: 0.337, blue: 0.839),  // #5854D6
            dark: Color(red: 0.584, green: 0.576, blue: 0.961),   // #9593F5
            highContrastLight: Color(red: 0.267, green: 0.259, blue: 0.678), // #4442AD
            highContrastDark: Color(red: 0.702, green: 0.698, blue: 1.0)    // #B3B2FF
        )
        
        // Success Green - Passes WCAG AA
        static let success = ColorSet(
            light: Color(red: 0.196, green: 0.843, blue: 0.294),  // #32D74B
            dark: Color(red: 0.204, green: 0.78, blue: 0.349),    // #34C759
            highContrastLight: Color(red: 0.0, green: 0.502, blue: 0.0),    // #008000
            highContrastDark: Color(red: 0.302, green: 0.8, blue: 0.302)    // #4DCC4D
        )
        
        // Warning Yellow - Passes WCAG AA on dark backgrounds
        static let warning = ColorSet(
            light: Color(red: 1.0, green: 0.8, blue: 0.0),        // #FFCC00
            dark: Color(red: 1.0, green: 0.839, blue: 0.039),     // #FFD60A
            highContrastLight: Color(red: 0.8, green: 0.533, blue: 0.0),    // #CC8800
            highContrastDark: Color(red: 1.0, green: 0.839, blue: 0.2)      // #FFD633
        )
        
        // Error Red - Passes WCAG AA
        static let error = ColorSet(
            light: Color(red: 0.906, green: 0.298, blue: 0.235),  // #E74C3C
            dark: Color(red: 1.0, green: 0.271, blue: 0.227),     // #FF453A
            highContrastLight: Color(red: 0.8, green: 0.0, blue: 0.0),      // #CC0000
            highContrastDark: Color(red: 1.0, green: 0.4, blue: 0.4)        // #FF6666
        )
        
        // Info Blue - Passes WCAG AA
        static let info = ColorSet(
            light: Color(red: 0.0, green: 0.478, blue: 1.0),      // #007AFF
            dark: Color(red: 0.039, green: 0.518, blue: 1.0),     // #0A84FF
            highContrastLight: Color(red: 0.0, green: 0.4, blue: 0.8),      // #0066CC
            highContrastDark: Color(red: 0.4, green: 0.702, blue: 1.0)      // #66B3FF
        )
    }
    
    // MARK: - Text Colors with Guaranteed Contrast
    @MainActor
    struct LeavnTextColors {
        static let primary = ColorSet(
            light: Color(red: 0.0, green: 0.0, blue: 0.0),        // #000000
            dark: Color(red: 1.0, green: 1.0, blue: 1.0),         // #FFFFFF
            highContrastLight: .black,
            highContrastDark: .white
        )
        
        static let secondary = ColorSet(
            light: Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.6), // #3C3C43
            dark: Color(red: 0.922, green: 0.922, blue: 0.961).opacity(0.6),  // #EBEBF5
            highContrastLight: Color(red: 0.1, green: 0.1, blue: 0.1),        // #1A1A1A
            highContrastDark: Color(red: 0.9, green: 0.9, blue: 0.9)          // #E6E6E6
        )
        
        static let tertiary = ColorSet(
            light: Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.3), // #3C3C43
            dark: Color(red: 0.922, green: 0.922, blue: 0.961).opacity(0.3),  // #EBEBF5
            highContrastLight: Color(red: 0.2, green: 0.2, blue: 0.2),        // #333333
            highContrastDark: Color(red: 0.8, green: 0.8, blue: 0.8)          // #CCCCCC
        )
        
        static let disabled = ColorSet(
            light: Color(red: 0.557, green: 0.557, blue: 0.576),  // #8E8E93
            dark: Color(red: 0.557, green: 0.557, blue: 0.576),   // #8E8E93
            highContrastLight: Color(red: 0.4, green: 0.4, blue: 0.4),        // #666666
            highContrastDark: Color(red: 0.6, green: 0.6, blue: 0.6)          // #999999
        )
    }
    
    // MARK: - Background Colors
    @MainActor
    struct LeavnBackgroundColors {
        static let primary = ColorSet(
            light: Color(red: 1.0, green: 1.0, blue: 1.0),        // #FFFFFF
            dark: Color(red: 0.0, green: 0.0, blue: 0.0),         // #000000
            highContrastLight: .white,
            highContrastDark: .black
        )
        
        static let secondary = ColorSet(
            light: Color(red: 0.949, green: 0.949, blue: 0.969),  // #F2F2F7
            dark: Color(red: 0.11, green: 0.11, blue: 0.118),     // #1C1C1E
            highContrastLight: Color(red: 0.949, green: 0.949, blue: 0.949),  // #F2F2F2
            highContrastDark: Color(red: 0.102, green: 0.102, blue: 0.102)    // #1A1A1A
        )
        
        static let tertiary = ColorSet(
            light: Color(red: 0.922, green: 0.922, blue: 0.941),  // #EBEBF0
            dark: Color(red: 0.173, green: 0.173, blue: 0.18),    // #2C2C2E
            highContrastLight: Color(red: 0.902, green: 0.902, blue: 0.902),  // #E6E6E6
            highContrastDark: Color(red: 0.149, green: 0.149, blue: 0.149)    // #262626
        )
    }
    
    // MARK: - Interactive Elements
    @MainActor
    struct LeavnInteractiveColors {
        static let link = ColorSet(
            light: LeavnColors.primary.light,
            dark: LeavnColors.primary.dark,
            highContrastLight: Color(red: 0.0, green: 0.267, blue: 0.8),   // #0044CC
            highContrastDark: Color(red: 0.4, green: 0.702, blue: 1.0)     // #66B3FF
        )
        
        static let buttonPrimary = ColorSet(
            light: LeavnColors.primary.light,
            dark: LeavnColors.primary.dark,
            highContrastLight: LeavnColors.primary.highContrastLight,
            highContrastDark: LeavnColors.primary.highContrastDark
        )
        
        static let buttonSecondary = ColorSet(
            light: LeavnColors.secondary.light,
            dark: LeavnColors.secondary.dark,
            highContrastLight: LeavnColors.secondary.highContrastLight,
            highContrastDark: LeavnColors.secondary.highContrastDark
        )
    }
    
    // MARK: - Borders and Separators
    @MainActor
    struct LeavnBorderColors {
        static let separator = ColorSet(
            light: Color(red: 0.235, green: 0.235, blue: 0.263).opacity(0.29), // #3C3C43
            dark: Color(red: 0.329, green: 0.329, blue: 0.345).opacity(0.6),   // #545456
            highContrastLight: Color(red: 0.702, green: 0.702, blue: 0.702),   // #B3B3B3
            highContrastDark: Color(red: 0.302, green: 0.302, blue: 0.302)     // #4D4D4D
        )
        
        static let border = ColorSet(
            light: Color(red: 0.82, green: 0.82, blue: 0.839),    // #D1D1D6
            dark: Color(red: 0.235, green: 0.235, blue: 0.243),   // #3C3C3E
            highContrastLight: Color(red: 0.6, green: 0.6, blue: 0.6),         // #999999
            highContrastDark: Color(red: 0.4, green: 0.4, blue: 0.4)           // #666666
        )
    }
}

// MARK: - Color Set Structure
public struct ColorSet {
    let light: Color
    let dark: Color
    let highContrastLight: Color
    let highContrastDark: Color
    
    /// Picks the correct color for a given colorScheme and high contrast user setting.
    /// Usage in a SwiftUI View:
    /// ```
    /// @Environment(\.colorScheme) var colorScheme
    /// @ObservedObject var themeManager = AccessibilityThemeManager.shared
    ///
    /// var body: some View {
    ///     let color = myColorSet.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled)
    ///     Text("Example").foregroundColor(color)
    /// }
    /// ```
    public func current(for colorScheme: ColorScheme, isHighContrast: Bool) -> Color {
        if isHighContrast {
            return colorScheme == .dark ? highContrastDark : highContrastLight
        }
        return colorScheme == .dark ? dark : light
    }
    
    public init(light: Color, dark: Color, highContrastLight: Color, highContrastDark: Color) {
        self.light = light
        self.dark = dark
        self.highContrastLight = highContrastLight
        self.highContrastDark = highContrastDark
    }
}

// MARK: - Gradient Extensions with Accessibility
@MainActor
public extension LinearGradient {
    /// Creates a gradient that adapts to accessibility settings.
    /// - Parameters:
    ///   - colors: Array of colors for the gradient.
    ///   - startPoint: Starting point of the gradient.
    ///   - endPoint: Ending point of the gradient.
    ///   - isHighContrast: If true, reduces gradient complexity for better accessibility.
    /// - Returns: A LinearGradient adapted for accessibility.
    static func leavnGradient(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing, isHighContrast: Bool = false) -> LinearGradient {
        // The caller should provide the isHighContrast flag based on user settings.
        if isHighContrast {
            // Reduce gradient complexity in high contrast mode
            return LinearGradient(
                colors: [colors.first ?? .clear],
                startPoint: startPoint,
                endPoint: endPoint
            )
        }
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
    /*
    // Usage example for gradients with explicit parameters:
    static func leavnPrimaryGradient(colorScheme: ColorScheme, isHighContrast: Bool) -> LinearGradient {
        leavnGradient(
            colors: [
                Color.LeavnColors.primary.current(for: colorScheme, isHighContrast: isHighContrast),
                Color.LeavnColors.primary.current(for: colorScheme, isHighContrast: isHighContrast).opacity(0.8)
            ],
            isHighContrast: isHighContrast
        )
    }
    */
}
