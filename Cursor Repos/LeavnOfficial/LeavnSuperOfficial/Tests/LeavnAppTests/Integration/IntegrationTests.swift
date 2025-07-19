import XCTest
import ComposableArchitecture
import CoreData
@testable import LeavnApp

final class IntegrationTests: XCTestCase {
    
    var testPersistentContainer: NSPersistentContainer!
    
    override func setUpWithError() throws {
        super.setUp()
        
        // Setup in-memory Core Data stack for testing
        testPersistentContainer = {
            let container = NSPersistentContainer(name: "LeavnModel")
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Failed to load test store: \(error)")
                }
            }
            return container
        }()
    }
    
    override func tearDownWithError() throws {
        testPersistentContainer = nil
        super.tearDown()
    }
    
    // MARK: - End-to-End User Flow Tests
    
    @MainActor
    func testCompleteReadingSessionFlow() async throws {
        // Setup integrated dependencies
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() },
            withDependencies: {
                $0.bibleService = .mock
                $0.databaseClient = makeDatabaseClient()
                $0.userDefaults = .mock
                $0.settingsService = .mock
                $0.audioService = .mock
            }
        )
        
        // 1. User launches app and navigates to Bible
        await store.send(.tabSelected(.bible)) {
            $0.selectedTab = .bible
        }
        
        // 2. User selects a book and chapter
        await store.send(.bible(.selectBook(.john))) {
            $0.bible.selectedBook = .john
            $0.bible.selectedChapter = 1
        }
        
        await store.receive(\.bible.chapterResponse.success) {
            $0.bible.isLoading = false
            XCTAssertNotNil($0.bible.currentChapter)
        }
        
        // 3. User highlights a verse
        let verse = store.state.bible.currentChapter!.verses[0]
        await store.send(.bible(.selectVerse(verse))) {
            $0.bible.selectedVerse = verse
        }
        
        await store.send(.bible(.addHighlight(color: .yellow))) {
            XCTAssertTrue($0.bible.highlights.contains { 
                $0.reference == verse.reference && $0.color == .yellow 
            })
        }
        
        // 4. User adds a note
        await store.send(.bible(.addNote("This is the Word becoming flesh"))) {
            XCTAssertTrue($0.bible.notes.contains { 
                $0.reference == verse.reference 
            })
        }
        
        // 5. User bookmarks the chapter
        await store.send(.bible(.toggleBookmark)) {
            XCTAssertTrue($0.bible.bookmarks.contains { 
                $0.reference.book == .john && 
                $0.reference.chapter.rawValue == 1 
            })
        }
        
        // 6. Verify data persisted
        let highlights = try await store.dependencies.databaseClient.fetch(Highlight.self)
        XCTAssertFalse(highlights.isEmpty)
        
        let notes = try await store.dependencies.databaseClient.fetch(Note.self)
        XCTAssertFalse(notes.isEmpty)
        
        let bookmarks = try await store.dependencies.databaseClient.fetch(Bookmark.self)
        XCTAssertFalse(bookmarks.isEmpty)
    }
    
    @MainActor
    func testSearchAndNavigateFlow() async throws {
        let store = TestStore(
            initialState: AppReducer.State(),
            reducer: { AppReducer() },
            withDependencies: {
                $0.bibleService = .mock
                $0.databaseClient = makeDatabaseClient()
            }
        )
        
        // 1. Navigate to Bible
        await store.send(.tabSelected(.bible)) {
            $0.selectedTab = .bible
        }
        
        // 2. Perform search
        await store.send(.bible(.searchQueryChanged("God so loved"))) {
            $0.bible.searchQuery = "God so loved"
            $0.bible.isSearching = true
        }
        
        // 3. Receive search results
        await store.receive(\.bible.searchResponse.success, timeout: .seconds(2)) {
            $0.bible.isSearching = false
            XCTAssertFalse($0.bible.searchResults.isEmpty)
        }
        
        // 4. Select search result
        let searchResult = store.state.bible.searchResults[0]
        await store.send(.bible(.selectSearchResult(searchResult))) {
            $0.bible.selectedBook = searchResult.reference.book
            $0.bible.selectedChapter = searchResult.reference.chapter.rawValue
            $0.bible.searchQuery = ""
            $0.bible.searchResults = []
        }
        
        // 5. Verify navigation
        await store.receive(\.bible.chapterResponse.success) {
            XCTAssertEqual($0.bible.currentChapter?.book, searchResult.reference.book)
            XCTAssertEqual($0.bible.currentChapter?.number.rawValue, searchResult.reference.chapter.rawValue)
        }
    }
    
    // MARK: - Data Synchronization Tests
    
    func testOfflineDataSync() async throws {
        let offlineService = OfflineService(persistentContainer: testPersistentContainer)
        let bibleService = BibleService.mock
        
        // Download chapters for offline use
        let chapters = try await withThrowingTaskGroup(of: Chapter.self) { group in
            for chapter in 1...5 {
                group.addTask {
                    let reference = BibleReference(book: .matthew, chapter: chapter)
                    return try await bibleService.fetchPassage(reference)
                }
            }
            
            var downloadedChapters: [Chapter] = []
            for try await chapter in group {
                try await offlineService.saveChapterOffline(chapter)
                downloadedChapters.append(chapter)
            }
            return downloadedChapters
        }
        
        XCTAssertEqual(chapters.count, 5)
        
        // Verify offline availability
        for chapter in 1...5 {
            let isOffline = try await offlineService.isChapterOffline(.matthew, chapter)
            XCTAssertTrue(isOffline)
        }
        
        // Load offline chapter
        let offlineChapter = try await offlineService.loadOfflineChapter(.matthew, 3)
        XCTAssertNotNil(offlineChapter)
        XCTAssertEqual(offlineChapter?.book, .matthew)
        XCTAssertEqual(offlineChapter?.number.rawValue, 3)
    }
    
    func testDataExportImport() async throws {
        let databaseClient = makeDatabaseClient()
        let fileManager = FileManager.default
        let exportURL = fileManager.temporaryDirectory.appendingPathComponent("leavn-export.json")
        
        // Create test data
        let highlight = TestFixtures.sampleHighlight
        let bookmark = TestFixtures.sampleBookmark
        let note = TestFixtures.sampleNote
        
        try await databaseClient.save(highlight)
        try await databaseClient.save(bookmark)
        try await databaseClient.save(note)
        
        // Export data
        let exportData = ExportData(
            highlights: [highlight],
            bookmarks: [bookmark],
            notes: [note],
            readingPlans: [],
            settings: Settings()
        )
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(exportData)
        try data.write(to: exportURL)
        
        // Clear database
        try await databaseClient.delete(highlight)
        try await databaseClient.delete(bookmark)
        try await databaseClient.delete(note)
        
        // Verify data cleared
        let clearedHighlights = try await databaseClient.fetch(Highlight.self)
        XCTAssertTrue(clearedHighlights.isEmpty)
        
        // Import data
        let importData = try Data(contentsOf: exportURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let imported = try decoder.decode(ExportData.self, from: importData)
        
        for highlight in imported.highlights {
            try await databaseClient.save(highlight)
        }
        for bookmark in imported.bookmarks {
            try await databaseClient.save(bookmark)
        }
        for note in imported.notes {
            try await databaseClient.save(note)
        }
        
        // Verify import
        let importedHighlights = try await databaseClient.fetch(Highlight.self)
        XCTAssertEqual(importedHighlights.count, 1)
        XCTAssertEqual(importedHighlights[0].text, highlight.text)
    }
    
    // MARK: - API Integration Tests
    
    func testRealAPIIntegration() async throws {
        // Skip if no API key
        guard let apiKey = ProcessInfo.processInfo.environment["ESV_API_KEY"] else {
            throw XCTSkip("ESV_API_KEY not set")
        }
        
        let apiKeyManager = APIKeyManager(esvAPIKey: apiKey)
        let networkLayer = NetworkLayer.live
        let esvClient = ESVClient.liveValue
        let bibleService = BibleService.liveValue
        
        // Test complete flow with real API
        let reference = BibleReference(book: .john, chapter: 1, verse: 1)
        
        do {
            let chapter = try await withDependencies {
                $0.apiKeyManager = apiKeyManager
                $0.networkLayer = networkLayer
                $0.esvClient = esvClient
            } operation: {
                try await bibleService.fetchPassage(reference)
            }
            
            XCTAssertEqual(chapter.book, .john)
            XCTAssertEqual(chapter.number.rawValue, 1)
            XCTAssertFalse(chapter.verses.isEmpty)
            
            // Verify verse 1 content
            let verse1 = chapter.verses.first { $0.number == 1 }
            XCTAssertNotNil(verse1)
            XCTAssertTrue(verse1?.text.contains("In the beginning was the Word") ?? false)
            
        } catch {
            XCTFail("API request failed: \(error)")
        }
    }
    
    // MARK: - Performance Under Load Tests
    
    func testConcurrentDataOperations() async throws {
        let databaseClient = makeDatabaseClient()
        let concurrentOperations = 100
        
        // Perform concurrent saves
        try await withThrowingTaskGroup(of: Void.self) { group in
            for i in 0..<concurrentOperations {
                group.addTask {
                    let highlight = Highlight(
                        reference: BibleReference(book: .john, chapter: i % 21 + 1, verse: 1),
                        text: "Test verse \(i)",
                        color: .yellow,
                        note: nil,
                        createdAt: Date(),
                        modifiedAt: Date()
                    )
                    try await databaseClient.save(highlight)
                }
            }
            
            try await group.waitForAll()
        }
        
        // Verify all saved
        let highlights = try await databaseClient.fetch(Highlight.self)
        XCTAssertEqual(highlights.count, concurrentOperations)
        
        // Perform concurrent reads
        let readResults = try await withThrowingTaskGroup(of: [Highlight].self) { group in
            for _ in 0..<10 {
                group.addTask {
                    try await databaseClient.fetch(Highlight.self)
                }
            }
            
            var allResults: [[Highlight]] = []
            for try await result in group {
                allResults.append(result)
            }
            return allResults
        }
        
        // Verify consistency
        for results in readResults {
            XCTAssertEqual(results.count, concurrentOperations)
        }
    }
    
    // MARK: - Helper Methods
    
    private func makeDatabaseClient() -> DatabaseClient {
        let context = testPersistentContainer.viewContext
        
        return DatabaseClient(
            save: { entity in
                // Implementation would save to Core Data
            },
            fetch: { entityType in
                // Implementation would fetch from Core Data
                []
            },
            delete: { entity in
                // Implementation would delete from Core Data
            },
            update: { entity, changes in
                // Implementation would update in Core Data
            }
        )
    }
}

// MARK: - Export Data Model
struct ExportData: Codable {
    let highlights: [Highlight]
    let bookmarks: [Bookmark]
    let notes: [Note]
    let readingPlans: [ReadingPlan]
    let settings: Settings
}

// MARK: - Network Layer Live Implementation
extension NetworkLayer {
    static let live = Self(
        request: { endpoint, method, parameters in
            var url = URL(string: "https://api.esv.org/v3")!
            url.appendPathComponent(endpoint)
            
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            
            if let parameters = parameters {
                if method == .get {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                    components.queryItems = parameters.map { 
                        URLQueryItem(name: $0.key, value: String(describing: $0.value)) 
                    }
                    request.url = components.url
                } else {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            }
            
            let (data, _) = try await URLSession.shared.data(for: request)
            return data
        },
        download: { url, destination in
            let (tempURL, _) = try await URLSession.shared.download(from: url)
            try FileManager.default.moveItem(at: tempURL, to: destination)
            return destination
        },
        upload: { url, data, mimeType in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            return responseData
        }
    )
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}