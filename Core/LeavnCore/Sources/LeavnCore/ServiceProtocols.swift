import Foundation
import Combine

// MARK: - Network Service Protocol
/// Handles all network communication for the app
public protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
    func upload(_ endpoint: Endpoint, data: Data) async throws -> Data
    func download(_ endpoint: Endpoint) async throws -> URL
    var isReachable: AnyPublisher<Bool, Never> { get }
}

// MARK: - Analytics Service Protocol
/// Tracks user events and app usage analytics
public protocol AnalyticsServiceProtocol {
    func track(event: String, properties: [String: Any]?)
    func trackError(_ error: Error, properties: [String: Any]?)
    func identify(userId: String, traits: [String: Any]?)
    func reset()
    func addProvider(_ provider: AnalyticsProvider)
}

/// Analytics provider interface for pluggable analytics backends
// AnalyticsProvider is now defined in AnalyticsKit/AnalyticsKit.swift

// MARK: - Bible Service Protocol
/// Manages Bible content retrieval and caching
public protocol BibleServiceProtocol {
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter
    func getVerse(reference: String, translation: String) async throws -> BibleVerse
    func searchVerses(query: String, translation: String) async throws -> [BibleVerse]
    func getAvailableTranslations() async throws -> [BibleTranslation]
    func getDailyVerse() async throws -> BibleVerse
}

// MARK: - Audio Service Protocol
/// Handles audio playback and text-to-speech
public protocol AudioServiceProtocol {
    func playVerse(_ verse: BibleVerse, voice: VoiceConfiguration?) async throws
    func pause()
    func resume()
    func stop()
    func generateAudio(text: String, voice: VoiceConfiguration) async throws -> URL
    var isPlaying: AnyPublisher<Bool, Never> { get }
    var progress: AnyPublisher<Double, Never> { get }
}

// MARK: - Authentication Service Protocol
/// Manages user authentication and session management
public protocol AuthenticationServiceProtocol {
    func signIn(email: String, password: String) async throws -> AuthUser
    func signUp(email: String, password: String, name: String) async throws -> AuthUser
    func signOut() async throws
    func resetPassword(email: String) async throws
    func refreshToken() async throws
    var currentUser: AnyPublisher<AuthUser?, Never> { get }
    var isAuthenticated: Bool { get }
}

// MARK: - Bible Cache Manager Protocol
/// Manages local caching of Bible content
public protocol BibleCacheManagerProtocol {
    func cacheChapter(_ chapter: BibleChapter, translation: String) async throws
    func getCachedChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter?
    func cacheVerse(_ verse: BibleVerse) async throws
    func getCachedVerse(reference: String, translation: String) async throws -> BibleVerse?
    func clearCache() async throws
    func getCacheSize() async throws -> Int64
}

// MARK: - Audio Cache Manager Protocol
/// Manages local caching of audio files
public protocol AudioCacheManagerProtocol {
    func cacheAudio(for key: String, data: Data) async throws
    func getCachedAudio(for key: String) async throws -> Data?
    func getCachedAudioURL(for key: String) async throws -> URL?
    func removeCachedAudio(for key: String) async throws
    func clearCache() async throws
    func getCacheSize() async throws -> Int64
}

// MARK: - Eleven Labs Service Protocol
/// Interface for ElevenLabs text-to-speech API
public protocol ElevenLabsServiceProtocol {
    func generateSpeech(text: String, voiceId: String, modelId: String?) async throws -> Data
    func getVoices() async throws -> [ElevenLabsVoice]
    func getModels() async throws -> [ElevenLabsModel]
}

// MARK: - Library Repository Protocol
/// Manages user's saved content library
public protocol LibraryRepositoryProtocol {
    // Items
    func getItems(filter: LibraryFilter?) async throws -> [LibraryItem]
    func getItem(id: String) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func updateItem(_ item: LibraryItem) async throws
    func deleteItem(id: String) async throws
    
