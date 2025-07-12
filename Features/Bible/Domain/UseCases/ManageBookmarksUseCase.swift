import Foundation

public protocol ManageBookmarksUseCaseProtocol {
    func getBookmarks() async throws -> [VerseBookmark]
    func addBookmark(verse: BibleVerse, note: String?, tags: [String]) async throws -> VerseBookmark
    func updateBookmark(_ bookmark: VerseBookmark) async throws
    func deleteBookmark(_ bookmark: VerseBookmark) async throws
    func isBookmarked(verseId: String) async throws -> Bool
}

public struct ManageBookmarksUseCase: ManageBookmarksUseCaseProtocol {
    private let repository: BibleAnnotationRepositoryProtocol
    
    public init(repository: BibleAnnotationRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getBookmarks() async throws -> [VerseBookmark] {
        try await repository.fetchBookmarks()
    }
    
    public func addBookmark(verse: BibleVerse, note: String?, tags: [String]) async throws -> VerseBookmark {
        let bookmark = VerseBookmark(
            verse: verse,
            note: note,
            tags: tags
        )
        try await repository.saveBookmark(bookmark)
        return bookmark
    }
    
    public func updateBookmark(_ bookmark: VerseBookmark) async throws {
        try await repository.updateBookmark(bookmark)
    }
    
    public func deleteBookmark(_ bookmark: VerseBookmark) async throws {
        try await repository.deleteBookmark(bookmark)
    }
    
    public func isBookmarked(verseId: String) async throws -> Bool {
        let bookmark = try await repository.fetchBookmark(for: verseId)
        return bookmark != nil
    }
}