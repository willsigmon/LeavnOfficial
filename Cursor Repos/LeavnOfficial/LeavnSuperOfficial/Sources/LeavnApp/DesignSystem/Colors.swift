import SwiftUI

public struct LeavnColors {
    // MARK: - Primary Colors
    public static let primary = Color("Primary", bundle: .main)
    public static let primaryDark = Color("PrimaryDark", bundle: .main)
    public static let primaryLight = Color("PrimaryLight", bundle: .main)
    
    // MARK: - Semantic Colors
    public static let background = Color(UIColor.systemBackground)
    public static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    public static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    public static let label = Color(UIColor.label)
    public static let secondaryLabel = Color(UIColor.secondaryLabel)
    public static let tertiaryLabel = Color(UIColor.tertiaryLabel)
    public static let placeholderText = Color(UIColor.placeholderText)
    
    public static let separator = Color(UIColor.separator)
    public static let opaqueSeparator = Color(UIColor.opaqueSeparator)
    
    // MARK: - Accent Colors
    public static let accent = Color.accentColor
    public static let success = Color.green
    public static let warning = Color.orange
    public static let error = Color.red
    public static let info = Color.blue
    
    // MARK: - Bible Specific
    public static let verseHighlight = Color.yellow.opacity(0.3)
    public static let crossReference = Color.blue.opacity(0.8)
    public static let redLetter = Color.red.opacity(0.8)
    
    // MARK: - Community Colors
    public static let prayerCardBackground = Color.blue.opacity(0.1)
    public static let groupCardBackground = Color.purple.opacity(0.1)
    
    // MARK: - Dynamic Colors
    public static func adaptiveColor(light: Color, dark: Color) -> Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Color Extensions
extension Color {
    public static let leavnPrimary = LeavnColors.primary
    public static let leavnBackground = LeavnColors.background
    public static let leavnSecondaryBackground = LeavnColors.secondaryBackground
    public static let leavnLabel = LeavnColors.label
    public static let leavnSecondaryLabel = LeavnColors.secondaryLabel
}