import SwiftUI
import Combine
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Accessibility Theme Manager
@MainActor
public class AccessibilityThemeManager: ObservableObject {
    public static let shared = AccessibilityThemeManager()
    
    @Published public var isHighContrastEnabled: Bool = false
    @Published public var colorScheme: ColorScheme = .light
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
public struct WCAGColors {
    private let themeManager = AccessibilityThemeManager.shared
    
    // MARK: - Primary Colors with WCAG AA Compliance
    public var primary: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#4DA6FF") : Color(hex: "#0066CC")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#3399FF") : Color(hex: "#007AFF")
    }
    
    public var primaryOnBackground: Color {
        // Ensures 4.5:1 contrast ratio for normal text
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#66B3FF") : Color(hex: "#004C99")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#4DA6FF") : Color(hex: "#0066CC")
    }
    
    // MARK: - Secondary Colors
    public var secondary: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#FFB366") : Color(hex: "#CC6600")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#FF9F40") : Color(hex: "#FF8C00")
    }
    
    // MARK: - Semantic Colors
    public var success: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#4DCC4D") : Color(hex: "#008000")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#34C759") : Color(hex: "#32A852")
    }
    
    public var warning: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#FFD633") : Color(hex: "#CC8800")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#FFCC00") : Color(hex: "#FFA500")
    }
    
    public var error: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#FF6666") : Color(hex: "#CC0000")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#FF453A") : Color(hex: "#E74444")
    }
    
    public var info: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#66B3FF") : Color(hex: "#0066CC")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#4DA6FF") : Color(hex: "#007AFF")
    }
    
    // MARK: - Text Colors with Proper Contrast
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
    
    public var secondaryText: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#E6E6E6") : Color(hex: "#1A1A1A")
        }
        #if canImport(UIKit)
        return Color(UIColor.secondaryLabel)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.6) : Color.black.opacity(0.6)
        #endif
    }
    
    public var tertiaryText: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#CCCCCC") : Color(hex: "#333333")
        }
        #if canImport(UIKit)
        return Color(UIColor.tertiaryLabel)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.3) : Color.black.opacity(0.3)
        #endif
    }
    
    public var disabledText: Color {
        // Ensures 3:1 contrast ratio for disabled elements
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#999999") : Color(hex: "#666666")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#8E8E93") : Color(hex: "#8E8E93")
    }
    
    // MARK: - Background Colors
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
    
    public var secondaryBackground: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#1A1A1A") : Color(hex: "#F2F2F2")
        }
        #if canImport(UIKit)
        return Color(UIColor.secondarySystemBackground)
        #else
        return themeManager.colorScheme == .dark ? Color(white: 0.11) : Color(white: 0.95)
        #endif
    }
    
    public var tertiaryBackground: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#262626") : Color(hex: "#E6E6E6")
        }
        #if canImport(UIKit)
        return Color(UIColor.tertiarySystemBackground)
        #else
        return themeManager.colorScheme == .dark ? Color(white: 0.17) : Color(white: 0.92)
        #endif
    }
    
    // MARK: - Interactive Element Colors
    public var buttonBackground: Color {
        primary
    }
    
    public var buttonText: Color {
        // Always ensures proper contrast on button backgrounds
        .white
    }
    
    public var linkColor: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#66B3FF") : Color(hex: "#0044CC")
        }
        return primary
    }
    
    // MARK: - Border and Separator Colors
    public var separator: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#4D4D4D") : Color(hex: "#B3B3B3")
        }
        #if canImport(UIKit)
        return Color(UIColor.separator)
        #else
        return themeManager.colorScheme == .dark ? Color.white.opacity(0.2) : Color.black.opacity(0.2)
        #endif
    }
    
    public var border: Color {
        if themeManager.isHighContrastEnabled {
            return themeManager.colorScheme == .dark ? Color(hex: "#666666") : Color(hex: "#999999")
        }
        return themeManager.colorScheme == .dark ? Color(hex: "#3C3C3E") : Color(hex: "#D1D1D6")
    }
}

// MARK: - Dynamic Type Scaling
public struct ScaledFont: ViewModifier {
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
public struct ContrastChecker {
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

public struct ContrastResult {
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
public struct HighContrastModifier: ViewModifier {
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.colorSchemeContrast, 
                         themeManager.isHighContrastEnabled ? .increased : .standard)
    }
}

public extension View {
    func supportHighContrast() -> some View {
        modifier(HighContrastModifier())
    }
}

// MARK: - Focus Indicator for Accessibility
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