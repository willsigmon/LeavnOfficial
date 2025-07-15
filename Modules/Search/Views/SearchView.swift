import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    
    public init(viewModel: SearchViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search the Bible...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if !viewModel.searchText.isEmpty {
                        Button(action: viewModel.clearSearch) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Filter Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        FilterChip(title: "All", isSelected: true) {}
                        FilterChip(title: "Verses", isSelected: false) {}
                        FilterChip(title: "Topics", isSelected: false) {}
                    }
                    .padding(.horizontal)
                }
                
                // Content
                if viewModel.isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if !viewModel.searchResults.isEmpty {
                    // Search Results
                    List(viewModel.searchResults) { result in
                        SearchResultRow(result: result)
                    }
                } else if viewModel.searchText.isEmpty {
                    // Recent Searches
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Recent Searches")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button("Clear") {
                                viewModel.clearRecentSearches()
                            }
                            .font(.caption)
                        }
                        .padding(.horizontal)
                        
                        List(["Faith", "Love", "Hope"], id: \.self) { search in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                
                                Text(search)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.searchText = search
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Results",
                        systemImage: "magnifyingglass",
                        description: Text("Try searching for different terms")
                    )
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

struct SearchResultRow: View {
    let result: BibleSearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(result.verse.bookName) \(result.verse.chapter):\(result.verse.verse)")
                    .font(.headline)
                
                Spacer()
                
                Text(result.verse.bookName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(result.verse.text)
                .font(.body)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView(viewModel: SearchViewModel(
        searchService: DIContainer.shared.searchService,
        bibleService: DIContainer.shared.bibleService
    ))
}