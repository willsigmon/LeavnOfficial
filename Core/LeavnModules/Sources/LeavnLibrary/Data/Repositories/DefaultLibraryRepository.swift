import Foundation
import LeavnCore
import NetworkingKit
import PersistenceKit

public final class DefaultLibraryRepository: LibraryRepository {
    private let networkService: NetworkService
    private let localStorage: Storage
    private let fileStorage: Storage
    private let cacheStorage: Storage
    private let libraryAPIClient: LibraryAPIClient
    
    // Storage keys
    private let libraryItemsKey = "library_items"
    private let collectionsKey = "library_collections"
    private let downloadsKey = "library_downloads"
    private let statisticsKey = "library_statistics"
    private let syncStatusKey = "library_sync_status"
    
    // Events
    private let eventSubject = AsyncChannel<LibraryEvent>()
    public var events: AsyncStream<LibraryEvent> {
        eventSubject.stream
    }
    
    public init(
        networkService: NetworkService,
        localStorage: Storage,
        fileStorage: Storage,
        cacheStorage: Storage
    ) {
        self.networkService = networkService
        self.localStorage = localStorage
        self.fileStorage = fileStorage
        self.cacheStorage = cacheStorage
        self.libraryAPIClient = LibraryAPIClient(networkService: networkService)
    }
    
    // MARK: - Library Items Management
    public func getAllItems() async throws -> [LibraryItem] {
        try await localStorage.load([LibraryItem].self, forKey: libraryItemsKey) ?? []
    }
    
    public func getItems(
        filters: LibraryFilters,
        sortOptions: LibrarySortOptions,
        limit: Int,
        offset: Int
    ) async throws -> [LibraryItem] {
        var items = try await getAllItems()
        
        // Apply filters
        items = applyFilters(items, filters: filters)
        
        // Apply sorting
        items = applySorting(items, sortOptions: sortOptions)
        
        // Apply pagination
        let endIndex = min(offset + limit, items.count)
        guard offset < items.count else { return [] }
        
        return Array(items[offset..<endIndex])
    }
    
    public func getItem(by id: String) async throws -> LibraryItem? {
        let items = try await getAllItems()
        return items.first { $0.id == id }
    }
    
    public func saveItem(_ item: LibraryItem) async throws {
        var items = try await getAllItems()
        
        // Remove existing item if updating
        items.removeAll { $0.id == item.id }
        items.append(item)
        
        try await localStorage.save(items, forKey: libraryItemsKey)
        
        // Sync to cloud if enabled
        try await syncItemToCloud(item)
        
        await eventSubject.send(.itemAdded(item))
    }
    
    public func deleteItem(id: String) async throws {
        var items = try await getAllItems()
        items.removeAll { $0.id == id }
        
        try await localStorage.save(items, forKey: libraryItemsKey)
        
        // Delete from cloud
        try await libraryAPIClient.deleteItem(id: id)
        
        await eventSubject.send(.itemDeleted(id))
    }
    
    public func updateItem(_ item: LibraryItem) async throws {
        try await saveItem(item)
        await eventSubject.send(.itemUpdated(item))
    }
    
    public func markItemAsAccessed(id: String) async throws {
        guard var item = try await getItem(by: id) else { return }
        
        let updatedItem = LibraryItem(
            id: item.id,
            title: item.title,
            subtitle: item.subtitle,
            description: item.description,
            contentType: item.contentType,
            sourceType: item.sourceType,
            sourceId: item.sourceId,
            sourceURL: item.sourceURL,
            thumbnailURL: item.thumbnailURL,
            coverImageURL: item.coverImageURL,
            author: item.author,
            tags: item.tags,
            categories: item.categories,
            savedAt: item.savedAt,
            lastAccessedAt: Date(),
            isDownloaded: item.isDownloaded,
            downloadProgress: item.downloadProgress,
            fileSize: item.fileSize,
            metadata: item.metadata
        )
        
        try await updateItem(updatedItem)
    }
    
