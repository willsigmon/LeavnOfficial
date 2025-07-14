import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search the Bible...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            viewModel.performSearch()
                        }
                    
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
                        ForEach(viewModel.filters, id: \.self) { filter in
                            FilterChip(
                                title: filter,
                                isSelected: viewModel.selectedFilter == filter
                            ) {
                                viewModel.selectedFilter = filter
                            }
                        }
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
                        
                        List(viewModel.recentSearches, id: \.self) { search in
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                
                                Text(search)
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.searchText = search
                                viewModel.performSearch()
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
    let result: SearchResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(result.reference)
                    .font(.headline)
                
                Spacer()
                
                Text(result.book)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Text(result.text)
                .font(.body)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
}