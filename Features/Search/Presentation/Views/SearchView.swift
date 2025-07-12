import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @StateObject private var coordinator: SearchCoordinator
    
    public init(viewModel: SearchViewModel, coordinator: SearchCoordinator) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationTitle("Search")
                .searchable(
                    text: .init(
                        get: { viewModel.state.query },
                        set: { viewModel.updateQuery($0) }
                    ),
                    prompt: "Search the Bible..."
                )
                .toolbar {
                    if !viewModel.state.recentSearches.isEmpty {
                        ToolbarItem(placement: .primaryAction) {
                            Button("Clear History") {
                                Task { await viewModel.clearRecentSearches() }
                            }
                        }
                    }
                }
                .sheet(isPresented: $coordinator.isShowingBibleReader) {
                    if let result = coordinator.selectedResult {
                        BibleReaderSheetView(result: result, coordinator: coordinator)
                    }
                }
        }
        .task {
            await viewModel.onAppear()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(spacing: 0) {
            filterBar
            
            if viewModel.state.isSearching {
                loadingView
            } else if viewModel.state.showEmptyState {
                emptyStateView
            } else if viewModel.state.showNoResults {
                noResultsView
            } else if viewModel.state.hasResults {
                searchResultsList
            }
        }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        isSelected: viewModel.state.selectedFilter == filter
                    ) {
                        viewModel.selectFilter(filter)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var searchResultsList: some View {
        List(viewModel.state.searchResults) { result in
            SearchResultRow(result: result) {
                viewModel.selectSearchResult(result)
            }
        }
        .listStyle(.plain)
    }
    
    private var emptyStateView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !viewModel.state.recentSearches.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Searches")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.state.recentSearches, id: \.self) { search in
                            Button(action: { viewModel.selectRecentSearch(search) }) {
                                HStack {
                                    Image(systemName: "clock")
                                        .foregroundColor(.secondary)
                                    Text(search)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
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
                        ForEach(viewModel.state.popularSearches, id: \.self) { search in
                            Button(action: { viewModel.selectPopularSearch(search) }) {
                                Text(search)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.accentColor.opacity(0.1))
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
    
    private var noResultsView: some View {
        ContentUnavailableView(
            "No Results",
            systemImage: "magnifyingglass",
            description: Text("No verses found for \"\(viewModel.state.query)\"")
        )
    }
    
    private var loadingView: some View {
        ProgressView("Searching...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Views

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(uiColor: .systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(result.reference)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(result.translation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(highlightedText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
    
    private var highlightedText: AttributedString {
        var attributedString = AttributedString(result.text)
        
        // Apply highlights
        for highlight in result.highlights {
            let startIndex = attributedString.index(
                attributedString.startIndex,
                offsetByCharacters: highlight.start
            )
            let endIndex = attributedString.index(
                startIndex,
                offsetByCharacters: highlight.length
            )
            
            if startIndex < attributedString.endIndex && endIndex <= attributedString.endIndex {
                attributedString[startIndex..<endIndex].backgroundColor = .yellow.opacity(0.3)
                attributedString[startIndex..<endIndex].foregroundColor = .primary
            }
        }
        
        return attributedString
    }
}

struct BibleReaderSheetView: View {
    let result: SearchResult
    let coordinator: SearchCoordinator
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text(result.reference)
                    .font(.largeTitle)
                    .padding()
                
                ScrollView {
                    Text(result.text)
                        .font(.body)
                        .padding()
                }
            }
            .navigationTitle("Bible Reader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                        coordinator.dismissBibleReader()
                    }
                }
            }
        }
    }
}