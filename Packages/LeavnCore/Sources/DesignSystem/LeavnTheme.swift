import SwiftUI

// MARK: - Vibrant Theme System
public struct LeavnTheme {
    
    // MARK: - Brand Colors (Vibrant & Whimsical)
    public struct Colors {
        // Primary gradient inspired by your screenshots
        public static let primaryGradient = LinearGradient(
            colors: [
                Color(red: 0.71, green: 0.65, blue: 0.97), // Light purple
                Color(red: 0.64, green: 0.48, blue: 0.92)  // Deeper purple
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Accent colors for excitement
        public static let accent = Color(red: 0.64, green: 0.48, blue: 0.92) // Main purple
        public static let accentLight = Color(red: 0.78, green: 0.71, blue: 0.97)
        public static let accentDark = Color(red: 0.51, green: 0.36, blue: 0.82)
        
        // Jesus words special color
        public static let jesusWords = Color(red: 1.0, green: 0.42, blue: 0.42) // Warm red
        
        // Playful semantic colors
        public static let success = Color(red: 0.35, green: 0.84, blue: 0.64) // Mint green
        public static let warning = Color(red: 1.0, green: 0.76, blue: 0.29) // Golden yellow
        public static let error = Color(red: 0.96, green: 0.42, blue: 0.47) // Soft red
        public static let info = Color(red: 0.40, green: 0.69, blue: 0.95) // Sky blue
        
        // Rich backgrounds
        public static let darkBackground = Color(red: 0.05, green: 0.05, blue: 0.1)
        public static let darkSecondary = Color(red: 0.08, green: 0.05, blue: 0.12)
        
        // Glass effects
        public static let glassLight = Color.white.opacity(0.1)
        public static let glassBorder = Color.white.opacity(0.2)
        
        // Category colors (for books, topics, etc.)
        public static let categoryColors = [
            Color(red: 0.96, green: 0.42, blue: 0.47), // Coral
            Color(red: 0.40, green: 0.69, blue: 0.95), // Sky
            Color(red: 0.35, green: 0.84, blue: 0.64), // Mint
            Color(red: 1.0, green: 0.76, blue: 0.29),  // Golden
            Color(red: 0.64, green: 0.48, blue: 0.92), // Purple
            Color(red: 0.96, green: 0.56, blue: 0.69), // Pink
            Color(red: 0.44, green: 0.89, blue: 0.81), // Teal
            Color(red: 0.95, green: 0.61, blue: 0.36)  // Orange
        ]
    }
    
    // MARK: - Motion & Animation
    public struct Motion {
        public static let quickBounce = Animation.spring(response: 0.3, dampingFraction: 0.7)
        public static let smoothSpring = Animation.spring(response: 0.5, dampingFraction: 0.8)
        public static let delightful = Animation.spring(response: 0.4, dampingFraction: 0.65)
        public static let elastic = Animation.spring(response: 0.6, dampingFraction: 0.5)
        
        // Stagger delays for lists
        public static func staggerDelay(index: Int) -> Double {
            return Double(index) * 0.03
        }
    }
    
    // MARK: - Shadows & Depth
    public struct Shadows {
        public struct Shadow: Sendable {
            public let color: Color
            public let radius: CGFloat
            public let x: CGFloat
            public let y: CGFloat
        }
        
        public static let soft = Shadow(
            color: Color.black.opacity(0.15),
            radius: 8,
            x: 0,
            y: 4
        )
        
        public static let glow = Shadow(
            color: Colors.accent.opacity(0.3),
            radius: 20,
            x: 0,
            y: 0
        )
        
        public static let elevation = Shadow(
            color: Color.black.opacity(0.2),
            radius: 15,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Typography with Character
    public struct Typography {
        public static let displayLarge = Font.system(size: 40, weight: .black, design: .rounded)
        public static let displayMedium = Font.system(size: 32, weight: .bold, design: .rounded)
        public static let titleLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        public static let titleMedium = Font.system(size: 22, weight: .semibold, design: .rounded)
        public static let headline = Font.system(size: 18, weight: .semibold, design: .rounded)
        public static let body = Font.system(size: 16, weight: .regular, design: .default)
        public static let caption = Font.system(size: 13, weight: .medium, design: .rounded)
        public static let micro = Font.system(size: 11, weight: .medium, design: .rounded)
        
        // Special Bible reading font
        public static func readerFont(size: CGFloat) -> Font {
            Font.custom("Georgia", size: size)
                .weight(.regular)
        }
    }
}

// MARK: - Enhanced Components

public struct GlassCard<Content: View>: View {
    public let content: Content
    public let cornerRadius: CGFloat
    public let glowColor: Color?
    
    public init(
        cornerRadius: CGFloat = 20,
        glowColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.cornerRadius = cornerRadius
        self.glowColor = glowColor
    }
    
    public var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(LeavnTheme.Colors.glassBorder, lineWidth: 1)
                    )
            )
            .shadow(
                color: glowColor ?? LeavnTheme.Shadows.soft.color,
                radius: glowColor != nil ? LeavnTheme.Shadows.glow.radius : LeavnTheme.Shadows.soft.radius,
                x: LeavnTheme.Shadows.soft.x,
                y: LeavnTheme.Shadows.soft.y
            )
    }
}

// MARK: - View Extensions

public extension View {
    func glowEffect(color: Color = LeavnTheme.Colors.accent, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color.opacity(0.4), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.2), radius: radius * 2, x: 0, y: 0)
    }
    
    func shimmerEffect() -> some View {
        self
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.3),
                            Color.white.opacity(0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width)
                    .animation(
                        .linear(duration: 2)
                            .repeatForever(autoreverses: false),
                        value: true
                    )
                }
            )
            .clipped()
    }
    
    func bounceOnTap() -> some View {
        self
            .scaleEffect(1)
            .onTapGesture {
                withAnimation(LeavnTheme.Motion.quickBounce) {
                    // Trigger animation
                }
            }
    }
}

// MARK: - Color Extension
public extension Color {
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
