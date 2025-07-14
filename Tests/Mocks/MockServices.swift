import Foundation
@testable import LeavnCore
@testable import NetworkingKit
@testable import PersistenceKit

// MARK: - Mock Network Service

class MockNetworkService: NetworkServiceProtocol {
    var shouldReturnError = false
    var mockResponse: Data?
    var requestCount = 0
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        requestCount += 1
        
        if shouldReturnError {
            throw NetworkError.requestFailed
        }
        
        guard let data = mockResponse else {
            throw NetworkError.noData
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - Mock Persistence Service

class MockPersistenceService: PersistenceServiceProtocol {
    private var storage: [String: Any] = [:]
    var saveCount = 0
    var retrieveCount = 0
    
    func save<T: Codable>(_ object: T, for key: String) throws {
        saveCount += 1
        let data = try JSONEncoder().encode(object)
        storage[key] = data
    }
    
    func retrieve<T: Decodable>(_ type: T.Type, for key: String) throws -> T? {
        retrieveCount += 1
        guard let data = storage[key] as? Data else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func delete(for key: String) {
        storage.removeValue(forKey: key)
    }
    
    func clearAll() {
        storage.removeAll()
    }
}

// MARK: - Mock Authentication Service

class MockAuthenticationService: AuthenticationServiceProtocol {
    var isAuthenticated = false
    var currentUser: User?
    var loginCallCount = 0
    var logoutCallCount = 0
    
    func login(email: String, password: String) async throws -> User {
        loginCallCount += 1
        
        if email == "test@example.com" && password == "password123" {
            let user = User(id: "123", email: email, name: "Test User")
            currentUser = user
            isAuthenticated = true
            return user
        } else {
            throw AuthenticationError.invalidCredentials
        }
    }
    
    func logout() async {
        logoutCallCount += 1
        currentUser = nil
        isAuthenticated = false
    }
    
    func refreshToken() async throws {
        if !isAuthenticated {
            throw AuthenticationError.notAuthenticated
        }
    }
}

// MARK: - Mock Types

struct User: Codable {
    let id: String
    let email: String
    let name: String
}

enum NetworkError: Error {
    case requestFailed
    case noData
}

enum AuthenticationError: Error {
    case invalidCredentials
    case notAuthenticated
}