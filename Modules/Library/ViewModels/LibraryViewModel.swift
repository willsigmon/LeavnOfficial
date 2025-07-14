import Foundation
import SwiftUI
import Combine

@MainActor
class LibraryViewModel: ObservableObject {
    @Published var libraryItems: [LibraryItem] = []
    @Published var collections: [LibraryCollection] = []
    @Published var statistics: LibraryStatistics?
    @Published var selectedFilter: LibraryFilter?
    @Published var isLoading = false
    @Published var isSyncing = false
    @Published var error: Error?
    @Published var lastSyncDate: Date?
    
    private let libraryRepository: LibraryRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        libraryRepository: LibraryRepositoryProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.libraryRepository = libraryRepository ?? container.libraryRepository
        self.analyticsService = analyticsService ?? container.analyticsService
        
        Task {
            await loadLibraryData()
        }
    }
    
    func loadLibraryData() async {
        isLoading = true
        error = nil
        
        do {
            // Load items with current filter
            libraryItems = try await libraryRepository.getItems(filter: selectedFilter)
            
            // Load collections
            collections = try await libraryRepository.getCollections()
            
            // Load statistics
            statistics = try await libraryRepository.getStatistics()
            
            // Get last sync date
            lastSyncDate = try await libraryRepository.getLastSyncDate()
            
            analyticsService.track(event: "library_loaded", properties: [
                "items_count": libraryItems.count,
                "collections_count": collections.count
            ])
        } catch {
            self.error = error
            print("Failed to load library data: \(error)")
        }
        
        isLoading = false
    }
    
    func addBookmark(reference: String, text: String) async {
        let bookmark = LibraryItem(
            type: .bookmark,
            title: reference,
            content: text,
            reference: reference
        )
        
        do {
            try await libraryRepository.saveItem(bookmark)
            await loadLibraryData()
            
            analyticsService.track(event: "bookmark_added", properties: [
                "reference": reference
            ])
        } catch {
            self.error = error
            print("Failed to add bookmark: \(error)")
        }
    }
    
    func addHighlight(reference: String, text: String, color: Color = .yellow) async {
        let highlight = LibraryItem(
            type: .highlight,
            title: reference,
            content: text,
            reference: reference
        )
        
        do {
            try await libraryRepository.saveItem(highlight)
            await loadLibraryData()
            
            analyticsService.track(event: "highlight_added", properties: [
                "reference": reference,
                "color": color.description
            ])
        } catch {
            self.error = error
            print("Failed to add highlight: \(error)")
        }
    }
    
    func addNote(reference: String, content: String) async {
        let note = LibraryItem(
            type: .note,
            title: "Note on \(reference)",
            content: content,
            reference: reference
        )
        
        do {
            try await libraryRepository.saveItem(note)
            await loadLibraryData()
            
            analyticsService.track(event: "note_added", properties: [
                "reference": reference,
                "content_length": content.count
            ])
        } catch {
            self.error = error
            print("Failed to add note: \(error)")
        }
    }
    
    func addFavorite(verse: BibleVerse) async {
        let favorite = LibraryItem(
            type: .favorite,
            title: verse.reference,
            content: verse.text,
            reference: verse.reference,
            metadata: [
                "book": verse.book,
                "chapter": String(verse.chapter),
                "verse": String(verse.verse),
                "translation": verse.translation
            ]
        )
        
        do {
            try await libraryRepository.saveItem(favorite)
            await loadLibraryData()
            
            analyticsService.track(event: "favorite_added", properties: [
                "reference": verse.reference,
                "translation": verse.translation
            ])
        } catch {
            self.error = error
            print("Failed to add favorite: \(error)")
        }
    }
    
    func deleteItem(_ item: LibraryItem) async {
        do {
            try await libraryRepository.deleteItem(id: item.id)
            await loadLibraryData()
            
            analyticsService.track(event: "library_item_deleted", properties: [
                "type": item.type.rawValue,
                "id": item.id
            ])
        } catch {
            self.error = error
            print("Failed to delete item: \(error)")
        }
    }
    
    func createCollection(name: String, description: String?) async {
        let collection = LibraryCollection(
            id: UUID().uuidString,
            name: name,
            description: description,
            itemIds: [],
            createdAt: Date(),
            updatedAt: Date()
        )
        
        do {
            try await libraryRepository.createCollection(collection)
            await loadLibraryData()
            
            analyticsService.track(event: "collection_created", properties: [
                "name": name
            ])
        } catch {
            self.error = error
            print("Failed to create collection: \(error)")
        }
    }
    
    func addItemToCollection(_ item: LibraryItem, collection: LibraryCollection) async {
        var updatedCollection = collection
        updatedCollection.itemIds.append(item.id)
        
        do {
            try await libraryRepository.updateCollection(updatedCollection)
            await loadLibraryData()
            
            analyticsService.track(event: "item_added_to_collection", properties: [
                "item_id": item.id,
                "collection_id": collection.id
            ])
        } catch {
            self.error = error
            print("Failed to add item to collection: \(error)")
        }
    }
    
    func syncLibrary() async {
        isSyncing = true
        error = nil
        
        do {
            try await libraryRepository.sync()
            await loadLibraryData()
            
            analyticsService.track(event: "library_synced", properties: nil)
        } catch {
            self.error = error
            print("Failed to sync library: \(error)")
        }
        
        isSyncing = false
    }
    
    func applyFilter(_ filter: LibraryFilter?) {
        selectedFilter = filter
        
        Task {
            await loadLibraryData()
        }
    }
    
    func searchLibrary(query: String) async -> [LibraryItem] {
        do {
            let results = try await libraryRepository.search(query: query, filter: selectedFilter)
            
            analyticsService.track(event: "library_search", properties: [
                "query": query,
                "results_count": results.count
            ])
            
            return results
        } catch {
            self.error = error
            print("Library search failed: \(error)")
            return []
        }
    }
}

// MARK: - Legacy Model Types (for backward compatibility)

struct BookmarkItem: Identifiable {
    let id: String
    let reference: String
    let dateAdded: Date
}

struct HighlightItem: Identifiable {
    let id: String
    let reference: String
    let text: String
    let color: Color
    let dateAdded: Date
}

struct NoteItem: Identifiable {
    let id: String
    let reference: String
    let content: String
    let dateAdded: Date
}

struct ReadingPlan: Identifiable {
    let id: String
    let name: String
    let progress: Double
    let daysRemaining: Int
}