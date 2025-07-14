import SwiftUI

// MARK: - Accessible Card Component
public struct AccessibleCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: EdgeInsets?
    let accessibilityLabel: String?
    let accessibilityHint: String?
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @FocusState private var isFocused: Bool
    
    public enum CardStyle {
        case elevated
        case filled
        case outlined
        case interactive
        
        func backgroundColor(colorScheme: ColorScheme, highContrast: Bool) -> Color {
            switch self {
            case .elevated, .interactive:
                return Color.LeavnBackgroundColors.secondary.current
            case .filled:
                return Color.LeavnBackgroundColors.tertiary.current
            case .outlined:
                return Color.LeavnBackgroundColors.primary.current
            }
        }
        
        func borderColor(highContrast: Bool) -> Color {
            switch self {
            case .outlined:
                return Color.LeavnBorderColors.border.current
            default:
                return .clear
            }
        }
        
        func shadowRadius(highContrast: Bool) -> CGFloat {
            if highContrast { return 0 }
            switch self {
            case .elevated: return 4
            case .interactive: return 2
            default: return 0
            }
        }
    }
    
    public init(
        style: CardStyle = .elevated,
        padding: EdgeInsets? = nil,
        accessibilityLabel: String? = nil,
        accessibilityHint: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityHint = accessibilityHint
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(scaledPadding)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .cornerRadius(scaledCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: scaledCornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .overlay(
                // Focus indicator for interactive cards
                RoundedRectangle(cornerRadius: scaledCornerRadius)
                    .stroke(
                        isFocused && style == .interactive ? focusIndicatorColor : Color.clear,
                        lineWidth: focusIndicatorWidth
                    )
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
            .focused($isFocused)
            .accessibilityElement(children: style == .interactive ? .combine : .contain)
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityHint(accessibilityHint ?? "")
            .accessibilityAddTraits(style == .interactive ? [.isButton] : [])
    }
    
    private var scaledPadding: EdgeInsets {
        let basePadding = padding ?? EdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        
        let scale = sizeCategory.isAccessibilityCategory ? 1.5 : 1.0
        
        return EdgeInsets(
            top: basePadding.top * scale,
            leading: basePadding.leading * scale,
            bottom: basePadding.bottom * scale,
            trailing: basePadding.trailing * scale
        )
    }
    
    private var scaledCornerRadius: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 12
    }
    
    private var backgroundColor: Color {
        style.backgroundColor(colorScheme: colorScheme, highContrast: themeManager.isHighContrastEnabled)
    }
    
    private var borderColor: Color {
        style.borderColor(highContrast: themeManager.isHighContrastEnabled)
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .outlined:
            return themeManager.isHighContrastEnabled ? 2 : 1
        default:
            return 0
        }
    }
    
    private var shadowColor: Color {
        themeManager.isHighContrastEnabled ? .clear : Color.black.opacity(0.1)
    }
    
    private var shadowRadius: CGFloat {
        style.shadowRadius(highContrast: themeManager.isHighContrastEnabled)
    }
    
    private var shadowY: CGFloat {
        themeManager.isHighContrastEnabled ? 0 : 2
    }
    
    private var focusIndicatorColor: Color {
        Color.LeavnColors.accent.current
    }
    
    private var focusIndicatorWidth: CGFloat {
        themeManager.isHighContrastEnabled ? 4 : 3
    }
}

// MARK: - Accessible List Item
public struct AccessibleListItem<Content: View>: View {
    let content: Content
    let showDisclosureIndicator: Bool
    let isEnabled: Bool
    let accessibilityLabel: String?
    let action: (() -> Void)?
    
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @State private var isPressed = false
    
