import SwiftUI

// MARK: - Accessible Section Header
public struct AccessibleSectionHeader: View {
    let title: String
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(Color.LeavnTextColors.primary.current)
            .accessibilityAddTraits(.isHeader)
            .padding(.bottom, 8)
    }
}

// MARK: - Accessible Divider
public struct AccessibleDivider: View {
    public enum DividerStyle {
        case section
        case item
    }
    
    let style: DividerStyle
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public init(style: DividerStyle = .item) {
        self.style = style
    }
    
    public var body: some View {
        Rectangle()
            .fill(Color.LeavnBorderColors.separator.current)
            .frame(height: dividerHeight)
            .accessibilityHidden(true)
    }
    
    private var dividerHeight: CGFloat {
        switch style {
        case .section:
            return themeManager.isHighContrastEnabled ? 2 : 1
        case .item:
            return themeManager.isHighContrastEnabled ? 1 : 0.5
        }
    }
}

// MARK: - Accessible List Item
public struct AccessibleListItem<Content: View>: View {
    let content: () -> Content
    @FocusState private var isFocused: Bool
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isFocused ? Color.LeavnBackgroundColors.secondary.current : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused && themeManager.isHighContrastEnabled
                            ? Color.LeavnColors.primary.current
                            : Color.clear,
                        lineWidth: 2
                    )
            )
            .focused($isFocused)
            .accessibilityElement(children: .combine)
    }
}

// MARK: - Accessible Badge
public struct AccessibleBadge: View {
    public enum BadgeStyle {
        case primary
        case secondary
        case success
        case warning
        case error
        case info
    }
    
    let text: String
    let style: BadgeStyle
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(_ text: String, style: BadgeStyle = .primary) {
        self.text = text
        self.style = style
    }
    
    public var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .cornerRadius(12)
            .accessibilityLabel("\(text) badge")
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary, .success, .error, .info:
            return .white
        case .secondary:
            return Color.LeavnColors.primary.current
        case .warning:
            return Color.LeavnTextColors.primary.current
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return Color.LeavnColors.primary.current
        case .secondary:
            return Color.LeavnColors.primary.current.opacity(0.1)
        case .success:
            return Color.LeavnColors.success.current
        case .warning:
            return Color.LeavnColors.warning.current
        case .error:
            return Color.LeavnColors.error.current
        case .info:
            return Color.LeavnColors.info.current
        }
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
                .font(.system(size: 64))
                .foregroundColor(Color.LeavnTextColors.tertiary.current)
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                AccessibleText(title, style: .headline)
                    .multilineTextAlignment(.center)
                
                AccessibleText(message, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.LeavnTextColors.secondary.current)
            }
            
            if let actionTitle = actionTitle, let action = action {
                AccessibleLeavnButton(actionTitle, style: .primary, size: .medium, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(message)")
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 24 : 16
    }
}