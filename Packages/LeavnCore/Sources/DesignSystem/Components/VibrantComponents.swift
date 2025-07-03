import SwiftUI

// MARK: - Vibrant Verse Card
public struct VerseCard: View {
    let verseNumber: Int
    let text: String
    let reference: String
    let isHighlighted: Bool
    let isJesusWords: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var appear = false
    
    public init(
        verseNumber: Int,
        text: String,
        reference: String,
        isHighlighted: Bool = false,
        isJesusWords: Bool = false,
        onTap: @escaping () -> Void = {}
    ) {
        self.verseNumber = verseNumber
        self.text = text
        self.reference = reference
        self.isHighlighted = isHighlighted
        self.isJesusWords = isJesusWords
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) {
                isPressed = true
            }
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(LeavnTheme.Motion.quickBounce) {
                    isPressed = false
                }
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Verse number bubble
                Text("\(verseNumber)")
                    .font(LeavnTheme.Typography.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(isJesusWords ? LeavnTheme.Colors.jesusWords : LeavnTheme.Colors.accent)
                            .shadow(
                                color: (isJesusWords ? LeavnTheme.Colors.jesusWords : LeavnTheme.Colors.accent).opacity(0.4),
                                radius: 8,
                                x: 0,
                                y: 4
                            )
                    )
                    .scaleEffect(appear ? 1 : 0)
                    .animation(
                        LeavnTheme.Motion.delightful.delay(0.1),
                        value: appear
                    )
                
                // Verse content
                VStack(alignment: .leading, spacing: 8) {
                    Text(text)
                        .font(isJesusWords ? 
                              LeavnTheme.Typography.readerFont(size: 18).italic() :
                              LeavnTheme.Typography.readerFont(size: 18))
                        .foregroundColor(isJesusWords ? LeavnTheme.Colors.jesusWords : .primary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(reference)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isHighlighted ? 
                          LeavnTheme.Colors.accent.opacity(0.1) : 
                          Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                isHighlighted ? 
                                LeavnTheme.Colors.accent.opacity(0.3) : 
                                Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .shadow(
                color: LeavnTheme.Shadows.soft.value.color,
                radius: isPressed ? 2 : LeavnTheme.Shadows.soft.value.radius,
                x: 0,
                y: isPressed ? 1 : LeavnTheme.Shadows.soft.value.yOffset
            )
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            .animation(
                LeavnTheme.Motion.smoothSpring,
                value: appear
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Vibrant Card Component
public struct LeavnCard<Content: View>: View {
    private let content: Content
    private let style: CardStyle
    
    @State private var appear = false
    
    public enum CardStyle {
        case standard
        case glass
        case gradient
        case elevated
    }
    
    public init(
        style: CardStyle = .standard,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
    }
    
    public var body: some View {
        content
            .background(backgroundView)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(
                color: shadowColor,
                radius: shadowRadius,
                x: 0,
                y: 8
            )
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.9)
            .animation(LeavnTheme.Motion.smoothSpring, value: appear)
            .onAppear {
                appear = true
            }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .standard:
            Color(UIColor.secondarySystemBackground)
        case .glass:
            ZStack {
                LeavnTheme.Colors.glassLight
                #if os(iOS) || os(visionOS)
                Rectangle()
                    .fill(.ultraThinMaterial)
                #else
                LeavnTheme.Colors.glassLight.opacity(0.8)
                #endif
            }
        case .gradient:
            LeavnTheme.Colors.primaryGradient.opacity(0.1)
        case .elevated:
            Color(UIColor.tertiarySystemBackground)
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .gradient:
            return LeavnTheme.Colors.accent.opacity(0.2)
        default:
            return Color.black.opacity(0.1)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case .elevated:
            return 15
        case .gradient:
            return 20
        default:
            return 8
        }
    }
}

// MARK: - Animated Tab Item
public struct AnimatedTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    @State private var animateIcon = false
    
    public init(
        icon: String,
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) {
                animateIcon = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateIcon = false
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? "\(icon).fill" : icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? LeavnTheme.Colors.accent : .secondary)
                    .scaleEffect(animateIcon ? 1.2 : 1)
                    .rotationEffect(.degrees(animateIcon ? 10 : 0))
                
                Text(title)
                    .font(LeavnTheme.Typography.micro)
                    .foregroundColor(isSelected ? LeavnTheme.Colors.accent : .secondary)
            }
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Vibrant Loading View
public struct VibrantLoadingView: View {
    let message: String
    @State private var animate = false
    
    public init(message: String = "Loading...") {
        self.message = message
    }
    
    public var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .stroke(LeavnTheme.Colors.accent.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LeavnTheme.Colors.primaryGradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(animate ? 360 : 0))
                    .animation(
                        .linear(duration: 1)
                            .repeatForever(autoreverses: false),
                        value: animate
                    )
            }
            
            Text(message)
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
        )
        .shadow(radius: 20)
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Pulse Animation Modifier
struct PulseEffect: ViewModifier {
    @State private var pulse = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(pulse ? 1.05 : 1)
            .opacity(pulse ? 0.8 : 1)
            .animation(
                .easeInOut(duration: 1)
                    .repeatForever(autoreverses: true),
                value: pulse
            )
            .onAppear {
                pulse = true
            }
    }
}

public extension View {
    func pulseEffect() -> some View {
        modifier(PulseEffect())
    }
}
