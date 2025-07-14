import Foundation

// MARK: - Get Library Items Use Case
public struct GetLibraryItemsUseCase: UseCase {
    public typealias Input = GetLibraryItemsInput
    public typealias Output = [LibraryItem]
    
    private let libraryRepository: LibraryRepository
    
    public init(libraryRepository: LibraryRepository) {
        self.libraryRepository = libraryRepository
    }
    
    public func execute(_ input: GetLibraryItemsInput) async throws -> [LibraryItem] {
        try await libraryRepository.getItems(
            filters: input.filters,
            sortOptions: input.sortOptions,
            limit: input.limit,
            offset: input.offset
        )
    }
}

// MARK: - Save Content to Library Use Case
public struct SaveContentToLibraryUseCase: UseCase {
    public typealias Input = SaveContentInput
    public typealias Output = LibraryItem
    
    private let libraryRepository: LibraryRepository
    private let analyticsService: AnalyticsService?
    
    public init(libraryRepository: LibraryRepository, analyticsService: AnalyticsService? = nil) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: SaveContentInput) async throws -> LibraryItem {
        // Create library item from input
        let item = LibraryItem(
            title: input.title,
            subtitle: input.subtitle,
            description: input.description,
            contentType: input.contentType,
            sourceType: input.sourceType,
            sourceId: input.sourceId,
            sourceURL: input.sourceURL,
            thumbnailURL: input.thumbnailURL,
            author: input.author,
            tags: input.tags,
            categories: input.categories,
            metadata: input.metadata
        )
        
        // Save to repository
        try await libraryRepository.saveItem(item)
        
        // Track analytics
        analyticsService?.track(event: LibraryAnalyticsEvent.itemSaved(
            itemId: item.id,
            contentType: item.contentType.rawValue,
            sourceType: item.sourceType.rawValue
        ))
        
        return item
    }
}

// MARK: - Manage Collections Use Case
public struct ManageCollectionsUseCase: UseCase {
    public typealias Input = CollectionManagementInput
    public typealias Output = LibraryCollection
    
    private let libraryRepository: LibraryRepository
    private let analyticsService: AnalyticsService?
    
    public init(libraryRepository: LibraryRepository, analyticsService: AnalyticsService? = nil) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: CollectionManagementInput) async throws -> LibraryCollection {
        switch input.action {
        case .create(let collection):
            try await libraryRepository.createCollection(collection)
            
            analyticsService?.track(event: LibraryAnalyticsEvent.collectionCreated(
                collectionId: collection.id,
                name: collection.name
            ))
            
            return collection
            
        case .update(let collection):
            try await libraryRepository.updateCollection(collection)
            
            analyticsService?.track(event: LibraryAnalyticsEvent.collectionUpdated(
                collectionId: collection.id,
                name: collection.name
            ))
            
            return collection
            
        case .addItems(let collectionId, let itemIds):
            guard let collection = try await libraryRepository.getCollection(by: collectionId) else {
                throw LeavnError.notFound
            }
            
            try await libraryRepository.addItemsToCollection(
                itemIds: itemIds,
                collectionId: collectionId
            )
            
            analyticsService?.track(event: LibraryAnalyticsEvent.itemsAddedToCollection(
                collectionId: collectionId,
                itemCount: itemIds.count
            ))
            
            return collection
            
        case .removeItems(let collectionId, let itemIds):
            guard let collection = try await libraryRepository.getCollection(by: collectionId) else {
                throw LeavnError.notFound
            }
            
            try await libraryRepository.removeItemsFromCollection(
                itemIds: itemIds,
                collectionId: collectionId
            )
            
            return collection
        }
    }
}

// MARK: - Download Management Use Case
public struct ManageDownloadsUseCase: UseCase {
    public typealias Input = DownloadManagementInput
    public typealias Output = LibraryDownload?
    
    private let libraryRepository: LibraryRepository
    private let analyticsService: AnalyticsService?
    
