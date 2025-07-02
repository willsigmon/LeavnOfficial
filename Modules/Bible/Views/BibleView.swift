import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem

public struct BibleView: View {
    @StateObject private var viewModel: BibleViewModel
    @State private var showBookPicker = false
    @State private var selectedVerse: BibleVerse?
    @State private var animateEntry = false
    @State private var showSearch = false
    
    public init() {
        let container = DIContainer.shared
        _viewModel = StateObject(wrappedValue: BibleViewModel(
            bibleService: container.requireBibleService(),
            cacheService: container.requireCacheService(),
            libraryService: container.requireLibraryService(),
            analyticsService: container.analyticsService
        ))
    }
    
    public var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                // Custom navigation header
                customHeader
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    VibrantLoadingView(message: "Loading Scripture...")
                    Spacer()
                } else if viewModel.verses.isEmpty {
                    Spacer()
                    PlayfulEmptyState(
                        icon: "book.closed",
                        title: "No verses found",
                        message: "Try selecting a different chapter or book",
                        buttonTitle: "Choose Book",
                        action: { showBookPicker = true }
                    )
                    Spacer()
                } else {
                    versesList
                }
            }
            
            // Floating action buttons
            FloatingActionButtons(viewModel: viewModel, showSearch: $showSearch)
        }
        .sheet(isPresented: $showBookPicker) {
            BookPickerView(
                selectedBook: viewModel.currentBook,
                selectedChapter: viewModel.currentChapter
            ) { book, chapter in
                Task {
                    await viewModel.loadChapter(book: book, chapter: chapter)
                    animateEntry = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        animateEntry = true
                    }
                }
            }
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailView(verse: verse)
        }
        .sheet(isPresented: $showSearch) {
            // TODO: Navigate to SearchView from parent view to avoid circular dependency
            Text("Search functionality is available from the main tab bar")
                .padding()
        }
        .task {
            await viewModel.loadInitialData()
            animateEntry = true
        }
    }
    
    // MARK: - Subviews
    
    private var customHeader: some View {
        HStack {
            // Book & Chapter selector
            Button(action: { showBookPicker = true }) {
                HStack(spacing: 8) {
                    Text(viewModel.currentBook?.name ?? "Select Book")
                        .font(.headline)
                    
                    Text("\u{25BE}")
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Chapter navigation
            HStack(spacing: 16) {
                Button(action: {
                    Task { await viewModel.previousChapter() }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                }
                .disabled(!viewModel.canGoPrevious)
                .opacity(viewModel.canGoPrevious ? 1 : 0.5)
                
                Text("Chapter \(viewModel.currentChapter)")
                    .font(.headline)
                
                Button(action: {
                    Task { await viewModel.nextChapter() }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                }
                .disabled(!viewModel.canGoNext)
                .opacity(viewModel.canGoNext ? 1 : 0.5)
            }
        }
        .padding()
        .background(Material.ultraThinMaterial)
    }
    
    private var versesList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(viewModel.verses, id: \.id) { verse in
                    BibleVerseView(verse: verse, onTap: {
                        selectedVerse = verse
                    })
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .id(verse.id)
                    .opacity(animateEntry ? 1 : 0)
                    .offset(y: animateEntry ? 0 : 20)
                    .animation(.easeOut(duration: 0.3).delay(Double(verse.verse) * 0.03), value: animateEntry)
                }
            }
            .listStyle(PlainListStyle())
            .onChange(of: viewModel.verses) { _ in
                withAnimation {
                    if let firstVerse = viewModel.verses.first {
                        proxy.scrollTo(firstVerse.id, anchor: .top)
                    }
                }
            }
        }
    }
}

// MARK: - Floating Action Buttons
struct FloatingActionButtons: View {
    @ObservedObject var viewModel: BibleViewModel
    @Binding var showSearch: Bool
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                
                VStack(spacing: 16) {
                    // Search button
                    FloatingActionButton(icon: "magnifyingglass") {
                        showSearch = true
                    }
                    
                    // Navigation buttons
                    HStack(spacing: 16) {
                        FloatingActionButton(icon: "chevron.left") {
                            viewModel.previousChapter()
                        }
                        .opacity(viewModel.canGoPrevious ? 1 : 0.5)
                        .disabled(!viewModel.canGoPrevious)
                        
                        FloatingActionButton(icon: "chevron.right") {
                            viewModel.nextChapter()
                        }
                        .opacity(viewModel.canGoNext ? 1 : 0.5)
                        .disabled(!viewModel.canGoNext)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 30)
            }
        }
    }
}

// MARK: - Bible Verse View
struct BibleVerseView: View {
    let verse: BibleVerse
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Text("\(verse.verse)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(width: 24, alignment: .trailing)
                        .padding(.top, 2)
                    
                    Text(verse.text)
                        .font(.body)
                        .foregroundColor(verse.isRedLetter ? .accentColor : .primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Divider()
                    .padding(.leading, 32)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews
#Preview {
    BibleView()
}
