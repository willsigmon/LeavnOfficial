import SwiftUI

public struct BibleReaderView: View {
    @StateObject private var viewModel: BibleViewModel
    @StateObject private var coordinator: BibleCoordinator
    @State private var scrollToVerse: Int?
    
    public init(viewModel: BibleViewModel, coordinator: BibleCoordinator) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._coordinator = StateObject(wrappedValue: coordinator)
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            content
                .navigationTitle(viewModel.state.currentReference ?? "Bible")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        navigationControls
                    }
                    
                    ToolbarItem(placement: .principal) {
                        referenceButton
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        menuButton
                    }
                }
                .sheet(isPresented: $coordinator.isShowingBookPicker) {
                    BookPickerView(
                        selectedBook: coordinator.selectedBook,
                        onSelect: viewModel.selectBook
                    )
                }
                .sheet(isPresented: $coordinator.isShowingChapterPicker) {
                    if let book = coordinator.selectedBook {
                        ChapterPickerView(
                            book: book,
                            selectedChapter: coordinator.currentChapter,
                            onSelect: viewModel.goToChapter
                        )
                    }
                }
                .sheet(isPresented: $coordinator.isShowingTranslationPicker) {
                    TranslationPickerView(
                        selectedTranslation: coordinator.currentTranslation,
                        onSelect: viewModel.selectTranslation
                    )
                }
                .sheet(isPresented: $coordinator.isShowingVerseComparison) {
                    if let verse = coordinator.selectedVerse {
                        VerseComparisonView(verse: verse, viewModel: viewModel)
                    }
                }
                .sheet(isPresented: $coordinator.isShowingReaderSettings) {
                    ReaderSettingsView(config: viewModel.state.readingConfig)
                }
        }
        .task {
            await viewModel.onAppear()
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if viewModel.state.isLoadingChapter {
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let chapter = viewModel.state.currentChapter {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(chapter.verses) { verse in
                            VerseRowView(
                                verse: verse,
                                isBookmarked: viewModel.state.isVerseBookmarked(verse.id),
                                highlightColor: viewModel.state.highlightColor(verse.id),
                                config: viewModel.state.readingConfig,
                                onTap: { viewModel.selectVerse(verse) },
                                onBookmark: { await viewModel.toggleBookmark(for: verse) }
                            )
                            .id(verse.verse)
                        }
                    }
                    .padding()
                }
                .onChange(of: scrollToVerse) { _, newValue in
                    if let verse = newValue {
                        withAnimation {
                            proxy.scrollTo(verse, anchor: .top)
                        }
                    }
                }
            }
        } else {
            ContentUnavailableView(
                "Select a Book",
                systemImage: "book.closed",
                description: Text("Choose a book to start reading")
            )
        }
    }
    
    private var navigationControls: some View {
        HStack(spacing: 16) {
            Button(action: viewModel.goToPreviousChapter) {
                Image(systemName: "chevron.left")
            }
            .disabled(coordinator.currentChapter == 1 && coordinator.selectedBook == nil)
            
            Button(action: viewModel.goToNextChapter) {
                Image(systemName: "chevron.right")
            }
            .disabled(
                coordinator.selectedBook == nil ||
                coordinator.currentChapter >= (coordinator.selectedBook?.chapters ?? 0)
            )
        }
    }
    
    private var referenceButton: some View {
        Button(action: viewModel.showBookPicker) {
            HStack(spacing: 4) {
                Text(viewModel.state.currentReference ?? "Select Book")
                    .font(.headline)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
        }
    }
    
    private var menuButton: some View {
        Menu {
            Button(action: viewModel.showTranslationPicker) {
                Label(coordinator.currentTranslation.fullName, systemImage: "character.book.closed")
            }
            
            Button(action: viewModel.showReaderSettings) {
                Label("Reader Settings", systemImage: "textformat")
            }
            
            Divider()
            
            Button(action: { /* Show bookmarks */ }) {
                Label("Bookmarks", systemImage: "bookmark")
            }
            
            Button(action: { /* Show highlights */ }) {
                Label("Highlights", systemImage: "highlighter")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}

// MARK: - Supporting Views

struct VerseRowView: View {
    let verse: BibleVerse
    let isBookmarked: Bool
    let highlightColor: String?
    let config: BibleReadingConfig
    let onTap: () -> Void
    let onBookmark: () async -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if config.showVerseNumbers {
                Text("\(verse.verse)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(minWidth: 20, alignment: .trailing)
            }
            
            Text(verse.text)
                .font(.system(size: config.fontSize))
                .lineSpacing(config.lineSpacing)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    highlightColor.map { Color($0).opacity(0.3) }
                )
                .onTapGesture(perform: onTap)
            
            Button(action: { Task { await onBookmark() } }) {
                Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(isBookmarked ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, config.paragraphSpacing * 4)
    }
}

// Placeholder views
struct BookPickerView: View {
    let selectedBook: BibleBook?
    let onSelect: (BibleBook) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Book Picker")
                .navigationTitle("Select Book")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct ChapterPickerView: View {
    let book: BibleBook
    let selectedChapter: Int
    let onSelect: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Chapter Picker for \(book.name)")
                .navigationTitle("Select Chapter")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
        }
    }
}

struct TranslationPickerView: View {
    let selectedTranslation: BibleTranslation
    let onSelect: (BibleTranslation) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(BibleTranslation.allCases, id: \.self) { translation in
                HStack {
                    VStack(alignment: .leading) {
                        Text(translation.rawValue)
                            .font(.headline)
                        Text(translation.fullName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    if translation == selectedTranslation {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(translation)
                    dismiss()
                }
            }
            .navigationTitle("Select Translation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

struct VerseComparisonView: View {
    let verse: BibleVerse
    let viewModel: BibleViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Verse Comparison")
                .navigationTitle("Compare Translations")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}

struct ReaderSettingsView: View {
    let config: BibleReadingConfig
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Text("Reader Settings")
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") { dismiss() }
                    }
                }
        }
    }
}