    // Collections
    func getCollections() async throws -> [LibraryCollection]
    func getCollection(id: String) async throws -> LibraryCollection?
    func createCollection(_ collection: LibraryCollection) async throws
    func updateCollection(_ collection: LibraryCollection) async throws
    func deleteCollection(id: String) async throws
    
    // Search
    func search(query: String, filter: LibraryFilter?) async throws -> [LibraryItem]
    
    // Statistics
    func getStatistics() async throws -> LibraryStatistics
    
    // Sync
    func sync() async throws
    func getLastSyncDate() async throws -> Date?
}

// MARK: - Settings Repository Protocol
/// Manages app settings storage and retrieval
public protocol SettingsRepositoryProtocol {
    func getSettings() async throws -> AppSettings
    func updateSettings(_ settings: AppSettings) async throws
    func updateSetting<T: Codable>(key: String, value: T) async throws
    func resetToDefaults() async throws
    func exportSettings() async throws -> Data
    func importSettings(from data: Data) async throws
    func getSettingsHistory(limit: Int) async throws -> [SettingsChangeEvent]
    func createBackup(name: String) async throws -> SettingsBackup
    func getBackups() async throws -> [SettingsBackup]
    func restoreBackup(_ backup: SettingsBackup) async throws
}

// MARK: - Search Repository Protocol
/// Handles content search functionality
public protocol SearchRepositoryProtocol {
    func searchBible(query: String, translation: String?, books: [String]?) async throws -> [BibleSearchResult]
    func searchLibrary(query: String) async throws -> [LibrarySearchResult]
    func getRecentSearches(limit: Int) async throws -> [SearchQuery]
    func saveSearch(_ query: SearchQuery) async throws
    func clearSearchHistory() async throws
}

// MARK: - Life Situation Repository Protocol
/// Manages life situations and related content
public protocol LifeSituationRepositoryProtocol {
    func getSituations() async throws -> [LifeSituation]
    func getSituation(id: String) async throws -> LifeSituation?
    func getRelatedVerses(for situationId: String) async throws -> [BibleVerse]
    func getRelatedContent(for situationId: String) async throws -> [RelatedContent]
    func searchSituations(query: String) async throws -> [LifeSituation]
    func getRecentlyViewed() async throws -> [LifeSituation]
    func markAsViewed(_ situationId: String) async throws
    func getFavorites() async throws -> [LifeSituation]
    func toggleFavorite(_ situationId: String) async throws
}

// MARK: - Supporting Types
public typealias Endpoint = ServiceEndpoint

public struct ServiceEndpoint: @unchecked Sendable {
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    public let headers: [String: String]?
    public let encoding: ParameterEncoding
    
    public init(path: String, method: HTTPMethod = .get, parameters: [String: Any]? = nil, headers: [String: String]? = nil, encoding: ParameterEncoding = .url) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.encoding = encoding
    }
}

public enum ParameterEncoding {
    case url
    case json
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

public struct BibleChapter: Codable, Sendable {
    public let book: String
    public let chapter: Int
    public let verses: [BibleVerse]
    public let translation: String
    
    public init(book: String, chapter: Int, verses: [BibleVerse], translation: String) {
        self.book = book
        self.chapter = chapter
        self.verses = verses
        self.translation = translation
    }
}

public struct BibleVerse: Codable, Identifiable, Sendable {
    public let id: String
    public let reference: String
    public let text: String
    public let book: String
    public let chapter: Int
    public let verse: Int
    public let translation: String
    
