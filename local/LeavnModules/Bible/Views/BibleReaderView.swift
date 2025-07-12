import SwiftUI
import LeavnCore
import LeavnServices

public struct BibleReaderView: View {
    @StateObject private var viewModel: BibleReaderViewModel
    @State private var showChapterPicker = false
    @State private var showTranslationPicker = false
    @State private var showSettings = false
    @State private var showBookmarkSheet = false
    @State private var showAudioControls = false
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var container: DIContainer
    
    public init(book: BibleBook? = nil, chapter: Int? = nil) {
        _viewModel = StateObject(
            wrappedValue: BibleReaderViewModel(
                book: book,
                chapter: chapter ?? 1,
                bibleService: DIContainer.shared.bibleService,
                analyticsService: DIContainer.shared.analyticsService
            )
        )
    }
    
    public var body: some View {
        ZStack {
            // Background
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            // Content
            Group {
                if viewModel.isLoading {
                    VStack {
                        ProgressView("Loading...")
                            .padding()
                        Spacer()
                    }
                } else if let error = viewModel.error {
                    VStack {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                            .padding()
                        
                        Button("Retry") {
                            Task { await viewModel.loadChapter() }
                        }
                        .buttonStyle(.bordered)
                        .padding()
                        
                        Spacer()
                    }
                } else {
                    readerContent
                }
            }
        }
        .overlay(alignment: .bottom) {
            if showAudioControls {
                AudioControlsView(
                    audioService: DIContainer.shared.requireAudioService(),
                    currentChapter: viewModel.currentChapterObject
                )
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showAudioControls)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
            
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    showTranslationPicker = true
                } label: {
                    Text(viewModel.currentTranslation.abbreviation.uppercased())
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .cornerRadius(4)
                }
                
                Menu {
                    Button {
                        showAudioControls.toggle()
                    } label: {
                        Label("Audio", systemImage: showAudioControls ? "speaker.wave.3.fill" : "speaker.wave.3")
                    }
                    
                    Button("Bookmark") {
                        showBookmarkSheet = true
                    }
                    
                    Button("Increase Font") {
                        viewModel.increaseFontSize()
                    }
                    
                    Button("Decrease Font") {
                        viewModel.decreaseFontSize()
                    }
                    
                    Button("Settings") {
                        showSettings = true
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .task {
            await viewModel.loadChapter()
        }
        .sheet(isPresented: $showChapterPicker) {
            BookPickerView(
                selectedBook: viewModel.book,
                selectedChapter: viewModel.chapter
            ) { book, chapter in
                viewModel.updateBook(book, chapter: chapter)
                showChapterPicker = false
            }
        }
        .sheet(isPresented: $showTranslationPicker) {
            TranslationPickerView(
                selectedTranslation: viewModel.currentTranslation
            ) { translation in
                viewModel.updateTranslation(translation)
                showTranslationPicker = false
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                ReaderSettingsView()
                    .navigationTitle("Reader Settings")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showSettings = false
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $showBookmarkSheet) {
            if let verse = viewModel.selectedVerse {
                AddBookmarkSheet(verse: verse, verseText: verse.text)
            }
        }
    }
    
    private var readerContent: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Chapter header
                    HStack {
                        Text(viewModel.navigationTitle)
                            .font(.title2.bold())
                            .padding(.vertical, 16)
                            .padding(.horizontal, 16)
                        
                        Spacer()
                        
                        // Chapter navigation
                        HStack(spacing: 16) {
                            Button {
                                Task { await viewModel.previousChapter() }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.headline)
                            }
                            .disabled(!viewModel.canGoToPreviousChapter)
                            .opacity(viewModel.canGoToPreviousChapter ? 1 : 0.5)
                            
                            Text("Chapter \(viewModel.chapter)")
                                .font(.headline)
                            
                            Button {
                                Task { await viewModel.nextChapter() }
                            } label: {
                                Image(systemName: "chevron.right")
                                    .font(.headline)
                            }
                            .disabled(!viewModel.canGoToNextChapter)
                            .opacity(viewModel.canGoToNextChapter ? 1 : 0.5)
                        }
                        .padding(.trailing, 16)
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .onTapGesture {
                        showChapterPicker = true
                    }
                    
                    // Verses
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.verses) { verse in
                            VerseView(verse: verse) {
                                viewModel.selectVerse(verse)
                                // Show verse options or details
                            }
                            .id(verse.id)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                }
                .padding(.bottom, 24)
            }
            .onChange(of: viewModel.scrollToVerse) { _, verseId in
                if let verseId = verseId {
                    withAnimation {
                        proxy.scrollTo(verseId, anchor: .center)
                    }
                }
            }
        }
    }
}

// MARK: - Previews

struct BibleReaderView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BibleReaderView(book: .genesis, chapter: 1)
        }
    }
}