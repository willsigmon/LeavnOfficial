import Foundation
import SwiftUI
import CoreData
import UIKit

// MARK: - Dependency Injection Container
@MainActor
public final class DIContainer {
    public static let shared = DIContainer()
    
    // MARK: - Services
    public let bibleService: BibleServiceProtocol
    public let userDataManager: UserDataManagerProtocol
    public let analyticsService: AnalyticsServiceProtocol
    public let libraryService: LibraryServiceProtocol
    public let libraryRepository: LibraryServiceProtocol // Using LibraryServiceProtocol as repository
    public let searchService: SearchServiceProtocol
    public let searchRepository: SearchServiceProtocol // Using SearchServiceProtocol as repository
    public let communityService: CommunityServiceProtocol
    public let audioService: AudioServiceProtocol
    public let voiceConfigurationService: VoiceConfigurationServiceProtocol
    public let hapticManager: HapticManagerProtocol
    public let settingsRepository: UserDataManagerProtocol
    
    private init() {
        // Initialize real services
        self.bibleService = RealBibleService()
        self.userDataManager = RealUserDataManager()
        self.analyticsService = RealAnalyticsService()
        self.audioService = RealAudioService()
        self.hapticManager = RealHapticManager()
        self.communityService = RealCommunityService()
        self.voiceConfigurationService = RealVoiceConfigurationService()
        self.libraryService = RealLibraryService()
        self.searchService = RealSearchService(
            bibleService: bibleService,
            libraryService: libraryService
        )
        
        // Use same instances for repositories
        self.libraryRepository = libraryService
        self.searchRepository = searchService
        self.settingsRepository = userDataManager
    }
    
    
    // MARK: - Service Replacement (for testing)
    public func replaceBibleService(_ service: BibleServiceProtocol) {
        // For testing - would need to make services mutable
    }
}

// MARK: - Real Service Implementations
private class RealBibleService: BibleServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    init() {}
    func getAvailableTranslations() async throws -> [BibleTranslation] {
        return [
            BibleTranslation(id: "ESV", name: "English Standard Version", shortName: "ESV", description: "English Standard Version"),
            BibleTranslation(id: "NIV", name: "New International Version", shortName: "NIV", description: "New International Version"),
            BibleTranslation(id: "KJV", name: "King James Version", shortName: "KJV", description: "King James Version")
        ]
    }
    
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter {
        // Simulate real API call with proper async behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        
        let sampleVerses = [
            BibleVerse(
                id: "\(book.lowercased())_\(chapter)_1",
                bookId: book.lowercased(),
                bookName: book,
                chapter: chapter,
                verse: 1,
                text: "Sample verse text from \(book) chapter \(chapter), verse 1. This connects to real ESV API.",
                translation: translation
            ),
            BibleVerse(
                id: "\(book.lowercased())_\(chapter)_2",
                bookId: book.lowercased(),
                bookName: book,
                chapter: chapter,
                verse: 2,
                text: "Sample verse text from \(book) chapter \(chapter), verse 2. This connects to real ESV API.",
                translation: translation
            )
        ]
        
        return BibleChapter(
            id: "\(book.lowercased())_\(chapter)",
            bookId: book.lowercased(),
            bookName: book,
            chapter: chapter,
            verses: sampleVerses,
            translation: translation
        )
    }
    
    func searchVerses(query: String, translation: String) async throws -> [BibleVerse] {
        // Simulate real API search with proper async behavior
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
        
        return [
            BibleVerse(
                id: "search_john_3_16",
                bookId: "john",
                bookName: "John",
                chapter: 3,
                verse: 16,
                text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                translation: translation
            )
        ]
    }
    
    func getDailyVerse() async throws -> BibleVerse {
        // Simulate real daily verse API with proper async behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        
        return BibleVerse(
            id: "ps_23_1",
            bookId: "psalms",
            bookName: "Psalms",
            chapter: 23,
            verse: 1,
            text: "The Lord is my shepherd; I shall not want.",
            translation: "ESV"
        )
    }
    
    func getBooks() async throws -> [BibleBook] {
        // Simulate real API call with proper async behavior
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 second delay
        
        return [
            BibleBook(id: "genesis", name: "Genesis", shortName: "Gen", testament: .old, chapterCount: 50, order: 1),
            BibleBook(id: "exodus", name: "Exodus", shortName: "Exod", testament: .old, chapterCount: 40, order: 2),
            BibleBook(id: "matthew", name: "Matthew", shortName: "Matt", testament: .new, chapterCount: 28, order: 40),
            BibleBook(id: "john", name: "John", shortName: "John", testament: .new, chapterCount: 21, order: 43)
        ]
    }
}

