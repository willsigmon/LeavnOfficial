import XCTest
import Dependencies
@testable import LeavnApp

final class BibleServiceTests: XCTestCase {
    
    // MARK: - Fetch Passage Tests
    
    func testFetchPassageSuccess() async throws {
        let service = BibleService.mock
        
        let reference = BibleReference(book: .john, chapter: 3, verse: 16)
        let chapter = try await service.fetchPassage(reference)
        
        XCTAssertEqual(chapter.book, .john)
        XCTAssertEqual(chapter.number.rawValue, 3)
        XCTAssertFalse(chapter.verses.isEmpty)
    }
    
    func testFetchChapterSuccess() async throws {
        let service = BibleService.mock
        
        let reference = BibleReference(book: .genesis, chapter: 1)
        let chapter = try await service.fetchPassage(reference)
        
        XCTAssertEqual(chapter.book, .genesis)
        XCTAssertEqual(chapter.number.rawValue, 1)
        XCTAssertFalse(chapter.verses.isEmpty)
        XCTAssertEqual(chapter.verses.count, 5) // Based on mock data
    }
    
    func testParseVersesFromText() async throws {
        // Test the actual parsing logic with real ESV-style text
        let esvText = """
        [1] In the beginning, God created the heavens and the earth.
        [2] And the earth was without form, and void; and darkness was upon the face of the deep. And the Spirit of God moved upon the face of the waters.
        [3] And God said, Let there be light: and there was light.
        """
        
        let service = withDependencies {
            $0.esvClient = ESVClient(
                getPassage: { _, _, _ in
                    ESVResponse(query: "Genesis 1", text: esvText, verseNumbers: true)
                },
                search: { _ in [] }
            )
        } operation: {
            BibleService.liveValue
        }
        
        let reference = BibleReference(book: .genesis, chapter: 1)
        let chapter = try await service.fetchPassage(reference)
        
        XCTAssertEqual(chapter.verses.count, 3)
        XCTAssertEqual(chapter.verses[0].number, 1)
        XCTAssertEqual(chapter.verses[1].number, 2)
        XCTAssertEqual(chapter.verses[2].number, 3)
        XCTAssertTrue(chapter.verses[0].text.contains("In the beginning"))
    }
    
    // MARK: - Search Tests
    
    func testSearchPassagesSuccess() async throws {
        let service = BibleService.mock
        
        let results = try await service.searchPassages("God so loved")
        
        XCTAssertFalse(results.isEmpty)
        XCTAssertEqual(results.count, 2) // Based on mock data
        XCTAssertTrue(results.first?.text.contains("God so loved") ?? false)
    }
    
