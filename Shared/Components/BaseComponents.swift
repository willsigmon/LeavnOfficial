import SwiftUI

// MARK: - Base Card Component
public struct BaseCard<Content: View>: View {
    let content: Content
    let style: CardStyle
    let padding: EdgeInsets
    let cornerRadius: CGFloat
    let shadowStyle: ShadowStyle
    let tapAction: (() -> Void)?
    
    public enum CardStyle {
        case elevated
        case filled
        case outlined
        case minimal
        
        var backgroundColor: Color {
            switch self {
            case .elevated, .filled:
                return Color(.systemBackground)
            case .outlined:
                return Color(.systemBackground)
            case .minimal:
                return Color.clear
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outlined:
                return Color(.systemGray4)
            default:
                return Color.clear
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outlined:
                return 1
            default:
                return 0
            }
        }
    }
    
    public enum ShadowStyle {
        case none
        case light
        case medium
        case heavy
        
        var radius: CGFloat {
            switch self {
            case .none: return 0
            case .light: return 2
            case .medium: return 5
            case .heavy: return 10
            }
        }
        
        var offset: CGSize {
            switch self {
            case .none: return .zero
            case .light: return CGSize(width: 0, height: 1)
            case .medium: return CGSize(width: 0, height: 2)
            case .heavy: return CGSize(width: 0, height: 4)
            }
        }
        
        var opacity: Double {
            switch self {
            case .none: return 0
            case .light: return 0.05
            case .medium: return 0.1
            case .heavy: return 0.2
            }
        }
    }
    
    public init(
        style: CardStyle = .elevated,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        cornerRadius: CGFloat = 12,
        shadowStyle: ShadowStyle = .medium,
        tapAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.shadowStyle = shadowStyle
        self.tapAction = tapAction
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if let tapAction = tapAction {
                Button(action: tapAction) {
                    cardContent
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                cardContent
            }
        }
    }
    
    private var cardContent: some View {
        content
            .padding(padding)
            .background(style.backgroundColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
            .shadow(
                color: Color.black.opacity(shadowStyle.opacity),
                radius: shadowStyle.radius,
                x: shadowStyle.offset.width,
                y: shadowStyle.offset.height
            )
    }
}

// MARK: - Base Action Button
public struct BaseActionButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyle
    let size: ButtonSize
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    public enum ButtonStyle {
        case primary
        case secondary
        case outline
        case ghost
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color.accentColor
            case .secondary:
                return Color(.systemGray5)
            case .outline, .ghost:
                return Color.clear
            case .destructive:
                return Color.red
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive:
                return Color.white
            case .secondary:
                return Color.primary
            case .outline, .ghost:
                return Color.accentColor
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outline:
                return Color.accentColor
            default:
                return Color.clear
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outline:
                return 1
            default:
                return 0
            }
        }
    }
    
    public enum ButtonSize {
        case small
        case medium
        case large
        
        var padding: EdgeInsets {
            switch self {
            case .small:
                return EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)
            case .medium:
                return EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
            case .large:
                return EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small:
                return .caption
            case .medium:
                return .subheadline
            case .large:
                return .headline
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small:
                return .caption
            case .medium:
                return .subheadline
            case .large:
                return .title3
            }
        }
    }
    
    public init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                        .foregroundColor(style.foregroundColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconSize)
                }
                
                Text(title)
                    .font(size.fontSize)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.foregroundColor)
            .padding(size.padding)
            .frame(maxWidth: .infinity)
            .background(style.backgroundColor)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            )
        }
        .disabled(!isEnabled || isLoading)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Base Icon Button
public struct BaseIconButton: View {
    let icon: String
    let style: IconButtonStyle
    let size: IconButtonSize
    let isEnabled: Bool
    let action: () -> Void
    
    public enum IconButtonStyle {
        case filled
        case outlined
        case plain
        
        var backgroundColor: Color {
            switch self {
            case .filled:
                return Color.accentColor
            case .outlined:
                return Color.clear
            case .plain:
                return Color.clear
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .filled:
                return Color.white
            case .outlined, .plain:
                return Color.accentColor
            }
        }
        
