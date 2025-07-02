import SwiftUI
import LeavnCore

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            Text("Bible")
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(TabItem.bible)
            
            Text("Search")
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(TabItem.search)
            
            Text("Library")
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(TabItem.library)
            
            Text("Community")
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(TabItem.community)
            
            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(TabItem.settings)
        }
    }
}
