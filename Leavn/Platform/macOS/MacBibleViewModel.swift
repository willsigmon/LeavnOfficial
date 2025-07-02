import SwiftUI
import AppKit
import LeavnCore
import LeavnServices

@MainActor
@Observable
final class MacBibleViewModel {
    // MARK: - Properties
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let libraryService: LibraryServiceProtocol
    private let searchService: SearchServiceProtocol
    
    var selectedBook: BibleBook?
    var selectedChapter: Int = 1
    var verses: [BibleVerse] = []
    var searchResults: [APISearchResult] = []
    var isLoading = false
    var error: Error?
    
    // macOS specific
    var sidebarSelection: SidebarItem? = .bible
    var isFullScreen = false
    var selectedTranslation: Translation = .kjv
    var recentlyViewed: [RecentItem] = []
    var studyNotes: [StudyNote] = []
    var splitViewGeometry: SplitViewGeometry = .init()
    
    // Window management
    var secondaryWindows: [SecondaryWindow] = []
    
    // MARK: - Initialization
    init(
        bibleService: BibleServiceProtocol = DIContainer.shared.resolve(BibleServiceProtocol.self)!,
        cacheService: CacheServiceProtocol = DIContainer.shared.resolve(CacheServiceProtocol.self)!,
        libraryService: LibraryServiceProtocol = DIContainer.shared.resolve(LibraryServiceProtocol.self)!,
        searchService: SearchServiceProtocol = DIContainer.shared.resolve(SearchServiceProtocol.self)!
    ) {
        self.bibleService = bibleService
        self.cacheService = cacheService
        self.libraryService = libraryService
        self.searchService = searchService
        
        setupKeyboardShortcuts()
        loadRecentItems()
    }
    
    // MARK: - Public Methods
    func loadChapter() async {
        guard let book = selectedBook else { return }
        
        isLoading = true
        error = nil
        
        do {
            verses = try await bibleService.getChapter(
                bookId: book.id,
                chapter: selectedChapter,
                translation: selectedTranslation
            )
            
            addToRecentItems(book: book, chapter: selectedChapter)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func search(_ query: String) async {
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        do {
            searchResults = try await searchService.search(
                query: query,
                translation: selectedTranslation,
                searchType: .fullText
            )
        } catch {
            self.error = error
        }
    }
    
    func openInNewWindow(verse: Verse) {
        let window = SecondaryWindow(
            id: UUID(),
            type: .verseDetail(verse),
            frame: calculateNewWindowFrame()
        )
        secondaryWindows.append(window)
    }
    
    func exportToPDF(verses: [Verse]) async throws -> URL {
        let renderer = PDFRenderer()
        return try await renderer.render(verses: verses, translation: selectedTranslation)
    }
    
    // MARK: - Private Methods
    private func setupKeyboardShortcuts() {
        // Setup global keyboard shortcuts for macOS
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            self.handleKeyEvent(event)
            return event
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard event.modifierFlags.contains(.command) else { return event }
        
        switch event.charactersIgnoringModifiers {
        case "f":
            // Focus search
            return nil
        case "n":
            // Next chapter
            Task { await navigateChapter(direction: .next) }
            return nil
        case "p":
            // Previous chapter
            Task { await navigateChapter(direction: .previous) }
            return nil
        default:
            return event
        }
    }
    
    private func loadRecentItems() {
        // Load from UserDefaults or cache
        if let data = UserDefaults.standard.data(forKey: "recentItems"),
           let items = try? JSONDecoder().decode([RecentItem].self, from: data) {
            recentlyViewed = items
        }
    }
    
    private func addToRecentItems(book: Book, chapter: Int) {
        let item = RecentItem(
            id: UUID(),
            book: book,
            chapter: chapter,
            timestamp: Date()
        )
        
        recentlyViewed.insert(item, at: 0)
        if recentlyViewed.count > 10 {
            recentlyViewed.removeLast()
        }
        
        saveRecentItems()
    }
    
    private func saveRecentItems() {
        if let data = try? JSONEncoder().encode(recentlyViewed) {
            UserDefaults.standard.set(data, forKey: "recentItems")
        }
    }
    
    private func calculateNewWindowFrame() -> NSRect {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        let screenFrame = screen.visibleFrame
        let windowWidth: CGFloat = 600
        let windowHeight: CGFloat = 800
        let offset = CGFloat(secondaryWindows.count * 30)
        
        return NSRect(
            x: screenFrame.midX - windowWidth/2 + offset,
            y: screenFrame.midY - windowHeight/2 - offset,
            width: windowWidth,
            height: windowHeight
        )
    }
    
    enum NavigationDirection {
        case next, previous
    }
    
    private func navigateChapter(direction: NavigationDirection) async {
        guard let book = selectedBook else { return }
        
        switch direction {
        case .next:
            if selectedChapter < book.chapters {
                selectedChapter += 1
                await loadChapter()
            }
        case .previous:
            if selectedChapter > 1 {
                selectedChapter -= 1
                await loadChapter()
            }
        }
    }
}

// MARK: - Supporting Types
enum SidebarItem: String, CaseIterable {
    case bible = "Bible"
    case search = "Search"
    case library = "Library"
    case notes = "Notes"
    case settings = "Settings"
}

struct RecentItem: Codable, Identifiable {
    let id: UUID
    let book: Book
    let chapter: Int
    let timestamp: Date
}

struct StudyNote: Identifiable {
    let id: UUID
    let verseReference: String
    let content: String
    let createdAt: Date
    var updatedAt: Date
}

struct SplitViewGeometry {
    var sidebarWidth: CGFloat = 250
    var notesWidth: CGFloat = 300
    var showNotes: Bool = false
}

struct SecondaryWindow: Identifiable {
    let id: UUID
    let type: WindowType
    let frame: NSRect
}

enum WindowType {
    case verseDetail(Verse)
    case comparison([Verse])
    case studyNote(StudyNote)
}

// PDF Renderer
struct PDFRenderer {
    func render(verses: [Verse], translation: Translation) async throws -> URL {
        // Implementation would use PDFKit to create formatted PDF
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("export.pdf")
        // Actual PDF creation logic here
        return tempURL
    }
}
