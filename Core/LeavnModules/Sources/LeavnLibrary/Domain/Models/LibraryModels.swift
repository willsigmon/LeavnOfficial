import Foundation
import LeavnCore

// MARK: - Library View State
// This file now contains only module-specific types
// All shared domain models are imported from LeavnCore

public struct LibraryViewState: Equatable {
    public var items: [LibraryItem] = []
    public var collections: [LibraryCollection] = []
    public var selectedFilter: LibraryFilter = LibraryFilter()
    public var isLoading: Bool = false
    public var error: Error? = nil
    public var searchQuery: String = ""
    public var selectedItemId: String? = nil
    public var selectedCollectionId: String? = nil
    public var statistics: LibraryStatistics? = nil
    public var isSyncing: Bool = false
    public var downloadProgress: [String: Double] = [:]
    
    public init(
        items: [LibraryItem] = [],
        collections: [LibraryCollection] = [],
        selectedFilter: LibraryFilter = LibraryFilter(),
        isLoading: Bool = false,
        error: Error? = nil,
        searchQuery: String = "",
        selectedItemId: String? = nil,
        selectedCollectionId: String? = nil,
        statistics: LibraryStatistics? = nil,
        isSyncing: Bool = false,
        downloadProgress: [String: Double] = [:]
    ) {
        self.items = items
        self.collections = collections
        self.selectedFilter = selectedFilter
        self.isLoading = isLoading
        self.error = error
        self.searchQuery = searchQuery
        self.selectedItemId = selectedItemId
        self.selectedCollectionId = selectedCollectionId
        self.statistics = statistics
        self.isSyncing = isSyncing
        self.downloadProgress = downloadProgress
    }
    
    public static func == (lhs: LibraryViewState, rhs: LibraryViewState) -> Bool {
        lhs.items == rhs.items &&
        lhs.collections == rhs.collections &&
        lhs.isLoading == rhs.isLoading &&
        lhs.searchQuery == rhs.searchQuery &&
        lhs.selectedItemId == rhs.selectedItemId &&
        lhs.selectedCollectionId == rhs.selectedCollectionId &&
        lhs.statistics == rhs.statistics &&
        lhs.isSyncing == rhs.isSyncing &&
        lhs.downloadProgress == rhs.downloadProgress
    }
}

// MARK: - Library View Events
public enum LibraryViewEvent {
    case loadItems
    case loadCollections
    case searchItems(query: String)
    case filterItems(filter: LibraryFilter)
    case selectItem(id: String)
    case selectCollection(id: String)
    case deleteItem(id: String)
    case deleteCollection(id: String)
    case downloadItem(id: String)
    case cancelDownload(id: String)
    case syncLibrary
    case refreshStatistics
    case createCollection(name: String, description: String)
    case addItemsToCollection(collectionId: String, itemIds: [String])
    case removeItemsFromCollection(collectionId: String, itemIds: [String])
}

// MARK: - Library-specific Extensions
public extension LibraryItem {
    var isOfflineAvailable: Bool {
        isDownloaded && downloadProgress >= 1.0
    }
    
    var formattedFileSize: String {
        guard let fileSize = fileSize else { return "Unknown" }
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var timeSinceAccessed: String? {
        guard let lastAccessed = lastAccessedAt else { return nil }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: lastAccessed, relativeTo: Date())
    }
}