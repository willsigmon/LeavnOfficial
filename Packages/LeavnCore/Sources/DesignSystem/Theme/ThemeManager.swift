import SwiftUI
import Combine

// MARK: - Theme Manager
@MainActor
public class ThemeManager: ObservableObject {
    public static let shared = ThemeManager()
    
    @AppStorage("colorSchemePreference") public var colorSchemePreference: ColorSchemePreference = .system
    @AppStorage("selectedTheme") public var selectedTheme: ThemeName = .default
    @Published public var currentTheme: Theme = .default
    
    private init() {
        updateTheme()
    }
    
    public func updateTheme() {
        currentTheme = Theme(rawValue: selectedTheme.rawValue)
    }
    
    public func colorScheme(for scheme: ColorScheme) -> ColorScheme? {
        switch colorSchemePreference {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

// MARK: - Color Scheme Preference
public enum ColorSchemePreference: String, CaseIterable {
    case system = "System"
    case light = "Light" 
    case dark = "Dark"
}

// MARK: - Theme Names
public enum ThemeName: String, CaseIterable, Sendable {
    case `default` = "Default"
    case ocean = "Ocean"
    case forest = "Forest"
    case sunset = "Sunset"
    case midnight = "Midnight"
}

// MARK: - Theme Protocol
public protocol ThemeProtocol {
    var name: ThemeName { get }
    var colors: ThemeColors { get }
    var typography: Typography { get }
    var spacing: Spacing { get }
}

// MARK: - Theme
public struct Theme: ThemeProtocol, Sendable {
    public let name: ThemeName
    public let colors: ThemeColors
    public let typography: Typography
    public let spacing: Spacing
    
    public init(name: ThemeName) {
        self.name = name
        self.colors = ThemeColors(theme: name)
        self.typography = Typography()
        self.spacing = Spacing()
    }
    
    public static let `default` = Theme(name: .default)
}

// MARK: - Theme Colors
public struct ThemeColors: Sendable {
    public let primary: Color
    public let secondary: Color
    public let accent: Color
    public let background: Color
    public let surface: Color
    public let text: Color
    public let textSecondary: Color
    public let error: Color
    public let warning: Color
    public let success: Color
    public let info: Color
    
    public init(theme: ThemeName) {
        switch theme {
        case .default:
            // Use colors from LeavnTheme
            self.primary = LeavnTheme.Colors.accent
            self.secondary = LeavnTheme.Colors.accentLight
            self.accent = LeavnTheme.Colors.accentDark
            self.background = Color(UIColor.systemBackground)
            self.surface = Color(UIColor.secondarySystemBackground)
            self.text = Color(UIColor.label)
            self.textSecondary = Color(UIColor.secondaryLabel)
            self.error = LeavnTheme.Colors.error
            self.warning = LeavnTheme.Colors.warning
            self.success = LeavnTheme.Colors.success
            self.info = LeavnTheme.Colors.info
            
        case .ocean:
            self.primary = Color(hex: "#006BA6")
            self.secondary = Color(hex: "#0496FF")
            self.accent = Color(hex: "#3ABEFF")
            self.background = Color(hex: "#E8F4FD")
            self.surface = Color(hex: "#FFFFFF")
            self.text = Color(hex: "#1A1A1A")
            self.textSecondary = Color(hex: "#6B7280")
            self.error = Color(hex: "#EF4444")
            self.warning = Color(hex: "#F59E0B")
            self.success = Color(hex: "#10B981")
            self.info = Color(hex: "#3B82F6")
            
        case .forest:
            self.primary = Color(hex: "#2D5016")
            self.secondary = Color(hex: "#5D8A31")
            self.accent = Color(hex: "#8CBF3F")
            self.background = Color(hex: "#F3F7F0")
            self.surface = Color(hex: "#FFFFFF")
            self.text = Color(hex: "#1A1A1A")
            self.textSecondary = Color(hex: "#6B7280")
            self.error = Color(hex: "#DC2626")
            self.warning = Color(hex: "#D97706")
            self.success = Color(hex: "#059669")
            self.info = Color(hex: "#2563EB")
            
        case .sunset:
            self.primary = Color(hex: "#FF6B6B")
            self.secondary = Color(hex: "#FFE66D")
            self.accent = Color(hex: "#FF9FF3")
            self.background = Color(hex: "#FFF5F5")
            self.surface = Color(hex: "#FFFFFF")
            self.text = Color(hex: "#1A1A1A")
            self.textSecondary = Color(hex: "#6B7280")
            self.error = Color(hex: "#E11D48")
            self.warning = Color(hex: "#EA580C")
            self.success = Color(hex: "#16A34A")
            self.info = Color(hex: "#1D4ED8")
            
        case .midnight:
            self.primary = Color(hex: "#8B5CF6")
            self.secondary = Color(hex: "#A78BFA")
            self.accent = Color(hex: "#C4B5FD")
            self.background = Color(hex: "#0F0F23")
            self.surface = Color(hex: "#1A1A2E")
            self.text = Color(hex: "#FFFFFF")
            self.textSecondary = Color(hex: "#A0A0B8")
            self.error = Color(hex: "#F87171")
            self.warning = Color(hex: "#FBBF24")
            self.success = Color(hex: "#34D399")
            self.info = Color(hex: "#60A5FA")
        }
    }
}

// MARK: - Typography
public struct Typography: Sendable {
    public let largeTitle = Font.largeTitle
    public let title = Font.title
    public let title2 = Font.title2
    public let title3 = Font.title3
    public let headline = Font.headline
    public let body = Font.body
    public let callout = Font.callout
    public let subheadline = Font.subheadline
    public let footnote = Font.footnote
    public let caption = Font.caption
    public let caption2 = Font.caption2
}

// MARK: - Spacing
public struct Spacing: Sendable {
    public let xs: CGFloat = 4
    public let sm: CGFloat = 8
    public let md: CGFloat = 16
    public let lg: CGFloat = 24
    public let xl: CGFloat = 32
    public let xxl: CGFloat = 48
}

// MARK: - Theme Environment Key
public struct ThemeEnvironmentKey: EnvironmentKey {
    public typealias Value = Theme

    public static let defaultValue = Theme.default
}

public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

// MARK: - Theme View Modifier
public struct ThemedView: ViewModifier {
    @ObservedObject private var themeManager = ThemeManager.shared
    
    public func body(content: Content) -> some View {
        content
            .environment(\.theme, $themeManager.currentTheme)
            .preferredColorScheme(themeManager.colorScheme(for: .light))
    }
}

public extension View {
    func themed() -> some View {
        modifier(ThemedView())
    }
}
