// AppColors.swift: Centralized, scalable color palette for app-wide theming.

import SwiftUI

/// Provides a centralized, scalable color palette for app-wide theming.
public struct AppColors {
    // MARK: - Primary Colors
    
    /// The primary brand color.
    public static let primary = Color("PrimaryColor", bundle: .main)
    
    /// A darker variant of the primary brand color.
    public static let primaryDark = Color("PrimaryDarkColor", bundle: .main)
    
    /// A lighter variant of the primary brand color.
    public static let primaryLight = Color("PrimaryLightColor", bundle: .main)
    
    // MARK: - Semantic Colors
    
    /// The main background color for views.
    public static let background = Color("BackgroundColor", bundle: .main)
    
    /// A secondary background color, used for grouped or secondary content.
    public static let secondaryBackground = Color("SecondaryBackgroundColor", bundle: .main)
    
    /// A tertiary background color, used for subtle backgrounds.
    public static let tertiaryBackground = Color("TertiaryBackgroundColor", bundle: .main)
    
    /// The primary color for text.
    public static let text = Color("TextColor", bundle: .main)
    
    /// A secondary color for less prominent text.
    public static let secondaryText = Color("SecondaryTextColor", bundle: .main)
    
    /// A tertiary color for even less prominent text elements.
    public static let tertiaryText = Color("TertiaryTextColor", bundle: .main)
    
    // MARK: - Status Colors
    
    /// Color representing success status.
    public static let success = Color.green
    
    /// Color representing warning status.
    public static let warning = Color.orange
    
    /// Color representing error status.
    public static let error = Color.red
    
    /// Color representing informational status.
    public static let info = Color.blue
    
    // MARK: - Feature Colors
    
    /// A red color with high opacity for red letter styling.
    public static let redLetter = Color.red.opacity(0.9)
    
    /// A yellow highlight color with reduced opacity.
    public static let highlightYellow = Color.yellow.opacity(0.3)
    
    /// A blue color used for bookmarks.
    public static let bookmarkBlue = Color.blue
    
    /// A green color used for notes.
    public static let noteGreen = Color.green
    
    // MARK: - Default Implementations (fallbacks)
    
    /// Default fallback colors used when asset colors are unavailable.
    public struct Default {
        /// Default primary color fallback.
        public static let primary = Color.blue
        
        /// Default dark variant of primary color fallback.
        public static let primaryDark = Color.blue.opacity(0.8)
        
        /// Default light variant of primary color fallback.
        public static let primaryLight = Color.blue.opacity(0.3)
        
        /// Default system background color fallback.
        public static let background = Color(.systemBackground)
        
        /// Default secondary system background color fallback.
        public static let secondaryBackground = Color(.secondarySystemBackground)
        
        /// Default tertiary system background color fallback.
        public static let tertiaryBackground = Color(.tertiarySystemBackground)
        
        /// Default primary text color fallback.
        public static let text = Color(.label)
        
        /// Default secondary text color fallback.
        public static let secondaryText = Color(.secondaryLabel)
        
        /// Default tertiary text color fallback.
        public static let tertiaryText = Color(.tertiaryLabel)
    }
}

// MARK: - Color Extensions

public extension Color {
    /// Creates a color that adapts dynamically to light and dark interface styles.
    ///
    /// - Parameters:
    ///   - light: The color to use in light mode.
    ///   - dark: The color to use in dark mode.
    /// - Returns: A dynamic color that automatically switches based on the interface style.
    static func dynamic(light: Color, dark: Color) -> Color {
        return Color(UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}
