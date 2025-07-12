import SwiftUI

@MainActor
public final class BibleCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var selectedBook: BibleBook?
    @Published public var currentChapter: Int = 1
    @Published public var currentTranslation: BibleTranslation = .niv
    
    // Sheet presentations
    @Published public var isShowingBookPicker = false
    @Published public var isShowingChapterPicker = false
    @Published public var isShowingTranslationPicker = false
    @Published public var isShowingVerseComparison = false
    @Published public var isShowingReaderSettings = false
    @Published public var isShowingBookmarkEditor = false
    @Published public var isShowingShareSheet = false
    
    // Selected items for sheets
    @Published public var selectedVerse: BibleVerse?
    @Published public var selectedBookmark: VerseBookmark?
    @Published public var versesToCompare: [BibleVerse] = []
    
    public init() {}
    
    // MARK: - Navigation Actions
    
    public func navigateToBook(_ book: BibleBook, chapter: Int = 1) {
        selectedBook = book
        currentChapter = chapter
        path.append(BibleDestination.reader(book: book, chapter: chapter))
    }
    
    public func navigateToChapter(_ chapter: Int) {
        currentChapter = chapter
        if let book = selectedBook {
            path.removeLast(path.count)
            path.append(BibleDestination.reader(book: book, chapter: chapter))
        }
    }
    
    public func navigateToVerse(_ verse: BibleVerse) {
        // Find the book and navigate
        navigateToBook(
            BibleBook(
                id: verse.bookId,
                name: verse.bookName,
                testament: .new, // This would need to be resolved
                chapterCount: 1, // This would need to be resolved
                abbreviation: verse.bookId,
                genre: .gospel // This would need to be resolved
            ),
            chapter: verse.chapter
        )
        selectedVerse = verse
    }
    
    public func goToPreviousChapter() {
        if currentChapter > 1 {
            navigateToChapter(currentChapter - 1)
        } else {
            // TODO: Navigate to previous book's last chapter
        }
    }
    
    public func goToNextChapter() {
        if let book = selectedBook, currentChapter < book.chapterCount {
            navigateToChapter(currentChapter + 1)
        } else {
            // TODO: Navigate to next book's first chapter
        }
    }
    
    // MARK: - Sheet Actions
    
    public func showBookPicker() {
        isShowingBookPicker = true
    }
    
    public func showChapterPicker() {
        isShowingChapterPicker = true
    }
    
    public func showTranslationPicker() {
        isShowingTranslationPicker = true
    }
    
    public func showVerseComparison(for verse: BibleVerse) {
        selectedVerse = verse
        isShowingVerseComparison = true
    }
    
    public func showReaderSettings() {
        isShowingReaderSettings = true
    }
    
    public func showBookmarkEditor(for verse: BibleVerse, bookmark: VerseBookmark? = nil) {
        selectedVerse = verse
        selectedBookmark = bookmark
        isShowingBookmarkEditor = true
    }
    
    public func showShareSheet(for verse: BibleVerse) {
        selectedVerse = verse
        isShowingShareSheet = true
    }
    
    // MARK: - Translation Management
    
    public func changeTranslation(_ translation: BibleTranslation) {
        currentTranslation = translation
        isShowingTranslationPicker = false
    }
    
    // MARK: - Reset
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
    
    public func dismissAllSheets() {
        isShowingBookPicker = false
        isShowingChapterPicker = false
        isShowingTranslationPicker = false
        isShowingVerseComparison = false
        isShowingReaderSettings = false
        isShowingBookmarkEditor = false
        isShowingShareSheet = false
    }
}

// MARK: - Navigation Destinations

public enum BibleDestination: Hashable {
    case reader(book: BibleBook, chapter: Int)
    case verseDetail(verse: BibleVerse)
    case bookmarksList
    case highlightsList
}