    public init(id: String, reference: String, text: String, book: String, chapter: Int, verse: Int, translation: String) {
        self.id = id
        self.reference = reference
        self.text = text
        self.book = book
        self.chapter = chapter
        self.verse = verse
        self.translation = translation
    }
}

// BibleTranslation is now defined in BibleService.swift

// VoiceConfiguration is now defined in BibleTypes.swift to avoid duplication

// ElevenLabsVoice is defined in ElevenLabsService.swift

public struct ElevenLabsModel: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

// LibraryFilter is now defined in LibraryTypes.swift
// DateRange is now defined in CommonTypes.swift
// LibraryItemType is replaced by LibraryContentType in LibraryTypes.swift

// LibraryStatistics is now defined in LibraryTypes.swift

// BibleSearchResult is now defined in BibleTypes.swift to avoid duplication

// LibrarySearchResult needs LibraryItem from LibraryTypes.swift
public struct LibrarySearchResult: Identifiable, Sendable {
    public let id: String
    public let item: LibraryItem // This type is now imported from LibraryTypes.swift
    public let relevance: Double
    
    public init(id: String = UUID().uuidString, item: LibraryItem, relevance: Double) {
        self.id = id
        self.item = item
        self.relevance = relevance
    }
}

// SearchQuery is now defined in BibleTypes.swift to avoid duplication

public struct RelatedContent: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let type: String
    public let url: URL?
    
    public init(id: String, title: String, type: String, url: URL? = nil) {
        self.id = id
        self.title = title
        self.type = type
        self.url = url
    }
}

// AppSettings is defined in SettingsModels.swift

// Theme and FontSize are defined in SettingsModels.swift

public struct SettingsChangeEvent: @unchecked Sendable {
    public let setting: String
    public let oldValue: Any?
    public let newValue: Any?
    
    public init(setting: String, oldValue: Any?, newValue: Any?) {
        self.setting = setting
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

// MARK: - Settings Types (Temporary - will be moved to proper module)
// These are placeholder types to avoid circular dependencies
public struct AppSettings: Codable, Sendable {
    public init() {}
}

public struct SettingsBackup: Codable, Sendable {
    public let settings: AppSettings
    public let createdAt: Date
    public let version: String
    
    public init(settings: AppSettings, createdAt: Date = Date(), version: String = "1.0") {
        self.settings = settings
        self.createdAt = createdAt
        self.version = version
    }
}

// MARK: - Additional Types
public struct BibleTranslation: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let abbreviation: String
    public let language: String
    
    public init(id: String, name: String, abbreviation: String, language: String = "en") {
        self.id = id
        self.name = name
        self.abbreviation = abbreviation
        self.language = language
    }
}

public struct VoiceConfiguration: Codable, Sendable {
    public let voiceId: String
    public let speed: Double
    public let pitch: Double
    
    public init(voiceId: String, speed: Double = 1.0, pitch: Double = 1.0) {
        self.voiceId = voiceId
        self.speed = speed
        self.pitch = pitch
    }
}

public struct ElevenLabsVoice: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let category: String?
    
    public init(id: String, name: String, category: String? = nil) {
        self.id = id
        self.name = name
        self.category = category
    }
}

public protocol AnalyticsProvider {
    func track(event: String, properties: [String: Any]?)
    func identify(userId: String, traits: [String: Any]?)
    func reset()
}

// MARK: - Search Types
public struct BibleSearchResult: Identifiable, Sendable {
    public let id: String
    public let verse: BibleVerse
    public let relevance: Double
    
    public init(id: String = UUID().uuidString, verse: BibleVerse, relevance: Double) {
        self.id = id
        self.verse = verse
        self.relevance = relevance
    }
}

public struct SearchQuery: Codable, Identifiable, Sendable {
    public let id: String
    public let query: String
    public let timestamp: Date
    
    public init(id: String = UUID().uuidString, query: String, timestamp: Date = Date()) {
        self.id = id
        self.query = query
        self.timestamp = timestamp
    }
}

// MARK: - Life Situation Types
public struct LifeSituation: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let category: String
    public let verses: [BibleVerse]
    public let prayers: [String]
    
    public init(
        id: String,
        title: String,
        description: String,
        category: String,
        verses: [BibleVerse] = [],
        prayers: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.verses = verses
        self.prayers = prayers
    }
}