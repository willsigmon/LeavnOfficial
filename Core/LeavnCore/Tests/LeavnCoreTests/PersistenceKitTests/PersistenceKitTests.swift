import XCTest
@testable import PersistenceKit

final class PersistenceKitTests: XCTestCase {
    var sut: PersistenceKit!
    
    override func setUp() {
        super.setUp()
        sut = PersistenceKit()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testPersistenceKitInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testDataPersistence() throws {
        // Test data persistence functionality
        let testData = "Test Data"
        let key = "testKey"
        
        sut.save(testData, for: key)
        let retrieved: String? = sut.retrieve(for: key)
        
        XCTAssertEqual(retrieved, testData)
    }
}