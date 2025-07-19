import Foundation
import Dependencies

// MARK: - Network Layer
public struct NetworkLayer: Sendable {
    public var request: @Sendable (String, HTTPMethod, [String: Any]?) async throws -> Data
    public var download: @Sendable (URL, URL) async throws -> URL
    public var upload: @Sendable (URL, Data, String) async throws -> Data
}

// MARK: - HTTP Method
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Dependency Implementation
extension NetworkLayer: DependencyKey {
    public static let liveValue = Self(
        request: { endpoint, method, parameters in
            guard let baseURL = URL(string: "https://api.leavn.app/v1") else {
                throw NetworkError.invalidURL
            }
            
            var url = baseURL.appendingPathComponent(endpoint)
            var request = URLRequest(url: url)
            request.httpMethod = method.rawValue
            request.timeoutInterval = 30
            
            // Add authentication header if available
            @Dependency(\.authClient) var authClient
            if let token = try? await authClient.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            // Handle parameters based on method
            if let parameters = parameters {
                switch method {
                case .get:
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                    components.queryItems = parameters.map { 
                        URLQueryItem(name: $0.key, value: String(describing: $0.value)) 
                    }
                    request.url = components.url
                    
                case .post, .put, .patch, .delete:
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            return data
        },
        download: { url, destination in
            let (tempURL, response) = try await URLSession.shared.download(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.downloadFailed
            }
            
            try FileManager.default.moveItem(at: tempURL, to: destination)
            return destination
        },
        upload: { url, data, mimeType in
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            request.timeoutInterval = 60
            
            @Dependency(\.authClient) var authClient
            if let token = try? await authClient.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.uploadFailed
            }
            
            return responseData
        }
    )
    
    public static let testValue = Self(
        request: { _, _, _ in Data() },
        download: { _, destination in destination },
        upload: { _, _, _ in Data() }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var networkLayer: NetworkLayer {
        get { self[NetworkLayer.self] }
        set { self[NetworkLayer.self] = newValue }
    }
}

// MARK: - Network Errors
public enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, data: Data)
    case downloadFailed
    case uploadFailed
    case noInternetConnection
    case timeout
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .downloadFailed:
            return "Download failed"
        case .uploadFailed:
            return "Upload failed"
        case .noInternetConnection:
            return "No internet connection"
        case .timeout:
            return "Request timed out"
        }
    }
}

// MARK: - URL Session Configuration
public extension URLSession {
    static let leavnSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 300
        configuration.requestCachePolicy = .useProtocolCachePolicy
        
        return URLSession(configuration: configuration)
    }()
}