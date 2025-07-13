import SwiftUI
import LeavnCore
import LeavnBible
import LeavnSearch
import LeavnLibrary
import LeavnCommunity
import LeavnSettings
import LeavnLifeSituations
import DesignSystem

private enum MainTab: Int, CaseIterable {
    case home = 0, bible, search, library, lifeSituations, settings
    // case community // Hidden for now - coming soon
}

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: MainTab = .home
    @State private var previousTab: MainTab = .home
    
    var body: some View {
        if appState.isInitialized {
            ZStack(alignment: .bottom) {
                // Content
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(MainTab.home)
                    
                    BibleView()
                        .tag(MainTab.bible)
                    
                    SearchView()
                        .tag(MainTab.search)
                    
                    LibraryView()
                        .tag(MainTab.library)
                    
                    LifeSituationsView()
                        .tag(MainTab.lifeSituations)

                    // CommunityView()
                    //     .tag(MainTab.community)
                    
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
        } else {
            // Loading screen while services initialize
            LoadingView()
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
        case .home: "house"
        case .bible: "book"
        case .search: "magnifyingglass"
        case .library: "books.vertical"
        case .lifeSituations: "heart.text.square"
        // case .community: "person.3"
        case .settings: "gearshape"
        }
    }
    
    private func title(for tab: MainTab) -> String {
        switch tab {
        case .home: "Home"
        case .bible: "Bible"
        case .search: "Search"
        case .library: "Library"
        case .lifeSituations: "Situations"
        // case .community: "Community"
        case .settings: "Settings"
        }
    }
    
    private var safeAreaInset: CGFloat {
        #if os(iOS)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        #endif
        return 0
    }
}

// MARK: - Loading View

struct LoadingView: View {
    @State private var progress: Double = 0.0
    @State private var animationAmount = 1.0
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo animation
            Image(systemName: "book.closed.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
                .scaleEffect(animationAmount)
                .animation(
                    .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                    value: animationAmount
                )
                .onAppear {
                    animationAmount = 1.2
                }
            
            VStack(spacing: 12) {
                Text("Leavn")
                    .font(.largeTitle.bold())
                
                Text("Preparing your experience...")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Progress indicator
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}
