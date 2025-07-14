import Foundation

// MARK: - Library Domain Models
// These types are shared between LeavnServices and LeavnLibrary modules

public struct LibraryItem: Codable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let description: String
    public let contentType: LibraryContentType
    public let sourceType: LibrarySourceType
    public let sourceId: String
    public let sourceURL: URL?
    public let thumbnailURL: URL?
    public let coverImageURL: URL?
    public let author: String?
    public let tags: [String]
    public let categories: [String]
    public let savedAt: Date
    public let lastAccessedAt: Date?
    public let isDownloaded: Bool
    public let downloadProgress: Double
    public let fileSize: Int64?
    public let metadata: LibraryItemMetadata
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String? = nil,
        description: String,
        contentType: LibraryContentType,
        sourceType: LibrarySourceType,
        sourceId: String,
        sourceURL: URL? = nil,
        thumbnailURL: URL? = nil,
        coverImageURL: URL? = nil,
        author: String? = nil,
        tags: [String] = [],
        categories: [String] = [],
        savedAt: Date = Date(),
        lastAccessedAt: Date? = nil,
        isDownloaded: Bool = false,
        downloadProgress: Double = 0.0,
        fileSize: Int64? = nil,
        metadata: LibraryItemMetadata = LibraryItemMetadata()
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = contentType
        self.sourceType = sourceType
        self.sourceId = sourceId
        self.sourceURL = sourceURL
        self.thumbnailURL = thumbnailURL
        self.coverImageURL = coverImageURL
        self.author = author
        self.tags = tags
        self.categories = categories
        self.savedAt = savedAt
        self.lastAccessedAt = lastAccessedAt
        self.isDownloaded = isDownloaded
        self.downloadProgress = downloadProgress
        self.fileSize = fileSize
        self.metadata = metadata
    }
}

public enum LibraryContentType: String, Codable, CaseIterable, Sendable {
    case bibleVerse = "bible_verse"
    case prayer = "prayer"
    case devotional = "devotional"
    case sermon = "sermon"
    case article = "article"
    case book = "book"
    case video = "video"
    case podcast = "podcast"
    case audio = "audio"
    case lifeSituation = "life_situation"
    case note = "note"
    case highlight = "highlight"
    case bookmark = "bookmark"
    
    public var displayName: String {
        switch self {
        case .bibleVerse: return "Bible Verse"
        case .prayer: return "Prayer"
        case .devotional: return "Devotional"
        case .sermon: return "Sermon"
        case .article: return "Article"
        case .book: return "Book"
        case .video: return "Video"
        case .podcast: return "Podcast"
        case .audio: return "Audio"
        case .lifeSituation: return "Life Situation"
        case .note: return "Note"
        case .highlight: return "Highlight"
        case .bookmark: return "Bookmark"
        }
    }
}

public enum LibrarySourceType: String, Codable, Sendable {
    case bible
    case prayer
    case devotional
    case sermon
    case article
    case lifeSituation
    case userCreated
    case external
}

public struct LibraryItemMetadata: Codable, Sendable {
    public var customFields: [String: AnyCodable]
    
    public init(customFields: [String: AnyCodable] = [:]) {
        self.customFields = customFields
    }
}

// MARK: - Library Collection
public struct LibraryCollection: Codable, Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let coverImageURL: URL?
    public let itemIds: [String]
    public let createdAt: Date
    public let updatedAt: Date
    public let isPrivate: Bool
    public let tags: [String]
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        coverImageURL: URL? = nil,
        itemIds: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPrivate: Bool = true,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.coverImageURL = coverImageURL
        self.itemIds = itemIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPrivate = isPrivate
        self.tags = tags
    }
}

// MARK: - Library Statistics
public struct LibraryStatistics: Codable, Sendable {
    public let totalItems: Int
    public let itemsByType: [LibraryContentType: Int]
    public let totalCollections: Int
    public let totalSize: Int64
    public let lastSyncDate: Date?
    
