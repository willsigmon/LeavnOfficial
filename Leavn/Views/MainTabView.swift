import SwiftUI
import LeavnCore
import LeavnBible
import LeavnSearch
import LeavnLibrary
import LeavnCommunity
import LeavnSettings
import DesignSystem
// import LeavnCommunity (removed unnecessary import)
// import LeavnSettings (removed unnecessary import)
// import DesignSystem (removed unnecessary import)

private enum MainTab: Int, CaseIterable {
    case bible = 0, search, library, community, settings
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: MainTab = .bible
    @State private var previousTab: MainTab = .bible
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                BibleView()
                    .tag(MainTab.bible)
                
                SearchView()
                    .tag(MainTab.search)
                
                LibraryView()
                    .tag(MainTab.library)
                
                CommunityView()
                    .tag(MainTab.community)
                
                SettingsView()
                    .tag(MainTab.settings)
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .toolbar(.hidden, for: .tabBar)
            
            // Custom tab bar
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                customTabBar
            }
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                AnimatedTabItem(
                    icon: icon(for: tab),
                    title: title(for: tab),
                    isSelected: selectedTab == tab
                ) {
                    selectedTab = tab
                }
            }
        }
        .padding(.horizontal)
        .frame(height: 50)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.horizontal)
        .padding(.bottom, safeAreaInset > 0 ? 0 : 12)
    }
    
    private func icon(for tab: MainTab) -> String {
        switch tab {
        case .bible: "book"
        case .search: "magnifyingglass"
        case .library: "books.vertical"
        case .community: "person.3"
        case .settings: "gearshape"
        }
    }
    
    private func title(for tab: MainTab) -> String {
        switch tab {
        case .bible: "Bible"
        case .search: "Search"
        case .library: "Library"
        case .community: "Community"
        case .settings: "Settings"
        }
    }
    
    private var safeAreaInset: CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}
