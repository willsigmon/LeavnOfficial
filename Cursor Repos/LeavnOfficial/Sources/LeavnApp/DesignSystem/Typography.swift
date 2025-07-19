import SwiftUI

public struct LeavnTypography {
    // MARK: - Display
    public static func largeTitle(_ text: String) -> some View {
        Text(text)
            .font(.largeTitle)
            .fontWeight(.bold)
            .fontDesign(.rounded)
    }
    
    public static func title(_ text: String) -> some View {
        Text(text)
            .font(.title)
            .fontWeight(.semibold)
    }
    
    public static func title2(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.semibold)
    }
    
    public static func title3(_ text: String) -> some View {
        Text(text)
            .font(.title3)
            .fontWeight(.medium)
    }
    
    // MARK: - Body
    public static func headline(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .fontWeight(.semibold)
    }
    
    public static func body(_ text: String) -> some View {
        Text(text)
            .font(.body)
    }
    
    public static func callout(_ text: String) -> some View {
        Text(text)
            .font(.callout)
    }
    
    public static func subheadline(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
    }
    
    public static func footnote(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
    }
    
    public static func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
    }
    
    public static func caption2(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
    }
    
    // MARK: - Bible Specific
    public static func verseNumber(_ number: Int) -> some View {
        Text("\(number)")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.leavnSecondaryLabel)
            .baselineOffset(-2)
    }
    
    public static func verseText(_ text: String) -> some View {
        Text(text)
            .font(.custom("Georgia", size: 18, relativeTo: .body))
            .lineSpacing(8)
    }
    
    public static func bookTitle(_ text: String) -> some View {
        Text(text)
            .font(.title2)
            .fontWeight(.bold)
            .fontDesign(.serif)
    }
    
    public static func chapterNumber(_ number: Int) -> some View {
        Text("\(number)")
            .font(.system(size: 48, weight: .light, design: .serif))
            .foregroundColor(.leavnSecondaryLabel)
    }
}

// MARK: - Text Modifiers
public struct LeavnTextStyle: ViewModifier {
    let style: TextStyle
    
    public enum TextStyle {
        case primary
        case secondary
        case tertiary
        case accent
        case error
        case success
    }
    
    public func body(content: Content) -> some View {
        content
            .foregroundColor(color)
    }
    
    private var color: Color {
        switch style {
        case .primary: return .leavnLabel
        case .secondary: return .leavnSecondaryLabel
        case .tertiary: return LeavnColors.tertiaryLabel
        case .accent: return LeavnColors.accent
        case .error: return LeavnColors.error
        case .success: return LeavnColors.success
        }
    }
}

extension View {
    public func leavnTextStyle(_ style: LeavnTextStyle.TextStyle) -> some View {
        modifier(LeavnTextStyle(style: style))
    }
}