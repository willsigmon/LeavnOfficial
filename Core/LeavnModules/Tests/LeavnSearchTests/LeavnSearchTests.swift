import XCTest
@testable import LeavnSearch

final class LeavnSearchTests: XCTestCase {
    var sut: LeavnSearchViewModel!
    
    override func setUp() {
        super.setUp()
        sut = LeavnSearchViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSearchViewModelInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testSearchQuery() async throws {
        // Test search functionality
        let query = "love"
        await sut.search(for: query)
        XCTAssertFalse(sut.searchResults.isEmpty)
    }
    
    func testEmptySearchQuery() async throws {
        // Test empty search query
        let query = ""
        await sut.search(for: query)
        XCTAssertTrue(sut.searchResults.isEmpty)
    }
}