import SwiftUI

public struct LeavnTheme {
    // MARK: - Typography
    public struct Typography {
        // Title sizes
        public static let titleLarge = Font.system(size: 32, weight: .bold, design: .default)
        public static let title = Font.system(size: 28, weight: .bold, design: .default)
        public static let titleMedium = Font.system(size: 24, weight: .semibold, design: .default)
        public static let titleSmall = Font.system(size: 20, weight: .semibold, design: .default)
        
        // Headlines
        public static let headline = Font.system(size: 17, weight: .semibold, design: .default)
        public static let headlineSmall = Font.system(size: 15, weight: .semibold, design: .default)
        
        // Body text
        public static let body = Font.system(size: 17, weight: .regular, design: .default)
        public static let bodySmall = Font.system(size: 15, weight: .regular, design: .default)
        
        // Caption and labels
        public static let caption = Font.system(size: 12, weight: .regular, design: .default)
        public static let captionBold = Font.system(size: 12, weight: .semibold, design: .default)
        public static let label = Font.system(size: 13, weight: .regular, design: .default)
        
        // Bible text
        public static let verseText = Font.system(size: 18, weight: .regular, design: .serif)
        public static let verseReference = Font.system(size: 14, weight: .medium, design: .default)
    }
    
    // MARK: - Colors
    public struct Colors {
        // Primary colors
        public static let primary = Color.blue
        public static let secondary = Color.purple
        public static let accent = Color.indigo
        
        // Gradients
        public static let primaryGradient = LinearGradient(
            colors: [Color.blue, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let accentGradient = LinearGradient(
            colors: [Color.indigo, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        // Semantic colors
        public static let success = Color.green
        public static let warning = Color.orange
        public static let error = Color.red
        public static let info = Color.blue
        
        // Background colors
        public static let background = Color(UIColor.systemBackground)
        public static let secondaryBackground = Color(UIColor.secondarySystemBackground)
        public static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
        
        // Text colors
        public static let primaryText = Color.primary
        public static let secondaryText = Color.secondary
        public static let tertiaryText = Color(UIColor.tertiaryLabel)
        
        // Special purpose
        public static let divider = Color(UIColor.separator)
        public static let overlay = Color.black.opacity(0.4)
    }
    
    // MARK: - Spacing
    public struct Spacing {
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 20
        public static let xLarge: CGFloat = 24
        public static let xxLarge: CGFloat = 32
        public static let xxxLarge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    public struct CornerRadius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xLarge: CGFloat = 20
        public static let round: CGFloat = 9999
    }
    
    // MARK: - Shadows
    public struct Shadow {
        public static let small = ShadowStyle(
            color: Color.black.opacity(0.08),
            radius: 4,
            x: 0,
            y: 2
        )
        
        public static let medium = ShadowStyle(
            color: Color.black.opacity(0.12),
            radius: 8,
            x: 0,
            y: 4
        )
        
        public static let large = ShadowStyle(
            color: Color.black.opacity(0.16),
            radius: 16,
            x: 0,
            y: 8
        )
    }
    
    // MARK: - Animation
    public struct Animation {
        public static let fast = SwiftUI.Animation.easeInOut(duration: 0.2)
        public static let medium = SwiftUI.Animation.easeInOut(duration: 0.3)
        public static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        
        public static let spring = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.8)
        public static let springBouncy = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.6)
    }
}

// MARK: - Shadow Style
public struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}