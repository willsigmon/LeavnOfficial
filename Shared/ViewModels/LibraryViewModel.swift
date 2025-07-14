import Foundation
import SwiftUI
import Combine

@MainActor
class LibraryViewModel: BaseViewModel {
    @Published var libraryItems: [LibraryItem] = []
    @Published var collections: [LibraryCollection] = []
    @Published var statistics: LibraryStatistics?
    @Published var selectedFilter: LibraryFilter?
    @Published var lastSyncDate: Date?
    
    private let libraryService: LibraryServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    init(
        libraryService: LibraryServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.libraryService = libraryService ?? container.libraryService
        self.analyticsService = analyticsService ?? container.analyticsService
        
        super.init()
        
        Task {
            await loadLibraryData()
        }
    }
    
    func loadLibraryData() async {
        execute({
            self.libraryItems = try await self.libraryService.getLibraryItems()
            
            self.analyticsService.track(event: "library_loaded", properties: [
                "items_count": self.libraryItems.count
            ])
        })
    }
    
    func addBookmark(reference: String, text: String) async {
        let bookmark = LibraryItem(
            id: UUID().uuidString,
            title: reference,
            type: .bookmark,
            content: text
        )
        
        execute({
            try await self.libraryService.addLibraryItem(bookmark)
            await self.loadLibraryData()
            
            self.analyticsService.track(event: "bookmark_added", properties: [
                "reference": reference
            ])
        })
    }
    
    func addFavorite(verse: BibleVerse) async {
        let favorite = LibraryItem(
            id: UUID().uuidString,
            title: verse.reference,
            type: .favorite,
            content: verse.text
        )
        
        execute({
            try await self.libraryService.addLibraryItem(favorite)
            await self.loadLibraryData()
            
            self.analyticsService.track(event: "favorite_added", properties: [
                "reference": verse.reference,
                "translation": verse.translation
            ])
        })
    }
    
    func deleteItem(_ item: LibraryItem) async {
        execute({
            try await self.libraryService.removeLibraryItem(item)
            await self.loadLibraryData()
            
            self.analyticsService.track(event: "library_item_deleted", properties: [
                "type": item.type.rawValue,
                "id": item.id
            ])
        })
    }
    
    func searchLibrary(query: String) async -> [LibraryItem] {
        do {
            let results = try await libraryService.searchLibraryItems(query: query)
            
            analyticsService.track(event: "library_search", properties: [
                "query": query,
                "results_count": results.count
            ])
            
            return results.map { $0.item }
        } catch {
            self.error = error
            return []
        }
    }
}