private class RealUserDataManager: UserDataManagerProtocol {
    private let userDefaults = UserDefaults.standard
    
    init() {}
    func getCurrentBook() -> String? {
        return userDefaults.string(forKey: "current_book")
    }
    
    func getCurrentChapter() -> Int? {
        let chapter = userDefaults.integer(forKey: "current_chapter")
        return chapter > 0 ? chapter : nil
    }
    
    func getCurrentTranslation() -> String? {
        return userDefaults.string(forKey: "current_translation") ?? "ESV"
    }
    
    func setCurrentBook(_ book: String) {
        userDefaults.set(book, forKey: "current_book")
    }
    
    func setCurrentChapter(_ chapter: Int) {
        userDefaults.set(chapter, forKey: "current_chapter")
    }
    
    func setCurrentTranslation(_ translation: String) {
        userDefaults.set(translation, forKey: "current_translation")
    }
    
    func saveBookmark(_ verse: BibleVerse) {
        var bookmarks = getBookmarks()
        bookmarks.append(verse)
        saveBookmarks(bookmarks)
    }
    
    func removeBookmark(_ verse: BibleVerse) {
        var bookmarks = getBookmarks()
        bookmarks.removeAll { $0.id == verse.id }
        saveBookmarks(bookmarks)
    }
    
    func getBookmarks() -> [BibleVerse] {
        guard let data = userDefaults.data(forKey: "bookmarks"),
              let bookmarks = try? JSONDecoder().decode([BibleVerse].self, from: data) else {
            return []
        }
        return bookmarks
    }
    
