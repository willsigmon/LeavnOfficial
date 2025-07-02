import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import LibraryModels

// MARK: - View Model

/// ViewModel for the Library module that manages the state and business logic for the library view.
/// Handles loading, filtering, and managing library items across different categories.

@MainActor
public class LibraryViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var bookmarks: [LibraryModels.LibraryItem] = []
    @Published public var notes: [LibraryModels.LibraryItem] = []
    @Published public var highlights: [LibraryModels.LibraryItem] = []
    @Published public var readingPlans: [LibraryModels.LibraryItem] = []
    @Published public var favorites: [LibraryModels.LibraryItem] = []
    @Published public var collections: [LibraryModels.LibraryItem] = []
    @Published public var isLoading = false
    @Published public var error: Error?
    
    // MARK: - Private Properties
    private let libraryService: LibraryServiceProtocol?
    
    // MARK: - Computed Properties
    public var totalItems: Int {
        bookmarks.count + notes.count + highlights.count + readingPlans.count + favorites.count + collections.count
    }

    // MARK: - Initialization
    public init() {
        self.libraryService = DIContainer.shared.libraryService
        Task {
            await loadLibrary()
        }
    }
    
    // MARK: - Public Methods
    public func loadLibrary() async {
        isLoading = true
        error = nil
        
        guard let libraryService = libraryService else {
            error = ServiceError.notInitialized
            isLoading = false
            return
        }
        
        do {
            // Load all library data from the service
            async let bookmarksData = libraryService.getBookmarks()
            async let notesData = libraryService.getNotes()
            async let highlightsData = libraryService.getHighlights()
            async let readingPlansData = libraryService.getReadingPlans()
            
            // Convert service data to LibraryItems
            let (bookmarksList, notesList, highlightsList, plansList) = try await (bookmarksData, notesData, highlightsData, readingPlansData)
            
            // Convert Bookmark to LibraryItem
            bookmarks = bookmarksList.map { bookmark in
                LibraryModels.LibraryItem(
                    sourceId: bookmark.id,
                    title: bookmark.verse.reference,
                    icon: "bookmark.fill",
                    category: .bookmarks,
                    date: bookmark.createdAt,
                    itemCount: 1,
                    verses: [LibraryModels.LibraryVerse(
                        number: bookmark.verse.verse,
                        text: bookmark.verse.text,
                        reference: bookmark.verse.reference
                    )]
                )
            }
            
            // Convert Note to LibraryItem
            notes = notesList.map { note in
                LibraryModels.LibraryItem(
                    sourceId: note.id,
                    title: note.verse.reference,
                    icon: "note.text",
                    category: .notes,
                    date: note.createdAt,
                    itemCount: 1,
                    verses: [LibraryModels.LibraryVerse(
                        number: note.verse.verse,
                        text: note.verse.text,
                        reference: note.verse.reference
                    )]
                )
            }
            
            // Convert Highlight to LibraryItem
            highlights = highlightsList.map { highlight in
                LibraryModels.LibraryItem(
                    sourceId: highlight.id,
                    title: highlight.verse.reference,
                    icon: "highlighter",
                    category: .highlights,
                    date: highlight.createdAt,
                    itemCount: 1,
                    colorIndex: highlight.colorIndex,
                    verses: [LibraryModels.LibraryVerse(
                        number: highlight.verse.verse,
                        text: highlight.verse.text,
                        reference: highlight.verse.reference
                    )]
                )
            }
            
            // Convert ReadingPlan to LibraryItem
            readingPlans = plansList.map { plan in
                LibraryModels.LibraryItem(
                    sourceId: plan.id,
                    title: plan.name,
                    icon: "calendar.circle",
                    category: .readingPlans,
                    date: plan.startDate ?? Date(),
                    itemCount: plan.days.count
                )
            }
            
            // Favorites and collections remain empty for now as they're not in the service protocol
            favorites = []
            collections = []
            
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    public func isEmpty(for category: LibraryModels.LibraryCategory) -> Bool {
        items(for: category).isEmpty
    }
    
    public func items(for category: LibraryModels.LibraryCategory) -> [LibraryModels.LibraryItem] {
        switch category {
        case .bookmarks: return bookmarks
        case .notes: return notes
        case .highlights: return highlights
        case .readingPlans: return readingPlans
        case .favorites: return favorites
        case .collections: return collections
        }
    }
    
    public func itemCount(for category: LibraryModels.LibraryCategory) -> Int {
        items(for: category).count
    }
    
    public func deleteItem(_ item: LibraryModels.LibraryItem) async {
        guard let libraryService = libraryService else { return }
        
        do {
            switch item.category {
            case .bookmarks:
                try await libraryService.removeBookmark(item.sourceId)
                bookmarks.removeAll { $0.id == item.id }
            case .notes:
                try await libraryService.deleteNote(item.sourceId)
                notes.removeAll { $0.id == item.id }
            case .highlights:
                try await libraryService.removeHighlight(item.sourceId)
                highlights.removeAll { $0.id == item.id }
            case .readingPlans:
                try await libraryService.removeReadingPlan(item.sourceId)
                readingPlans.removeAll { $0.id == item.id }
            case .favorites:
                // Not implemented in service yet
                favorites.removeAll { $0.id == item.id }
            case .collections:
                // Not implemented in service yet
                collections.removeAll { $0.id == item.id }
            }
        } catch {
            self.error = error
        }
    }
}
