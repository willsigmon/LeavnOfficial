import SwiftUI
import LeavnCore
import LeavnServices

public struct BibleView: View {
    @State private var viewModel: BibleViewModel?
    @State private var showBookPicker = false
    @State private var selectedVerse: BibleVerse?
    @State private var isInitialized = false
    @State private var showAudioControls = false
    @State private var showBookInfo = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if isInitialized, let viewModel = viewModel {
                    // Header
                    header(viewModel: viewModel)
                    
                    // Content
                    content(viewModel: viewModel)
                } else {
                    // Loading state
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading Bible...")
                            .font(.headline)
                        Text("Initializing services...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .overlay(alignment: .bottom) {
                if showAudioControls, let viewModel = viewModel {
                    if let audioService = DIContainer.shared.audioService,
                       let book = viewModel.currentBook {
                        AudioControlsView(
                            audioService: audioService,
                            currentChapter: BibleChapter(
                                id: UUID().uuidString,
                                bookName: book.name,
                                bookId: book.id,
                                chapterNumber: viewModel.currentChapter,
                                verses: viewModel.verses
                            )
                        )
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: showAudioControls)
                    }
                }
            }
        }
        .onAppear {
            initializeIfNeeded()
        }
        .sheet(isPresented: $showBookPicker) {
            if let viewModel = viewModel {
                BookPickerView(
                    selectedBook: viewModel.currentBook,
                    selectedChapter: viewModel.currentChapter
                ) { book, chapter in
                    Task {
                        await viewModel.loadChapter(book: book, chapter: chapter)
                    }
                }
            }
        }
        .sheet(item: $selectedVerse) { verse in
            VerseDetailView(verse: verse)
        }
        .sheet(isPresented: $showBookInfo) {
            if let book = viewModel?.currentBook {
                BookInfoView(book: book, chapter: viewModel?.currentChapter ?? 1)
            }
        }
    }
    
    private func initializeIfNeeded() {
        guard !isInitialized else { return }
        
        Task {
            // Wait for DIContainer to be fully initialized
            await DIContainer.shared.waitForInitialization()
            
            // Now safely access services
            let container = DIContainer.shared
            let vm = BibleViewModel(
                bibleService: container.requireBibleService(),
                cacheService: container.requireCacheService(),
                libraryService: container.requireLibraryService(),
                analyticsService: container.analyticsService
            )
            
            await MainActor.run {
                self.viewModel = vm
                self.isInitialized = true
            }
            
            // Load initial data
            await vm.loadInitialData()
        }
    }
    
    // MARK: - Subviews
    
    private func header(viewModel: BibleViewModel) -> some View {
        HStack {
            // Book & Chapter selector
            Button(action: { showBookPicker = true }) {
                HStack(spacing: 4) {
                    Text(viewModel.currentBook?.name ?? "Select Book")
                        .font(.headline.bold())
                    Text("\(viewModel.currentChapter)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .foregroundColor(.primary)
            
            Spacer()
            
            HStack(spacing: 16) {
                // Info Button
                Button(action: {
                    showBookInfo = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
                
                // Audio Toggle
                Button(action: {
                    withAnimation(.spring()) {
                        showAudioControls.toggle()
                    }
                }) {
                    Image(systemName: showAudioControls ? "speaker.wave.3.fill" : "speaker.wave.3")
                        .font(.title3)
                        .foregroundColor(showAudioControls ? .accentColor : .primary)
                }
                
                // Previous Chapter
                Button(action: {
                    viewModel.previousChapter()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.bold())
                }
                .disabled(viewModel.isLoading)
                
                // Next Chapter
                Button(action: {
                    viewModel.nextChapter()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3.bold())
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
    
    private func content(viewModel: BibleViewModel) -> some View {
        Group {
            if viewModel.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Loading Scripture...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.verses.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No verses found")
                        .font(.title2.bold())
                    Text("Try selecting a different chapter or book")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Button("Choose Book") {
                        showBookPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                versesList(viewModel: viewModel)
            }
        }
    }
    
    private func versesList(viewModel: BibleViewModel) -> some View {
        List {
            ForEach(viewModel.verses, id: \.id) { verse in
                VerseRow(verse: verse) {
                    selectedVerse = verse
                }
            }
        }
        .listStyle(PlainListStyle())
    }
}

// MARK: - Verse Row Component

private struct VerseRow: View {
    let verse: BibleVerse
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(verse.verse)")
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
                    .frame(width: 30, alignment: .leading)
                
                Text(verse.text)
                    .font(.body)
                    .lineLimit(nil)
                
                Spacer()
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Previews
#Preview {
    BibleView()
}
