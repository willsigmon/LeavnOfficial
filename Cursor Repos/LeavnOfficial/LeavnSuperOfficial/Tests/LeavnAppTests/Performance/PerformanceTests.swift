import XCTest
import ComposableArchitecture
@testable import LeavnApp

final class PerformanceTests: XCTestCase {
    
    // MARK: - App Launch Performance
    
    func testAppInitializationPerformance() {
        measure {
            _ = withDependencies {
                $0.userDefaults = .mock
                $0.bibleService = .mock
                $0.settingsService = .mock
                $0.databaseClient = .mock
            } operation: {
                AppReducer()
            }
        }
    }
    
    // MARK: - Bible Service Performance
    
    func testBiblePassageFetchPerformance() {
        let service = BibleService.mock
        
        measureAsync { [service] in
            for book in [Book.genesis, .psalms, .matthew, .john, .revelation] {
                let reference = BibleReference(book: book, chapter: 1)
                _ = try await service.fetchPassage(reference)
            }
        }
    }
    
    func testBibleSearchPerformance() {
        let service = BibleService.mock
        let queries = ["love", "faith", "God", "Jesus", "salvation"]
        
        measureAsync { [service] in
            for query in queries {
                _ = try await service.searchPassages(query)
            }
        }
    }
    
    func testVerseParsingPerformance() {
        let longPassage = generateLongPassage(verseCount: 100)
        
        measure {
            _ = parseTestVerses(from: longPassage, book: .genesis, chapter: 1)
        }
    }
    
    // MARK: - Database Performance
    
    func testDatabaseSavePerformance() {
        let highlights = (1...100).map { i in
            Highlight(
                reference: BibleReference(book: .john, chapter: 3, verse: i),
                text: "Test verse \(i)",
                color: .yellow,
                note: "Test note \(i)",
                createdAt: Date(),
                modifiedAt: Date()
            )
        }
        
        let client = DatabaseClient.mock
        
        measureAsync { [client] in
            for highlight in highlights {
                try await client.save(highlight)
            }
        }
    }
    
    func testDatabaseFetchPerformance() {
        let client = DatabaseClient.mock
        
        measureAsync { [client] in
            _ = try await client.fetch(Highlight.self)
            _ = try await client.fetch(Bookmark.self)
            _ = try await client.fetch(Note.self)
            _ = try await client.fetch(ReadingPlan.self)
        }
    }
    
    // MARK: - Reducer Performance
    
    @MainActor
    func testBibleReducerActionPerformance() async {
        let store = TestStore(
            initialState: BibleReducer.State(
                currentChapter: TestFixtures.sampleChapter
            )
        ) {
            BibleReducer()
        } withDependencies: {
            $0.bibleService = .mock
            $0.databaseClient = .mock
        }
        
        measure {
            let expectation = expectation(description: "Actions processed")
            
            Task { @MainActor in
                // Simulate rapid user interactions
                for i in 1...10 {
                    await store.send(.selectVerse(TestFixtures.sampleChapter.verses[i % 2]))
                    await store.send(.addHighlight(color: .yellow))
                    await store.send(.removeHighlight(UUID()))
                }
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 5)
        }
    }
    
    // MARK: - Memory Performance
    