    public init(libraryRepository: LibraryRepository, analyticsService: AnalyticsService? = nil) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: DownloadManagementInput) async throws -> LibraryDownload? {
        switch input.action {
        case .start(let itemId):
            let download = try await libraryRepository.startDownload(itemId: itemId)
            
            analyticsService?.track(event: LibraryAnalyticsEvent.downloadStarted(
                itemId: itemId,
                contentType: "unknown" // Would need to fetch item for content type
            ))
            
            return download
            
        case .pause(let itemId):
            try await libraryRepository.pauseDownload(itemId: itemId)
            return try await libraryRepository.getDownloadStatus(itemId: itemId)
            
        case .resume(let itemId):
            try await libraryRepository.resumeDownload(itemId: itemId)
            return try await libraryRepository.getDownloadStatus(itemId: itemId)
            
        case .cancel(let itemId):
            try await libraryRepository.cancelDownload(itemId: itemId)
            
            analyticsService?.track(event: LibraryAnalyticsEvent.downloadCancelled(itemId: itemId))
            
            return nil
            
        case .delete(let itemId):
            try await libraryRepository.deleteDownload(itemId: itemId)
            return nil
            
        case .getStatus(let itemId):
            return try await libraryRepository.getDownloadStatus(itemId: itemId)
        }
    }
}

// MARK: - Search Library Use Case
public struct SearchLibraryUseCase: UseCase {
    public typealias Input = SearchLibraryInput
    public typealias Output = [LibraryItem]
    
    private let libraryRepository: LibraryRepository
    private let analyticsService: AnalyticsService?
    
    public init(libraryRepository: LibraryRepository, analyticsService: AnalyticsService? = nil) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: SearchLibraryInput) async throws -> [LibraryItem] {
        let results = try await libraryRepository.searchItems(
            query: input.query,
            filters: input.filters
        )
        
        analyticsService?.track(event: LibraryAnalyticsEvent.librarySearched(
            query: input.query,
            resultCount: results.count,
            hasFilters: !input.filters.isEmpty
        ))
        
        return results
    }
}

// MARK: - Get Library Statistics Use Case
public struct GetLibraryStatisticsUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = LibraryStatistics
    
    private let libraryRepository: LibraryRepository
    
    public init(libraryRepository: LibraryRepository) {
        self.libraryRepository = libraryRepository
    }
    
    public func execute(_ input: Void) async throws -> LibraryStatistics {
        try await libraryRepository.getLibraryStatistics()
    }
}

// MARK: - Sync Library Use Case
public struct SyncLibraryUseCase: UseCase {
    public typealias Input = Void
    public typealias Output = LibrarySyncStatus
    
    private let libraryRepository: LibraryRepository
    private let analyticsService: AnalyticsService?
    
    public init(libraryRepository: LibraryRepository, analyticsService: AnalyticsService? = nil) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(_ input: Void) async throws -> LibrarySyncStatus {
        analyticsService?.track(event: LibraryAnalyticsEvent.syncStarted)
        
        do {
            try await libraryRepository.syncLibrary()
            let status = try await libraryRepository.getSyncStatus()
            
            analyticsService?.track(event: LibraryAnalyticsEvent.syncCompleted)
            
            return status
        } catch {
            analyticsService?.track(event: LibraryAnalyticsEvent.syncFailed(
                error: error.localizedDescription
            ))
            
            throw error
        }
    }
}

// MARK: - Input Models
public struct GetLibraryItemsInput {
    public let filters: LibraryFilters
    public let sortOptions: LibrarySortOptions
    public let limit: Int
    public let offset: Int
    
    public init(
        filters: LibraryFilters = LibraryFilters(),
        sortOptions: LibrarySortOptions = LibrarySortOptions(),
        limit: Int = 50,
        offset: Int = 0
    ) {
        self.filters = filters
        self.sortOptions = sortOptions
        self.limit = limit
        self.offset = offset
    }
}

public struct SaveContentInput {
    public let title: String
    public let subtitle: String?
    public let description: String
    public let contentType: LibraryContentType
    public let sourceType: LibrarySourceType
    public let sourceId: String
    public let sourceURL: URL?
    public let thumbnailURL: URL?
    public let author: String?
    public let tags: [String]
    public let categories: [String]
    public let metadata: LibraryItemMetadata
    
    public init(
        title: String,
        subtitle: String? = nil,
        description: String,
        contentType: LibraryContentType,
        sourceType: LibrarySourceType,
        sourceId: String,
        sourceURL: URL? = nil,
        thumbnailURL: URL? = nil,
        author: String? = nil,
        tags: [String] = [],
        categories: [String] = [],
        metadata: LibraryItemMetadata = LibraryItemMetadata()
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.contentType = contentType
        self.sourceType = sourceType
        self.sourceId = sourceId
        self.sourceURL = sourceURL
        self.thumbnailURL = thumbnailURL
        self.author = author
        self.tags = tags
        self.categories = categories
        self.metadata = metadata
    }
}

public struct CollectionManagementInput {
    public let action: CollectionAction
    
    public init(action: CollectionAction) {
        self.action = action
    }
    
