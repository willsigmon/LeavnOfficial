import Foundation
import SwiftUI

// MARK: - Design System
@MainActor
public struct DesignSystem {
    public static let shared = DesignSystem()
    
    private init() {}
    
    public let colors = Colors()
    public let typography = Typography()
    public let spacing = Spacing()
    public let cornerRadius = CornerRadius()
    public let shadows = Shadows()
    public let animations = Animations()
    public let accessibility = AccessibilityThemeManager.shared
    public let wcagColors = WCAGColors()
}

// MARK: - Colors
public struct Colors {
    // Use WCAG compliant color sets
    public var primary: Color { Color.LeavnColors.primary.current }
    public var primaryLight: Color { Color.LeavnColors.primary.light }
    public var primaryDark: Color { Color.LeavnColors.primary.dark }
    
    // Secondary Colors
    public var secondary: Color { Color.LeavnColors.secondary.current }
    public var secondaryLight: Color { Color.LeavnColors.secondary.light }
    public var secondaryDark: Color { Color.LeavnColors.secondary.dark }
    
    // Semantic Colors with WCAG compliance
    public var success: Color { Color.LeavnColors.success.current }
    public var warning: Color { Color.LeavnColors.warning.current }
    public var error: Color { Color.LeavnColors.error.current }
    public var info: Color { Color.LeavnColors.info.current }
    
    // Neutral Colors with proper contrast
    public var background: Color { Color.LeavnBackgroundColors.primary.current }
    public var secondaryBackground: Color { Color.LeavnBackgroundColors.secondary.current }
    public var tertiaryBackground: Color { Color.LeavnBackgroundColors.tertiary.current }
    
    public var label: Color { Color.LeavnTextColors.primary.current }
    public var secondaryLabel: Color { Color.LeavnTextColors.secondary.current }
    public var tertiaryLabel: Color { Color.LeavnTextColors.tertiary.current }
    public var quaternaryLabel: Color { Color.LeavnTextColors.tertiary.current }
    
    public var separator: Color { Color.LeavnBorderColors.separator.current }
    public var opaqueSeparator: Color { Color.LeavnBorderColors.border.current }
}

// MARK: - Typography
public struct Typography {
    // Display - Using Dynamic Type
    public let displayLarge = Font.system(.largeTitle, design: .rounded, weight: .regular)
    public let displayMedium = Font.system(.title, design: .rounded, weight: .regular)
    public let displaySmall = Font.system(.title2, design: .rounded, weight: .regular)
    
    // Headline - Using Dynamic Type
    public let headlineLarge = Font.system(.title2, design: .rounded, weight: .semibold)
    public let headlineMedium = Font.system(.title3, design: .rounded, weight: .semibold)
    public let headlineSmall = Font.system(.headline, design: .rounded, weight: .semibold)
    
    // Title - Using Dynamic Type
    public let titleLarge = Font.system(.title3, design: .default, weight: .medium)
    public let titleMedium = Font.system(.headline, design: .default, weight: .medium)
    public let titleSmall = Font.system(.subheadline, design: .default, weight: .medium)
    
    // Body - Using Dynamic Type
    public let bodyLarge = Font.system(.body, design: .default, weight: .regular)
    public let bodyMedium = Font.system(.callout, design: .default, weight: .regular)
    public let bodySmall = Font.system(.footnote, design: .default, weight: .regular)
    
    // Label - Using Dynamic Type
    public let labelLarge = Font.system(.subheadline, design: .default, weight: .medium)
    public let labelMedium = Font.system(.footnote, design: .default, weight: .medium)
    public let labelSmall = Font.system(.caption, design: .default, weight: .medium)
}

// MARK: - Spacing
public struct Spacing {
    public let xxs: CGFloat = 2
    public let xs: CGFloat = 4
    public let s: CGFloat = 8
    public let m: CGFloat = 16
    public let l: CGFloat = 24
    public let xl: CGFloat = 32
    public let xxl: CGFloat = 48
    public let xxxl: CGFloat = 64
}

// MARK: - Corner Radius
public struct CornerRadius {
    public let none: CGFloat = 0
    public let xs: CGFloat = 4
    public let s: CGFloat = 8
    public let m: CGFloat = 12
    public let l: CGFloat = 16
    public let xl: CGFloat = 24
    public let full: CGFloat = .infinity
}

