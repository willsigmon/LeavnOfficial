import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            BibleView()
                .tabItem {
                    Label("Bible", systemImage: "book")
                }
                .tag(1)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(2)
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical")
                }
                .tag(3)
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
                .tag(4)
        }
    }
}

#Preview {
    MainTabView()
}