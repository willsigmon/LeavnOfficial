import Foundation
import Combine

// MARK: - Bible Service Protocol
public protocol BibleServiceProtocol {
    func getAvailableTranslations() async throws -> [BibleTranslation]
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter
    func searchVerses(query: String, translation: String) async throws -> [BibleVerse]
    func getDailyVerse() async throws -> BibleVerse
    func getBooks() async throws -> [BibleBook]
}

// MARK: - User Data Manager Protocol
public protocol UserDataManagerProtocol {
    func getCurrentBook() -> String?
    func getCurrentChapter() -> Int?
    func getCurrentTranslation() -> String?
    func setCurrentBook(_ book: String)
    func setCurrentChapter(_ chapter: Int)
    func setCurrentTranslation(_ translation: String)
    func saveBookmark(_ verse: BibleVerse)
    func removeBookmark(_ verse: BibleVerse)
    func getBookmarks() -> [BibleVerse]
    func clearAllData() async throws
}

// MARK: - Analytics Service Protocol
public protocol AnalyticsServiceProtocol {
    func track(event: String, properties: [String: Any])
    func identify(userId: String, traits: [String: Any])
}

// MARK: - Library Service Protocol
public protocol LibraryServiceProtocol {
    func getLibraryItems() async throws -> [LibraryItem]
    func addLibraryItem(_ item: LibraryItem) async throws
    func removeLibraryItem(_ item: LibraryItem) async throws
    func searchLibraryItems(query: String) async throws -> [LibrarySearchResult]
}

// MARK: - Search Service Protocol
public protocol SearchServiceProtocol {
    func searchVerses(query: String, translation: String) async throws -> [BibleSearchResult]
    func searchLibrary(query: String) async throws -> [LibrarySearchResult]
    func getSearchSuggestions(query: String) async throws -> [String]
    func getRecentSearches(limit: Int) async throws -> [SearchQuery]
    func saveSearch(_ query: SearchQuery) async throws
    func clearSearchHistory() async throws
    func searchBible(query: String, translation: String?, books: [String]?) async throws -> [BibleSearchResult]
}

// MARK: - Community Service Protocol
public protocol CommunityServiceProtocol {
    func getPosts() async throws -> [CommunityPost]
    func createPost(_ post: CommunityPost) async throws
    func getGroups() async throws -> [CommunityGroup]
    func joinGroup(_ group: CommunityGroup) async throws
    func getFeedPosts(limit: Int) async throws -> [CommunityPost]
    func createPost(content: String, groupId: String?) async throws -> CommunityPost
    func likePost(postId: String) async throws
    func getUserGroups() async throws -> [CommunityGroup]
    func joinGroup(groupId: String) async throws
    func leaveGroup(groupId: String) async throws
}

// MARK: - Audio Service Protocol
public protocol AudioServiceProtocol {
    func getAudioChapter(book: String, chapter: Int) async throws -> AudioChapter
    func playAudio(chapter: AudioChapter) async throws
    func pauseAudio() async throws
    func stopAudio() async throws
    func setVolume(_ volume: Double) async throws
    func setPlaybackSpeed(_ speed: Double) async throws
}

// MARK: - Voice Configuration Service Protocol
public protocol VoiceConfigurationServiceProtocol {
    func getAvailableVoices() async throws -> [Voice]
    func getVoicePreferences() async throws -> VoicePreferences
    func setVoicePreferences(_ preferences: VoicePreferences) async throws
}

// MARK: - Haptic Manager Protocol
public protocol HapticManagerProtocol {
    func triggerFeedback()
    func triggerSuccess()
    func triggerError()
    func triggerWarning()
    func triggerSelection()
}

// MARK: - Bible Service Protocol Extensions
extension BibleServiceProtocol {
    func getPassage(reference: String) async throws -> BiblePassage {
        // Default implementation
        let verses = try await searchVerses(query: reference, translation: "ESV")
        return BiblePassage(id: reference, reference: reference, text: verses.map { $0.text }.joined(separator: " "), verses: verses)
    }
}