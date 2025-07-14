import SwiftUI
import Combine

/// Coordinates app-wide state and navigation
@MainActor
public final class AppCoordinator: ObservableObject {
    // MARK: - Published Properties
    @Published public var isFirstLaunch: Bool
    @Published public var showOnboarding = false
    @Published public var currentUser: User?
    @Published public var isAuthenticated = false
    @Published public var showMainApp = false
    
    // MARK: - Navigation State
    @Published public var selectedTab: AppTab = .home
    @Published public var navigationPath = NavigationPath()
    @Published public var presentedSheet: SheetType?
    @Published public var presentedAlert: AlertType?
    
    // MARK: - App State
    @Published public var isLoading = false
    @Published public var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.isFirstLaunch = !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if isFirstLaunch {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Monitor authentication state
        $isAuthenticated
            .sink { [weak self] authenticated in
                self?.showMainApp = authenticated && !self!.showOnboarding
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Navigation Methods
    public func navigate(to destination: NavigationDestination) {
        navigationPath.append(destination)
    }
    
    public func popToRoot() {
        navigationPath.removeLast(navigationPath.count)
    }
    
    public func selectTab(_ tab: AppTab) {
        selectedTab = tab
    }
    
    public func present(sheet: SheetType) {
        presentedSheet = sheet
    }
    
    public func present(alert: AlertType) {
        presentedAlert = alert
    }
    
    public func dismissSheet() {
        presentedSheet = nil
    }
    
    public func dismissAlert() {
        presentedAlert = nil
    }
    
    // MARK: - App Flow
    public func completeOnboarding() {
        showOnboarding = false
        isFirstLaunch = false
        if isAuthenticated {
            showMainApp = true
        }
    }
    
    public func signIn(user: User) {
        currentUser = user
        isAuthenticated = true
    }
    
    public func signOut() {
        currentUser = nil
        isAuthenticated = false
        showMainApp = false
        popToRoot()
    }
}

// MARK: - Sheet Types
public enum SheetType: Identifiable {
    case profile
    case settings
    case search
    case share(content: String)
    case bibleInfo(book: String)
    case devotion(Devotion)
    case prayerRequest
    case newPost
    
    public var id: String {
        switch self {
        case .profile: return "profile"
        case .settings: return "settings"
        case .search: return "search"
        case .share: return "share"
        case .bibleInfo: return "bibleInfo"
        case .devotion: return "devotion"
        case .prayerRequest: return "prayerRequest"
        case .newPost: return "newPost"
        }
    }
}

// MARK: - Alert Types
public enum AlertType: Identifiable {
    case error(message: String)
    case confirmation(title: String, message: String, action: () -> Void)
    case success(message: String)
    
    public var id: String {
        switch self {
        case .error: return "error"
        case .confirmation: return "confirmation"
        case .success: return "success"
        }
    }
}