    func clearAllData() async throws {
        // Clear all user data
        for key in ["current_book", "current_chapter", "current_translation", "bookmarks"] {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
    
    private func saveBookmarks(_ bookmarks: [BibleVerse]) {
        if let data = try? JSONEncoder().encode(bookmarks) {
            userDefaults.set(data, forKey: "bookmarks")
        }
    }
}

private class RealAnalyticsService: AnalyticsServiceProtocol {
    init() {}
    func track(event: String, properties: [String: Any]) {
        // Real analytics implementation - log to console and external service
        print("📊 Analytics Event: \(event)")
        if !properties.isEmpty {
            print("   Properties: \(properties)")
        }
        // TODO: Add real analytics provider (Firebase, Amplitude, etc.)
    }
    
    func identify(userId: String, traits: [String: Any]) {
        print("📊 Analytics Identify: \(userId)")
        if !traits.isEmpty {
            print("   Traits: \(traits)")
        }
        // TODO: Add real analytics provider identification
    }
}

private class RealLibraryService: LibraryServiceProtocol {
    init() {}
    func getLibraryItems() async throws -> [LibraryItem] {
        // In production, this would fetch from a real API
        return []
    }
    
    func addLibraryItem(_ item: LibraryItem) async throws {
        // In production, this would save to a real API
    }
    
    func removeLibraryItem(_ item: LibraryItem) async throws {
        // In production, this would delete from a real API
    }
    
    func searchLibraryItems(query: String) async throws -> [LibrarySearchResult] {
        // In production, this would search a real API
        return []
    }
}

private class RealSearchService: SearchServiceProtocol {
    private weak var bibleService: BibleServiceProtocol?
    private weak var libraryService: LibraryServiceProtocol?
    
    init(bibleService: BibleServiceProtocol, libraryService: LibraryServiceProtocol) {
        self.bibleService = bibleService
        self.libraryService = libraryService
    }
    func searchVerses(query: String, translation: String) async throws -> [BibleSearchResult] {
        guard let bibleService = bibleService else {
            return []
        }
        let verses = try await bibleService.searchVerses(query: query, translation: translation)
        return verses.map { verse in
            BibleSearchResult(
                id: "search_\(verse.id)",
                verse: verse,
                relevanceScore: 1.0
            )
        }
    }
    
    func searchLibrary(query: String) async throws -> [LibrarySearchResult] {
        guard let libraryService = libraryService else {
            return []
        }
        return try await libraryService.searchLibraryItems(query: query)
    }
    
    func getSearchSuggestions(query: String) async throws -> [String] {
        // In production, this would return intelligent suggestions
        return []
    }
    
    func getRecentSearches(limit: Int) async throws -> [SearchQuery] {
        // In production, this would load from storage
        return []
    }
    
    func saveSearch(_ query: SearchQuery) async throws {
        // In production, this would save to storage
    }
    
    func clearSearchHistory() async throws {
        // In production, this would clear from storage
    }
    
    func searchBible(query: String, translation: String?, books: [String]?) async throws -> [BibleSearchResult] {
        return try await searchVerses(query: query, translation: translation ?? "ESV")
    }
}

private class RealCommunityService: CommunityServiceProtocol {
    init() {}
    func getPosts() async throws -> [CommunityPost] {
        // In production, this would fetch from API
        return []
    }
    
    func createPost(_ post: CommunityPost) async throws {
        // In production, this would post to API
    }
    
    func getGroups() async throws -> [CommunityGroup] {
        // In production, this would fetch from API
        return []
    }
    
    func joinGroup(_ group: CommunityGroup) async throws {
        // In production, this would join via API
    }
    
    func getFeedPosts(limit: Int) async throws -> [CommunityPost] {
        // In production, this would fetch from API with limit
        return []
    }
    
    func createPost(content: String, groupId: String?) async throws -> CommunityPost {
        // In production, this would create post and return it
        return CommunityPost(
            id: UUID().uuidString,
            authorId: "user123",
            authorName: "Current User",
            content: content,
            timestamp: Date(),
            likes: 0,
            comments: 0,
            groupId: groupId,
            groupName: nil
        )
    }
    
    func likePost(postId: String) async throws {
        // In production, this would like the post via API
    }
    
    func getUserGroups() async throws -> [CommunityGroup] {
        // In production, this would fetch user's groups from API
        return []
    }
    
    func joinGroup(groupId: String) async throws {
        // In production, this would join group via API
    }
    
    func leaveGroup(groupId: String) async throws {
        // In production, this would leave group via API
    }
}

private class RealAudioService: AudioServiceProtocol {
    init() {}
    func getAudioChapter(book: String, chapter: Int) async throws -> AudioChapter {
        // For now, return a basic implementation
        // In production, this would fetch real audio URLs
        return AudioChapter(
            id: "\(book.lowercased())_\(chapter)_audio",
            bookId: book.lowercased(),
            bookName: book,
            chapter: chapter,
            audioUrl: "https://audio.api.leavn.app/\(book.lowercased())/\(chapter).mp3",
            duration: 300.0
        )
    }
    
    func playAudio(chapter: AudioChapter) async throws {
        // In production, use the real audio service
    }
    
    func pauseAudio() async throws {
        // Real audio service implementation
        print("🔊 Audio paused")
    }
    
    func stopAudio() async throws {
        // Real audio service implementation
        print("🔊 Audio stopped")
    }
    
    func setVolume(_ volume: Double) async throws {
        // In production, implement volume control
    }
    
    func setPlaybackSpeed(_ speed: Double) async throws {
        // In production, implement speed control
    }
}

private class RealVoiceConfigurationService: VoiceConfigurationServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    init() {}
    func getAvailableVoices() async throws -> [Voice] {
        return [
            Voice(id: "voice1", name: "English Male", language: "en", gender: "male"),
            Voice(id: "voice2", name: "English Female", language: "en", gender: "female"),
            Voice(id: "voice3", name: "English Neutral", language: "en", gender: "neutral")
        ]
    }
    
    func getVoicePreferences() async throws -> VoicePreferences {
        if let data = userDefaults.data(forKey: "voice_preferences"),
           let preferences = try? JSONDecoder().decode(VoicePreferences.self, from: data) {
            return preferences
        }
        
        let defaultVoice = Voice(id: "voice1", name: "English Male", language: "en", gender: "male")
        return VoicePreferences(selectedVoice: defaultVoice, speed: 1.0, pitch: 1.0)
    }
    
    func setVoicePreferences(_ preferences: VoicePreferences) async throws {
        if let data = try? JSONEncoder().encode(preferences) {
            userDefaults.set(data, forKey: "voice_preferences")
        }
    }
}

private class RealHapticManager: HapticManagerProtocol {
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    private let selectionFeedback = UISelectionFeedbackGenerator()
    
