import Foundation

public protocol GetBibleChapterUseCaseProtocol {
    func execute(bookId: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter
}

public struct GetBibleChapterUseCase: GetBibleChapterUseCaseProtocol {
    private let repository: BibleRepositoryProtocol
    private let annotationRepository: BibleAnnotationRepositoryProtocol
    
    public init(
        repository: BibleRepositoryProtocol,
        annotationRepository: BibleAnnotationRepositoryProtocol
    ) {
        self.repository = repository
        self.annotationRepository = annotationRepository
    }
    
    public func execute(bookId: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter {
        // Fetch the chapter
        var chapter = try await repository.fetchChapter(
            bookId: bookId,
            chapter: chapter,
            translation: translation
        )
        
        // Fetch highlights and bookmarks in parallel
        async let highlights = annotationRepository.fetchHighlights()
        async let bookmarks = annotationRepository.fetchBookmarks()
        
        // Wait for both to complete
        let (fetchedHighlights, fetchedBookmarks) = try await (highlights, bookmarks)
        
        // Create a set of highlighted verse IDs for quick lookup
        let highlightedVerseIds = Set(fetchedHighlights.map { $0.verseId })
        let bookmarkedVerseIds = Set(fetchedBookmarks.map { $0.verse.id })
        
        // Enrich verses with annotation data
        let enrichedVerses = chapter.verses.map { verse in
            var enrichedVerse = verse
            // Add metadata about highlights and bookmarks
            // This would require extending the BibleVerse model with metadata properties
            return enrichedVerse
        }
        
        return BibleChapter(
            bookId: chapter.bookId,
            bookName: chapter.bookName,
            number: chapter.number,
            verses: enrichedVerses,
            translation: chapter.translation
        )
    }
}