    public enum CollectionAction {
        case create(LibraryCollection)
        case update(LibraryCollection)
        case addItems(collectionId: String, itemIds: [String])
        case removeItems(collectionId: String, itemIds: [String])
    }
}

public struct DownloadManagementInput {
    public let action: DownloadAction
    
    public init(action: DownloadAction) {
        self.action = action
    }
    
    public enum DownloadAction {
        case start(itemId: String)
        case pause(itemId: String)
        case resume(itemId: String)
        case cancel(itemId: String)
        case delete(itemId: String)
        case getStatus(itemId: String)
    }
}

public struct SearchLibraryInput {
    public let query: String
    public let filters: LibraryFilters
    
    public init(query: String, filters: LibraryFilters = LibraryFilters()) {
        self.query = query
        self.filters = filters
    }
}

// MARK: - Library Analytics Events
enum LibraryAnalyticsEvent: AnalyticsEvent {
    case itemSaved(itemId: String, contentType: String, sourceType: String)
    case itemAccessed(itemId: String, contentType: String, duration: TimeInterval?)
    case itemDeleted(itemId: String, contentType: String)
    case collectionCreated(collectionId: String, name: String)
    case collectionUpdated(collectionId: String, name: String)
    case collectionDeleted(collectionId: String, name: String)
    case itemsAddedToCollection(collectionId: String, itemCount: Int)
    case downloadStarted(itemId: String, contentType: String)
    case downloadCompleted(itemId: String, contentType: String, size: Int64)
    case downloadCancelled(itemId: String)
    case librarySearched(query: String, resultCount: Int, hasFilters: Bool)
    case syncStarted
    case syncCompleted
    case syncFailed(error: String)
    case libraryExported(itemCount: Int)
    case libraryImported(itemCount: Int)
    
    var name: String {
        switch self {
        case .itemSaved: return "library_item_saved"
        case .itemAccessed: return "library_item_accessed"
        case .itemDeleted: return "library_item_deleted"
        case .collectionCreated: return "library_collection_created"
        case .collectionUpdated: return "library_collection_updated"
        case .collectionDeleted: return "library_collection_deleted"
        case .itemsAddedToCollection: return "library_items_added_to_collection"
        case .downloadStarted: return "library_download_started"
        case .downloadCompleted: return "library_download_completed"
        case .downloadCancelled: return "library_download_cancelled"
        case .librarySearched: return "library_searched"
        case .syncStarted: return "library_sync_started"
        case .syncCompleted: return "library_sync_completed"
        case .syncFailed: return "library_sync_failed"
        case .libraryExported: return "library_exported"
        case .libraryImported: return "library_imported"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .itemSaved(let itemId, let contentType, let sourceType):
            return [
                "item_id": itemId,
                "content_type": contentType,
                "source_type": sourceType
            ]
            
        case .itemAccessed(let itemId, let contentType, let duration):
            var params: [String: Any] = [
                "item_id": itemId,
                "content_type": contentType
            ]
            if let duration = duration {
                params["duration_seconds"] = Int(duration)
            }
            return params
            
        case .itemDeleted(let itemId, let contentType):
            return [
                "item_id": itemId,
                "content_type": contentType
            ]
            
        case .collectionCreated(let collectionId, let name):
            return [
                "collection_id": collectionId,
                "collection_name": name
            ]
            
        case .collectionUpdated(let collectionId, let name):
            return [
                "collection_id": collectionId,
                "collection_name": name
            ]
            
        case .collectionDeleted(let collectionId, let name):
            return [
                "collection_id": collectionId,
                "collection_name": name
            ]
            
        case .itemsAddedToCollection(let collectionId, let itemCount):
            return [
                "collection_id": collectionId,
                "item_count": itemCount
            ]
            
        case .downloadStarted(let itemId, let contentType):
            return [
                "item_id": itemId,
                "content_type": contentType
            ]
            
        case .downloadCompleted(let itemId, let contentType, let size):
            return [
                "item_id": itemId,
                "content_type": contentType,
                "file_size_bytes": size
            ]
            
        case .downloadCancelled(let itemId):
            return ["item_id": itemId]
            
        case .librarySearched(let query, let resultCount, let hasFilters):
            return [
                "query": query,
                "result_count": resultCount,
                "has_filters": hasFilters
            ]
            
        case .syncStarted, .syncCompleted:
            return nil
            
        case .syncFailed(let error):
            return ["error": error]
            
        case .libraryExported(let itemCount):
            return ["item_count": itemCount]
            
        case .libraryImported(let itemCount):
            return ["item_count": itemCount]
        }
    }
}