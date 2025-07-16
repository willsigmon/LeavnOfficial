import SwiftUI

// MARK: - Accessible Text Component
public struct AccessibleText: View {
    let content: String
    let style: TextStyle
    let color: Color?
    let alignment: TextAlignment
    let lineLimit: Int?
    let minimumScaleFactor: CGFloat
    
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.sizeCategory) private var sizeCategory
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    
    public enum TextStyle {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case subheadline
        case body
        case callout
        case footnote
        case caption
        case caption2
        
        var font: Font {
            switch self {
            case .largeTitle: return .largeTitle
            case .title: return .title
            case .title2: return .title2
            case .title3: return .title3
            case .headline: return .headline
            case .subheadline: return .subheadline
            case .body: return .body
            case .callout: return .callout
            case .footnote: return .footnote
            case .caption: return .caption
            case .caption2: return .caption2
            }
        }
        
        var weight: Font.Weight {
            switch self {
            case .largeTitle, .title, .title2, .title3: return .bold
            case .headline: return .semibold
            case .subheadline, .callout: return .medium
            case .body, .footnote, .caption, .caption2: return .regular
            }
        }
        
        func defaultColor(colorScheme: ColorScheme, isHighContrast: Bool) -> Color {
            switch self {
            case .largeTitle, .title, .title2, .title3, .headline, .body:
                return Color.LeavnTextColors.primary.current(for: colorScheme, isHighContrast: isHighContrast)
            case .subheadline, .callout, .footnote:
                return Color.LeavnTextColors.secondary.current(for: colorScheme, isHighContrast: isHighContrast)
            case .caption, .caption2:
                return Color.LeavnTextColors.tertiary.current(for: colorScheme, isHighContrast: isHighContrast)
            }
        }
        
        var letterSpacing: CGFloat {
            switch self {
            case .largeTitle: return 0.5
            case .title, .title2, .title3: return 0.3
            case .headline, .subheadline: return 0.2
            case .body, .callout: return 0.1
            case .footnote, .caption, .caption2: return 0.0
            }
        }
        
        var lineSpacing: CGFloat {
            switch self {
            case .largeTitle: return 8
            case .title, .title2, .title3: return 6
            case .headline, .subheadline: return 4
            case .body, .callout: return 3
            case .footnote, .caption, .caption2: return 2
            }
        }
    }
    
    public init(
        _ content: String,
        style: TextStyle = .body,
        color: Color? = nil,
        alignment: TextAlignment = .leading,
        lineLimit: Int? = nil,
        minimumScaleFactor: CGFloat = 0.8
    ) {
        self.content = content
        self.style = style
        self.color = color
        self.alignment = alignment
        self.lineLimit = lineLimit
        self.minimumScaleFactor = minimumScaleFactor
    }
    
    public var body: some View {
        Text(content)
            .font(style.font)
            .fontWeight(style.weight)
            .foregroundColor(textColor)
            .kerning(adjustedLetterSpacing)
            .lineSpacing(adjustedLineSpacing)
            .multilineTextAlignment(alignment)
            .lineLimit(lineLimit)
            .minimumScaleFactor(minimumScaleFactor)
            .dynamicTypeSize(...DynamicTypeSize.accessibility3)
            .accessibilityLabel(content)
    }
    
    private var textColor: Color {
        if let customColor = color {
            return customColor
        }
        
        // Use high contrast colors if needed
        let currentColorScheme = colorScheme
        if themeManager.isHighContrastEnabled {
            switch style {
            case .largeTitle, .title, .title2, .title3, .headline, .body:
                return Color.LeavnTextColors.primary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
            case .subheadline, .callout, .footnote, .caption, .caption2:
                return Color.LeavnTextColors.secondary.current(for: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
            }
        }
        
        return style.defaultColor(colorScheme: currentColorScheme, isHighContrast: themeManager.isHighContrastEnabled)
    }
    
    private var adjustedLetterSpacing: CGFloat {
        // Increase letter spacing for accessibility text sizes
        let baseSpacing = style.letterSpacing
        return sizeCategory.isAccessibilityCategory ? baseSpacing * 1.5 : baseSpacing
    }
    
    private var adjustedLineSpacing: CGFloat {
        // Increase line spacing for better readability
        let baseSpacing = style.lineSpacing
        return sizeCategory.isAccessibilityCategory ? baseSpacing * 1.5 : baseSpacing
    }
}

