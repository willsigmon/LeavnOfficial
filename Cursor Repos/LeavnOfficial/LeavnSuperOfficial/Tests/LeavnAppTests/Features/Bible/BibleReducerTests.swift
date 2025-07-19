import XCTest
import ComposableArchitecture
import IdentifiedCollections
@testable import LeavnApp

@MainActor
final class BibleReducerTests: XCTestCase {
    
    // MARK: - Basic Navigation Tests
    
    func testBookSelection() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(),
            reducer: BibleReducer.init,
            dependencies: {
                $0.bibleService = .mock
            }
        )
        
        await store.send(.selectBook(.john)) {
            $0.selectedBook = .john
            $0.selectedChapter = 1
        }
        
        await store.receive(\.chapterResponse.success) {
            $0.currentChapter = TestFixtures.sampleChapter
            $0.isLoading = false
        }
    }
    
    func testChapterNavigation() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedBook: .genesis,
                selectedChapter: 1,
                currentChapter: TestFixtures.sampleChapter
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.bibleService = .mock
            }
        )
        
        // Navigate to next chapter
        await store.send(.navigateChapter(.next)) {
            $0.selectedChapter = 2
            $0.isLoading = true
        }
        
        await store.receive(\.chapterResponse.success) {
            $0.isLoading = false
        }
        
        // Navigate to previous chapter
        await store.send(.navigateChapter(.previous)) {
            $0.selectedChapter = 1
            $0.isLoading = true
        }
        
        await store.receive(\.chapterResponse.success) {
            $0.isLoading = false
        }
    }
    
    func testVerseSelection() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                currentChapter: TestFixtures.sampleChapter
            ),
            reducer: BibleReducer.init
        )
        
        let verse = TestFixtures.sampleChapter.verses[0]
        
        await store.send(.selectVerse(verse)) {
            $0.selectedVerse = verse
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchQuery() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(),
            reducer: BibleReducer.init,
            dependencies: {
                $0.bibleService = .mock
            }
        )
        
        await store.send(.searchQueryChanged("God so loved")) {
            $0.searchQuery = "God so loved"
            $0.isSearching = true
        }
        
        // Debounce delay
        await store.receive(\.searchResponse.success, timeout: .seconds(1)) {
            $0.isSearching = false
            XCTAssertFalse($0.searchResults.isEmpty)
        }
    }
    
    func testEmptySearchQuery() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                searchQuery: "test",
                searchResults: IdentifiedArrayOf<SearchResult>([TestFixtures.sampleSearchResult])
            ),
            reducer: BibleReducer.init
        )
        
        await store.send(.searchQueryChanged("")) {
            $0.searchQuery = ""
            $0.searchResults = []
            $0.isSearching = false
        }
    }
    
    // MARK: - Highlight Tests
    
    func testAddHighlight() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedVerse: TestFixtures.sampleVerse
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.databaseClient = .mock
            }
        )
        
        await store.send(.addHighlight(color: .yellow)) {
            $0.highlights.append(
                Highlight(
                    reference: TestFixtures.sampleVerse.reference,
                    text: TestFixtures.sampleVerse.text,
                    color: .yellow,
                    note: nil,
                    createdAt: Date(),
                    modifiedAt: Date()
                )
            )
        }
    }
    
    func testRemoveHighlight() async {
        let highlight = TestFixtures.sampleHighlight
        let store = makeTestStore(
            initialState: BibleReducer.State(
                highlights: [highlight]
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.databaseClient = .mock
            }
        )
        
        await store.send(.removeHighlight(highlight.id)) {
            $0.highlights.removeAll { $0.id == highlight.id }
        }
    }
    
    // MARK: - Bookmark Tests
    
    func testToggleBookmark() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedBook: .psalms,
                selectedChapter: 23
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.databaseClient = .mock
            }
        )
        
        // Add bookmark
        await store.send(.toggleBookmark) {
            XCTAssertTrue($0.bookmarks.contains { 
                $0.reference.book == .psalms && 
                $0.reference.chapter.rawValue == 23 
            })
        }
        
        // Remove bookmark
        await store.send(.toggleBookmark) {
            XCTAssertFalse($0.bookmarks.contains { 
                $0.reference.book == .psalms && 
                $0.reference.chapter.rawValue == 23 
            })
        }
    }
    
    // MARK: - Note Tests
    
    func testAddNote() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedVerse: TestFixtures.sampleVerse
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.databaseClient = .mock
            }
        )
        
        let noteContent = "This is a test note"
        
        await store.send(.addNote(noteContent)) {
            XCTAssertTrue($0.notes.contains { 
                $0.reference == TestFixtures.sampleVerse.reference &&
                $0.content == noteContent
            })
        }
    }
    
    // MARK: - Audio Tests
    
    func testPlayAudio() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedBook: .john,
                selectedChapter: 3
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.audioService = .mock
            }
        )
        
        await store.send(.playAudio) {
            $0.audioState.isPlaying = true
            $0.audioState.currentBook = .john
            $0.audioState.currentChapter = 3
        }
    }
    
    func testPauseAudio() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                audioState: AudioPlaybackState(
                    isPlaying: true,
                    currentBook: .john,
                    currentChapter: 3
                )
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.audioService = .mock
            }
        )
        
        await store.send(.pauseAudio) {
            $0.audioState.isPlaying = false
        }
    }
    
    // MARK: - Cross Reference Tests
    
    func testLoadCrossReferences() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedVerse: TestFixtures.sampleVerse
            ),
            reducer: BibleReducer.init,
            dependencies: {
                $0.bibleService = .mock
            }
        )
        
        await store.send(.loadCrossReferences) {
            $0.isLoadingCrossReferences = true
        }
        
        await store.receive(\.crossReferencesResponse.success) {
            $0.isLoadingCrossReferences = false
            XCTAssertFalse($0.crossReferences.isEmpty)
        }
    }
    
    // MARK: - Error Handling Tests
    
    func testChapterLoadingError() async {
        struct TestError: Error, Equatable {}
        
        let store = makeTestStore(
            initialState: BibleReducer.State(),
            reducer: BibleReducer.init,
            dependencies: {
                $0.bibleService.fetchPassage = { _ in
                    throw TestError()
                }
            }
        )
        
        await store.send(.selectBook(.genesis)) {
            $0.selectedBook = .genesis
            $0.selectedChapter = 1
            $0.isLoading = true
        }
        
        await store.receive(\.chapterResponse.failure) {
            $0.isLoading = false
            $0.alert = AlertState {
                TextState("Error")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Failed to load chapter. Please try again.")
            }
        }
    }
    
    // MARK: - Reading Mode Tests
    
    func testToggleReadingMode() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                readingMode: .continuous
            ),
            reducer: BibleReducer.init
        )
        
        await store.send(.toggleReadingMode) {
            $0.readingMode = .verse
        }
        
        await store.send(.toggleReadingMode) {
            $0.readingMode = .continuous
        }
    }
    
    // MARK: - Share Tests
    
    func testShareVerse() async {
        let store = makeTestStore(
            initialState: BibleReducer.State(
                selectedVerse: TestFixtures.sampleVerse
            ),
            reducer: BibleReducer.init
        )
        
        await store.send(.shareVerse(TestFixtures.sampleVerse)) {
            $0.shareSheet = ShareSheet(
                items: [
                    "\(TestFixtures.sampleVerse.text)\n\n- \(TestFixtures.sampleVerse.reference.displayText)"
                ]
            )
        }
    }
}

// MARK: - Test Fixtures Extension
private extension TestFixtures {
    static let sampleSearchResult = SearchResult(
        reference: BibleReference(book: .john, chapter: 3, verse: 16),
        text: "For God so loved the world...",
        context: "John 3:16-17"
    )
}