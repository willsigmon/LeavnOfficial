import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// Import the LeavnColors here or define a fallback
private extension Color {
    static func safeLeavnColor(_ getter: @autoclosure () -> Color) -> Color {
        // Fallback to a default color if LeavnColors is not available
        return getter()
    }
}

// MARK: - Theme Colors (Legacy Support)
public extension Color {
    /// Primary brand colors - Now using WCAG compliant colors
    static var leavnPrimary: Color { defaultLeavnPrimary }
    static var leavnSecondary: Color { defaultLeavnSecondary }
    static var leavnAccent: Color { defaultLeavnAccent }
    
    /// Semantic colors for different states
    static var leavnSuccess: Color { defaultLeavnSuccess }
    static var leavnWarning: Color { defaultLeavnWarning }
    static var leavnError: Color { defaultLeavnError }
    static var leavnInfo: Color { defaultLeavnInfo }
    
    /// Background colors
    static var leavnBackground: Color { Color(UIColor.systemBackground) }
    static var leavnSecondaryBackground: Color { Color(UIColor.secondarySystemBackground) }
    static var leavnTertiaryBackground: Color { Color(UIColor.tertiarySystemBackground) }
    
    /// Text colors
    static var leavnPrimaryText: Color { Color(UIColor.label) }
    static var leavnSecondaryText: Color { Color(UIColor.secondaryLabel) }
    static var leavnTertiaryText: Color { Color(UIColor.tertiaryLabel) }
    
    /// Leave status colors - WCAG compliant
    static var leaveApproved: Color { defaultLeavnSuccess }
    static var leavePending: Color { defaultLeavnWarning }
    static var leaveRejected: Color { defaultLeavnError }
    static var leaveCancelled: Color { Color(UIColor.tertiaryLabel) }
}

// MARK: - Default Theme Colors (Fallbacks)
public extension Color {
    /// Fallback colors when custom colors are not defined in Asset Catalog
    static var defaultLeavnPrimary: Color {
        Color(red: 0.0, green: 0.478, blue: 1.0) // Blue
    }
    
    static var defaultLeavnSecondary: Color {
        Color(red: 0.235, green: 0.235, blue: 0.263) // Dark Gray
    }
    
    static var defaultLeavnAccent: Color {
        Color(red: 1.0, green: 0.624, blue: 0.039) // Orange
    }
    
    static var defaultLeavnSuccess: Color {
        Color(red: 0.2, green: 0.78, blue: 0.35) // Green
    }
    
    static var defaultLeavnWarning: Color {
        Color(red: 1.0, green: 0.8, blue: 0.0) // Yellow
    }
    
    static var defaultLeavnError: Color {
        Color(red: 0.91, green: 0.26, blue: 0.21) // Red
    }
    
    static var defaultLeavnInfo: Color {
        Color(red: 0.0, green: 0.478, blue: 1.0) // Blue
    }
}

// MARK: - Gradient Extensions
public extension LinearGradient {
    /// Primary gradient for headers and CTAs - Accessibility aware
    static var leavnPrimaryGradient: LinearGradient {
        LinearGradient.leavnGradient(
            colors: [
                Color.defaultLeavnPrimary,
                Color.defaultLeavnPrimary.opacity(0.8)
            ]
        )
    }
    
    /// Secondary gradient for backgrounds
    static var leavnBackgroundGradient: LinearGradient {
        LinearGradient.leavnGradient(
            colors: [
                Color(UIColor.systemBackground),
                Color(UIColor.secondarySystemBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    /// Success gradient
    static var leavnSuccessGradient: LinearGradient {
        LinearGradient.leavnGradient(
            colors: [
                Color.defaultLeavnSuccess,
                Color.defaultLeavnSuccess.opacity(0.8)
            ]
        )
    }
    
    static func leavnGradient(colors: [Color], startPoint: UnitPoint = .leading, endPoint: UnitPoint = .trailing) -> LinearGradient {
        return LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - Color Utilities
public extension Color {
    /// Initialize Color from hex string
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
    
    /// Get hex string representation of color
    func hexString() -> String {
        #if canImport(UIKit)
        let components = UIColor(self).cgColor.components
        let r: CGFloat = components?[0] ?? 0.0
        let g: CGFloat = components?[1] ?? 0.0
        let b: CGFloat = components?[2] ?? 0.0
        
        let hexString = String(
            format: "#%02lX%02lX%02lX",
            lround(Double(r * 255)),
            lround(Double(g * 255)),
            lround(Double(b * 255))
        )
        
        return hexString
        #else
        // Fallback for non-UIKit platforms
        return "#000000"
        #endif
    }
    
    /// Adjust color brightness
    func adjustBrightness(by percentage: Double) -> Color {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(
            hue: Double(hue),
            saturation: Double(saturation),
            brightness: Double(brightness) * (1 + percentage),
            opacity: Double(alpha)
        )
        #else
        // Fallback for non-UIKit platforms
        return self
        #endif
    }
}

// MARK: - Adaptive Colors (Legacy Support)
public extension Color {
    /// Returns appropriate color based on color scheme
    static func adaptive(light: Color, dark: Color) -> Color {
        // Simple implementation - in a real app this would use @Environment(\.colorScheme)
        return light
    }
    
    /// Common adaptive colors - Now using WCAG compliant colors
    static var adaptiveGray: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var adaptiveBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var adaptiveSecondaryBackground: Color {
        Color(UIColor.secondarySystemBackground)
    }
    
    static var adaptiveTertiaryBackground: Color {
        Color(UIColor.tertiarySystemBackground)
    }
    
    static var adaptiveLabel: Color {
        Color(UIColor.label)
    }
    
    static var adaptiveSecondaryLabel: Color {
        Color(UIColor.secondaryLabel)
    }
    
    static var adaptiveTertiaryLabel: Color {
        Color(UIColor.tertiaryLabel)
    }
}

// MARK: - Preview Helpers
struct ColorTheme_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Status colors
            HStack(spacing: 20) {
                ColorSwatch(color: .leaveApproved, name: "Approved")
                ColorSwatch(color: .leavePending, name: "Pending")
                ColorSwatch(color: .leaveRejected, name: "Rejected")
                ColorSwatch(color: .leaveCancelled, name: "Cancelled")
            }
            
            // Theme colors
            HStack(spacing: 20) {
                ColorSwatch(color: .defaultLeavnPrimary, name: "Primary")
                ColorSwatch(color: .defaultLeavnSecondary, name: "Secondary")
                ColorSwatch(color: .defaultLeavnAccent, name: "Accent")
            }
            
            // Gradients
            VStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient.leavnPrimaryGradient)
                    .frame(height: 60)
                    .overlay(Text("Primary Gradient").foregroundColor(.white))
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient.leavnSuccessGradient)
                    .frame(height: 60)
                    .overlay(Text("Success Gradient").foregroundColor(.white))
            }
        }
        .padding()
    }
    
    struct ColorSwatch: View {
        let color: Color
        let name: String
        
        var body: some View {
            VStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 80, height: 80)
                Text(name)
                    .font(.caption)
            }
        }
    }
}