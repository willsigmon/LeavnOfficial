import UIKit

public struct AppFonts {
    public enum Size: CGFloat {
        case small = 13      // Combines caption & footnote
        case medium = 17     // Body text
        case large = 20      // Headlines & titles
        case extraLarge = 28 // Section headers
        case display = 34    // Hero text & large titles
    }

    public static func font(for size: Size, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size.rawValue, weight: weight)
    }
}
