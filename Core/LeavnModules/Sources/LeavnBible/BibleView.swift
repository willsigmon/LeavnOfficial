import SwiftUI

public struct BibleView: View {
    @StateObject private var viewModel = BibleViewModel()
    @State private var searchText = ""
    @State private var verseReference = "John 3:16"
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab Bar
                BibleTabBar(
                    selectedTab: viewModel.state.selectedTab,
                    onTabSelected: { viewModel.send(.selectTab($0)) }
                )
                
                // Content
                switch viewModel.state.selectedTab {
                case .read:
                    readView
                case .search:
                    searchView
                case .favorites:
                    favoritesView
                }
            }
            .navigationTitle("Bible")
            .navigationBarTitleDisplayMode(.large)
            .background(ds.colors.background)
            .onAppear {
                viewModel.send(.loadTranslations)
                viewModel.send(.loadFavorites)
            }
        }
    }
    
    // MARK: - Read View
    private var readView: some View {
        ScrollView {
            VStack(spacing: ds.spacing.l) {
                // Translation Selector
                if !viewModel.state.translations.isEmpty {
                    TranslationSelector(
                        translations: viewModel.state.translations,
                        selectedTranslation: viewModel.state.selectedTranslation,
                        onTranslationSelected: { viewModel.send(.selectTranslation($0)) }
                    )
                    .padding(.horizontal)
                }
                
                // Verse Input
                VStack(spacing: ds.spacing.m) {
                    HStack {
                        TextField("Enter verse reference", text: $verseReference)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        LeavnIconButton(
                            icon: "arrow.right.circle.fill",
                            style: .primary
                        ) {
                            viewModel.send(.loadVerse(reference: verseReference))
                        }
                    }
                    
                    if let error = viewModel.state.error {
                        ErrorView(error: error)
                    }
                }
                .padding(.horizontal)
                
                // Current Verse
                if let verse = viewModel.state.currentVerse {
                    VerseCard(
                        verse: verse,
                        isFavorite: viewModel.state.favoriteVerses.contains(where: { $0.id == verse.id }),
                        onFavoriteToggle: { viewModel.send(.toggleFavorite(verse: verse)) }
                    )
                    .padding(.horizontal)
                }
                
                if viewModel.state.isLoading {
                    ProgressView()
                        .padding()
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Search View
    private var searchView: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(ds.colors.secondaryLabel)
                
                TextField("Search the Bible...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        viewModel.send(.searchBible(query: searchText))
                    }
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ds.colors.secondaryLabel)
                    }
                }
            }
            .padding()
            .background(ds.colors.secondaryBackground)
            .cornerRadius(ds.cornerRadius.m)
            .padding()
            
            // Search Results
            if viewModel.state.isSearching {
                ProgressView("Searching...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                SearchResultsList(
                    results: viewModel.state.searchResults,
                    onVerseSelected: { result in
                        viewModel.send(.loadVerse(reference: result.verse.reference))
                        viewModel.send(.selectTab(.read))
                    }
                )
            }
        }
    }
    
    // MARK: - Favorites View
    private var favoritesView: some View {
        ScrollView {
            LazyVStack(spacing: ds.spacing.m) {
                if viewModel.state.favoriteVerses.isEmpty {
                    EmptyStateView(
                        icon: "heart",
                        title: "No Favorites Yet",
                        message: "Verses you favorite will appear here"
                    )
                    .padding(.top, 100)
                } else {
                    ForEach(viewModel.state.favoriteVerses) { verse in
                        VerseCard(
                            verse: verse,
                            isFavorite: true,
                            onFavoriteToggle: { viewModel.send(.toggleFavorite(verse: verse)) }
                        )
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Supporting Views
private struct BibleTabBar: View {
    let selectedTab: BibleTab
    let onTabSelected: (BibleTab) -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(BibleTab.allCases, id: \.self) { tab in
                Button(action: { onTabSelected(tab) }) {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 24))
                        Text(tab.rawValue)
                            .font(ds.typography.labelSmall)
                    }
                    .foregroundColor(selectedTab == tab ? ds.colors.primary : ds.colors.secondaryLabel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, ds.spacing.s)
                }
            }
        }
        .background(ds.colors.secondaryBackground)
    }
}

private struct TranslationSelector: View {
    let translations: [BibleTranslation]
    let selectedTranslation: BibleTranslation?
    let onTranslationSelected: (BibleTranslation) -> Void
    
    var body: some View {
        Menu {
            ForEach(translations) { translation in
                Button(action: { onTranslationSelected(translation) }) {
                    HStack {
                        Text(translation.name)
                        if selectedTranslation?.id == translation.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedTranslation?.abbreviation ?? "Select")
                Image(systemName: "chevron.down")
            }
            .font(ds.typography.titleMedium)
            .foregroundColor(ds.colors.primary)
            .padding(.horizontal, ds.spacing.m)
            .padding(.vertical, ds.spacing.s)
            .background(ds.colors.primary.opacity(0.1))
            .cornerRadius(ds.cornerRadius.m)
        }
    }
}

private struct VerseCard: View {
    let verse: BibleVerse
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: ds.spacing.m) {
            HStack {
                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    Text(verse.reference)
                        .font(ds.typography.titleMedium)
                        .foregroundColor(ds.colors.primary)
                    
                    Text(verse.translation)
                        .font(ds.typography.labelSmall)
                        .foregroundColor(ds.colors.secondaryLabel)
                }
                
                Spacer()
                
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? ds.colors.error : ds.colors.secondaryLabel)
                }
            }
            
            Text(verse.text)
                .font(ds.typography.bodyLarge)
                .foregroundColor(ds.colors.label)
                .lineSpacing(4)
        }
        .padding()
        .background(ds.colors.secondaryBackground)
        .cornerRadius(ds.cornerRadius.m)
    }
}

private struct SearchResultsList: View {
    let results: [BibleSearchResult]
    let onVerseSelected: (BibleSearchResult) -> Void
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: ds.spacing.s) {
                ForEach(results) { result in
                    Button(action: { onVerseSelected(result) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: ds.spacing.xs) {
                                Text(result.verse.reference)
                                    .font(ds.typography.titleSmall)
                                    .foregroundColor(ds.colors.primary)
                                
                                Text(result.verse.text)
                                    .font(ds.typography.bodySmall)
                                    .foregroundColor(ds.colors.secondaryLabel)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(ds.colors.tertiaryLabel)
                        }
                        .padding()
                        .background(ds.colors.secondaryBackground)
                        .cornerRadius(ds.cornerRadius.s)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: ds.spacing.m) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(ds.colors.tertiaryLabel)
            
            Text(title)
                .font(ds.typography.titleLarge)
                .foregroundColor(ds.colors.label)
            
            Text(message)
                .font(ds.typography.bodyMedium)
                .foregroundColor(ds.colors.secondaryLabel)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private struct ErrorView: View {
    let error: Error
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(ds.colors.error)
            
            Text(error.localizedDescription)
                .font(ds.typography.bodySmall)
                .foregroundColor(ds.colors.error)
        }
        .padding()
        .background(ds.colors.error.opacity(0.1))
        .cornerRadius(ds.cornerRadius.s)
    }
}