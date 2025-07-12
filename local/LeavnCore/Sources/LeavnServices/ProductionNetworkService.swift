import Foundation
import LeavnCore
import Network
import Combine

// MARK: - Production Network Service Implementation

public actor ProductionNetworkService: @preconcurrency NetworkServiceProtocol {
    
    // MARK: - Properties
    
    private let session: URLSession
    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue
    private var isInitialized = false
    private var currentNetworkPath: NWPath?
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(false)
    
    // Network configuration
    private let timeoutInterval: TimeInterval = 30.0
    private let maxRetries = 3
    
    // MARK: - Publisher
    
    public var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    public init() {
        // Configure URL session
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval * 2
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = URLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB
            diskCapacity: 100 * 1024 * 1024   // 100 MB
        )
        
        self.session = URLSession(configuration: configuration)
        self.monitor = NWPathMonitor()
        self.monitorQueue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
    }
    
    public func initialize() async throws {
        // Start network monitoring
        monitor.pathUpdateHandler = { [weak self] path in
            Task { [weak self] in
                await self?.updateNetworkPath(path)
            }
        }
        monitor.start(queue: monitorQueue)
        
        isInitialized = true
        print("🌐 ProductionNetworkService initialized")
    }
    
    deinit {
        monitor.cancel()
    }
    
    // MARK: - NetworkServiceProtocol Implementation
    
    public func isConnected() async -> Bool {
        guard let path = currentNetworkPath else {
            return false
        }
        return path.status == .satisfied
    }
    
    public func request<T: Codable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        guard await isConnected() else {
            throw ServiceError.network(.notConnected)
        }
        
        return try await performRequest(endpoint, responseType: T.self)
    }
    
    public func download(_ url: URL) async throws -> Data {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        guard await isConnected() else {
            throw ServiceError.network(.notConnected)
        }
        
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.data(.invalidResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ServiceError.network(.serverError(statusCode: httpResponse.statusCode, message: message))
        }
        
        return data
    }
    
    // MARK: - Advanced Network Methods
    
    public func requestWithRetry<T: Codable & Sendable>(
        _ endpoint: APIEndpoint,
        responseType: T.Type,
        retryCount: Int = 0
    ) async throws -> T {
        do {
            return try await request(endpoint)
        } catch {
            if retryCount < maxRetries && shouldRetry(error: error) {
                let delay = Double(retryCount + 1) * 0.5 // Progressive delay
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                return try await requestWithRetry(endpoint, responseType: responseType, retryCount: retryCount + 1)
            }
            throw error
        }
    }
    
    public func getNetworkInfo() async -> NetworkInfo {
        guard let path = currentNetworkPath else {
            return NetworkInfo(isConnected: false, connectionType: .unknown, isExpensive: false)
        }
        
        let connectionType: NetworkInfo.ConnectionType
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
        
        return NetworkInfo(
            isConnected: path.status == .satisfied,
            connectionType: connectionType,
            isExpensive: path.isExpensive
        )
    }
    
    // MARK: - Private Methods
    
    private func updateNetworkPath(_ path: NWPath) async {
        currentNetworkPath = path
        isConnectedSubject.send(path.status == .satisfied)
        
        let status = path.status == .satisfied ? "Connected" : "Disconnected"
        let type = getConnectionTypeString(path)
        print("🌐 Network status: \(status) (\(type))")
    }
    
    private func performRequest<T: Codable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = URL(string: endpoint.path) else {
            throw ServiceError.user(.invalidParameters)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        // Add headers
        if let headers = endpoint.headers {
            for (key, value) in headers {
                // Ensure the value is a string to prevent NSNumber crashes
                request.setValue(String(describing: value), forHTTPHeaderField: key)
            }
        }
        
        // Add common headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Leavn/1.0", forHTTPHeaderField: "User-Agent")
        
        // Add body for POST/PUT requests
        if let parameters = endpoint.parameters, endpoint.method != .GET {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // Convert string dictionary to JSON
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        // Perform request
        let (data, response) = try await session.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ServiceError.data(.invalidResponse)
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw ServiceError.auth(.required)
            } else if httpResponse.statusCode == 403 {
                throw ServiceError.auth(.permissionDenied)
            } else if httpResponse.statusCode == 404 {
                throw ServiceError.data(.notFound)
            } else if httpResponse.statusCode == 429 {
                throw ServiceError.network(.rateLimited)
            } else {
                let message = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw ServiceError.network(.serverError(statusCode: httpResponse.statusCode, message: message))
            }
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(responseType, from: data)
        } catch let error {
            print("Decoding error: \(error)")
            throw ServiceError.data(.decodingError(error))
        }
    }
    
    private func shouldRetry(error: Error) -> Bool {
        if let serviceError = error as? ServiceError {
            switch serviceError {
            case .network(let type):
                switch type {
                case .notConnected:
                    return false
                case .timeout:
                    return true
                case .serverError(let statusCode, _):
                    return statusCode >= 500
                case .rateLimited:
                    return true
                }
            default:
                return false
            }
        }
        return true // Retry for unknown errors
    }
    
    private func getConnectionTypeString(_ path: NWPath) -> String {
        if path.usesInterfaceType(.wifi) {
            return "WiFi"
        } else if path.usesInterfaceType(.cellular) {
            return "Cellular"
        } else if path.usesInterfaceType(.wiredEthernet) {
            return "Ethernet"
        } else {
            return "Unknown"
        }
    }
}

// MARK: - Network Info Model

public struct NetworkInfo {
    public let isConnected: Bool
    public let connectionType: ConnectionType
    public let isExpensive: Bool
    
    public enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    public init(isConnected: Bool, connectionType: ConnectionType, isExpensive: Bool) {
        self.isConnected = isConnected
        self.connectionType = connectionType
        self.isExpensive = isExpensive
    }
}
