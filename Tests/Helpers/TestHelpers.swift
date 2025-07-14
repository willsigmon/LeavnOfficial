import Foundation
import XCTest

// MARK: - Test Helpers

extension XCTestCase {
    /// Wait for async operation with timeout
    func waitForAsync(timeout: TimeInterval = 5.0, file: StaticString = #file, line: UInt = #line, _ operation: @escaping () async throws -> Void) {
        let expectation = expectation(description: "Async operation")
        
        Task {
            do {
                try await operation()
                expectation.fulfill()
            } catch {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
            }
        }
        
        wait(for: [expectation], timeout: timeout)
    }
}

// MARK: - Mock Helpers

struct MockNetworkResponse {
    let data: Data?
    let response: URLResponse?
    let error: Error?
    
    static func success(data: Data, statusCode: Int = 200) -> MockNetworkResponse {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.example.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )
        return MockNetworkResponse(data: data, response: response, error: nil)
    }
    
    static func failure(error: Error) -> MockNetworkResponse {
        return MockNetworkResponse(data: nil, response: nil, error: error)
    }
}

// MARK: - Test Data

struct TestData {
    static let sampleJSON = """
    {
        "id": "123",
        "title": "Test Item",
        "description": "This is a test item"
    }
    """.data(using: .utf8)!
    
    static let sampleBibleVerse = """
    {
        "reference": "John 3:16",
        "text": "For God so loved the world...",
        "version": "KJV"
    }
    """.data(using: .utf8)!
}