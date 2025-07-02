import SwiftUI
import LeavnCore
import DesignSystem
import LeavnBible

// MARK: - Main View

public struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @State private var selectedFilter: SearchFilter = .all
    @State private var selectedVerse: BibleVerse?
    @FocusState private var isSearchFocused: Bool

    public init() {}

    public var body: some View {
        ZStack {
            AnimatedGradientBackground()
            VStack(spacing: 0) {
                searchHeader
                contentBody
            }
        }
        .sheet(item: $selectedVerse) { verse in
            NavigationView {
                BibleReaderView(book: BibleBook(from: verse.bookName), chapter: verse.chapter)
            }
        }
    }

    private var contentBody: some View {
        Group {
            if searchText.isEmpty && viewModel.recentSearches.isEmpty && viewModel.searchResults.isEmpty {
                emptyState
            } else if viewModel.isSearching {
                Spacer()
                VibrantLoadingView(message: "Searching...")
                Spacer()
            } else {
                searchResultsList
            }
        }
    }
}

// MARK: - View Components

private extension SearchView {
    var searchHeader: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Search")
                    .font(LeavnTheme.Typography.displayMedium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LeavnTheme.Colors.accentLight, LeavnTheme.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)

            // Search Bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)

                TextField("Search the Bible...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(LeavnTheme.Typography.body)
                    .focused($isSearchFocused)
                    .onSubmit(performSearch)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        viewModel.clearSearch()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSearchFocused ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 2)
                    )
            )
            .padding(.horizontal, 20)
            .animation(LeavnTheme.Motion.quickBounce, value: isSearchFocused)

            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(SearchFilter.allCases, id: \.self) { filter in
                        FilterChip(
                            title: filter.title,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                            if !searchText.isEmpty {
                                performSearch()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }

    var emptyState: some View {
        VStack(spacing: 40) {
            Spacer()
            PlayfulEmptyState(
                icon: "magnifyingglass.circle",
                title: "Start Your Search",
                message: "Search for verses, words, or phrases across the entire Bible",
                buttonTitle: "Search Now",
                action: { isSearchFocused = true }
            )
            
            // Suggested Searches
            VStack(alignment: .leading, spacing: 16) {
                Text("Popular Searches")
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.secondary)
                VStack(spacing: 12) {
                    SuggestedSearchRow(text: "Love", icon: "heart.fill", color: LeavnTheme.Colors.error) {
                        searchText = "Love"; performSearch()
                    }
                    SuggestedSearchRow(text: "Faith", icon: "star.fill", color: LeavnTheme.Colors.warning) {
                        searchText = "Faith"; performSearch()
                    }
                    SuggestedSearchRow(text: "Peace", icon: "leaf.fill", color: LeavnTheme.Colors.success) {
                        searchText = "Peace"; performSearch()
                    }
                    SuggestedSearchRow(text: "Hope", icon: "sun.max.fill", color: LeavnTheme.Colors.info) {
                        searchText = "Hope"; performSearch()
                    }
                }
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }

    var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // Recent Searches
                if searchText.isEmpty && !viewModel.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Recent")
                                .font(LeavnTheme.Typography.headline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("Clear") {
                                Task {
                                    await viewModel.clearRecentSearches()
                                }
                            }
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(LeavnTheme.Colors.accent)
                        }
                        .padding(.horizontal, 20)

                        ForEach(viewModel.recentSearches, id: \.self) { search in
                            RecentSearchRow(text: search) {
                                searchText = search
                                performSearch()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }

                // Search Results
                if !viewModel.searchResults.isEmpty {
                    ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                        SearchResultCard(
                            result: result,
                            searchText: searchText,
                            delay: LeavnTheme.Motion.staggerDelay(index: index)
                        ) {
                            selectedVerse = BibleVerse(
                                bookName: result.bookName,
                                bookId: result.bookId,
                                chapter: result.chapter,
                                verse: result.verse,
                                text: result.text,
                                translation: result.translation
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 6)
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

// MARK: - Actions

private extension SearchView {
    func performSearch() {
        guard !searchText.isEmpty else { return }
        Task {
            await viewModel.search(query: searchText, filter: selectedFilter)
        }
        isSearchFocused = false
    }
}

// MARK: - Helper Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LeavnTheme.Typography.caption)
                .fontWeight(.semibold)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(isSelected ? LeavnTheme.Colors.accent : Color(UIColor.systemBackground))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(UIColor.separator), lineWidth: 0.5)
                )
        }
    }
}

struct SuggestedSearchRow: View {
    let text: String
    let icon: String
    let color: Color
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) { isPressed = true }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isPressed = false }
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                Text(text)
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(color)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
    }
}

struct RecentSearchRow: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                Text(text)
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct SearchResultCard: View {
    let result: SearchResult
    let searchText: String
    let delay: Double
    let action: () -> Void
    @State private var appear = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) { isPressed = true }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isPressed = false }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(result.bookName)
                        .font(LeavnTheme.Typography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(LeavnTheme.Colors.accent)
                    Text("•")
                        .foregroundColor(.secondary)
                    Text("Chapter \(result.chapter)")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("v.\(result.verse)")
                        .font(LeavnTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(LeavnTheme.Colors.accent)
                        )
                }
                Text(highlightedText)
                    .font(LeavnTheme.Typography.body)
                    .multilineTextAlignment(.leading)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .scaleEffect(isPressed ? 0.97 : 1)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            .animation(
                LeavnTheme.Motion.smoothSpring.delay(delay),
                value: appear
            )
        }
        .buttonStyle(.plain)
        .onAppear { appear = true }
    }
    
    private var highlightedText: AttributedString {
        var attributedString = AttributedString(result.text)
        
        // Find and highlight search text
        if let range = result.text.range(of: searchText, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: result.text)
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].foregroundColor = LeavnTheme.Colors.accent
                attributedString[attributedRange].font = LeavnTheme.Typography.body.bold()
            }
        }
        
        return attributedString
    }
}