    public init(
        totalItems: Int,
        itemsByType: [LibraryContentType: Int],
        totalCollections: Int,
        totalSize: Int64 = 0,
        lastSyncDate: Date? = nil
    ) {
        self.totalItems = totalItems
        self.itemsByType = itemsByType
        self.totalCollections = totalCollections
        self.totalSize = totalSize
        self.lastSyncDate = lastSyncDate
    }
}

// MARK: - Library Filter
public struct LibraryFilter: Sendable {
    public let contentTypes: [LibraryContentType]?
    public let sourceTypes: [LibrarySourceType]?
    public let tags: [String]?
    public let categories: [String]?
    public let searchQuery: String?
    public let isDownloaded: Bool?
    public let dateRange: DateRange?
    public let sortBy: LibrarySortOption
    public let limit: Int?
    public let offset: Int?
    
    public init(
        contentTypes: [LibraryContentType]? = nil,
        sourceTypes: [LibrarySourceType]? = nil,
        tags: [String]? = nil,
        categories: [String]? = nil,
        searchQuery: String? = nil,
        isDownloaded: Bool? = nil,
        dateRange: DateRange? = nil,
        sortBy: LibrarySortOption = .savedAt(ascending: false),
        limit: Int? = nil,
        offset: Int? = nil
    ) {
        self.contentTypes = contentTypes
        self.sourceTypes = sourceTypes
        self.tags = tags
        self.categories = categories
        self.searchQuery = searchQuery
        self.isDownloaded = isDownloaded
        self.dateRange = dateRange
        self.sortBy = sortBy
        self.limit = limit
        self.offset = offset
    }
}

public enum LibrarySortOption: Sendable {
    case title(ascending: Bool)
    case savedAt(ascending: Bool)
    case lastAccessed(ascending: Bool)
    case author(ascending: Bool)
    case contentType
}

// MARK: - Library Events
public enum LibraryEvent {
    case itemAdded(LibraryItem)
    case itemUpdated(LibraryItem)
    case itemDeleted(String)
    case collectionCreated(LibraryCollection)
    case collectionUpdated(LibraryCollection)
    case collectionDeleted(String)
    case syncStarted
    case syncCompleted(Result<LibraryStatistics, Error>)
    case downloadStarted(itemId: String)
    case downloadProgress(itemId: String, progress: Double)
    case downloadCompleted(itemId: String, result: Result<URL, Error>)
}

// MARK: - Library Use Case Protocols
public protocol GetLibraryItemsUseCaseProtocol {
    func execute(filter: LibraryFilter?) async throws -> [LibraryItem]
}

public protocol SaveContentToLibraryUseCaseProtocol {
    func execute(item: LibraryItem) async throws
}

public protocol ManageCollectionsUseCaseProtocol {
    func createCollection(_ collection: LibraryCollection) async throws
    func updateCollection(_ collection: LibraryCollection) async throws
    func deleteCollection(id: String) async throws
    func addItemsToCollection(collectionId: String, itemIds: [String]) async throws
    func removeItemsFromCollection(collectionId: String, itemIds: [String]) async throws
}

public protocol ManageDownloadsUseCaseProtocol {
    func downloadItem(id: String) async throws -> URL
    func cancelDownload(id: String) async throws
    func deleteDownload(id: String) async throws
    func getDownloadProgress(id: String) -> Double
}

public protocol SearchLibraryUseCaseProtocol {
    func execute(query: String, filter: LibraryFilter?) async throws -> [LibraryItem]
}

public protocol GetLibraryStatisticsUseCaseProtocol {
    func execute() async throws -> LibraryStatistics
}

public protocol SyncLibraryUseCaseProtocol {
    func execute() async throws
    func getLastSyncDate() async throws -> Date?
}

// MARK: - Library View Model Protocol
public protocol LibraryViewModelProtocol: ObservableObject {
    associatedtype State
    associatedtype Event
    
    var currentState: State { get }
    func handle(event: Event)
}