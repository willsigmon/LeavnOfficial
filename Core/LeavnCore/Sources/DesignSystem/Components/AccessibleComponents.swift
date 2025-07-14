import SwiftUI

// MARK: - Accessible Section Header (removed - use AccessibleSectionHeader from AccessibleText.swift instead)

// MARK: - Simple Divider (removed - use AccessibleDivider from AccessibleCard.swift instead)

// MARK: - Accessible List Item (Simple)
// Note: A more complete version exists in AccessibleCard.swift
public struct SimpleAccessibleListItem<Content: View>: View {
    let content: () -> Content
    @FocusState private var isFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
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
                    .fill(isFocused ? Color.LeavnBackgroundColors.secondary.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isFocused && themeManager.isHighContrastEnabled
                            ? Color.LeavnColors.primary.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled)
                            : Color.clear,
                        lineWidth: 2
                    )
            )
            .focused($isFocused)
            .accessibilityElement(children: .combine)
    }
}

// MARK: - Accessible Badge (removed - use AccessibleBadge from AccessibleText.swift instead)

// MARK: - Simple Accessible Empty State
// Note: A more complete version exists in AccessibleCard.swift
public struct SimpleAccessibleEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
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
                .foregroundColor(Color.LeavnTextColors.tertiary.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled))
                .accessibilityHidden(true)
            
            VStack(spacing: 8) {
                AccessibleText(title, style: .headline)
                    .multilineTextAlignment(.center)
                
                AccessibleText(message, style: .body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.LeavnTextColors.secondary.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled))
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