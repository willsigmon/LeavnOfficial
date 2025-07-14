import Foundation

// MARK: - Library Repository Protocol
public protocol LibraryRepository: Repository {
    // MARK: - Library Items Management
    func getAllItems() async throws -> [LibraryItem]
    func getItems(filters: LibraryFilters, sortOptions: LibrarySortOptions, limit: Int, offset: Int) async throws -> [LibraryItem]
    func getItem(by id: String) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func deleteItem(id: String) async throws
    func updateItem(_ item: LibraryItem) async throws
    func markItemAsAccessed(id: String) async throws
    
    // MARK: - Collections Management
    func getAllCollections() async throws -> [LibraryCollection]
    func getCollection(by id: String) async throws -> LibraryCollection?
    func createCollection(_ collection: LibraryCollection) async throws
    func updateCollection(_ collection: LibraryCollection) async throws
    func deleteCollection(id: String) async throws
    func addItemToCollection(itemId: String, collectionId: String) async throws
    func removeItemFromCollection(itemId: String, collectionId: String) async throws
    func getItemsInCollection(collectionId: String) async throws -> [LibraryItem]
    func reorderCollections(_ collectionIds: [String]) async throws
    
    // MARK: - Search and Filter
    func searchItems(query: String, filters: LibraryFilters) async throws -> [LibraryItem]
    func getRecentlyAdded(limit: Int) async throws -> [LibraryItem]
    func getMostAccessed(limit: Int) async throws -> [LibraryItem]
    func getItemsByContentType(_ contentType: LibraryContentType) async throws -> [LibraryItem]
    func getItemsByAuthor(_ author: String) async throws -> [LibraryItem]
    func getItemsByTag(_ tag: String) async throws -> [LibraryItem]
    func getItemsByCategory(_ category: String) async throws -> [LibraryItem]
    
    // MARK: - Downloads Management
    func getDownloadableItems() async throws -> [LibraryItem]
    func getDownloadedItems() async throws -> [LibraryItem]
    func startDownload(itemId: String) async throws -> LibraryDownload
    func pauseDownload(itemId: String) async throws
    func resumeDownload(itemId: String) async throws
    func cancelDownload(itemId: String) async throws
    func deleteDownload(itemId: String) async throws
    func getDownloadStatus(itemId: String) async throws -> LibraryDownload?
    func getAllDownloads() async throws -> [LibraryDownload]
    func getActiveDownloads() async throws -> [LibraryDownload]
    
    // MARK: - Statistics and Analytics
    func getLibraryStatistics() async throws -> LibraryStatistics
    func getStorageUsage() async throws -> (used: Int64, available: Int64)
    func getItemAccessHistory(itemId: String) async throws -> [Date]
    func trackItemAccess(itemId: String, duration: TimeInterval?) async throws
    
    // MARK: - Sync and Backup
    func getSyncStatus() async throws -> LibrarySyncStatus
    func syncLibrary() async throws
    func exportLibrary() async throws -> URL
    func importLibrary(from url: URL) async throws -> Int
    func backupLibrary() async throws -> URL
    func restoreLibrary(from url: URL) async throws
    
    // MARK: - Bulk Operations
    func deleteItems(ids: [String]) async throws
    func addItemsToCollection(itemIds: [String], collectionId: String) async throws
    func removeItemsFromCollection(itemIds: [String], collectionId: String) async throws
    func updateItemTags(itemIds: [String], tags: [String]) async throws
    func updateItemCategories(itemIds: [String], categories: [String]) async throws
    
    // MARK: - Content Type Specific
    func saveBibleVerse(reference: String, text: String, translation: String) async throws -> LibraryItem
    func saveNote(title: String, content: String, tags: [String]) async throws -> LibraryItem
    func saveBookmark(url: URL, title: String, description: String?) async throws -> LibraryItem
    func saveHighlight(text: String, sourceId: String, location: String) async throws -> LibraryItem
    
    // MARK: - Recommendations
    func getRecommendedItems(based on: LibraryItem) async throws -> [LibraryItem]
    func getPopularItems(timeframe: RecommendationTimeframe) async throws -> [LibraryItem]
    func getSimilarItems(to itemId: String) async throws -> [LibraryItem]
}

// MARK: - Supporting Types
public enum RecommendationTimeframe: String, CaseIterable {
    case today = "today"
    case thisWeek = "this_week"
    case thisMonth = "this_month"
    case allTime = "all_time"
    
    public var displayName: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .allTime: return "All Time"
        }
    }
}

// MARK: - Library Events
public enum LibraryEvent {
    case itemAdded(LibraryItem)
    case itemUpdated(LibraryItem)
    case itemDeleted(String)
    case collectionCreated(LibraryCollection)
    case collectionUpdated(LibraryCollection)
    case collectionDeleted(String)
    case downloadStarted(String)
    case downloadCompleted(String)
    case downloadFailed(String, Error)
    case syncStarted
    case syncCompleted
    case syncFailed(Error)
}