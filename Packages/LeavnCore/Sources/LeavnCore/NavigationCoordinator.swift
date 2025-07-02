import SwiftUI
import Combine

/// Main navigation coordinator for the app
@MainActor
public final class NavigationCoordinator: ObservableObject {
    
    // MARK: - Navigation State
    @Published public var selectedTab: AppTab = .home
    @Published public var navigationPaths: [AppTab: NavigationPath] = [:]
    @Published public var presentedSheet: SheetDestination?
    @Published public var presentedFullScreen: FullScreenDestination?
    
    // MARK: - Initialization
    public init() {
        // Initialize navigation paths for each tab
        for tab in AppTab.allCases {
            navigationPaths[tab] = NavigationPath()
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Navigate to a specific tab
    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    /// Push a destination onto the current tab's navigation stack
    public func push(_ destination: NavigationDestination) {
        navigationPaths[selectedTab]?.append(destination)
    }
    
    /// Pop the current view from the navigation stack
    public func pop() {
        if !navigationPaths[selectedTab]!.isEmpty {
            navigationPaths[selectedTab]!.removeLast()
        }
    }
    
    /// Pop to root of current tab
    public func popToRoot() {
        navigationPaths[selectedTab] = NavigationPath()
    }
    
    /// Present a sheet
    public func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    
    /// Dismiss the current sheet
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    /// Present a full screen cover
    public func presentFullScreen(_ destination: FullScreenDestination) {
        presentedFullScreen = destination
    }
    
    /// Dismiss the current full screen cover
    public func dismissFullScreen() {
        presentedFullScreen = nil
    }
    
    /// Reset all navigation state
    public func reset() {
        selectedTab = .home
        for tab in AppTab.allCases {
            navigationPaths[tab] = NavigationPath()
        }
        presentedSheet = nil
        presentedFullScreen = nil
    }
}

// MARK: - Navigation Destinations

/// Main app tabs
public enum AppTab: String, CaseIterable, Identifiable {
    case home
    case bible
    case search
    case library
    case settings
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .home: return "Home"
        case .bible: return "Bible"
        case .search: return "Search"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }
    
    public var icon: String {
        switch self {
        case .home: return "house.fill"
        case .bible: return "book.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

/// Navigation destinations for push navigation
public enum NavigationDestination: Hashable {
    case bibleChapter(book: String, chapter: Int)
    case bibleVerse(book: String, chapter: Int, verse: Int)
    case searchResults(query: String)
    case readingPlan(id: String)
    case bookmark(id: String)
    case devotion(id: String)
    case profile
    case preferences
    case about
}

/// Sheet destinations
public enum SheetDestination: Identifiable {
    case verseOptions(verse: BibleVerse)
    case addBookmark(verse: BibleVerse)
    case shareVerse(verse: BibleVerse)
    case noteEditor(verse: BibleVerse)
    case translationPicker
    case chapterPicker(book: String)
    case settings
    
    public var id: String {
        switch self {
        case .verseOptions: return "verseOptions"
        case .addBookmark: return "addBookmark"
        case .shareVerse: return "shareVerse"
        case .noteEditor: return "noteEditor"
        case .translationPicker: return "translationPicker"
        case .chapterPicker: return "chapterPicker"
        case .settings: return "settings"
        }
    }
}

/// Full screen destinations
public enum FullScreenDestination: Identifiable {
    case onboarding
    case readingMode(verses: [BibleVerse])
    case devotionReader(devotion: Devotion)
    
    public var id: String {
        switch self {
        case .onboarding: return "onboarding"
        case .readingMode: return "readingMode"
        case .devotionReader: return "devotionReader"
        }
    }
}

// MARK: - App Coordinator

/// Main app coordinator that manages app-wide state
@MainActor
public final class AppCoordinator: ObservableObject {
    @Published public var isFirstLaunch = false
    @Published public var currentUser: User?
    @Published public var preferences = UserPreferences()
    
    public init() {
        checkFirstLaunch()
    }
    
    private func checkFirstLaunch() {
        isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}
