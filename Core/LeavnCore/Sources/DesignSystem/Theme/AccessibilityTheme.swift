import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color Extension for Hex Support
// Color hex initializer is now defined in Extensions/Color+Extensions.swift

// MARK: - Accessibility Theme Manager
@MainActor
public class AccessibilityThemeManager: ObservableObject {
    public static let shared = AccessibilityThemeManager()
    
    @Published public var isHighContrastEnabled: Bool = false
    @Published public var colorScheme: SwiftUI.ColorScheme = .light
    @Published public var dynamicTypeSize: DynamicTypeSize = .medium
    @Published public var reduceMotion: Bool = false
    @Published public var increaseContrast: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupAccessibilityObservers()
    }
    
    private func setupAccessibilityObservers() {
        // Observe system accessibility settings
        #if canImport(UIKit) && !os(watchOS)
        NotificationCenter.default.publisher(for: UIAccessibility.darkerSystemColorsStatusDidChangeNotification)
            .sink { _ in
                self.isHighContrastEnabled = UIAccessibility.isDarkerSystemColorsEnabled
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIAccessibility.reduceMotionStatusDidChangeNotification)
            .sink { _ in
                self.reduceMotion = UIAccessibility.isReduceMotionEnabled
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIAccessibility.darkerSystemColorsStatusDidChangeNotification)
            .sink { _ in
                self.increaseContrast = UIAccessibility.isDarkerSystemColorsEnabled
            }
            .store(in: &cancellables)
        #endif
    }
}

// MARK: - WCAG Compliant Color Palette
public struct WCAGColors: Sendable {
    @MainActor
    private var themeManager: AccessibilityThemeManager {
        AccessibilityThemeManager.shared
    }
    
    // MARK: - Primary Colors with WCAG AA Compliance
    @MainActor
    public var primary: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#4DA6FF") : Color( "#0066CC")
        }
        return themeManager.colorScheme == .dark ? Color( "#3399FF") : Color( "#007AFF")
    }
    
    @MainActor
    public var primaryOnBackground: Color {
        // Ensures 4.5:1 contrast ratio for normal text
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#66B3FF") : Color( "#004C99")
        }
        return themeManager.colorScheme == .dark ? Color( "#4DA6FF") : Color( "#0066CC")
    }
    
    // MARK: - Secondary Colors
    @MainActor
    public var secondary: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#FFB366") : Color( "#CC6600")
        }
        return themeManager.colorScheme == .dark ? Color( "#FF9F40") : Color( "#FF8C00")
    }
    
    // MARK: - Semantic Colors
    @MainActor
    public var success: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#4DCC4D") : Color( "#008000")
        }
        return themeManager.colorScheme == .dark ? Color( "#34C759") : Color( "#32A852")
    }
    
    @MainActor
    public var warning: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#FFD633") : Color( "#CC8800")
        }
        return themeManager.colorScheme == .dark ? Color( "#FFCC00") : Color( "#FFA500")
    }
    
    @MainActor
    public var error: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#FF6666") : Color( "#CC0000")
        }
        return themeManager.colorScheme == .dark ? Color( "#FF453A") : Color( "#E74444")
    }
    
    @MainActor
    public var info: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#66B3FF") : Color( "#0066CC")
        }
        return themeManager.colorScheme == .dark ? Color( "#4DA6FF") : Color( "#007AFF")
    }
    
    // MARK: - Text Colors with Proper Contrast
    @MainActor
    public var primaryText: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? .white : .black
        }
        #if canImport(UIKit)
        return Color(UIColor.label)
        #else
        return themeManager.colorScheme == .dark ? .white : .black
        #endif
    }
    
    @MainActor
    public var secondaryText: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#E6E6E6") : Color( "#1A1A1A")
        }
        #if canImport(UIKit)
        return Color(UIColor.secondaryLabel)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
        #endif
    }
    
    @MainActor
    public var tertiaryText: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#CCCCCC") : Color( "#333333")
        }
        #if canImport(UIKit)
        return Color(UIColor.tertiaryLabel)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)
        #endif
    }
    
    @MainActor
    public var disabledText: Color {
        // Ensures 3:1 contrast ratio for disabled elements
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#999999") : Color( "#666666")
        }
        return themeManager.colorScheme == .dark ? Color( "#8E8E93") : Color( "#8E8E93")
    }
    
    // MARK: - Background Colors
    @MainActor
    public var background: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? .black : .white
        }
        #if canImport(UIKit)
        return Color(UIColor.systemBackground)
        #else
        return themeManager.colorScheme == .dark ? .black : .white
        #endif
    }
    
    @MainActor
    public var secondaryBackground: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#1A1A1A") : Color( "#F2F2F2")
        }
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #else
        return themeManager.colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.95)
        #endif
    }
    
    @MainActor
    public var tertiaryBackground: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#262626") : Color( "#E6E6E6")
        }
        #if canImport(UIKit)
        return Color(UIColor.tertiarySystemBackground)
        #else
        return themeManager.colorScheme == .dark ? Color(white: 0.17) : Color(white: 0.92)
        #endif
    }
    
    // MARK: - Interactive Element Colors
    @MainActor
    public var buttonBackground: Color {
        primary
    }
    
    @MainActor
    public var buttonText: Color {
        // Always ensures proper contrast on button backgrounds
        .white
    }
    
    @MainActor
    public var linkColor: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#66B3FF") : Color( "#0044CC")
        }
        return primary
    }
    
    // MARK: - Border and Separator Colors
    @MainActor
    public var separator: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#4D4D4D") : Color( "#B3B3B3")
        }
        #if canImport(UIKit)
        return Color(UIColor.separator)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
        #endif
    }
    
    @MainActor
    public var border: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color( "#666666") : Color( "#999999")
        }
        return themeManager.colorScheme == .dark ? Color( "#3C3C3E") : Color( "#D1D1D6")
    }
}

