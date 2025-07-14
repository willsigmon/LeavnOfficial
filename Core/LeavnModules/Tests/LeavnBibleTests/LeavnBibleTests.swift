import XCTest
@testable import LeavnBible

final class LeavnBibleTests: XCTestCase {
    var sut: LeavnBibleViewModel!
    
    override func setUp() {
        super.setUp()
        sut = LeavnBibleViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testBibleViewModelInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testLoadBibleBooks() async throws {
        // Test loading Bible books
        await sut.loadBooks()
        XCTAssertFalse(sut.books.isEmpty)
    }
    
    func testSelectBook() throws {
        // Test book selection
        let testBook = "Genesis"
        sut.selectBook(testBook)
        XCTAssertEqual(sut.selectedBook, testBook)
    }
}