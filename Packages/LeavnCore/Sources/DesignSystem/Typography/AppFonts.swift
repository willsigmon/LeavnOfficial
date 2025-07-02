import UIKit

public struct AppFonts {
    public enum Size: CGFloat {
        case caption = 12
        case footnote = 13
        case subheadline = 15
        case body = 17
        case headline = 18
        case title = 20
        case largeTitle = 34
    }

    public static func font(for size: Size, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: size.rawValue, weight: weight)
    }
}