// MARK: - Shadows
public struct Shadows {
    // Reduced shadows for high contrast mode
    public var elevation1: Shadow {
        AccessibilityThemeManager.shared.isHighContrastEnabled
            ? Shadow(color: .clear, radius: 0, y: 0)
            : Shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
    
    public var elevation2: Shadow {
        AccessibilityThemeManager.shared.isHighContrastEnabled
            ? Shadow(color: .clear, radius: 0, y: 0)
            : Shadow(color: .black.opacity(0.08), radius: 4, y: 2)
    }
    
    public var elevation3: Shadow {
        AccessibilityThemeManager.shared.isHighContrastEnabled
            ? Shadow(color: .clear, radius: 0, y: 0)
            : Shadow(color: .black.opacity(0.10), radius: 8, y: 4)
    }
    
    public var elevation4: Shadow {
        AccessibilityThemeManager.shared.isHighContrastEnabled
            ? Shadow(color: .clear, radius: 0, y: 0)
            : Shadow(color: .black.opacity(0.12), radius: 12, y: 6)
    }
    
    public var elevation5: Shadow {
        AccessibilityThemeManager.shared.isHighContrastEnabled
            ? Shadow(color: .clear, radius: 0, y: 0)
            : Shadow(color: .black.opacity(0.14), radius: 16, y: 8)
    }
}

public struct Shadow {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - Animations
public struct Animations {
    // Respect reduce motion preference
    public var fast: Animation? {
        AccessibilityThemeManager.shared.reduceMotion ? nil : Animation.easeInOut(duration: 0.2)
    }
    
    public var medium: Animation? {
        AccessibilityThemeManager.shared.reduceMotion ? nil : Animation.easeInOut(duration: 0.3)
    }
    
    public var slow: Animation? {
        AccessibilityThemeManager.shared.reduceMotion ? nil : Animation.easeInOut(duration: 0.5)
    }
    
    public var spring: Animation? {
        AccessibilityThemeManager.shared.reduceMotion ? nil : Animation.spring(response: 0.4, dampingFraction: 0.8)
    }
    
    public var bouncy: Animation? {
        AccessibilityThemeManager.shared.reduceMotion ? nil : Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
}

// MARK: - Design System Extensions
public extension View {
    var ds: DesignSystem {
        DesignSystem.shared
    }
}

// MARK: - Legacy Support (for backward compatibility)
public extension Color {
    static let leavnPrimary = DesignSystem.shared.colors.primary
    static let leavnSecondary = DesignSystem.shared.colors.secondary
    static let leavnBackground = DesignSystem.shared.colors.background
    static let leavnText = DesignSystem.shared.colors.label
}

public enum LeavnFont {
    case largeTitle
    case title
    case headline
    case body
    case caption
    
    public var font: Font {
        switch self {
        case .largeTitle: return DesignSystem.shared.typography.displayLarge
        case .title: return DesignSystem.shared.typography.titleLarge
        case .headline: return DesignSystem.shared.typography.headlineMedium
        case .body: return DesignSystem.shared.typography.bodyMedium
        case .caption: return DesignSystem.shared.typography.labelSmall
        }
    }
}

public enum LeavnSpacing {
    public static let xxSmall: CGFloat = DesignSystem.shared.spacing.xxs
    public static let xSmall: CGFloat = DesignSystem.shared.spacing.xs
    public static let small: CGFloat = DesignSystem.shared.spacing.s
    public static let medium: CGFloat = DesignSystem.shared.spacing.m
    public static let large: CGFloat = DesignSystem.shared.spacing.l
    public static let xLarge: CGFloat = DesignSystem.shared.spacing.xl
    public static let xxLarge: CGFloat = DesignSystem.shared.spacing.xxl
}

// MARK: - View Modifiers
public struct LeavnCardStyle: ViewModifier {
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .background(DesignSystem.shared.colors.background)
            .cornerRadius(DesignSystem.shared.cornerRadius.m)
            .shadow(
                color: DesignSystem.shared.shadows.elevation2.color,
                radius: DesignSystem.shared.shadows.elevation2.radius,
                x: DesignSystem.shared.shadows.elevation2.x,
                y: DesignSystem.shared.shadows.elevation2.y
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.shared.cornerRadius.m)
                    .stroke(
                        themeManager.isHighContrastEnabled ? DesignSystem.shared.colors.separator : Color.clear,
                        lineWidth: themeManager.isHighContrastEnabled ? 1 : 0
                    )
            )
    }
}

public extension View {
    func leavnCard() -> some View {
        modifier(LeavnCardStyle())
    }
}