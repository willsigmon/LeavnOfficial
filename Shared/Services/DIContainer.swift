import Foundation
import SwiftUI

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
    
    private init() {
        // Initialize with mock implementations for now
        self.bibleService = MockBibleService()
        self.userDataManager = MockUserDataManager()
        self.analyticsService = MockAnalyticsService()
        self.libraryService = MockLibraryService()
        self.libraryRepository = MockLibraryService() // Same instance
        self.searchService = MockSearchService()
        self.searchRepository = MockSearchService() // Same instance
        self.communityService = MockCommunityService()
        self.audioService = MockAudioService()
        self.voiceConfigurationService = MockVoiceConfigurationService()
        self.hapticManager = MockHapticManager()
    }
    
    // MARK: - Service Replacement (for testing)
    public func replaceBibleService(_ service: BibleServiceProtocol) {
        // For testing - would need to make services mutable
    }
}

// MARK: - Mock Implementations
private class MockBibleService: BibleServiceProtocol {
    func getAvailableTranslations() async throws -> [BibleTranslation] {
        return [
            BibleTranslation(id: "ESV", name: "English Standard Version", shortName: "ESV", description: "English Standard Version"),
            BibleTranslation(id: "NIV", name: "New International Version", shortName: "NIV", description: "New International Version"),
            BibleTranslation(id: "KJV", name: "King James Version", shortName: "KJV", description: "King James Version")
        ]
    }
    
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter {
        // Mock implementation
        let sampleVerses = [
            BibleVerse(
                id: "gen_1_1",
                bookId: "genesis",
                bookName: "Genesis",
                chapter: 1,
                verse: 1,
                text: "In the beginning, God created the heavens and the earth.",
                translation: translation
            ),
            BibleVerse(
                id: "gen_1_2",
                bookId: "genesis",
                bookName: "Genesis",
                chapter: 1,
                verse: 2,
                text: "The earth was without form and void, and darkness was over the face of the deep. And the Spirit of God was hovering over the face of the waters.",
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
        // Mock search results
        return [
            BibleVerse(
                id: "john_3_16",
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
        return [
            BibleBook(id: "genesis", name: "Genesis", shortName: "Gen", testament: .old, chapterCount: 50, order: 1),
            BibleBook(id: "exodus", name: "Exodus", shortName: "Exod", testament: .old, chapterCount: 40, order: 2),
            BibleBook(id: "matthew", name: "Matthew", shortName: "Matt", testament: .new, chapterCount: 28, order: 40),
            BibleBook(id: "john", name: "John", shortName: "John", testament: .new, chapterCount: 21, order: 43)
        ]
    }
}

private class MockUserDataManager: UserDataManagerProtocol {
    private var currentBook: String?
    private var currentChapter: Int?
    private var currentTranslation: String?
    private var bookmarks: [BibleVerse] = []
    
    func getCurrentBook() -> String? { currentBook }
    func getCurrentChapter() -> Int? { currentChapter }
    func getCurrentTranslation() -> String? { currentTranslation }
    
    func setCurrentBook(_ book: String) { currentBook = book }
    func setCurrentChapter(_ chapter: Int) { currentChapter = chapter }
    func setCurrentTranslation(_ translation: String) { currentTranslation = translation }
    
    func saveBookmark(_ verse: BibleVerse) {
        bookmarks.append(verse)
    }
    
    func removeBookmark(_ verse: BibleVerse) {
        bookmarks.removeAll { $0.id == verse.id }
    }
    
    func getBookmarks() -> [BibleVerse] { bookmarks }
}

private class MockAnalyticsService: AnalyticsServiceProtocol {
    func track(event: String, properties: [String: Any]) {
        print("Analytics: \(event) - \(properties)")
    }
    
    func identify(userId: String, traits: [String: Any]) {
        print("Analytics identify: \(userId) - \(traits)")
    }
}

private class MockLibraryService: LibraryServiceProtocol {
    func getLibraryItems() async throws -> [LibraryItem] {
        return []
    }
    
    func addLibraryItem(_ item: LibraryItem) async throws {
        // Mock implementation
    }
    
    func removeLibraryItem(_ item: LibraryItem) async throws {
        // Mock implementation
    }
    
    func searchLibraryItems(query: String) async throws -> [LibrarySearchResult] {
        return []
    }
}

private class MockSearchService: SearchServiceProtocol {
    func searchVerses(query: String, translation: String) async throws -> [BibleSearchResult] {
        return []
    }
    
    func searchLibrary(query: String) async throws -> [LibrarySearchResult] {
        return []
    }
    
    func getSearchSuggestions(query: String) async throws -> [String] {
        return []
    }
    
    func getRecentSearches(limit: Int) async throws -> [SearchQuery] {
        return []
    }
    
    func saveSearch(_ query: SearchQuery) async throws {
        // Mock implementation
    }
    
    func clearSearchHistory() async throws {
        // Mock implementation
    }
    
    func searchBible(query: String, translation: String?, books: [String]?) async throws -> [BibleSearchResult] {
        return []
    }
}

private class MockCommunityService: CommunityServiceProtocol {
    func getPosts() async throws -> [CommunityPost] {
        return []
    }
    
    func createPost(_ post: CommunityPost) async throws {
        // Mock implementation
    }
    
    func getGroups() async throws -> [CommunityGroup] {
        return []
    }
    
    func joinGroup(_ group: CommunityGroup) async throws {
        // Mock implementation
    }
}

private class MockAudioService: AudioServiceProtocol {
    func getAudioChapter(book: String, chapter: Int) async throws -> AudioChapter {
        return AudioChapter(
            id: "\(book.lowercased())_\(chapter)_audio",
            bookId: book.lowercased(),
            bookName: book,
            chapter: chapter,
            audioUrl: "mock://audio/\(book.lowercased())_\(chapter).mp3",
            duration: 300.0
        )
    }
    
    func playAudio(chapter: AudioChapter) async throws {
        // Mock implementation
    }
    
    func pauseAudio() async throws {
        // Mock implementation
    }
    
    func stopAudio() async throws {
        // Mock implementation
    }
    
    func setVolume(_ volume: Double) async throws {
        // Mock implementation
    }
    
    func setPlaybackSpeed(_ speed: Double) async throws {
        // Mock implementation
    }
}

private class MockVoiceConfigurationService: VoiceConfigurationServiceProtocol {
    func getAvailableVoices() async throws -> [Voice] {
        return [
            Voice(id: "voice1", name: "English Male", language: "en", gender: "male"),
            Voice(id: "voice2", name: "English Female", language: "en", gender: "female")
        ]
    }
    
    func getVoicePreferences() async throws -> VoicePreferences {
        let defaultVoice = Voice(id: "voice1", name: "English Male", language: "en", gender: "male")
        return VoicePreferences(selectedVoice: defaultVoice, speed: 1.0, pitch: 1.0)
    }
    
    func setVoicePreferences(_ preferences: VoicePreferences) async throws {
        // Mock implementation
    }
}

private class MockHapticManager: HapticManagerProtocol {
    func triggerFeedback() {
        // Mock implementation
    }
    
    func triggerSuccess() {
        // Mock implementation
    }
    
    func triggerError() {
        // Mock implementation
    }
    
    func triggerWarning() {
        // Mock implementation
    }
    
    func triggerSelection() {
        // Mock implementation
    }
}

// MARK: - Environment Key for Haptic Manager
public struct HapticManagerEnvironmentKey: EnvironmentKey {
    public static let defaultValue: HapticManagerProtocol = MockHapticManager()
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