        var borderColor: Color {
            switch self {
            case .outlined:
                return Color.accentColor
            default:
                return Color.clear
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .outlined:
                return 1
            default:
                return 0
            }
        }
    }
    
    public enum IconButtonSize {
        case small
        case medium
        case large
        
        var frameSize: CGFloat {
            switch self {
            case .small: return 32
            case .medium: return 44
            case .large: return 56
            }
        }
        
        var iconSize: Font {
            switch self {
            case .small: return .caption
            case .medium: return .title3
            case .large: return .title2
            }
        }
    }
    
    public init(
        icon: String,
        style: IconButtonStyle = .filled,
        size: IconButtonSize = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(size.iconSize)
                .foregroundColor(style.foregroundColor)
                .frame(width: size.frameSize, height: size.frameSize)
                .background(style.backgroundColor)
                .cornerRadius(size.frameSize / 2)
                .overlay(
                    Circle()
                        .stroke(style.borderColor, lineWidth: style.borderWidth)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
}

// MARK: - Base List Item
public struct BaseListItem<Content: View>: View {
    let content: Content
    let showDisclosureIndicator: Bool
    let showDivider: Bool
    let action: (() -> Void)?
    
    public init(
        showDisclosureIndicator: Bool = false,
        showDivider: Bool = true,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showDisclosureIndicator = showDisclosureIndicator
        self.showDivider = showDivider
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Group {
                if let action = action {
                    Button(action: action) {
                        listItemContent
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    listItemContent
                }
            }
            
            if showDivider {
                Divider()
                    .padding(.leading, 16)
            }
        }
    }
    
    private var listItemContent: some View {
        HStack {
            content
            
            if showDisclosureIndicator {
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.clear)
        .contentShape(Rectangle())
    }
}

// MARK: - Base Error View
public struct BaseErrorView: View {
    let title: String
    let message: String
    let icon: String
    let retryAction: (() -> Void)?
    
    public init(
        title: String = "Something went wrong",
        message: String,
        icon: String = "exclamationmark.triangle",
        retryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let retryAction = retryAction {
                BaseActionButton(
                    title: "Try Again",
                    icon: "arrow.clockwise",
                    style: .primary,
                    size: .medium,
                    action: retryAction
                )
                .frame(maxWidth: 200)
            }
        }
        .padding(24)
        .frame(maxWidth: 400)
    }
}

// MARK: - Base Empty State View
public struct BaseEmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    public init(
        title: String,
        message: String,
        icon: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                BaseActionButton(
                    title: actionTitle,
                    style: .primary,
                    size: .medium,
                    action: action
                )
                .frame(maxWidth: 200)
            }
        }
        .padding(32)
        .frame(maxWidth: 400)
    }
}

// MARK: - Base Loading View
public struct BaseLoadingView: View {
    let message: String?
    let style: LoadingStyle
    
    public enum LoadingStyle {
        case standard
        case compact
        case minimal
        
        var progressViewScale: CGFloat {
            switch self {
            case .standard: return 1.5
            case .compact: return 1.0
            case .minimal: return 0.8
            }
        }
    }
    
    public init(message: String? = nil, style: LoadingStyle = .standard) {
        self.message = message
        self.style = style
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(style.progressViewScale)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(style == .minimal ? 16 : 24)
    }
}

// MARK: - Preview
struct BaseComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                BaseCard {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Card Title")
                            .font(.headline)
                        Text("This is a sample card content with some text.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                
                BaseActionButton(
                    title: "Primary Button",
                    icon: "star.fill",
                    style: .primary,
                    action: {}
                )
                
                BaseIconButton(
                    icon: "heart.fill",
                    style: .filled,
                    action: {}
                )
                
                BaseErrorView(
                    title: "Error",
                    message: "Something went wrong. Please try again.",
                    retryAction: {}
                )
                
                BaseEmptyStateView(
                    title: "No Items",
                    message: "There are no items to display.",
                    icon: "tray",
                    actionTitle: "Add Item",
                    action: {}
                )
                
                BaseLoadingView(message: "Loading...")
            }
            .padding()
        }
    }
}