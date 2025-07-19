import Foundation

// MARK: - Service Protocol Definitions

public protocol BibleServiceProtocol: Actor {
    func fetchPassage(_ request: ESVRequest) async throws -> ESVResponse
    func searchBible(query: String, translation: String) async throws -> [SearchResult]
    func getCrossReferences(for verse: Verse) async throws -> [CrossReference]
}

public protocol AudioServiceProtocol: Actor {
    func streamAudio(for text: String, voice: Voice) async throws -> AsyncThrowingStream<Data, Error>
    func downloadAudio(for verses: [Verse], voice: Voice) async throws -> URL
    func getAvailableVoices() async throws -> [Voice]
}

public protocol CommunityServiceProtocol: Actor {
    func fetchActivities(limit: Int, offset: Int) async throws -> [Activity]
    func fetchGroups(userId: String) async throws -> [Group]
    func fetchPrayers(category: CreatePrayerRequest.PrayerCategory?) async throws -> [Prayer]
    func createPrayer(_ request: CreatePrayerRequest) async throws -> Prayer
    func joinGroup(_ groupId: String) async throws
}

public protocol LibraryServiceProtocol: Actor {
    func fetchBookmarks(userId: String) async throws -> [Bookmark]
    func fetchHighlights(userId: String) async throws -> [Highlight]
    func fetchNotes(userId: String) async throws -> [Note]
    func fetchReadingPlans(userId: String) async throws -> [ReadingPlan]
    func saveBookmark(_ bookmark: Bookmark) async throws
    func saveHighlight(_ highlight: Highlight) async throws
    func saveNote(_ note: Note) async throws
}

// MARK: - Cache Types

public struct CacheEntry<T: Codable>: Codable {
    public let value: T
    public let timestamp: Date
    public let expiresAt: Date
    
    public var isExpired: Bool {
        Date() > expiresAt
    }
    
    public init(value: T, ttl: TimeInterval = 3600) {
        self.value = value
        self.timestamp = Date()
        self.expiresAt = Date().addingTimeInterval(ttl)
    }
}

// MARK: - Sync Types

public struct SyncOperation: Identifiable, Codable {
    public let id: String
    public let type: OperationType
    public let entityType: EntityType
    public let entityId: String
    public let data: Data?
    public let timestamp: Date
    public let status: SyncStatus
    
    public enum OperationType: String, Codable {
        case create
        case update
        case delete
    }
    
    public enum EntityType: String, Codable {
        case bookmark
        case highlight
        case note
        case prayer
        case readingProgress
        case settings
    }
    
    public enum SyncStatus: String, Codable {
        case pending
        case syncing
        case completed
        case failed
    }
    
    public init(
        id: String? = nil,
        type: OperationType,
        entityType: EntityType,
        entityId: String,
        data: Data? = nil,
        timestamp: Date = Date(),
        status: SyncStatus = .pending
    ) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.entityType = entityType
        self.entityId = entityId
        self.data = data
        self.timestamp = timestamp
        self.status = status
    }
}

// MARK: - Analytics Types

public struct AnalyticsEvent: Codable {
    public let name: String
    public let parameters: [String: String]
    public let timestamp: Date
    public let userId: String?
    public let sessionId: String
    
    public init(
        name: String,
        parameters: [String: String] = [:],
        timestamp: Date = Date(),
        userId: String? = nil,
        sessionId: String
    ) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
        self.userId = userId
        self.sessionId = sessionId
    }
}

// MARK: - Configuration Types

public struct APIConfiguration {
    public let esvAPIKey: String?
    public let elevenLabsAPIKey: String?
    public let backendURL: URL
    public let webSocketURL: URL
    public let environment: Environment
    
    public enum Environment: String {
        case development
        case staging
        case production
    }
    
    public init(
        esvAPIKey: String? = ProcessInfo.processInfo.environment["ESV_API_KEY"],
        elevenLabsAPIKey: String? = ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"],
        backendURL: URL,
        webSocketURL: URL,
        environment: Environment = .production
    ) {
        self.esvAPIKey = esvAPIKey
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.backendURL = backendURL
        self.webSocketURL = webSocketURL
        self.environment = environment
    }
}