    // MARK: - Collections Management
    public func getAllCollections() async throws -> [LibraryCollection] {
        try await localStorage.load([LibraryCollection].self, forKey: collectionsKey) ?? []
    }
    
    public func getCollection(by id: String) async throws -> LibraryCollection? {
        let collections = try await getAllCollections()
        return collections.first { $0.id == id }
    }
    
    public func createCollection(_ collection: LibraryCollection) async throws {
        var collections = try await getAllCollections()
        collections.append(collection)
        
        try await localStorage.save(collections, forKey: collectionsKey)
        
        // Sync to cloud
        try await libraryAPIClient.createCollection(collection)
        
        await eventSubject.send(.collectionCreated(collection))
    }
    
    public func updateCollection(_ collection: LibraryCollection) async throws {
        var collections = try await getAllCollections()
        collections.removeAll { $0.id == collection.id }
        collections.append(collection)
        
        try await localStorage.save(collections, forKey: collectionsKey)
        
        // Sync to cloud
        try await libraryAPIClient.updateCollection(collection)
        
        await eventSubject.send(.collectionUpdated(collection))
    }
    
    public func deleteCollection(id: String) async throws {
        var collections = try await getAllCollections()
        collections.removeAll { $0.id == id }
        
        try await localStorage.save(collections, forKey: collectionsKey)
        
        // Delete from cloud
        try await libraryAPIClient.deleteCollection(id: id)
        
        await eventSubject.send(.collectionDeleted(id))
    }
    
    public func addItemToCollection(itemId: String, collectionId: String) async throws {
        guard var collection = try await getCollection(by: collectionId) else {
            throw LeavnError.notFound
        }
        
        var itemIds = collection.itemIds
        if !itemIds.contains(itemId) {
            itemIds.append(itemId)
            
            let updatedCollection = LibraryCollection(
                id: collection.id,
                name: collection.name,
                description: collection.description,
                color: collection.color,
                iconName: collection.iconName,
                itemIds: itemIds,
                itemCount: itemIds.count,
                createdAt: collection.createdAt,
                updatedAt: Date(),
                isDefault: collection.isDefault,
                sortOrder: collection.sortOrder
            )
            
            try await updateCollection(updatedCollection)
        }
    }
    
    public func removeItemFromCollection(itemId: String, collectionId: String) async throws {
        guard var collection = try await getCollection(by: collectionId) else {
            throw LeavnError.notFound
        }
        
        let itemIds = collection.itemIds.filter { $0 != itemId }
        
        let updatedCollection = LibraryCollection(
            id: collection.id,
            name: collection.name,
            description: collection.description,
            color: collection.color,
            iconName: collection.iconName,
            itemIds: itemIds,
            itemCount: itemIds.count,
            createdAt: collection.createdAt,
            updatedAt: Date(),
            isDefault: collection.isDefault,
            sortOrder: collection.sortOrder
        )
        
        try await updateCollection(updatedCollection)
    }
    
    public func getItemsInCollection(collectionId: String) async throws -> [LibraryItem] {
        guard let collection = try await getCollection(by: collectionId) else {
            throw LeavnError.notFound
        }
        
        let allItems = try await getAllItems()
        return allItems.filter { collection.itemIds.contains($0.id) }
    }
    
    public func reorderCollections(_ collectionIds: [String]) async throws {
        var collections = try await getAllCollections()
        
        for (index, collectionId) in collectionIds.enumerated() {
            if let collectionIndex = collections.firstIndex(where: { $0.id == collectionId }) {
                let updatedCollection = LibraryCollection(
                    id: collections[collectionIndex].id,
                    name: collections[collectionIndex].name,
                    description: collections[collectionIndex].description,
                    color: collections[collectionIndex].color,
                    iconName: collections[collectionIndex].iconName,
                    itemIds: collections[collectionIndex].itemIds,
                    itemCount: collections[collectionIndex].itemCount,
                    createdAt: collections[collectionIndex].createdAt,
                    updatedAt: Date(),
                    isDefault: collections[collectionIndex].isDefault,
                    sortOrder: index
                )
                collections[collectionIndex] = updatedCollection
            }
        }
        
        try await localStorage.save(collections, forKey: collectionsKey)
    }
    
