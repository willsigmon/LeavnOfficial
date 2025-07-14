import Foundation

public protocol BibleRepository: Repository {
    func getVerse(reference: String, translation: String?) async throws -> BibleVerse
    func getChapter(book: String, chapter: Int, translation: String?) async throws -> BibleChapter
    func getPassage(reference: String, translation: String?) async throws -> BiblePassage
    func getTranslations() async throws -> [BibleTranslation]
    func getBooks(includeApocrypha: Bool) async throws -> [BibleBook]
    func searchVerses(query: String, translation: String?) async throws -> [BibleSearchResult]
    func getFavoriteVerses() async throws -> [BibleVerse]
    func addFavoriteVerse(_ verse: BibleVerse) async throws
    func removeFavoriteVerse(_ verseId: String) async throws
    func clearCache() async throws
    func getCacheSize() async throws -> Int64
}

public final class DefaultBibleRepository: BibleRepository {
    private let bibleService: BibleService
    private let localStorage: Storage
    private let cacheManager: BibleCacheManager
    
    private let favoritesKey = "favorite_verses"
    
    public init(
        bibleService: BibleService, 
        localStorage: Storage,
        cacheManager: BibleCacheManager
    ) {
        self.bibleService = bibleService
        self.localStorage = localStorage
        self.cacheManager = cacheManager
    }
    
    public func getVerse(reference: String, translation: String? = nil) async throws -> BibleVerse {
        try await bibleService.fetchVerse(reference: reference, translation: translation)
    }
    
    public func getChapter(book: String, chapter: Int, translation: String? = nil) async throws -> BibleChapter {
        try await bibleService.fetchChapter(book: book, chapter: chapter, translation: translation)
    }
    
    public func getPassage(reference: String, translation: String? = nil) async throws -> BiblePassage {
        try await bibleService.fetchPassage(reference: reference, translation: translation)
    }
    
    public func getTranslations() async throws -> [BibleTranslation] {
        try await bibleService.fetchTranslations()
    }
    
    public func getBooks(includeApocrypha: Bool = false) async throws -> [BibleBook] {
        try await bibleService.getBooks(includeApocrypha: includeApocrypha)
    }
    
    public func searchVerses(query: String, translation: String?) async throws -> [BibleSearchResult] {
        try await bibleService.search(query: query, translation: translation)
    }
    
    public func clearCache() async throws {
        try await cacheManager.clearCache()
    }
    
    public func getCacheSize() async throws -> Int64 {
        try await cacheManager.getCacheSize()
    }
    
    public func getFavoriteVerses() async throws -> [BibleVerse] {
        let favorites = try await localStorage.load([BibleVerse].self, forKey: favoritesKey)
        return favorites ?? []
    }
    
    public func addFavoriteVerse(_ verse: BibleVerse) async throws {
        var favorites = try await getFavoriteVerses()
        if !favorites.contains(where: { $0.id == verse.id }) {
            favorites.append(verse)
            try await localStorage.save(favorites, forKey: favoritesKey)
        }
    }
    
    public func removeFavoriteVerse(_ verseId: String) async throws {
        var favorites = try await getFavoriteVerses()
        favorites.removeAll(where: { $0.id == verseId })
        try await localStorage.save(favorites, forKey: favoritesKey)
    }
}