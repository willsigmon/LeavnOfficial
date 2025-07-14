import XCTest
@testable import LeavnLibrary

final class LeavnLibraryTests: XCTestCase {
    var sut: LeavnLibraryViewModel!
    
    override func setUp() {
        super.setUp()
        sut = LeavnLibraryViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testLibraryViewModelInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testAddItemToLibrary() throws {
        // Test adding item to library
        let item = LibraryItem(id: "1", title: "Test Item", type: .note)
        sut.addItem(item)
        XCTAssertTrue(sut.items.contains(where: { $0.id == item.id }))
    }
    
    func testRemoveItemFromLibrary() throws {
        // Test removing item from library
        let item = LibraryItem(id: "1", title: "Test Item", type: .note)
        sut.addItem(item)
        sut.removeItem(item)
        XCTAssertFalse(sut.items.contains(where: { $0.id == item.id }))
    }
}