    // MARK: - Search and Filter
    public func searchItems(query: String, filters: LibraryFilters) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        let filteredItems = applyFilters(items, filters: filters)
        
        if query.isEmpty {
            return filteredItems
        }
        
        let lowercaseQuery = query.lowercased()
        return filteredItems.filter { item in
            item.title.lowercased().contains(lowercaseQuery) ||
            item.description.lowercased().contains(lowercaseQuery) ||
            item.author?.lowercased().contains(lowercaseQuery) == true ||
            item.tags.contains { $0.lowercased().contains(lowercaseQuery) } ||
            item.categories.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    public func getRecentlyAdded(limit: Int) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return Array(items.sorted { $0.savedAt > $1.savedAt }.prefix(limit))
    }
    
    public func getMostAccessed(limit: Int) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return Array(items
            .filter { $0.lastAccessedAt != nil }
            .sorted { $0.lastAccessedAt! > $1.lastAccessedAt! }
            .prefix(limit))
    }
    
    public func getItemsByContentType(_ contentType: LibraryContentType) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.contentType == contentType }
    }
    
    public func getItemsByAuthor(_ author: String) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.author == author }
    }
    
    public func getItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.tags.contains(tag) }
    }
    
    public func getItemsByCategory(_ category: String) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.categories.contains(category) }
    }
    
    // MARK: - Downloads Management
    public func getDownloadableItems() async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.contentType.supportsDownload }
    }
    
    public func getDownloadedItems() async throws -> [LibraryItem] {
        let items = try await getAllItems()
        return items.filter { $0.isDownloaded }
    }
    
    public func startDownload(itemId: String) async throws -> LibraryDownload {
        let download = LibraryDownload(
            itemId: itemId,
            status: .pending,
            startedAt: Date()
        )
        
        var downloads = try await getAllDownloads()
        downloads.append(download)
        try await localStorage.save(downloads, forKey: downloadsKey)
        
        // Start actual download process
        Task {
            await processDownload(download)
        }
        
        await eventSubject.send(.downloadStarted(itemId))
        
        return download
    }
    
    public func pauseDownload(itemId: String) async throws {
        var downloads = try await getAllDownloads()
        if let index = downloads.firstIndex(where: { $0.itemId == itemId }) {
            downloads[index] = LibraryDownload(
                id: downloads[index].id,
                itemId: downloads[index].itemId,
                status: .paused,
                progress: downloads[index].progress,
                totalBytes: downloads[index].totalBytes,
                downloadedBytes: downloads[index].downloadedBytes,
                startedAt: downloads[index].startedAt,
                completedAt: downloads[index].completedAt,
                error: downloads[index].error,
                retryCount: downloads[index].retryCount
            )
        }
        try await localStorage.save(downloads, forKey: downloadsKey)
    }
    
    public func resumeDownload(itemId: String) async throws {
        var downloads = try await getAllDownloads()
        if let index = downloads.firstIndex(where: { $0.itemId == itemId }) {
            downloads[index] = LibraryDownload(
                id: downloads[index].id,
                itemId: downloads[index].itemId,
                status: .downloading,
                progress: downloads[index].progress,
                totalBytes: downloads[index].totalBytes,
                downloadedBytes: downloads[index].downloadedBytes,
                startedAt: downloads[index].startedAt,
                completedAt: downloads[index].completedAt,
                error: downloads[index].error,
                retryCount: downloads[index].retryCount
            )
            
            // Resume download process
            Task {
                await processDownload(downloads[index])
            }
        }
        try await localStorage.save(downloads, forKey: downloadsKey)
    }
    
    public func cancelDownload(itemId: String) async throws {
        var downloads = try await getAllDownloads()
        downloads.removeAll { $0.itemId == itemId }
        try await localStorage.save(downloads, forKey: downloadsKey)
    }
    
    public func deleteDownload(itemId: String) async throws {
        // Delete local file
        // Implementation would delete the actual file from device storage
        
        // Update item status
        if var item = try await getItem(by: itemId) {
            let updatedItem = LibraryItem(
                id: item.id,
                title: item.title,
                subtitle: item.subtitle,
                description: item.description,
                contentType: item.contentType,
                sourceType: item.sourceType,
                sourceId: item.sourceId,
                sourceURL: item.sourceURL,
                thumbnailURL: item.thumbnailURL,
                coverImageURL: item.coverImageURL,
                author: item.author,
                tags: item.tags,
                categories: item.categories,
                savedAt: item.savedAt,
                lastAccessedAt: item.lastAccessedAt,
                isDownloaded: false,
                downloadProgress: 0.0,
                fileSize: item.fileSize,
                metadata: item.metadata
            )
            try await updateItem(updatedItem)
        }
        
        // Remove download record
        var downloads = try await getAllDownloads()
        downloads.removeAll { $0.itemId == itemId }
        try await localStorage.save(downloads, forKey: downloadsKey)
    }
    
    public func getDownloadStatus(itemId: String) async throws -> LibraryDownload? {
        let downloads = try await getAllDownloads()
        return downloads.first { $0.itemId == itemId }
    }
    
    public func getAllDownloads() async throws -> [LibraryDownload] {
        try await localStorage.load([LibraryDownload].self, forKey: downloadsKey) ?? []
    }
    
    public func getActiveDownloads() async throws -> [LibraryDownload] {
        let downloads = try await getAllDownloads()
        return downloads.filter { $0.status.isActive }
    }
    
    // MARK: - Statistics and Analytics
    public func getLibraryStatistics() async throws -> LibraryStatistics {
        // Check cache first
        if let cached = try await cacheStorage.load(LibraryStatistics.self, forKey: statisticsKey) {
            return cached
        }
        
        // Calculate statistics
        let items = try await getAllItems()
        let collections = try await getAllCollections()
        
        var itemsByType: [LibraryContentType: Int] = [:]
        var totalSize: Int64 = 0
        var downloadedSize: Int64 = 0
        
        for item in items {
            itemsByType[item.contentType] = (itemsByType[item.contentType] ?? 0) + 1
            if let fileSize = item.fileSize {
                totalSize += fileSize
                if item.isDownloaded {
                    downloadedSize += fileSize
                }
            }
        }
        
        let statistics = LibraryStatistics(
            totalItems: items.count,
            itemsByType: itemsByType,
            totalSize: totalSize,
            downloadedSize: downloadedSize,
            mostAccessedItems: try await getMostAccessed(limit: 10),
            recentlyAdded: try await getRecentlyAdded(limit: 10),
            collections: collections,
            lastSyncDate: try await getSyncStatus().lastSyncDate
        )
        
        // Cache for 5 minutes
        try await cacheStorage.save(statistics, forKey: statisticsKey)
        
        return statistics
    }
    
    public func getStorageUsage() async throws -> (used: Int64, available: Int64) {
        // This would calculate actual device storage usage
        let items = try await getDownloadedItems()
        let used = items.compactMap { $0.fileSize }.reduce(0, +)
        
        // Mock available storage calculation
        let totalDevice: Int64 = 64 * 1024 * 1024 * 1024 // 64GB mock
        let available = totalDevice - used
        
        return (used: used, available: available)
    }
    
    public func getItemAccessHistory(itemId: String) async throws -> [Date] {
        // This would return access history from analytics storage
        return []
    }
    
    public func trackItemAccess(itemId: String, duration: TimeInterval?) async throws {
        // Track in analytics system
        try await markItemAsAccessed(id: itemId)
    }
    
    // MARK: - Sync and Backup
    public func getSyncStatus() async throws -> LibrarySyncStatus {
        try await localStorage.load(LibrarySyncStatus.self, forKey: syncStatusKey) ?? LibrarySyncStatus()
    }
    
    public func syncLibrary() async throws {
        // Update sync status
        let syncStatus = LibrarySyncStatus(
            isEnabled: true,
            lastSyncDate: nil,
            pendingItems: 0,
            conflictItems: 0,
            status: .syncing,
            error: nil
        )
        try await localStorage.save(syncStatus, forKey: syncStatusKey)
        
        await eventSubject.send(.syncStarted)
        
        do {
            // Sync items to cloud
            let items = try await getAllItems()
            try await libraryAPIClient.syncItems(items)
            
            // Sync collections to cloud
            let collections = try await getAllCollections()
            try await libraryAPIClient.syncCollections(collections)
            
            // Update sync status
            let completedStatus = LibrarySyncStatus(
                isEnabled: true,
                lastSyncDate: Date(),
                pendingItems: 0,
                conflictItems: 0,
                status: .success,
                error: nil
            )
            try await localStorage.save(completedStatus, forKey: syncStatusKey)
            
            await eventSubject.send(.syncCompleted)
        } catch {
            // Update sync status with error
            let failedStatus = LibrarySyncStatus(
                isEnabled: true,
                lastSyncDate: nil,
                pendingItems: 0,
                conflictItems: 0,
                status: .failed,
                error: error.localizedDescription
            )
            try await localStorage.save(failedStatus, forKey: syncStatusKey)
            
            await eventSubject.send(.syncFailed(error))
            throw error
        }
    }
    
    public func exportLibrary() async throws -> URL {
        let items = try await getAllItems()
        let collections = try await getAllCollections()
        
        let exportData = LibraryExportData(
            items: items,
            collections: collections,
            exportDate: Date(),
            version: "1.0"
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(exportData)
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let exportURL = documentsURL.appendingPathComponent("library_export_\\(Date().timeIntervalSince1970).json")
        
        try data.write(to: exportURL)
        
        return exportURL
    }
    
    public func importLibrary(from url: URL) async throws -> Int {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let exportData = try decoder.decode(LibraryExportData.self, from: data)
        
        // Import items
        for item in exportData.items {
            try await saveItem(item)
        }
        
        // Import collections
        for collection in exportData.collections {
            try await createCollection(collection)
        }
        
        return exportData.items.count
    }
    
    public func backupLibrary() async throws -> URL {
        return try await exportLibrary()
    }
    
    public func restoreLibrary(from url: URL) async throws {
        _ = try await importLibrary(from: url)
    }
    
    // MARK: - Bulk Operations
    public func deleteItems(ids: [String]) async throws {
        var items = try await getAllItems()
        items.removeAll { ids.contains($0.id) }
        try await localStorage.save(items, forKey: libraryItemsKey)
        
        for id in ids {
            await eventSubject.send(.itemDeleted(id))
        }
    }
    
    public func addItemsToCollection(itemIds: [String], collectionId: String) async throws {
        for itemId in itemIds {
            try await addItemToCollection(itemId: itemId, collectionId: collectionId)
        }
    }
    
    public func removeItemsFromCollection(itemIds: [String], collectionId: String) async throws {
        for itemId in itemIds {
            try await removeItemFromCollection(itemId: itemId, collectionId: collectionId)
        }
    }
    
    public func updateItemTags(itemIds: [String], tags: [String]) async throws {
        let items = try await getAllItems()
        
        for itemId in itemIds {
            if let item = items.first(where: { $0.id == itemId }) {
                let updatedItem = LibraryItem(
                    id: item.id,
                    title: item.title,
                    subtitle: item.subtitle,
                    description: item.description,
                    contentType: item.contentType,
                    sourceType: item.sourceType,
                    sourceId: item.sourceId,
                    sourceURL: item.sourceURL,
                    thumbnailURL: item.thumbnailURL,
                    coverImageURL: item.coverImageURL,
                    author: item.author,
                    tags: tags,
                    categories: item.categories,
                    savedAt: item.savedAt,
                    lastAccessedAt: item.lastAccessedAt,
                    isDownloaded: item.isDownloaded,
                    downloadProgress: item.downloadProgress,
                    fileSize: item.fileSize,
                    metadata: item.metadata
                )
                try await updateItem(updatedItem)
            }
        }
    }
    
    public func updateItemCategories(itemIds: [String], categories: [String]) async throws {
        let items = try await getAllItems()
        
        for itemId in itemIds {
            if let item = items.first(where: { $0.id == itemId }) {
                let updatedItem = LibraryItem(
                    id: item.id,
                    title: item.title,
                    subtitle: item.subtitle,
                    description: item.description,
                    contentType: item.contentType,
                    sourceType: item.sourceType,
                    sourceId: item.sourceId,
                    sourceURL: item.sourceURL,
                    thumbnailURL: item.thumbnailURL,
                    coverImageURL: item.coverImageURL,
                    author: item.author,
                    tags: item.tags,
                    categories: categories,
                    savedAt: item.savedAt,
                    lastAccessedAt: item.lastAccessedAt,
                    isDownloaded: item.isDownloaded,
                    downloadProgress: item.downloadProgress,
                    fileSize: item.fileSize,
                    metadata: item.metadata
                )
                try await updateItem(updatedItem)
            }
        }
    }
    
    // MARK: - Content Type Specific
    public func saveBibleVerse(reference: String, text: String, translation: String) async throws -> LibraryItem {
        let item = LibraryItem(
            title: reference,
            description: text,
            contentType: .bibleVerse,
            sourceType: .bible,
            sourceId: reference,
            metadata: LibraryItemMetadata(
                translation: translation,
                customFields: ["verse_text": AnyCodable(text)]
            )
        )
        
        try await saveItem(item)
        return item
    }
    
    public func saveNote(title: String, content: String, tags: [String]) async throws -> LibraryItem {
        let item = LibraryItem(
            title: title,
            description: content,
            contentType: .note,
            sourceType: .userGenerated,
            sourceId: UUID().uuidString,
            tags: tags,
            metadata: LibraryItemMetadata(
                wordCount: content.split(separator: " ").count,
                customFields: ["note_content": AnyCodable(content)]
            )
        )
        
        try await saveItem(item)
        return item
    }
    
    public func saveBookmark(url: URL, title: String, description: String?) async throws -> LibraryItem {
        let item = LibraryItem(
            title: title,
            description: description ?? "",
            contentType: .bookmark,
            sourceType: .external,
            sourceId: url.absoluteString,
            sourceURL: url,
            metadata: LibraryItemMetadata(
                customFields: ["bookmark_url": AnyCodable(url.absoluteString)]
            )
        )
        
        try await saveItem(item)
        return item
    }
    
    public func saveHighlight(text: String, sourceId: String, location: String) async throws -> LibraryItem {
        let item = LibraryItem(
            title: "Highlight: \\(text.prefix(50))...",
            description: text,
            contentType: .highlight,
            sourceType: .userGenerated,
            sourceId: sourceId,
            metadata: LibraryItemMetadata(
                customFields: [
                    "highlight_text": AnyCodable(text),
                    "highlight_location": AnyCodable(location)
                ]
            )
        )
        
        try await saveItem(item)
        return item
    }
    
    // MARK: - Recommendations
    public func getRecommendedItems(based on: LibraryItem) async throws -> [LibraryItem] {
        let items = try await getAllItems()
        
        // Simple recommendation based on tags and content type
        return items.filter { item in
            item.id != on.id &&
            (item.contentType == on.contentType ||
             !Set(item.tags).isDisjoint(with: Set(on.tags)) ||
             item.author == on.author)
        }
    }
    
    public func getPopularItems(timeframe: RecommendationTimeframe) async throws -> [LibraryItem] {
        // This would use analytics data to determine popular items
        return try await getMostAccessed(limit: 20)
    }
    
    public func getSimilarItems(to itemId: String) async throws -> [LibraryItem] {
        guard let item = try await getItem(by: itemId) else { return [] }
        return try await getRecommendedItems(based: item)
    }
    
    // MARK: - Private Helper Methods
    private func applyFilters(_ items: [LibraryItem], filters: LibraryFilters) -> [LibraryItem] {
        var filtered = items
        
        if !filters.contentTypes.isEmpty {
            filtered = filtered.filter { filters.contentTypes.contains($0.contentType) }
        }
        
        if !filters.sourceTypes.isEmpty {
            filtered = filtered.filter { filters.sourceTypes.contains($0.sourceType) }
        }
        
        if !filters.categories.isEmpty {
            filtered = filtered.filter { item in
                !Set(item.categories).isDisjoint(with: Set(filters.categories))
            }
        }
        
        if !filters.tags.isEmpty {
            filtered = filtered.filter { item in
                !Set(item.tags).isDisjoint(with: Set(filters.tags))
            }
        }
        
        if !filters.authors.isEmpty {
            filtered = filtered.filter { item in
                guard let author = item.author else { return false }
                return filters.authors.contains(author)
            }
        }
        
        if let isDownloaded = filters.isDownloaded {
            filtered = filtered.filter { $0.isDownloaded == isDownloaded }
        }
        
        if let dateRange = filters.dateRange {
            filtered = filtered.filter { item in
                item.savedAt >= dateRange.start && item.savedAt <= dateRange.end
            }
        }
        
        return filtered
    }
    
    private func applySorting(_ items: [LibraryItem], sortOptions: LibrarySortOptions) -> [LibraryItem] {
        return items.sorted { lhs, rhs in
            let ascending = sortOptions.order == .ascending
            
            switch sortOptions.sortBy {
            case .title:
                return ascending ? lhs.title < rhs.title : lhs.title > rhs.title
            case .author:
                let lhsAuthor = lhs.author ?? ""
                let rhsAuthor = rhs.author ?? ""
                return ascending ? lhsAuthor < rhsAuthor : lhsAuthor > rhsAuthor
            case .dateAdded:
                return ascending ? lhs.savedAt < rhs.savedAt : lhs.savedAt > rhs.savedAt
            case .lastAccessed:
                let lhsDate = lhs.lastAccessedAt ?? Date.distantPast
                let rhsDate = rhs.lastAccessedAt ?? Date.distantPast
                return ascending ? lhsDate < rhsDate : lhsDate > rhsDate
            case .contentType:
                return ascending ? lhs.contentType.rawValue < rhs.contentType.rawValue : lhs.contentType.rawValue > rhs.contentType.rawValue
            case .fileSize:
                let lhsSize = lhs.fileSize ?? 0
                let rhsSize = rhs.fileSize ?? 0
                return ascending ? lhsSize < rhsSize : lhsSize > rhsSize
            case .rating:
                let lhsRating = lhs.metadata.rating ?? 0
                let rhsRating = rhs.metadata.rating ?? 0
                return ascending ? lhsRating < rhsRating : lhsRating > rhsRating
            case .custom:
                return false // Custom sorting would be implemented based on specific requirements
            }
        }
    }
    
    private func syncItemToCloud(_ item: LibraryItem) async throws {
        try await libraryAPIClient.saveItem(item)
    }
    
    private func processDownload(_ download: LibraryDownload) async {
        // This would implement the actual download logic
        // For now, it's a placeholder that simulates download progress
        
        var currentDownload = download
        currentDownload = LibraryDownload(
            id: download.id,
            itemId: download.itemId,
            status: .downloading,
            progress: 0.0,
            totalBytes: download.totalBytes,
            downloadedBytes: 0,
            startedAt: download.startedAt,
            completedAt: nil,
            error: nil,
            retryCount: download.retryCount
        )
        
        // Simulate download progress
        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            currentDownload = LibraryDownload(
                id: download.id,
                itemId: download.itemId,
                status: .downloading,
                progress: progress,
                totalBytes: download.totalBytes,
                downloadedBytes: Int64(Double(download.totalBytes) * progress),
                startedAt: download.startedAt,
                completedAt: nil,
                error: nil,
                retryCount: download.retryCount
            )
            
            // Update download status
            var downloads = (try? await getAllDownloads()) ?? []
            if let index = downloads.firstIndex(where: { $0.id == download.id }) {
                downloads[index] = currentDownload
                try? await localStorage.save(downloads, forKey: downloadsKey)
            }
            
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        // Mark as completed
        currentDownload = LibraryDownload(
            id: download.id,
            itemId: download.itemId,
            status: .completed,
            progress: 1.0,
            totalBytes: download.totalBytes,
            downloadedBytes: download.totalBytes,
            startedAt: download.startedAt,
            completedAt: Date(),
            error: nil,
            retryCount: download.retryCount
        )
        
        // Update download status
        var downloads = (try? await getAllDownloads()) ?? []
        if let index = downloads.firstIndex(where: { $0.id == download.id }) {
            downloads[index] = currentDownload
            try? await localStorage.save(downloads, forKey: downloadsKey)
        }
        
        await eventSubject.send(.downloadCompleted(download.itemId))
    }
}

