import SwiftUI
import LeavnBible
import LeavnSearch
import LeavnLibrary
import LeavnSettings
import LeavnCommunity
import LeavnServices

/// Main tab navigation view for the Leavn Bible app
/// Provides consistent navigation across all platforms with adaptive layouts
public struct MainTabView: View {
    @State private var selectedTab: AppTab = .bible
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.hapticManager) private var hapticManager
    
    public init() {}
    
    public var body: some View {
        Group {
            #if os(macOS) || os(visionOS)
            navigationSplitView
            #elseif os(watchOS)
            watchOSTabView
            #else
            if horizontalSizeClass == .regular {
                navigationSplitView
            } else {
                standardTabView
            }
            #endif
        }
    }
    
    // MARK: - Platform-Specific Views
    
    /// Standard tab view for iPhone and compact layouts
    private var standardTabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                tab.destination
                    .tabItem {
                        Label(tab.title, systemImage: tab.icon)
                    }
                    .tag(tab)
            }
        }
        .accentColor(.primary)
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue != newValue {
                hapticManager.triggerFeedback(.selection)
            }
        }
    }
    
    /// Navigation split view for iPad, macOS, and visionOS
    private var navigationSplitView: some View {
        NavigationSplitView {
            List(AppTab.allCases, id: \.self, selection: $selectedTab) { tab in
                NavigationLink(value: tab) {
                    Label(tab.title, systemImage: tab.icon)
                }
            }
            .navigationTitle("Leavn")
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 200, ideal: 250)
            #endif
        } detail: {
            selectedTab.destination
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue != newValue {
                hapticManager.triggerFeedback(.selection)
            }
        }
    }
    
    /// Compact tab view for Apple Watch
    @ViewBuilder
    private var watchOSTabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(AppTab.watchTabs, id: \.self) { tab in
                NavigationView {
                    tab.destination
                        .navigationTitle(tab.title)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(tab)
            }
        }
        .tabViewStyle(.page)
        .onChange(of: selectedTab) { oldValue, newValue in
            if oldValue != newValue {
                hapticManager.triggerFeedback(.selection)
            }
        }
    }
}

// MARK: - App Tab Enumeration

public enum AppTab: String, CaseIterable {
    case bible = "Bible"
    case search = "Search"
    case library = "Library"
    case community = "Community"
    case settings = "Settings"
    
    var title: String {
        return rawValue
    }
    
    var icon: String {
        switch self {
        case .bible: return "book.fill"
        case .search: return "magnifyingglass"
        case .library: return "books.vertical.fill"
        case .community: return "person.3.fill"
        case .settings: return "gear"
        }
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .bible:
            BibleView()
        case .search:
            SearchView()
        case .library:
            LibraryView()
        case .community:
            CommunityView()
        case .settings:
            SettingsView()
        }
    }
    
    /// Tabs available on Apple Watch (reduced set)
    static var watchTabs: [AppTab] {
        return [.bible, .search, .settings]
    }
}

// MARK: - Preview

#Preview("iPhone") {
    MainTabView()
        .environment(\.horizontalSizeClass, .compact)
}

#Preview("iPad") {
    MainTabView()
        .environment(\.horizontalSizeClass, .regular)
        .previewDevice("iPad Pro (12.9-inch) (6th generation)")
}

#if os(macOS)
#Preview("macOS") {
    MainTabView()
        .frame(minWidth: 800, minHeight: 600)
}
#endif

#if os(watchOS)
#Preview("watchOS") {
    MainTabView()
}
#endif