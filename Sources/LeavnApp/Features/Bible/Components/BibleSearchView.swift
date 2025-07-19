import SwiftUI
import ComposableArchitecture

struct BibleSearchView: View {
    @Bindable var store: StoreOf<BibleReducer>
    @FocusState private var isSearchFocused: Bool
    @State private var selectedScope: SearchScope = .all
    
    enum SearchScope: String, CaseIterable {
        case all = "All"
        case oldTestament = "Old Testament"
        case newTestament = "New Testament"
        case currentBook = "Current Book"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search the Bible...", text: $store.searchQuery.sending(\.searchQueryChanged))
                        .textFieldStyle(.plain)
                        .focused($isSearchFocused)
                        .onSubmit {
                            store.send(.searchSubmitted)
                        }
                    
                    if !store.searchQuery.isEmpty {
                        Button(action: { store.send(.clearSearch) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Scope Selector
                Picker("Search Scope", selection: $selectedScope) {
                    ForEach(SearchScope.allCases, id: \.self) { scope in
                        Text(scope.rawValue).tag(scope)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Search Results
                if store.isSearching {
                    LoadingView(message: "Searching...")
                        .frame(maxHeight: .infinity)
                } else if store.searchResults.isEmpty && !store.searchQuery.isEmpty {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No verses found matching '\(store.searchQuery)'"
                    )
                } else if !store.searchResults.isEmpty {
                    SearchResultsList(
                        results: filteredResults,
                        onSelect: { result in
                            store.send(.selectSearchResult(result))
                        }
                    )
                } else {
                    // Recent Searches / Suggestions
                    RecentSearchesView(
                        recentSearches: store.recentSearches,
                        popularSearches: store.popularSearches,
                        onSelect: { query in
                            store.send(.searchQueryChanged(query))
                            store.send(.searchSubmitted)
                        }
                    )
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        store.send(.toggleSearch)
                    }
                }
            }
        }
        .onAppear {
            isSearchFocused = true
        }
    }
    
    private var filteredResults: [SearchResult] {
        switch selectedScope {
        case .all:
            return store.searchResults
        case .oldTestament:
            return store.searchResults.filter { $0.book.isOldTestament }
        case .newTestament:
            return store.searchResults.filter { $0.book.isNewTestament }
        case .currentBook:
            return store.searchResults.filter { $0.book == store.currentBook }
        }
    }
}

struct SearchResultsList: View {
    let results: [SearchResult]
    let onSelect: (SearchResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(results) { result in
                    SearchResultRow(result: result)
                        .onTapGesture {
                            onSelect(result)
                        }
                    
                    Divider()
                        .padding(.leading, 60)
                }
            }
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Book Icon
            Image(systemName: result.book.icon)
                .font(.title2)
                .foregroundColor(.leavnPrimary)
                .frame(width: 40, height: 40)
                .background(Color.leavnPrimary.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                // Reference
                Text("\(result.book.name) \(result.chapter):\(result.verse)")
                    .font(.headline)
                
                // Verse Text with Highlighted Query
                Text(highlightedText)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.tertiaryLabel)
        }
        .padding()
        .contentShape(Rectangle())
    }
    
    private var highlightedText: AttributedString {
        var attributedString = AttributedString(result.text)
        
        // Highlight search terms
        if let range = attributedString.range(of: result.query, options: [.caseInsensitive, .diacriticInsensitive]) {
            attributedString[range].backgroundColor = .yellow.opacity(0.3)
            attributedString[range].font = .callout.bold()
        }
        
        return attributedString
    }
}

struct RecentSearchesView: View {
    let recentSearches: [String]
    let popularSearches: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Searches")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(recentSearches, id: \.self) { search in
                            Button(action: { onSelect(search) }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(search)
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Searches")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                        ForEach(popularSearches, id: \.self) { search in
                            Button(action: { onSelect(search) }) {
                                Text(search)
                                    .font(.callout)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.leavnPrimary.opacity(0.1))
                                    .foregroundColor(.leavnPrimary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
}

// Mock SearchResult model
struct SearchResult: Identifiable {
    let id = UUID()
    let book: Book
    let chapter: Int
    let verse: Int
    let text: String
    let query: String
}

// Book Extensions
extension Book {
    var icon: String {
        switch self {
        case .genesis, .exodus, .leviticus, .numbers, .deuteronomy:
            return "books.vertical"
        case .psalms:
            return "music.note"
        case .proverbs:
            return "lightbulb"
        case .matthew, .mark, .luke, .john:
            return "cross"
        case .acts:
            return "flame"
        case .revelation:
            return "crown"
        default:
            return "book"
        }
    }
    
    var isOldTestament: Bool {
        // Implementation based on actual book enum
        true
    }
    
    var isNewTestament: Bool {
        !isOldTestament
    }
}