import SwiftUI
import ComposableArchitecture

struct BookmarksGridView: View {
    let bookmarks: [Bookmark]
    let showViewAll: Bool
    let onViewAll: () -> Void
    
    init(bookmarks: [Bookmark], showViewAll: Bool = true, onViewAll: @escaping () -> Void) {
        self.bookmarks = bookmarks
        self.showViewAll = showViewAll
        self.onViewAll = onViewAll
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(bookmarks) { bookmark in
                    BookmarkCard(bookmark: bookmark)
                }
                
                if showViewAll {
                    ViewAllCard(title: "View All") {
                        onViewAll()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct BookmarkCard: View {
    let bookmark: Bookmark
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Color Indicator
            HStack {
                Circle()
                    .fill(Color(bookmark.color.uiColor))
                    .frame(width: 12, height: 12)
                
                Spacer()
                
                Image(systemName: "bookmark.fill")
                    .font(.caption)
                    .foregroundColor(.leavnPrimary)
            }
            
            // Reference
            VStack(alignment: .leading, spacing: 4) {
                Text(bookmark.book.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("\(bookmark.chapter):\(bookmark.startVerse)\(bookmark.endVerse != nil ? "-\(bookmark.endVerse!)" : "")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Title or Note Preview
            if let title = bookmark.title {
                Text(title)
                    .font(.caption)
                    .lineLimit(2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Date
            Text(bookmark.createdAt, style: .date)
                .font(.caption2)
                .foregroundColor(.tertiaryLabel)
        }
        .padding()
        .frame(width: 160, height: 140)
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            // Navigate to bookmark
        }
        .onLongPressGesture(
            minimumDuration: .infinity,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

struct EnhancedBookmarksView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @State private var selectedFilter: BookmarkFilter = .all
    @State private var selectedSort: BookmarkSort = .dateCreated
    @State private var viewMode: ViewMode = .grid
    
    enum BookmarkFilter: String, CaseIterable {
        case all = "All"
        case byBook = "By Book"
        case byColor = "By Color"
        case recent = "Recent"
    }
    
    enum BookmarkSort: String, CaseIterable {
        case dateCreated = "Date Created"
        case book = "Book Order"
        case alphabetical = "Alphabetical"
    }
    
    enum ViewMode: String, CaseIterable {
        case grid = "Grid"
        case list = "List"
        
        var icon: String {
            switch self {
            case .grid: return "square.grid.2x2"
            case .list: return "list.bullet"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                // Filter Menu
                Menu {
                    ForEach(BookmarkFilter.allCases, id: \.self) { filter in
                        Button(action: { selectedFilter = filter }) {
                            HStack {
                                Text(filter.rawValue)
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(selectedFilter.rawValue)
                        Image(systemName: "chevron.down")
                    }
                    .font(.callout)
                }
                
                Spacer()
                
                // View Mode Toggle
                Picker("View Mode", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search bookmarks...", text: $store.searchQuery.sending(\.searchQueryChanged))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)
            
            // Content
            if store.bookmarks.isEmpty {
                EmptyStateView(
                    icon: "bookmark",
                    title: "No Bookmarks Yet",
                    message: "Start bookmarking your favorite verses",
                    buttonTitle: "Browse Bible",
                    action: {
                        // Navigate to Bible
                    }
                )
            } else {
                switch viewMode {
                case .grid:
                    BookmarksGridContent(
                        bookmarks: filteredBookmarks,
                        onSelect: { bookmark in
                            store.send(.bookmarkTapped(bookmark))
                        }
                    )
                case .list:
                    BookmarksListContent(
                        bookmarks: filteredBookmarks,
                        onSelect: { bookmark in
                            store.send(.bookmarkTapped(bookmark))
                        },
                        onDelete: { bookmark in
                            store.send(.bookmarkDeleted(bookmark.id))
                        }
                    )
                }
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var filteredBookmarks: [Bookmark] {
        var bookmarks = Array(store.bookmarks)
        
        // Apply search
        if !store.searchQuery.isEmpty {
            bookmarks = bookmarks.filter { bookmark in
                bookmark.reference.localizedCaseInsensitiveContains(store.searchQuery) ||
                bookmark.title?.localizedCaseInsensitiveContains(store.searchQuery) == true ||
                bookmark.book.name.localizedCaseInsensitiveContains(store.searchQuery)
            }
        }
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .byBook:
            // Group by book (handled in view)
            break
        case .byColor:
            // Group by color (handled in view)
            break
        case .recent:
            bookmarks = Array(bookmarks.prefix(20))
        }
        
        // Apply sort
        switch selectedSort {
        case .dateCreated:
            bookmarks.sort { $0.createdAt > $1.createdAt }
        case .book:
            bookmarks.sort { $0.book.rawValue < $1.book.rawValue }
        case .alphabetical:
            bookmarks.sort { ($0.title ?? $0.reference) < ($1.title ?? $1.reference) }
        }
        
        return bookmarks
    }
}

struct BookmarksGridContent: View {
    let bookmarks: [Bookmark]
    let onSelect: (Bookmark) -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(bookmarks) { bookmark in
                    BookmarkGridItem(bookmark: bookmark) {
                        onSelect(bookmark)
                    }
                }
            }
            .padding()
        }
    }
}

struct BookmarkGridItem: View {
    let bookmark: Bookmark
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(Color(bookmark.color.uiColor))
                        .frame(width: 16, height: 16)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(.leavnPrimary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.book.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(bookmark.reference)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if let title = bookmark.title {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Text(bookmark.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.tertiaryLabel)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 140)
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct BookmarksListContent: View {
    let bookmarks: [Bookmark]
    let onSelect: (Bookmark) -> Void
    let onDelete: (Bookmark) -> Void
    
    var body: some View {
        List {
            ForEach(bookmarks) { bookmark in
                BookmarkListRow(bookmark: bookmark)
                    .onTapGesture {
                        onSelect(bookmark)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDelete(bookmark)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            // Share action
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.plain)
    }
}

struct BookmarkListRow: View {
    let bookmark: Bookmark
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(bookmark.color.uiColor))
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(bookmark.title ?? bookmark.reference)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "bookmark.fill")
                        .font(.caption)
                        .foregroundColor(.leavnPrimary)
                }
                
                Text(bookmark.reference)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(bookmark.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
        }
        .padding(.vertical, 4)
    }
}