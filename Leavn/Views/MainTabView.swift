import SwiftUI
import LeavnCore
import LeavnBible
import LeavnSearch
import LeavnLibrary
import LeavnCommunity
import LeavnSettings
import DesignSystem
import LeavnServices
// import LeavnCommunity (removed unnecessary import)
// import LeavnSettings (removed unnecessary import)
// import DesignSystem (removed unnecessary import)

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: TabItem = TabItem.bible { BibleView() }
    
    private var tabItems: [TabItem] {
        [
            TabItem.bible { BibleView() },
            TabItem.search { SearchView() },
            TabItem.library { LibraryView() },
            TabItem.community { CommunityView() },
            TabItem.settings { SettingsView() }
        ]
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                ForEach(tabItems) { item in
                    item.content
                        .tag(item)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            
            // Custom liquid glass tab bar
            LeavnCustomTabBar(
                selectedTab: $selectedTab,
                tabItems: tabItems
            )
            .padding(.horizontal)
            .padding(.bottom, safeAreaInset)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: selectedTab) { _, newValue in
            appState.selectedTabId = newValue.id
        }
        .onAppear {
            // Set initial tab based on app state
            if let initialTab = tabItems.first(where: { $0.id == appState.selectedTabId }) {
                selectedTab = initialTab
            }
        }
    }
    
    private var safeAreaInset: CGFloat {
        UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .map({$0 as? UIWindowScene})
            .compactMap({$0})
            .first?.windows
            .filter({$0.isKeyWindow}).first?.safeAreaInsets.bottom ?? 0
    }
}

// MARK: - Custom Liquid Glass Tab Bar
struct LeavnCustomTabBar: View {
    @Binding var selectedTab: TabItem
    let tabItems: [TabItem]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabItems) { tab in
                AnimatedTabItem(
                    icon: tab.icon,
                    title: tab.title,
                    isSelected: selectedTab.id == tab.id,
                    action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    }
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 14)
        .frame(height: 88, alignment: .top)
        .background(.regularMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AppState())
            .environmentObject(DIContainer.shared)
    }
}
#endif