// MARK: - Dynamic Type Scaling
public struct ScaledFont: ViewModifier, Sendable {
    @Environment(\.sizeCategory) var sizeCategory
    
    let style: Font.TextStyle
    let design: Font.Design
    let weight: Font.Weight
    
    public func body(content: Content) -> some View {
        content
            .font(.system(style, design: design, weight: weight))
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
    }
}

public extension View {
    func scaledFont(_ style: Font.TextStyle, design: Font.Design = .default, weight: Font.Weight = .regular) -> some View {
        modifier(ScaledFont(style: style, design: design, weight: weight))
    }
}

// MARK: - Contrast Checker
public struct ContrastChecker: Sendable {
    public static func checkContrast(foreground: Color, background: Color) -> ContrastResult {
        let fgLuminance = luminance(of: foreground)
        let bgLuminance = luminance(of: background)
        
        let lighter = max(fgLuminance, bgLuminance)
        let darker = min(fgLuminance, bgLuminance)
        
        let contrastRatio = (lighter + 0.05) / (darker + 0.05)
        
        return ContrastResult(
            ratio: contrastRatio,
            passesAA: contrastRatio >= 4.5,
            passesAAA: contrastRatio >= 7.0,
            passesLargeTextAA: contrastRatio >= 3.0,
            passesLargeTextAAA: contrastRatio >= 4.5
        )
    }
    
    private static func luminance(of color: Color) -> Double {
        #if canImport(UIKit)
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Convert to linear RGB
        let linearRed = red <= 0.03928 ? red / 12.92 : pow((red + 0.055) / 1.055, 2.4)
        let linearGreen = green <= 0.03928 ? green / 12.92 : pow((green + 0.055) / 1.055, 2.4)
        let linearBlue = blue <= 0.03928 ? blue / 12.92 : pow((blue + 0.055) / 1.055, 2.4)
        
        // Calculate relative luminance
        return 0.2126 * linearRed + 0.7152 * linearGreen + 0.0722 * linearBlue
        #else
        // Fallback for macOS/other platforms
        // For now, return a default middle value
        return 0.5
        #endif
    }
}

public struct ContrastResult: Sendable {
    public let ratio: Double
    public let passesAA: Bool
    public let passesAAA: Bool
    public let passesLargeTextAA: Bool
    public let passesLargeTextAAA: Bool
    
    public var description: String {
        String(format: "Contrast Ratio: %.2f:1", ratio)
    }
}

// MARK: - High Contrast Mode Support
@MainActor
public struct HighContrastModifier: ViewModifier {
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.accessibilityDifferentiateWithoutColor, themeManager.isHighContrastEnabled)
    }
}

public extension View {
    func supportHighContrast() -> some View {
        modifier(HighContrastModifier())
    }
}

// MARK: - Focus Indicator for Accessibility
@MainActor
public struct AccessibleFocusModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused ? WCAGColors().primary : Color.clear,
                        lineWidth: themeManager.isHighContrastEnabled ? 3 : 2
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
    }
}

public extension View {
    func accessibleFocus() -> some View {
        modifier(AccessibleFocusModifier())
    }
}

// MARK: - Accessibility Label Helper
public struct AccessibilityLabelModifier: ViewModifier {
    let label: String
    let hint: String?
    let traits: AccessibilityTraits
    
    public func body(content: Content) -> some View {
        content
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
}

public extension View {
    func accessibleLabel(_ label: String, hint: String? = nil, traits: AccessibilityTraits = []) -> some View {
        modifier(AccessibilityLabelModifier(label: label, hint: hint, traits: traits))
    }
}
