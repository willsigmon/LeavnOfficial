import SwiftUI
import ComposableArchitecture

@main
struct LeavnApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: Store(initialState: AppFeature.State()) {
                    AppFeature()
                }
            )
        }
    }
}

struct RootView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        TabView {
            BibleView()
                .tabItem {
                    Label("Bible", systemImage: "book.fill")
                }
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3.fill")
                }
            
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: "books.vertical.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}

// Placeholder views - these would come from feature modules
struct BibleView: View {
    var body: some View {
        NavigationStack {
            Text("Bible Study")
                .navigationTitle("Bible")
        }
    }
}

struct CommunityView: View {
    var body: some View {
        NavigationStack {
            Text("Prayer Wall & Groups")
                .navigationTitle("Community")
        }
    }
}

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            Text("Bookmarks & Notes")
                .navigationTitle("Library")
        }
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            Text("App Settings")
                .navigationTitle("Settings")
        }
    }
}

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var selectedTab = 0
    }
    
    enum Action {
        case tabSelected(Int)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none
            }
        }
    }
}