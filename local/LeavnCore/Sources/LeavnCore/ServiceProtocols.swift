// ServiceProtocols.swift
// Single source of truth for all service protocols

import Foundation
import Combine

// MARK: - Base Protocol

public protocol ServiceProtocol {
    func initialize() async throws
}

// MARK: - Bible Service

public protocol BibleServiceProtocol: ServiceProtocol, Sendable {
    func getBooks() async throws -> [BibleBook]
    func getChapter(book: String, chapter: Int, translation: BibleTranslation) async throws -> BibleChapter
    func getVerse(book: String, chapter: Int, verse: Int, translation: BibleTranslation) async throws -> BibleVerse
    func getTranslations() async throws -> [BibleTranslation]
    func getDailyVerse(translation: BibleTranslation) async throws -> BibleVerse
    func searchVerses(query: String, translation: BibleTranslation, books: [BibleBook]?) async throws -> [BibleVerse]
}

// MARK: - Search Service

public protocol SearchServiceProtocol: ServiceProtocol, Sendable {
    func search(query: String, options: SearchOptions) async throws -> [APISearchResult]
    func getRecentSearches() async -> [String]
    func clearRecentSearches() async
}

// MARK: - Library Service

public protocol LibraryServiceProtocol: ServiceProtocol, Sendable {
    func getBookmarks() async throws -> [Bookmark]
    func addBookmark(_ bookmark: Bookmark) async throws
    func removeBookmark(_ id: String) async throws
    func updateBookmark(_ bookmark: Bookmark) async throws
    func getBookmarksByTag(_ tag: String) async throws -> [Bookmark]
    func getAllTags() async throws -> [String]
    
    func getNotes() async throws -> [Note]
    func addNote(_ note: Note) async throws
    func updateNote(_ note: Note) async throws
    func deleteNote(_ id: String) async throws
    func getNote(for verse: BibleVerse) async -> Note?
    
    func getHighlights() async throws -> [Highlight]
    func addHighlight(_ highlight: Highlight) async throws
    func removeHighlight(_ id: String) async throws
    func getHighlight(for verse: BibleVerse) async -> Highlight?
    
    func getReadingPlans() async throws -> [ReadingPlan]
    func addReadingPlan(_ plan: ReadingPlan) async throws
    func updateReadingPlan(_ plan: ReadingPlan) async throws
    func removeReadingPlan(_ id: String) async throws
    func getActiveReadingPlan() async throws -> ReadingPlan?
    func setActiveReadingPlan(_ planId: String) async throws
    
    func getReadingHistory() async throws -> [ReadingHistory]
    func addReadingEntry(_ entry: ReadingHistory) async throws
    func getReadingStats() async throws -> ReadingStats
}

// MARK: - User Service

public protocol UserServiceProtocol: ServiceProtocol, Sendable {
    func getCurrentUser() async throws -> User?
    func updateUser(_ user: User) async throws
    func updatePreferences(_ preferences: UserPreferences) async throws
    func deleteUser() async throws
    func signIn() async throws -> User
    func signOut() async throws
    func isSignedIn() async -> Bool
}

// MARK: - Sync Service

public protocol SyncServiceProtocol: ServiceProtocol, Sendable {
    func syncData() async throws
    func enableSync() async throws
    func disableSync() async throws
    func getSyncStatus() async -> SyncStatus
    func forceSyncUser() async throws
    func forceSyncLibrary() async throws
}

// MARK: - AI Service

public protocol AIServiceProtocol: ServiceProtocol, Sendable {
    func generateContent(prompt: String) async throws -> String
    func getInsights(for verse: BibleVerse) async throws -> [AIInsight]
    func generateDevotion(for verse: BibleVerse) async throws -> Devotion
    func explainVerse(_ verse: BibleVerse, context: AIContext) async throws -> String
    func compareTranslations(_ verse: BibleVerse, translations: [BibleTranslation]) async throws -> TranslationComparison
    func getHistoricalContext(for verse: BibleVerse) async throws -> HistoricalContext
}

// MARK: - Cache Service

public protocol CacheServiceProtocol: ServiceProtocol, Sendable {
    func get<T: Codable & Sendable>(_ key: String, type: T.Type) async -> T?
    func set<T: Codable & Sendable>(_ key: String, value: T, expirationDate: Date?) async
    func remove(_ key: String) async
    func clear() async
    func getCacheSize() async -> Int64
    func clearExpiredItems() async
}

// MARK: - Network Service

public protocol NetworkServiceProtocol: ServiceProtocol, Sendable {
    func isConnected() async -> Bool
    func request<T: Codable>(_ endpoint: APIEndpoint) async throws -> T
    func download(_ url: URL) async throws -> Data
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

// MARK: - Analytics Service

public protocol AnalyticsServiceProtocol: ServiceProtocol, Sendable {
    func track(event: AnalyticsEvent) async
    func setUserProperty(_ key: String, value: String) async
    func flush() async
}

// MARK: - Audio Service

public protocol AudioServiceProtocol: ServiceProtocol, Sendable {
    func narrate(_ verse: BibleVerse, configuration: AudioConfiguration) async throws -> AudioNarration
    func narrateChapter(_ chapter: BibleChapter, configuration: AudioConfiguration) async throws -> [AudioNarration]
    func getAvailableVoices() async throws -> [ElevenLabsVoice]
    func preloadAudio(for verses: [BibleVerse], configuration: AudioConfiguration) async
    func stopNarration() async
    func pauseNarration() async
    func resumeNarration() async
    func setEmotionalContext(_ context: EmotionalState) async
    func generateSSML(for text: String, style: VoiceStyle) -> String
}

// MARK: - Life Situations Engine

public protocol LifeSituationsEngineProtocol: ServiceProtocol, Sendable {
    func analyzeSituation(_ text: String) async -> LifeSituation
    func getEmotionalJourney() async -> [LifeSituation]
    func getMostCommonEmotions(days: Int) async -> [(EmotionalState, Int)]
    func getVersesForMood(_ mood: EmotionalState) async -> [VerseRecommendation]
    func getVersesForCategory(_ category: LifeCategory, mood: EmotionalState) async -> [VerseRecommendation]
}

// MARK: - Community Service

public protocol CommunityServiceProtocol: ServiceProtocol, Sendable {
    func getPosts(limit: Int) async throws -> [CommunityPost]
    func createPost(_ post: CommunityPost) async throws
    func likePost(_ postId: String) async throws
    func unlikePost(_ postId: String) async throws
    func getComments(for postId: String) async throws -> [Comment]
    func addComment(to postId: String, comment: Comment) async throws
    func reportPost(_ postId: String, reason: String) async throws
    func blockUser(_ userId: String) async throws
    func getBlockedUsers() async throws -> [String]
    func unblockUser(_ userId: String) async throws
}