// MARK: - Accessible Label Component
public struct AccessibleLabel: View {
    let title: String
    let value: String
    let style: AccessibleText.TextStyle
    let valueStyle: AccessibleText.TextStyle
    let spacing: CGFloat
    
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(
        title: String,
        value: String,
        style: AccessibleText.TextStyle = .caption,
        valueStyle: AccessibleText.TextStyle = .body,
        spacing: CGFloat = 4
    ) {
        self.title = title
        self.value = value
        self.style = style
        self.valueStyle = valueStyle
        self.spacing = spacing
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: scaledSpacing) {
            AccessibleText(title, style: style)
            AccessibleText(value, style: valueStyle)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? spacing * 1.5 : spacing
    }
}

// MARK: - Contrast-Aware Badge
public struct AccessibleBadge: View {
    let text: String
    let style: BadgeStyle
    
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.colorScheme) private var colorScheme
    
    public enum BadgeStyle {
        case primary
        case secondary
        case success
        case warning
        case error
        case info
        
        func backgroundColor(colorScheme: ColorScheme, isHighContrast: Bool) -> Color {
            switch self {
            case .primary: return Color.LeavnColors.primary.current(for: colorScheme, isHighContrast: isHighContrast)
            case .secondary: return Color.LeavnColors.secondary.current(for: colorScheme, isHighContrast: isHighContrast)
            case .success: return Color.LeavnColors.success.current(for: colorScheme, isHighContrast: isHighContrast)
            case .warning: return Color.LeavnColors.warning.current(for: colorScheme, isHighContrast: isHighContrast)
            case .error: return Color.LeavnColors.error.current(for: colorScheme, isHighContrast: isHighContrast)
            case .info: return Color.LeavnColors.info.current(for: colorScheme, isHighContrast: isHighContrast)
            }
        }
        
        var foregroundColor: Color {
            // Always ensure proper contrast
            switch self {
            case .primary, .secondary, .success, .error, .info:
                return .white
            case .warning:
                // Warning yellow needs dark text for contrast
                return Color.black
            }
        }
    }
    
    public init(_ text: String, style: BadgeStyle = .primary) {
        self.text = text
        self.style = style
    }
    
    public var body: some View {
        Text(text)
            .font(.system(.caption2, design: .rounded, weight: .semibold))
            .foregroundColor(style.foregroundColor)
            .padding(.horizontal, scaledPadding)
            .padding(.vertical, scaledPadding / 2)
            .background(style.backgroundColor(colorScheme: colorScheme, isHighContrast: themeManager.isHighContrastEnabled))
            .cornerRadius(scaledCornerRadius)
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .accessibilityLabel(text)
            .accessibilityAddTraits(.isStaticText)
    }
    
    private var scaledPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }
    
    private var scaledCornerRadius: CGFloat {
        sizeCategory.isAccessibilityCategory ? 6 : 4
    }
}

// MARK: - Accessible Section Header
public struct AccessibleSectionHeader: View {
    let title: String
    let subtitle: String?
    
    @Environment(\.sizeCategory) private var sizeCategory
    
    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: scaledSpacing) {
            AccessibleText(title, style: .headline)
                .accessibilityAddTraits(.isHeader)
            
            if let subtitle = subtitle {
                AccessibleText(subtitle, style: .subheadline)
            }
        }
        .padding(.vertical, scaledPadding)
        .accessibilityElement(children: .combine)
    }
    
    private var scaledSpacing: CGFloat {
        sizeCategory.isAccessibilityCategory ? 6 : 4
    }
    
    private var scaledPadding: CGFloat {
        sizeCategory.isAccessibilityCategory ? 12 : 8
    }
}

// MARK: - High Contrast Text View Modifier
public struct HighContrastText: ViewModifier {
    @ObservedObject private var themeManager = AccessibilityThemeManager.shared
    @Environment(\.colorScheme) private var colorScheme
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(
                themeManager.isHighContrastEnabled
                    ? Color.LeavnTextColors.primary.current(for: colorScheme, isHighContrast: themeManager.isHighContrastEnabled)
                    : nil
            )
    }
}

public extension View {
    func highContrastText() -> some View {
        modifier(HighContrastText())
    }
}

// MARK: - Readable Width Modifier
public struct ReadableWidth: ViewModifier {
    @Environment(\.sizeCategory) private var sizeCategory
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    public func body(content: Content) -> some View {
        content
            .frame(maxWidth: maxWidth)
    }
    
    private var maxWidth: CGFloat {
        // Adjust max width based on text size and device
        if horizontalSizeClass == .regular {
            return sizeCategory.isAccessibilityCategory ? 800 : 680
        } else {
            return .infinity
        }
    }
}

public extension View {
    func readableWidth() -> some View {
        modifier(ReadableWidth())
    }
}