    public init(
        showDisclosureIndicator: Bool = true,
        isEnabled: Bool = true,
        accessibilityLabel: String? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showDisclosureIndicator = showDisclosureIndicator
        self.isEnabled = isEnabled
        self.accessibilityLabel = accessibilityLabel
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                action?()
            }
        }) {
            HStack(spacing: scaledSpacing) {
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if showDisclosureIndicator {
                    Image(systemName: "chevron.right")
                        .font(.system(.footnote, design: .default, weight: .semibold))
                        .foregroundColor(Color.LeavnTextColors.tertiary.current)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, scaledPadding)
            .padding(.horizontal, scaledHorizontalPadding)
            .contentShape(Rectangle())
        }
        .buttonStyle(AccessibleListItemButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
        .accessibilityLabel(accessibilityLabel ?? "")
        .accessibilityHint(action != nil ? "Double tap to select" : "")
        .accessibilityAddTraits(action != nil ? [.isButton] : [])
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 12
    }
    
    private var scaledPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 16 : 12
    }
    
    private var scaledHorizontalPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 20 : 16
    }
}

// MARK: - List Item Button Style
private struct AccessibleListItemButtonStyle: ButtonStyle {
    let isEnabled: Bool
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                configuration.isPressed && isEnabled
                    ? Color.LeavnBackgroundColors.tertiary.current
                    : Color.clear
            )
            .animation(
                themeManager.reduceMotion ? nil : .easeInOut(duration: 0.1),
                value: configuration.isPressed
            )
    }
}

// MARK: - Accessible Container
public struct AccessibleContainer<Content: View>: View {
    let content: Content
    let backgroundColor: Color?
    let padding: EdgeInsets?
    
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(
        backgroundColor: Color? = nil,
        padding: EdgeInsets? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.padding = padding
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(scaledPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                backgroundColor ?? Color.LeavnBackgroundColors.primary.current
            )
            .accessibilityElement(children: .contain)
    }
    
    private var scaledPadding: EdgeInsets {
        let basePadding = padding ?? EdgeInsets(
            top: 0,
            leading: 0,
            bottom: 0,
            trailing: 0
        )
        
        let scale = sizeCategory.isAccessibilityCategory ? 1.5 : 1.0
        
        return EdgeInsets(
            top: basePadding.top * scale,
            leading: basePadding.leading * scale,
            bottom: basePadding.bottom * scale,
            trailing: basePadding.trailing * scale
        )
    }
}

// MARK: - Accessible Divider
public struct AccessibleDivider: View {
    let style: DividerStyle
    
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public enum DividerStyle {
        case regular
        case thick
        case section
        
        var height: CGFloat {
            switch self {
            case .regular: return 0.5
            case .thick: return 1
            case .section: return 8
            }
        }
        
        var color: Color {
            switch self {
            case .regular, .thick:
                return Color.LeavnBorderColors.separator.current
            case .section:
                return Color.LeavnBackgroundColors.secondary.current
            }
        }
    }
    
    public init(style: DividerStyle = .regular) {
        self.style = style
    }
    
    public var body: some View {
        Rectangle()
            .fill(dividerColor)
            .frame(height: dividerHeight)
            .accessibilityHidden(true)
    }
    
    private var dividerHeight: CGFloat {
        themeManager.isHighContrastEnabled && style != .section
            ? style.height * 2
            : style.height
    }
    
    private var dividerColor: Color {
        style.color
    }
}

// MARK: - Accessible Empty State
public struct AccessibleEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: scaledSpacing) {
            Image(systemName: icon)
                .font(.system(size: scaledIconSize))
                .foregroundColor(Color.LeavnTextColors.tertiary.current)
                .accessibilityHidden(true)
            
            VStack(spacing: scaledTextSpacing) {
                AccessibleText(title, style: .title3, alignment: .center)
                AccessibleText(message, style: .body, alignment: .center)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                AccessibleLeavnButton(
                    actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
                .padding(.top, scaledButtonPadding)
            }
        }
        .padding(scaledPadding)
        .frame(maxWidth: 400)
        .accessibilityElement(children: .combine)
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 32 : 24
    }
    
    private var scaledTextSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }
    
    private var scaledButtonPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 24 : 16
    }
    
    private var scaledPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 32 : 24
    }
    
    private var scaledIconSize: CGFloat {
        sizeCategory.isAccessibilityCategory ? 64 : 48
    }
}