// MARK: - Supporting Types
private struct LibraryExportData: Codable {
    let items: [LibraryItem]
    let collections: [LibraryCollection]
    let exportDate: Date
    let version: String
}

// MARK: - AsyncChannel Helper
private actor AsyncChannel<T> {
    private var continuation: AsyncStream<T>.Continuation?
    
    lazy var stream: AsyncStream<T> = {
        AsyncStream { continuation in
            self.continuation = continuation
        }
    }()
    
    func send(_ value: T) {
        continuation?.yield(value)
    }
    
    func finish() {
        continuation?.finish()
    }
}

// MARK: - Library API Client
private final class LibraryAPIClient: BaseAPIClient {
    
    func saveItem(_ item: LibraryItem) async throws {
        let endpoint = Endpoint(
            path: "/library/items",
            method: .post,
            parameters: try item.asDictionary(),
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func deleteItem(id: String) async throws {
        let endpoint = Endpoint(
            path: "/library/items/\\(id)",
            method: .delete
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func createCollection(_ collection: LibraryCollection) async throws {
        let endpoint = Endpoint(
            path: "/library/collections",
            method: .post,
            parameters: try collection.asDictionary(),
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func updateCollection(_ collection: LibraryCollection) async throws {
        let endpoint = Endpoint(
            path: "/library/collections/\\(collection.id)",
            method: .put,
            parameters: try collection.asDictionary(),
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func deleteCollection(id: String) async throws {
        let endpoint = Endpoint(
            path: "/library/collections/\\(id)",
            method: .delete
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func syncItems(_ items: [LibraryItem]) async throws {
        let endpoint = Endpoint(
            path: "/library/sync/items",
            method: .post,
            parameters: ["items": try items.map { try $0.asDictionary() }],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
    
    func syncCollections(_ collections: [LibraryCollection]) async throws {
        let endpoint = Endpoint(
            path: "/library/sync/collections",
            method: .post,
            parameters: ["collections": try collections.map { try $0.asDictionary() }],
            encoding: JSONEncoding.default
        )
        
        _ = try await networkService.request(endpoint)
    }
}

// MARK: - Extensions
private extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError()
        }
        return dictionary
    }
}