import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Accessible Leavn Button
public struct AccessibleLeavnButton: View {
    let title: String
    let style: LeavnButtonStyle
    let size: LeavnButtonSize
    let isLoading: Bool
    let isEnabled: Bool
    let accessibilityLabel: String?
    let accessibilityHint: String?
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @FocusState private var isFocused: Bool
    
    public init(
        _ title: String,
        style: LeavnButtonStyle = .primary,
        size: LeavnButtonSize = .medium,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled && !isLoading {
                // Haptic feedback for button press
                #if canImport(UIKit) && !os(watchOS)
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.prepare()
                impactFeedback.impactOccurred()
                #endif
                
                action()
            }
        }) {
            HStack(spacing: scaledSpacing) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
                        .scaleEffect(progressViewScale)
                        .accessibilityHidden(true)
                }
                
                Text(title)
                    .font(scaledFont)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: scaledHeight)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(scaledCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: scaledCornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .overlay(
                // Focus indicator for keyboard navigation
                RoundedRectangle(cornerRadius: scaledCornerRadius)
                    .stroke(
                        isFocused ? focusIndicatorColor : Color.clear,
                        lineWidth: focusIndicatorWidth
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(themeManager.reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.8), value: isPressed)
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
        .focused($isFocused)
        .accessibilityLabel(accessibilityLabel ?? title)
        .accessibilityHint(accessibilityHint ?? defaultAccessibilityHint)
        .accessibilityAddTraits(accessibilityTraits)
        .accessibilityValue(isLoading ? Text("Loading") : Text(""))
    }
    
    // MARK: - State
    @State private var isPressed = false
    
    // MARK: - Computed Properties
    private var scaledFont: Font {
        switch size {
        case .small:
            return .system(.callout, design: .default, weight: .semibold)
        case .medium:
            return .system(.body, design: .default, weight: .semibold)
        case .large:
            return .system(.title3, design: .default, weight: .semibold)
        }
    }
    
    private var scaledHeight: CGFloat {
        let baseHeight: CGFloat
        switch size {
        case .small:
            baseHeight = 36
        case .medium:
            baseHeight = 44
        case .large:
            baseHeight = 56
        }
        
        // Scale height based on Dynamic Type
        #if canImport(UIKit)
        let scale = UIFontMetrics.default.scaledValue(for: 1.0)
        return baseHeight * max(1.0, min(scale, 1.5))
        #else
        return baseHeight
        #endif
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }
    
    private var scaledCornerRadius: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 12
    }
    
    private var progressViewScale: CGFloat {
        switch size {
        case .small: return 0.7
        case .medium: return 0.8
        case .large: return 0.9
        }
    }
    
    private var foregroundColor: Color {
        let currentColorScheme = colorScheme
        switch style {
        case .primary:
            return .white
        case .secondary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        case .tertiary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        let currentColorScheme = colorScheme
        if !isEnabled {
            return Color.LeavnBackgroundColors.tertiary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        }
        
        switch style {
        case .primary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        case .secondary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled).opacity(0.1)
        case .tertiary:
            return .clear
        case .destructive:
            return Color.LeavnColors.error.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        }
    }
    
    private var borderColor: Color {
        let currentColorScheme = colorScheme
        if !isEnabled {
            return Color.LeavnBorderColors.separator.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        }
        
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled).opacity(0.2)
        case .tertiary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary:
            return 1
        case .tertiary:
            return themeManager.isHighContrastEnabled ? 3 : 2
        }
    }
    
    private var focusIndicatorColor: Color {
        let currentColorScheme = colorScheme
        return themeManager.isHighContrastEnabled
            ? Color.LeavnColors.accent.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
            : Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
    }
    
    private var focusIndicatorWidth: CGFloat {
        themeManager.isHighContrastEnabled ? 4 : 3
    }
    
    private var defaultAccessibilityHint: String {
        if !isEnabled {
            return "Button is disabled"
        }
        if isLoading {
            return "Please wait while loading"
        }
        return "Double tap to activate"
    }
    
    private var accessibilityTraits: AccessibilityTraits {
        var traits: AccessibilityTraits = [.isButton]
        if !isEnabled {
            traits.insert(.isStaticText)
        }
        return traits
    }
}

// MARK: - Button Group for Better Touch Targets
public struct AccessibleButtonGroup<Content: View>: View {
    let spacing: CGFloat
    let content: Content
    
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(spacing: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: scaledSpacing) {
            content
        }
    }
    
    private var scaledSpacing: CGFloat {
        // Increase spacing for larger text sizes
        sizeCategory.isAccessibilityCategory ? spacing * 1.5 : spacing
    }
}

// MARK: - Icon Button with Accessibility
public struct AccessibleIconButton: View {
    let icon: String
    let size: LeavnButtonSize
    let style: LeavnButtonStyle
    let accessibilityLabel: String
    let accessibilityHint: String?
    let action: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @FocusState private var isFocused: Bool
    
    public init(
        icon: String,
        size: LeavnButtonSize = .medium,
        style: LeavnButtonStyle = .secondary,
        accessibilityLabel: String,
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(scaledIconFont)
                .foregroundColor(foregroundColor)
                .frame(width: scaledButtonSize, height: scaledButtonSize)
                .background(backgroundColor)
                .cornerRadius(scaledCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: scaledCornerRadius)
                        .stroke(
                            isFocused ? focusIndicatorColor : Color.clear,
                            lineWidth: focusIndicatorWidth
                        )
                        .animation(.easeInOut(duration: 0.2), value: isFocused)
                )
        }
        .focused($isFocused)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint(accessibilityHint ?? "Double tap to activate")
        .accessibilityAddTraits(.isButton)
    }
    
    private var scaledIconFont: Font {
        switch size {
        case .small:
            return .system(.callout, design: .default, weight: .medium)
        case .medium:
            return .system(.body, design: .default, weight: .medium)
        case .large:
            return .system(.title3, design: .default, weight: .medium)
        }
    }
    
    private var scaledButtonSize: CGFloat {
        let baseSize: CGFloat
        switch size {
        case .small:
            baseSize = 36
        case .medium:
            baseSize = 44
        case .large:
            baseSize = 56
        }
        
        // Ensure minimum touch target of 44x44 points
        #if canImport(UIKit)
        let scale = UIFontMetrics.default.scaledValue(for: 1.0)
        return max(44, baseSize * max(1.0, min(scale, 1.5)))
        #else
        return max(44, baseSize)
        #endif
    }
    
    private var scaledCornerRadius: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 12
    }
    
    private var foregroundColor: Color {
        let currentColorScheme = colorScheme
        switch style {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        let currentColorScheme = colorScheme
        switch style {
        case .primary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        case .secondary:
            return Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled).opacity(0.1)
        case .tertiary:
            return .clear
        case .destructive:
            return Color.LeavnColors.error.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
        }
    }
    
    private var focusIndicatorColor: Color {
        let currentColorScheme = colorScheme
        return themeManager.isHighContrastEnabled
            ? Color.LeavnColors.accent.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
            : Color.LeavnColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
    }
    
    private var focusIndicatorWidth: CGFloat {
        themeManager.isHighContrastEnabled ? 4 : 3
    }
}