    func testMemoryUsageForLargeChapter() {
        let options = XCTMeasureOptions()
        options.invocationOptions = .manuallyStart
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            startMeasuring()
            
            // Create a large chapter with many verses
            let verses = (1...150).map { verseNum in
                Verse(
                    reference: BibleReference(book: .psalms, chapter: 119, verse: verseNum),
                    text: String(repeating: "Test verse content ", count: 20),
                    number: verseNum
                )
            }
            
            _ = Chapter(
                book: .psalms,
                number: 119,
                verses: verses,
                headings: []
            )
        }
    }
    
    func testMemoryUsageForSearchResults() {
        let options = XCTMeasureOptions()
        options.invocationOptions = .manuallyStart
        
        measure(metrics: [XCTMemoryMetric()], options: options) {
            startMeasuring()
            
            // Create many search results
            let results = (1...1000).map { i in
                SearchResult(
                    reference: BibleReference(book: .john, chapter: i % 21 + 1, verse: i % 30 + 1),
                    text: String(repeating: "Search result text ", count: 10),
                    context: "John \(i % 21 + 1):\(i % 30 + 1)"
                )
            }
            
            _ = IdentifiedArrayOf<SearchResult>(uniqueElements: results)
        }
    }
    
    // MARK: - Network Performance
    
    func testNetworkRequestPerformance() {
        // Test with mock network layer
        let networkLayer = NetworkLayer.mock
        
        measureAsync {
            for _ in 1...10 {
                _ = try await networkLayer.request(
                    endpoint: "/passage",
                    method: .get,
                    parameters: ["q": "John 3:16"]
                )
            }
        }
    }
    
    // MARK: - UI Rendering Performance
    
    @MainActor
    func testViewRenderingPerformance() {
        let view = BibleView(
            store: Store(
                initialState: BibleReducer.State(
                    currentChapter: generateLargeChapter()
                ),
                reducer: { BibleReducer() }
            )
        )
        
        measure {
            _ = view.body
        }
    }
    
    // MARK: - Offline Service Performance
    
    func testOfflineDataSyncPerformance() {
        let service = OfflineService.mock
        let chapters = (1...50).map { chapterNum in
            Chapter(
                book: .genesis,
                number: chapterNum,
                verses: generateVerses(count: 30, book: .genesis, chapter: chapterNum),
                headings: []
            )
        }
        
        measureAsync { [service] in
            for chapter in chapters {
                try await service.saveChapterOffline(chapter)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateLongPassage(verseCount: Int) -> String {
        return (1...verseCount).map { i in
            "[\(i)] This is verse number \(i) with some content that simulates a real Bible verse."
        }.joined(separator: "\n")
    }
    
    private func parseTestVerses(from text: String, book: Book, chapter: Int) -> [Verse] {
        let lines = text.components(separatedBy: .newlines)
        return lines.compactMap { line in
            guard let match = line.firstMatch(of: /\[(\d+)\]/) else { return nil }
            let verseNum = Int(match.1) ?? 1
            let verseText = line.replacingOccurrences(of: match.0, with: "").trimmingCharacters(in: .whitespaces)
            
            return Verse(
                reference: BibleReference(book: book, chapter: chapter, verse: verseNum),
                text: verseText,
                number: verseNum
            )
        }
    }
    
    private func generateLargeChapter() -> Chapter {
        Chapter(
            book: .psalms,
            number: 119,
            verses: generateVerses(count: 176, book: .psalms, chapter: 119),
            headings: (0..<22).map { i in
                ChapterHeading(
                    text: "Section \(Character(UnicodeScalar(65 + i)!))",
                    startVerse: i * 8 + 1
                )
            }
        )
    }
    
    private func generateVerses(count: Int, book: Book, chapter: Int) -> [Verse] {
        (1...count).map { verseNum in
            Verse(
                reference: BibleReference(book: book, chapter: chapter, verse: verseNum),
                text: "This is verse \(verseNum) of \(book.name) chapter \(chapter).",
                number: verseNum
            )
        }
    }
}

// MARK: - Mock Network Layer
extension NetworkLayer {
    static let mock = Self(
        request: { _, _, _ in
            // Simulate network delay
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            return Data()
        },
        download: { _, _ in
            URL(fileURLWithPath: "/tmp/mock.download")
        },
        upload: { _, _, _ in
            Data()
        }
    )
}

// MARK: - Mock Offline Service
extension OfflineService {
    static let mock = Self(
        saveChapterOffline: { _ in },
        loadOfflineChapter: { _, _ in nil },
        deleteOfflineChapter: { _, _ in },
        isChapterOffline: { _, _ in false },
        getOfflineChapters: { [] },
        syncOfflineData: { }
    )
}