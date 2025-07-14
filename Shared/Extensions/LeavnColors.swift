import SwiftUI

// MARK: - Color System
public struct LeavnColors {
    public static let primary = ColorSet(
        light: Color(red: 0.0, green: 0.478, blue: 1.0),
        dark: Color(red: 0.1, green: 0.6, blue: 1.0)
    )
    
    public static let secondary = ColorSet(
        light: Color(red: 0.235, green: 0.235, blue: 0.263),
        dark: Color(red: 0.9, green: 0.9, blue: 0.9)
    )
    
    public static let accent = ColorSet(
        light: Color(red: 1.0, green: 0.624, blue: 0.039),
        dark: Color(red: 1.0, green: 0.7, blue: 0.2)
    )
    
    public static let success = ColorSet(
        light: Color(red: 0.2, green: 0.78, blue: 0.35),
        dark: Color(red: 0.3, green: 0.85, blue: 0.45)
    )
    
    public static let warning = ColorSet(
        light: Color(red: 1.0, green: 0.8, blue: 0.0),
        dark: Color(red: 1.0, green: 0.9, blue: 0.2)
    )
    
    public static let error = ColorSet(
        light: Color(red: 0.91, green: 0.26, blue: 0.21),
        dark: Color(red: 1.0, green: 0.4, blue: 0.4)
    )
    
    public static let info = ColorSet(
        light: Color(red: 0.0, green: 0.478, blue: 1.0),
        dark: Color(red: 0.2, green: 0.6, blue: 1.0)
    )
}

public struct LeavnBackgroundColors {
    public static let primary = ColorSet(
        light: Color(UIColor.systemBackground),
        dark: Color(UIColor.systemBackground)
    )
    
    public static let secondary = ColorSet(
        light: Color(UIColor.secondarySystemBackground),
        dark: Color(UIColor.secondarySystemBackground)
    )
    
    public static let tertiary = ColorSet(
        light: Color(UIColor.tertiarySystemBackground),
        dark: Color(UIColor.tertiarySystemBackground)
    )
}

public struct LeavnTextColors {
    public static let primary = ColorSet(
        light: Color(UIColor.label),
        dark: Color(UIColor.label)
    )
    
    public static let secondary = ColorSet(
        light: Color(UIColor.secondaryLabel),
        dark: Color(UIColor.secondaryLabel)
    )
    
    public static let tertiary = ColorSet(
        light: Color(UIColor.tertiaryLabel),
        dark: Color(UIColor.tertiaryLabel)
    )
}

// MARK: - ColorSet
public struct ColorSet {
    let light: Color
    let dark: Color
    let highContrastLight: Color
    let highContrastDark: Color
    
    public init(light: Color, dark: Color, highContrastLight: Color? = nil, highContrastDark: Color? = nil) {
        self.light = light
        self.dark = dark
        self.highContrastLight = highContrastLight ?? light
        self.highContrastDark = highContrastDark ?? dark
    }
    
    public var current: Color {
        return Color.adaptive(light: light, dark: dark)
    }
}

// MARK: - Adaptive Color Helper
public extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color.primary // Simple fallback - in a real app this would use @Environment(\.colorScheme)
    }
}

// MARK: - Gradient Extensions
public extension LinearGradient {
    static func leavnGradient(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> LinearGradient {
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}