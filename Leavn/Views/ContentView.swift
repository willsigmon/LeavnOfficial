import SwiftUI
import LeavnCore
import LeavnBible
import LeavnSearch
import LeavnLibrary
import LeavnCommunity
import LeavnSettings

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            BibleView()
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(TabItem.bible)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabItem.search)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(TabItem.library)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(TabItem.community)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabItem.settings)
        }
    }
}
