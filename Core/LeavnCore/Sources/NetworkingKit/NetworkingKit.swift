import Foundation
import Alamofire
import LeavnCore

// MARK: - Network Service Protocol
public protocol NetworkService {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
    func requestData(_ endpoint: Endpoint) async throws -> Data
    func upload<T: Decodable>(_ endpoint: Endpoint, data: Data) async throws -> T
    func download(_ endpoint: Endpoint) async throws -> URL
}

// MARK: - Endpoint Definition
public struct Endpoint {
    public let path: String
    public let method: HTTPMethod
    public let parameters: Parameters?
    public let headers: HTTPHeaders?
    public let encoding: ParameterEncoding
    
    public init(
        path: String,
        method: HTTPMethod = .get,
        parameters: Parameters? = nil,
        headers: HTTPHeaders? = nil,
        encoding: ParameterEncoding = URLEncoding.default
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
    private let session: Session
    private let configuration: LeavnConfiguration
    private let interceptor: RequestInterceptor?
    
    public init(
        configuration: LeavnConfiguration,
        interceptor: RequestInterceptor? = nil
    ) {
        self.configuration = configuration
        self.interceptor = interceptor
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        
        self.session = Session(
            configuration: config,
            interceptor: interceptor
        )
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func request(_ endpoint: Endpoint) async throws -> Data {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.request(
                url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers
            )
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error))
                }
            }
        }
    }
    
    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        return try await request(endpoint)
    }
    
    public func upload<T: Decodable>(_ endpoint: Endpoint, data: Data) async throws -> T {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(
                data,
                to: url,
                method: endpoint.method,
                headers: endpoint.headers
            )
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: self.mapError(error))
                }
            }
        }
    }
    
    public func download(_ endpoint: Endpoint) async throws -> URL {
        let url = configuration.baseURL.appendingPathComponent(endpoint.path)
        let destination = DownloadRequest.suggestedDownloadDestination()
        
        return try await withCheckedThrowingContinuation { continuation in
            session.download(
                url,
                method: endpoint.method,
                parameters: endpoint.parameters,
                encoding: endpoint.encoding,
                headers: endpoint.headers,
                to: destination
            )
            .validate()
            .response { response in
                if let fileURL = response.fileURL {
                    continuation.resume(returning: fileURL)
                } else if let error = response.error {
                    continuation.resume(throwing: self.mapError(error))
                } else {
                    continuation.resume(throwing: LeavnError.unknown)
                }
            }
        }
    }
    
    private func mapError(_ error: AFError) -> LeavnError {
        switch error {
        case .responseValidationFailed(let reason):
            switch reason {
            case .unacceptableStatusCode(let code):
                switch code {
                case 401:
                    return .unauthorized
                case 404:
                    return .notFound
                case 500...599:
                    return .serverError(message: "Server error: \\(code)")
                default:
                    return .networkError(underlying: error)
                }
            default:
                return .networkError(underlying: error)
            }
        case .responseSerializationFailed:
            return .decodingError(underlying: error)
        default:
            return .networkError(underlying: error)
        }
    }
}

// MARK: - Auth Interceptor
public final class AuthInterceptor: RequestInterceptor {
    private let tokenProvider: @Sendable () async -> String?
    
    public init(tokenProvider: @escaping @Sendable () async -> String?) {
        self.tokenProvider = tokenProvider
    }
    
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        Task {
            var request = urlRequest
            if let token = await tokenProvider() {
                request.setValue("Bearer \\(token)", forHTTPHeaderField: "Authorization")
            }
            completion(.success(request))
        }
    }
}