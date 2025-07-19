import ComposableArchitecture
import SwiftUI

/// The root reducer that manages the entire app's state and coordinates between feature modules.
///
/// `AppReducer` serves as the composition root for the application, integrating all feature reducers
/// and handling app-level concerns like navigation, deep linking, and background tasks.
///
/// ## Topics
///
/// ### State Management
/// - ``State``
/// - ``Action``
/// - ``Tab``
///
/// ### Integration
/// The reducer integrates with:
/// - Bible reading features via ``BibleReducer``
/// - Community features via ``CommunityReducer``
/// - Library management via ``LibraryReducer``
/// - App settings via ``SettingsReducer``
@Reducer
public struct AppReducer {
    /// The root state of the application containing all feature states.
    @ObservableState
    public struct State: Equatable {
        /// State for Bible reading features including passage display and navigation.
        public var bible: BibleReducer.State
        
        /// State for community features including prayer wall and study groups.
        public var community: CommunityReducer.State
        
        /// State for personal library including bookmarks, notes, and downloads.
        public var library: LibraryReducer.State
        
        /// State for app settings and configuration.
        public var settings: SettingsReducer.State
        
        /// Currently selected tab in the main navigation.
        public var selectedTab: Tab = .bible
        
        /// Indicates if this is the user's first launch of the app.
        public var isFirstLaunch: Bool = true
        
        /// Creates a new app state with default values for all features.
        public init() {
            self.bible = BibleReducer.State()
            self.community = CommunityReducer.State()
            self.library = LibraryReducer.State()
            self.settings = SettingsReducer.State()
        }
    }
    
    /// Actions that can be performed at the app level or delegated to feature reducers.
    public enum Action {
        /// Actions related to Bible reading features.
        case bible(BibleReducer.Action)
        
        /// Actions related to community features.
        case community(CommunityReducer.Action)
        
        /// Actions related to library management.
        case library(LibraryReducer.Action)
        
        /// Actions related to app settings.
        case settings(SettingsReducer.Action)
        
        /// User selected a different tab in the tab bar.
        case tabSelected(Tab)
        
        /// App has appeared and is ready for initial setup.
        case onAppear
        
        /// User has completed the first launch onboarding.
        case onFirstLaunchComplete
        
        /// Handle a deep link URL to navigate to specific content.
        /// - Parameter URL: The deep link URL to process (e.g., `leavn://bible/john/3/16`)
        case handleDeepLink(URL)
        
        /// Save current app state to persistent storage.
        case saveState
        
        /// Resume any paused operations after app returns to foreground.
        case resumeOperations
        
        /// Perform background refresh tasks when triggered by the system.
        case performBackgroundRefresh
        
        /// Perform background processing for maintenance tasks.
        case performBackgroundProcessing
    }
    
    /// Available tabs in the main navigation.
    public enum Tab: String, CaseIterable, Identifiable {
        /// Bible reading and study features.
        case bible = "Bible"
        
        /// Community prayer wall and groups.
        case community = "Community"
        
        /// Personal bookmarks, notes, and downloads.
        case library = "Library"
        
        /// App configuration and preferences.
        case settings = "Settings"
        
        public var id: String { rawValue }
        
        /// SF Symbol icon name for the tab.
        public var icon: String {
            switch self {
            case .bible: return "book.fill"
            case .community: return "person.3.fill"
            case .library: return "books.vertical.fill"
            case .settings: return "gearshape.fill"
            }
        }
        
        /// Accessibility label for VoiceOver support.
        public var accessibilityLabel: String {
            switch self {
            case .bible: return "Bible reading and study"
            case .community: return "Community prayer wall and groups"
            case .library: return "Your personal library and notes"
            case .settings: return "App settings and preferences"
            }
        }
    }
    
    @Dependency(\.userDefaults) var userDefaults
    @Dependency(\.apiKeyManager) var apiKeyManager
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.bible, action: \.bible) {
            BibleReducer()
        }
        
        Scope(state: \.community, action: \.community) {
            CommunityReducer()
        }
        
        Scope(state: \.library, action: \.library) {
            LibraryReducer()
        }
        
        Scope(state: \.settings, action: \.settings) {
            SettingsReducer()
        }
        
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .onAppear:
                state.isFirstLaunch = userDefaults.isFirstLaunch
                return .none
                
            case .onFirstLaunchComplete:
                state.isFirstLaunch = false
                userDefaults.isFirstLaunch = false
                return .none
                
            case .handleDeepLink(let url):
                // Parse and handle deep links
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    switch components.host {
                    case "bible":
                        // Handle bible deep links: leavn://bible/john/3/16
                        state.selectedTab = .bible
                        if let pathComponents = components.path.split(separator: "/").map(String.init),
                           pathComponents.count >= 3 {
                            let book = pathComponents[0]
                            let chapter = Int(pathComponents[1]) ?? 1
                            let verse = pathComponents.count > 2 ? Int(pathComponents[2]) : nil
                            return .send(.bible(.navigateToReference(book: book, chapter: chapter, verse: verse)))
                        }
                    case "community":
                        // Handle community deep links: leavn://community/post/123
                        state.selectedTab = .community
                        if let pathComponents = components.path.split(separator: "/").map(String.init),
                           pathComponents.count >= 2 {
                            let type = pathComponents[0]
                            let id = pathComponents[1]
                            return .send(.community(.navigateToContent(type: type, id: id)))
                        }
                    case "library":
                        // Handle library deep links
                        state.selectedTab = .library
                    case "settings":
                        // Handle settings deep links
                        state.selectedTab = .settings
                    default:
                        break
                    }
                }
                return .none
                
            case .saveState:
                // Save current state to persistence
                return .run { _ in
                    // Trigger Core Data save
                    @Dependency(\.databaseClient) var databaseClient
                    try await databaseClient.save()
                }
                
            case .resumeOperations:
                // Resume any paused operations
                return .merge(
                    .send(.bible(.resumeAudio)),
                    .send(.community(.reconnectWebSocket))
                )
                
            case .performBackgroundRefresh:
                // Perform background refresh
                return .run { _ in
                    @Dependency(\.offlineService) var offlineService
                    @Dependency(\.communityService) var communityService
                    
                    // Download offline content
                    try await offlineService.syncOfflineContent()
                    
                    // Fetch latest community updates
                    try await communityService.fetchLatestUpdates()
                }
                
            case .performBackgroundProcessing:
                // Perform background processing
                return .run { _ in
                    @Dependency(\.libraryService) var libraryService
                    
                    // Process any pending library updates
                    try await libraryService.processPendingUpdates()
                }
                
            case .bible, .community, .library, .settings:
                return .none
            }
        }
    }
}