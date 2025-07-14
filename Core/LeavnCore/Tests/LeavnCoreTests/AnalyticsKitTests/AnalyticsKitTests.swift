import XCTest
@testable import AnalyticsKit

final class AnalyticsKitTests: XCTestCase {
    var sut: AnalyticsKit!
    
    override func setUp() {
        super.setUp()
        sut = AnalyticsKit()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAnalyticsKitInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testEventTracking() throws {
        // Test event tracking functionality
        let eventName = "test_event"
        let parameters = ["key": "value"]
        
        XCTAssertNoThrow(sut.track(event: eventName, parameters: parameters))
    }
}
