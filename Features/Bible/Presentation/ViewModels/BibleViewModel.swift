import SwiftUI
import Combine

@MainActor
public final class BibleViewModel: ObservableObject {
    @Published private(set) var state = BibleState()
    
    private let getChapterUseCase: GetBibleChapterUseCaseProtocol
    private let getDailyVerseUseCase: GetDailyVerseUseCaseProtocol
    private let compareTranslationsUseCase: CompareTranslationsUseCaseProtocol
    private let manageBookmarksUseCase: ManageBookmarksUseCaseProtocol
    private let generateInsightUseCase: GenerateVerseInsightUseCaseProtocol
    private let coordinator: BibleCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        getChapterUseCase: GetBibleChapterUseCaseProtocol,
        getDailyVerseUseCase: GetDailyVerseUseCaseProtocol,
        compareTranslationsUseCase: CompareTranslationsUseCaseProtocol,
        manageBookmarksUseCase: ManageBookmarksUseCaseProtocol,
        generateInsightUseCase: GenerateVerseInsightUseCaseProtocol,
        coordinator: BibleCoordinator
    ) {
        self.getChapterUseCase = getChapterUseCase
        self.getDailyVerseUseCase = getDailyVerseUseCase
        self.compareTranslationsUseCase = compareTranslationsUseCase
        self.manageBookmarksUseCase = manageBookmarksUseCase
        self.generateInsightUseCase = generateInsightUseCase
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        // Sync coordinator state with view model state
        coordinator.$selectedBook
            .sink { [weak self] book in
                self?.state.currentBook = book
            }
            .store(in: &cancellables)
        
        coordinator.$currentTranslation
            .sink { [weak self] translation in
                self?.state.currentTranslation = translation
            }
            .store(in: &cancellables)
        
        // React to coordinator navigation
        coordinator.$currentChapter
            .combineLatest(coordinator.$selectedBook, coordinator.$currentTranslation)
            .sink { [weak self] chapter, book, translation in
                guard let self = self, let book = book else { return }
                Task {
                    await self.loadChapter(book: book, chapter: chapter, translation: translation)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Actions
    
    public func onAppear() async {
        await loadInitialData()
    }
    
    public func selectBook(_ book: BibleBook) {
        coordinator.navigateToBook(book)
    }
    
    public func goToChapter(_ chapter: Int) {
        coordinator.navigateToChapter(chapter)
    }
    
    public func goToPreviousChapter() {
        coordinator.goToPreviousChapter()
    }
    
    public func goToNextChapter() {
        coordinator.goToNextChapter()
    }
    
    public func selectTranslation(_ translation: BibleTranslation) {
        coordinator.changeTranslation(translation)
    }
    
    public func selectVerse(_ verse: BibleVerse) {
        coordinator.selectedVerse = verse
    }
    
    // MARK: - Bookmark Actions
    
    public func toggleBookmark(for verse: BibleVerse) async {
        do {
            let isBookmarked = try await manageBookmarksUseCase.isBookmarked(verseId: verse.id)
            
            if isBookmarked {
                if let bookmark = state.bookmarks.first(where: { $0.verse.id == verse.id }) {
                    try await manageBookmarksUseCase.deleteBookmark(bookmark)
                    state.bookmarks.removeAll { $0.id == bookmark.id }
                }
            } else {
                let bookmark = try await manageBookmarksUseCase.addBookmark(
                    verse: verse,
                    note: nil,
                    tags: []
                )
                state.bookmarks.append(bookmark)
            }
        } catch {
            state.error = error
        }
    }
    
    public func updateBookmark(_ bookmark: VerseBookmark) async {
        do {
            try await manageBookmarksUseCase.updateBookmark(bookmark)
            if let index = state.bookmarks.firstIndex(where: { $0.id == bookmark.id }) {
                state.bookmarks[index] = bookmark
            }
        } catch {
            state.error = error
        }
    }
    
    // MARK: - Insight Actions
    
    public func generateInsight(for verse: BibleVerse, type: VerseInsight.InsightType) async {
        state.isGeneratingInsight = true
        state.error = nil
        
        do {
            let insight = try await generateInsightUseCase.execute(for: verse, type: type)
            
            // Add to state
            var insights = state.insights[verse.id] ?? []
            insights.append(insight)
            state.insights[verse.id] = insights
            
            state.isGeneratingInsight = false
        } catch {
            state.error = error
            state.isGeneratingInsight = false
        }
    }
    
    // MARK: - Navigation Actions
    
    public func showBookPicker() {
        coordinator.showBookPicker()
    }
    
    public func showChapterPicker() {
        coordinator.showChapterPicker()
    }
    
    public func showTranslationPicker() {
        coordinator.showTranslationPicker()
    }
    
    public func showVerseComparison(for verse: BibleVerse) {
        coordinator.showVerseComparison(for: verse)
    }
    
    public func showReaderSettings() {
        coordinator.showReaderSettings()
    }
    
    public func showBookmarkEditor(for verse: BibleVerse) {
        coordinator.showBookmarkEditor(for: verse)
    }
    
    public func shareVerse(_ verse: BibleVerse) {
        coordinator.showShareSheet(for: verse)
    }
    
    // MARK: - Private Methods
    
    private func loadInitialData() async {
        // Load daily verse
        do {
            let dailyVerse = try await getDailyVerseUseCase.execute()
            state.dailyVerse = dailyVerse
        } catch {
            // Non-critical error
            print("Failed to load daily verse: \(error)")
        }
        
        // Load bookmarks
        do {
            let bookmarks = try await manageBookmarksUseCase.getBookmarks()
            state.bookmarks = bookmarks
        } catch {
            print("Failed to load bookmarks: \(error)")
        }
    }
    
    private func loadChapter(book: BibleBook, chapter: Int, translation: BibleTranslation) async {
        state.isLoadingChapter = true
        state.error = nil
        
        do {
            let chapterData = try await getChapterUseCase.execute(
                bookId: book.id,
                chapter: chapter,
                translation: translation
            )
            
            state.currentChapter = chapterData
            state.isLoadingChapter = false
            
            // Load insights for visible verses
            await loadInsightsForChapter(chapterData)
        } catch {
            state.error = error
            state.isLoadingChapter = false
        }
    }
    
    private func loadInsightsForChapter(_ chapter: BibleChapter) async {
        // Load cached insights for all verses in the chapter
        for verse in chapter.verses {
            do {
                let insights = try await generateInsightUseCase.getCachedInsights(for: verse.id)
                if !insights.isEmpty {
                    state.insights[verse.id] = insights
                }
            } catch {
                // Non-critical, continue
            }
        }
    }
}