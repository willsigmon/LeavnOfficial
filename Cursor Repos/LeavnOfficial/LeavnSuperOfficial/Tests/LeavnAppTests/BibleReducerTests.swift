import XCTest
import ComposableArchitecture
@testable import LeavnApp

final class BibleReducerTests: XCTestCase {
    @MainActor
    func testLoadPassage() async {
        let store = TestStore(initialState: BibleReducer.State()) {
            BibleReducer()
        } withDependencies: {
            $0.esvClient.getPassage = { book, chapter, verse in
                XCTAssertEqual(book, .genesis)
                XCTAssertEqual(chapter, 1)
                XCTAssertNil(verse)
                return PassageResponse(
                    text: "In the beginning God created the heavens and the earth.",
                    reference: "Genesis 1",
                    copyright: "ESV"
                )
            }
        }
        
        await store.send(.loadPassage(.genesis, 1, nil)) {
            $0.isLoading = true
            $0.error = nil
            $0.currentBook = .genesis
            $0.currentChapter = 1
            $0.currentVerse = nil
        }
        
        await store.receive(.passageResponse(.success(PassageResponse(
            text: "In the beginning God created the heavens and the earth.",
            reference: "Genesis 1",
            copyright: "ESV"
        )))) {
            $0.isLoading = false
            $0.passageText = "In the beginning God created the heavens and the earth."
        }
    }
    
    @MainActor
    func testBookmarkToggle() async {
        let store = TestStore(initialState: BibleReducer.State()) {
            BibleReducer()
        } withDependencies: {
            $0.databaseClient.saveBookmark = { bookmark in
                XCTAssertEqual(bookmark.reference, "Genesis 1:1")
            }
        }
        
        await store.send(.bookmarkToggled("Genesis 1:1")) {
            $0.bookmarks.append(Bookmark(
                reference: "Genesis 1:1",
                book: .genesis,
                chapter: 1,
                verse: 1
            ))
        }
    }
}