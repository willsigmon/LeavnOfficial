import SwiftUI

public struct CardView<Content: View>: View {
    let content: Content
    let style: CardStyle
    
    public enum CardStyle {
        case elevated
        case filled
        case outlined
    }
    
    public init(
        style: CardStyle = .elevated,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.content = content()
    }
    
    public var body: some View {
        content
            .background(backgroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .outlined ? 1 : 0)
            )
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: shadowY
            )
    }
    
    private var backgroundColor: Color {
        switch style {
        case .elevated, .outlined:
            return .leavnSecondaryBackground
        case .filled:
            return .leavnSecondaryBackground
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .outlined:
            return LeavnColors.separator
        default:
            return .clear
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .elevated:
            return Color.black.opacity(0.1)
        default:
            return .clear
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return 8
        default:
            return 0
        }
    }
    
    private var shadowY: CGFloat {
        switch style {
        case .elevated:
            return 2
        default:
            return 0
        }
    }
}

public struct InteractiveCard<Content: View>: View {
    let content: Content
    let action: () -> Void
    @State private var isPressed = false
    
    public init(
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.action = action
        self.content = content()
    }
    
    public var body: some View {
        CardView(style: .elevated) {
            content
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            action()
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}