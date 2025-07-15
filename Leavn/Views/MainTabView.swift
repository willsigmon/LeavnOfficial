import SwiftUI
import LeavnSearch
import LeavnLibrary
import LeavnCommunity

struct MainTabView: View {
    @State private var selectedTab = 0
    @Environment(\.diContainer) private var diContainer
    
    // Create ViewModels using the DI container
    @StateObject private var bibleViewModel: BibleViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var libraryViewModel: LibraryViewModel
    @StateObject private var communityViewModel: CommunityViewModel
    @StateObject private var settingsViewModel: SettingsViewModel
    
    init() {
        let container = DIContainer.shared
        
        // Initialize ViewModels with dependencies
        _bibleViewModel = StateObject(wrappedValue: BibleViewModel(
            bibleService: container.bibleService,
            userDataManager: container.userDataManager,
            analyticsService: container.analyticsService
        ))
        
        _searchViewModel = StateObject(wrappedValue: SearchViewModel(
            searchService: container.searchService,
            bibleService: container.bibleService,
            analyticsService: container.analyticsService
        ))
        
        _libraryViewModel = StateObject(wrappedValue: LibraryViewModel(
            libraryService: container.libraryService,
            analyticsService: container.analyticsService
        ))
        
        _communityViewModel = StateObject(wrappedValue: CommunityViewModel(
            communityService: container.communityService,
            analyticsService: container.analyticsService
        ))
        
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(
            userDataManager: container.userDataManager,
            analyticsService: container.analyticsService
        ))
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(bibleViewModel)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            BibleView()
                .environmentObject(bibleViewModel)
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(1)
            
            SearchView()
                .environmentObject(searchViewModel)
                .environmentObject(bibleViewModel)
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            LibraryView()
                .environmentObject(libraryViewModel)
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(3)
            
            CommunityView()
                .environmentObject(communityViewModel)
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(4)
        }
        .environmentObject(settingsViewModel)
    }
}

#Preview {
    MainTabView()
}