    func testSearchEmptyQuery() async throws {
        let service = withDependencies {
            $0.esvClient = ESVClient(
                getPassage: { _, _, _ in
                    ESVResponse(query: "", text: "", verseNumbers: true)
                },
                search: { _ in [] }
            )
        } operation: {
            BibleService.liveValue
        }
        
        let results = try await service.searchPassages("")
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Chapter Info Tests
    
    func testFetchChapterInfo() async throws {
        let service = BibleService.mock
        
        let info = try await service.fetchChapterInfo(.psalms, 23)
        
        XCTAssertEqual(info.book, .psalms)
        XCTAssertEqual(info.chapter, 23)
        XCTAssertEqual(info.verseCount, 6) // Psalm 23 has 6 verses
        XCTAssertTrue(info.hasPrevious)
        XCTAssertTrue(info.hasNext)
    }
    
    func testFetchFirstChapterInfo() async throws {
        let service = BibleService.mock
        
        let info = try await service.fetchChapterInfo(.genesis, 1)
        
        XCTAssertEqual(info.book, .genesis)
        XCTAssertEqual(info.chapter, 1)
        XCTAssertFalse(info.hasPrevious)
        XCTAssertTrue(info.hasNext)
    }
    
    func testFetchLastChapterInfo() async throws {
        let service = BibleService.mock
        
        let lastChapter = Book.revelation.chapterCount
        let info = try await service.fetchChapterInfo(.revelation, lastChapter)
        
        XCTAssertEqual(info.book, .revelation)
        XCTAssertEqual(info.chapter, lastChapter)
        XCTAssertTrue(info.hasPrevious)
        XCTAssertFalse(info.hasNext)
    }
    
    // MARK: - Verse of the Day Tests
    
    func testGetVerseOfTheDay() async throws {
        let service = BibleService.mock
        
        let verse = try await service.getVerseOfTheDay()
        
        XCTAssertEqual(verse.reference.book, .john)
        XCTAssertEqual(verse.reference.chapter.rawValue, 3)
        XCTAssertEqual(verse.reference.verse?.rawValue, 16)
        XCTAssertFalse(verse.text.isEmpty)
    }
    
    // MARK: - Cross References Tests
    
    func testGetCrossReferences() async throws {
        let service = BibleService.mock
        
        let reference = BibleReference(book: .matthew, chapter: 5, verse: 17)
        let crossRefs = try await service.getCrossReferences(reference)
        
        XCTAssertEqual(crossRefs.count, 2) // Based on mock data
        XCTAssertTrue(crossRefs.contains { $0.book == .matthew })
        XCTAssertTrue(crossRefs.contains { $0.book == .luke })
    }
    
    // MARK: - Error Handling Tests
    
    func testFetchPassageWithInvalidAPIKey() async throws {
        let service = withDependencies {
            $0.apiKeyManager = APIKeyManager(esvAPIKey: nil)
            $0.esvClient = .liveValue
        } operation: {
            BibleService.liveValue
        }
        
        let reference = BibleReference(book: .john, chapter: 3)
        
        do {
            _ = try await service.fetchPassage(reference)
            XCTFail("Should throw an error for missing API key")
        } catch {
            XCTAssertTrue(error is ESVError)
            if let esvError = error as? ESVError {
                XCTAssertEqual(esvError, .missingAPIKey)
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testFetchPassagePerformance() {
        let service = BibleService.mock
        
        measure {
            let expectation = expectation(description: "Fetch passage")
            
            Task {
                let reference = BibleReference(book: .john, chapter: 3)
                _ = try await service.fetchPassage(reference)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
    
    func testSearchPerformance() {
        let service = BibleService.mock
        
        measure {
            let expectation = expectation(description: "Search passages")
            
            Task {
                _ = try await service.searchPassages("love")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 1.0)
        }
    }
}

// MARK: - Integration Tests
final class BibleServiceIntegrationTests: XCTestCase {
    
    func testRealESVAPIIntegration() async throws {
        // Skip this test if no API key is available
        guard ProcessInfo.processInfo.environment["ESV_API_KEY"] != nil else {
            throw XCTSkip("ESV_API_KEY not set in environment")
        }
        
        let service = withDependencies {
            $0.apiKeyManager = APIKeyManager(
                esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"]
            )
            $0.esvClient = .liveValue
        } operation: {
            BibleService.liveValue
        }
        
        // Test fetching a real passage
        let reference = BibleReference(book: .john, chapter: 3, verse: 16)
        let chapter = try await service.fetchPassage(reference)
        
        XCTAssertEqual(chapter.book, .john)
        XCTAssertEqual(chapter.number.rawValue, 3)
        XCTAssertFalse(chapter.verses.isEmpty)
        
        // Verify the actual verse content
        let verse16 = chapter.verses.first { $0.number == 16 }
        XCTAssertNotNil(verse16)
        XCTAssertTrue(verse16?.text.contains("God so loved") ?? false)
    }
    
    func testRealESVSearchIntegration() async throws {
        // Skip this test if no API key is available
        guard ProcessInfo.processInfo.environment["ESV_API_KEY"] != nil else {
            throw XCTSkip("ESV_API_KEY not set in environment")
        }
        
        let service = withDependencies {
            $0.apiKeyManager = APIKeyManager(
                esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"]
            )
            $0.esvClient = .liveValue
        } operation: {
            BibleService.liveValue
        }
        
        // Test searching for real passages
        let results = try await service.searchPassages("faith hope love")
        
        XCTAssertFalse(results.isEmpty)
        // Should find 1 Corinthians 13:13 among results
        XCTAssertTrue(results.contains { result in
            result.reference.book == .firstCorinthians &&
            result.reference.chapter.rawValue == 13
        })
    }
}