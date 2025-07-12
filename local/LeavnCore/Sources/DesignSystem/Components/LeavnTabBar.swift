import SwiftUI

public struct LeavnTabBar: View {
    @Binding var selection: TabItem
    let items: [TabItem]
    
    public init(selection: Binding<TabItem>, items: [TabItem]) {
        self._selection = selection
        self.items = items
    }
    
    public var body: some View {
        #if os(iOS)
        iosTabBar
        #elseif os(macOS)
        macOSTabBar
        #elseif os(visionOS)
        visionOSTabBar
        #else
        EmptyView()
        #endif
    }
    
    // MARK: - iOS Tab Bar
    #if os(iOS)
    private var iosTabBar: some View {
        TabView(selection: $selection) {
            ForEach(items) { item in
                item.content
                    .tabItem {
                        Label(item.title, systemImage: item.icon)
                    }
                    .tag(item)
            }
        }
    }
    #endif
    
    // MARK: - macOS Tab Bar
    #if os(macOS)
    private var macOSTabBar: some View {
        HSplitView {
            // Sidebar
            List(items, selection: $selection) { item in
                Label(item.title, systemImage: item.icon)
                    .tag(item)
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 200, idealWidth: 250, maxWidth: 300)
            
            // Content
            if let selectedItem = items.first(where: { $0 == selection }) {
                selectedItem.content
            } else {
                Text("Select an item")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    #endif
    
    // MARK: - visionOS Tab Bar
    #if os(visionOS)
    private var visionOSTabBar: some View {
        NavigationStack {
            ZStack {
                // Content
                if let selectedItem = items.first(where: { $0 == selection }) {
                    selectedItem.content
                }
                
                // Floating tab bar
                VStack {
                    Spacer()
                    
                    HStack(spacing: 20) {
                        ForEach(items) { item in
                            TabButton(
                                item: item,
                                isSelected: selection == item,
                                action: { selection = item }
                            )
                        }
                    }
                    .padding()
                    .background(.regularMaterial)
                    .cornerRadius(20)
                    .padding()
                }
            }
        }
    }
    
    struct TabButton: View {
        let item: TabItem
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    Image(systemName: item.icon)
                        .font(.title2)
                        .symbolVariant(isSelected ? .fill : .none)
                    
                    Text(item.title)
                        .font(.caption)
                }
                .foregroundStyle(isSelected ? .primary : .secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .hoverEffect()
        }
    }
    #endif
}

// MARK: - Tab Item Model
public struct TabItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let icon: String
    public let content: AnyView
    
    public init<Content: View>(
        id: String,
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.content = AnyView(content())
    }
    
    public static func == (lhs: TabItem, rhs: TabItem) -> Bool {
        lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Convenience Extensions
public extension TabItem {
    static func bible<Content: View>(@ViewBuilder content: () -> Content) -> TabItem {
        TabItem(id: "bible", title: "Bible", icon: "book.fill", content: content)
    }
    
    static func search<Content: View>(@ViewBuilder content: () -> Content) -> TabItem {
        TabItem(id: "search", title: "Search", icon: "magnifyingglass", content: content)
    }
    
    static func library<Content: View>(@ViewBuilder content: () -> Content) -> TabItem {
        TabItem(id: "library", title: "Library", icon: "books.vertical.fill", content: content)
    }
    
    static func community<Content: View>(@ViewBuilder content: () -> Content) -> TabItem {
        TabItem(id: "community", title: "Community", icon: "person.3.fill", content: content)
    }
    
    static func settings<Content: View>(@ViewBuilder content: () -> Content) -> TabItem {
        TabItem(id: "settings", title: "Settings", icon: "gearshape.fill", content: content)
    }
}
