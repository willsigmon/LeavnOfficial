import XCTest
@testable import AuthenticationModule

final class AuthenticationModuleTests: XCTestCase {
    var sut: AuthenticationService!
    
    override func setUp() {
        super.setUp()
        sut = AuthenticationService()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testAuthenticationServiceInitialization() throws {
        XCTAssertNotNil(sut)
    }
    
    func testUserLogin() async throws {
        // Test user login
        let email = "test@example.com"
        let password = "testPassword123"
        
        let result = await sut.login(email: email, password: password)
        XCTAssertTrue(result.isSuccess)
    }
    
    func testUserLogout() async throws {
        // Test user logout
        await sut.logout()
        XCTAssertFalse(sut.isAuthenticated)
    }
}