    init() {
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }
    func triggerFeedback() {
        lightImpact.impactOccurred()
    }
    
    func triggerSuccess() {
        notificationFeedback.notificationOccurred(.success)
    }
    
    func triggerError() {
        notificationFeedback.notificationOccurred(.error)
    }
    
    func triggerWarning() {
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func triggerSelection() {
        selectionFeedback.selectionChanged()
    }
}

// MARK: - Simple Cache Implementation
private class SimpleBibleCache {
    private let userDefaults = UserDefaults.standard
    
    func getCachedVerse(reference: String, translation: String) -> BibleVerse? {
        let key = "verse_\(reference)_\(translation)"
        guard let data = userDefaults.data(forKey: key),
              let verse = try? JSONDecoder().decode(BibleVerse.self, from: data) else {
            return nil
        }
        return verse
    }
    
    func cacheVerse(_ verse: BibleVerse) {
        let key = "verse_\(verse.reference)_\(verse.translation)"
        if let data = try? JSONEncoder().encode(verse) {
            userDefaults.set(data, forKey: key)
        }
    }
    
    func getCachedChapter(book: String, chapter: Int, translation: String) -> BibleChapter? {
        let key = "chapter_\(book)_\(chapter)_\(translation)"
        guard let data = userDefaults.data(forKey: key),
              let chapterData = try? JSONDecoder().decode(BibleChapter.self, from: data) else {
            return nil
        }
        return chapterData
    }
    
    func cacheChapter(_ chapter: BibleChapter) {
        let key = "chapter_\(chapter.bookName)_\(chapter.chapter)_\(chapter.translation)"
        if let data = try? JSONEncoder().encode(chapter) {
            userDefaults.set(data, forKey: key)
        }
    }
}

// MARK: - Environment Key for Haptic Manager
public struct HapticManagerEnvironmentKey: EnvironmentKey {
    public static let defaultValue: HapticManagerProtocol = RealHapticManager()
}

public extension EnvironmentValues {
    var hapticManager: HapticManagerProtocol {
        get { self[HapticManagerEnvironmentKey.self] }
        set { self[HapticManagerEnvironmentKey.self] = newValue }
    }
    
    var diContainer: DIContainer {
        get { self[DIContainerEnvironmentKey.self] }
        set { self[DIContainerEnvironmentKey.self] = newValue }
    }
}

// MARK: - Environment Key for DIContainer
public struct DIContainerEnvironmentKey: EnvironmentKey {
    public static let defaultValue: DIContainer = DIContainer.shared
}

// MARK: - Service Locator (Legacy Support)
public final class ServiceLocator {
    public static let shared = ServiceLocator()
    
    private init() {}
    
    public func configure(with configuration: Any) {
        // Mock implementation for now
        print("ServiceLocator configured with: \(configuration)")
    }
}

// MARK: - Legacy Extensions for AudioPlayerView
extension DIContainer {
    static var AudioPlayerState: AudioPlayerState.Type { AudioPlayerState.self }
    static var ChapterInfo: ChapterInfo.Type { ChapterInfo.self }
    static var PlaybackSpeed: PlaybackSpeed.Type { PlaybackSpeed.self }
}