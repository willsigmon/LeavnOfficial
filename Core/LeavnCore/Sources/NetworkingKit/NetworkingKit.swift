import Foundation

// MARK: - Network Service Protocol
public protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
    func requestData(_ endpoint: Endpoint) async throws -> Data
    func upload<T: Decodable>(_ endpoint: Endpoint, data: Data) async throws -> T
    func download(_ endpoint: Endpoint) async throws -> URL
}

// MARK: - HTTP Method
public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// MARK: - Parameter Encoding
public enum ParameterEncoding {
    case url
    case json
}

// MARK: - Endpoint Definition
public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let parameters: [String: Any]?
    public let headers: [String: String]?
    public let encoding: ParameterEncoding
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        encoding: ParameterEncoding = .url
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.encoding = encoding
    }
}

// MARK: - Network Service Implementation
public final class DefaultNetworkService: NetworkService {
    private let session: URLSession
    private let configuration: LeavnConfiguration
    
    public init(configuration: LeavnConfiguration) {
        self.configuration = configuration
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        
        self.session = URLSession(configuration: config)
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func request(_ endpoint: Endpoint) async throws -> Data {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add parameters
        if let parameters = endpoint.parameters {
            switch endpoint.encoding {
            case .url:
                if endpoint.method == .get {
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    components?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components?.url
                } else {
                    request.httpBody = parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&").data(using: .utf8)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                }
            case .json:
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeavnError.networkError(underlying: nil)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapHTTPError(statusCode: httpResponse.statusCode)
        }
        
        return data
    }
    
    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        return try await request(endpoint)
    }
    
    public func upload<T: Decodable>(_ endpoint: Endpoint, data: Data) async throws -> T {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = data
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (responseData, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeavnError.networkError(underlying: nil)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapHTTPError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(T.self, from: responseData)
    }
    
    public func download(_ endpoint: Endpoint) async throws -> URL {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let (localURL, response) = try await session.download(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeavnError.networkError(underlying: nil)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw mapHTTPError(statusCode: httpResponse.statusCode)
        }
        
        // Move to permanent location
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        
        try? FileManager.default.removeItem(at: destinationURL)
        try FileManager.default.moveItem(at: localURL, to: destinationURL)
        
        return destinationURL
    }
    
    private func mapHTTPError(statusCode: Int) -> LeavnError {
        switch statusCode {
        case 401:
            return .unauthorized
        case 404:
            return .notFound
        case 500...599:
            return .serverError(message: "Server error: \(statusCode)")
        default:
            return .networkError(underlying: nil)
        }
    }
}

// MARK: - Request Interceptor Protocol
public protocol RequestInterceptor {
    func adapt(_ request: URLRequest) async -> URLRequest
}

// MARK: - Auth Interceptor
public final class AuthInterceptor: RequestInterceptor {
    private let tokenProvider: @Sendable () async -> String?
    
    public init(tokenProvider: @escaping @Sendable () async -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(_ request: URLRequest) async -> URLRequest {
        var modifiedRequest = request
        if let token = await tokenProvider() {
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return modifiedRequest
    }
}