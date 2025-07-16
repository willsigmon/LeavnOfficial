import SwiftUI

// MARK: - Color System (Legacy - use Color.LeavnColors instead)
// This struct is deprecated - use Color.LeavnColors from EnhancedColorTheme.swift instead

// MARK: - LeavnBackgroundColors and LeavnTextColors are now defined in Color.LeavnBackgroundColors and Color.LeavnTextColors in EnhancedColorTheme.swift

// MARK: - ColorSet is now defined in Core/LeavnCore/Sources/DesignSystem/Theme/EnhancedColorTheme.swift

// MARK: - Adaptive Color Helper
public extension Color {
    static func adaptive(light: Color, dark: Color) -> Color {
        return Color.primary // Simple fallback - in a real app this would use @Environment(\.colorScheme)
    }
}

// MARK: - Gradient Extensions
public extension LinearGradient {
    static func leavnGradient(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> LinearGradient {
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}