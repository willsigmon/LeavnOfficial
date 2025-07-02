import SwiftUI
import LeavnCore
import LeavnServices
import LeavnSearch
import LeavnLibrary
import LeavnCommunity
import LeavnSettings

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            TabView(selection: $selectedTab) {
                BibleView()
                    .tag(0)
                
                SearchView()
                    .tag(1)
                
                LibraryView()
                    .tag(2)
                
                CommunityView()
                    .tag(3)
                
                SettingsView()
                    .tag(4)
            }
            
            // Custom tab bar
            customTabBar
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            previousTab = oldValue
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            AnimatedTabItem(
                icon: "book",
                title: "Bible",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }
            
            AnimatedTabItem(
                icon: "magnifyingglass",
                title: "Search",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }
            
            AnimatedTabItem(
                icon: "books.vertical",
                title: "Library",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
            
            AnimatedTabItem(
                icon: "person.3",
                title: "Community",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
            
            AnimatedTabItem(
                icon: "gearshape",
                title: "Settings",
                isSelected: selectedTab == 4
            ) {
                selectedTab = 4
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(LeavnTheme.Colors.glassBorder, lineWidth: 1)
                )
        )
        .shadow(
            color: LeavnTheme.Shadows.elevation.color,
            radius: LeavnTheme.Shadows.elevation.radius,
            x: 0,
            y: LeavnTheme.Shadows.elevation.y
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}
