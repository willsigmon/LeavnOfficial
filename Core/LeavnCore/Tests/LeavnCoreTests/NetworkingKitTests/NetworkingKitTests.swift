import XCTest
@testable import NetworkingKit

final class NetworkingKitTests: XCTestCase {
    var sut: NetworkingKit!
    
    override func setUp() {
        super.setUp()
        sut = NetworkingKit()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testNetworkingKitInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testAPIEndpointConfiguration() throws {
        // Test API endpoint configuration
        XCTAssertNotNil(sut.baseURL)
    }
}