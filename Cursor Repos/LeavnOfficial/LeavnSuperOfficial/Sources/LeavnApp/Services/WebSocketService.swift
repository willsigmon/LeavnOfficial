import Foundation
import Dependencies
import Combine

// MARK: - WebSocket Service
@MainActor
public final class WebSocketService: NSObject {
    private var webSocket: URLSessionWebSocketTask?
    private var session: URLSession!
    private let baseURL: URL
    
    // Published events
    @Published public private(set) var connectionState: ConnectionState = .disconnected
    @Published public private(set) var lastError: WebSocketError?
    
    // Event subjects
    private let messageSubject = PassthroughSubject<WebSocketMessage, Never>()
    private let prayerUpdateSubject = PassthroughSubject<PrayerUpdate, Never>()
    private let groupUpdateSubject = PassthroughSubject<GroupUpdate, Never>()
    private let activitySubject = PassthroughSubject<CommunityActivity, Never>()
    
    // Public publishers
    public var messages: AnyPublisher<WebSocketMessage, Never> {
        messageSubject.eraseToAnyPublisher()
    }
    
    public var prayerUpdates: AnyPublisher<PrayerUpdate, Never> {
        prayerUpdateSubject.eraseToAnyPublisher()
    }
    
    public var groupUpdates: AnyPublisher<GroupUpdate, Never> {
        groupUpdateSubject.eraseToAnyPublisher()
    }
    
    public var activityUpdates: AnyPublisher<CommunityActivity, Never> {
        activitySubject.eraseToAnyPublisher()
    }
    
    // Retry configuration
    private var retryCount = 0
    private let maxRetries = 5
    private let retryDelay: TimeInterval = 2.0
    
    // Ping timer
    private var pingTimer: Timer?
    private let pingInterval: TimeInterval = 30.0
    
    public init(baseURL: URL = URL(string: "wss://api.leavnapp.com")!) {
        self.baseURL = baseURL
        super.init()
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.waitsForConnectivity = true
        
        self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
    }
    
    // MARK: - Public Methods
    
    public func connect(authToken: String) {
        guard connectionState != .connected else { return }
        
        connectionState = .connecting
        
        var request = URLRequest(url: baseURL.appendingPathComponent("ws"))
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 10
        
        webSocket = session.webSocketTask(with: request)
        webSocket?.resume()
        
        receiveMessage()
        startPingTimer()
    }
    
    public func disconnect() {
        stopPingTimer()
        webSocket?.cancel(with: .goingAway, reason: nil)
        webSocket = nil
        connectionState = .disconnected
        retryCount = 0
    }
    
    public func send(_ message: WebSocketMessage) async throws {
        guard connectionState == .connected else {
            throw WebSocketError.notConnected
        }
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(message)
        let message = URLSessionWebSocketTask.Message.data(data)
        
        try await webSocket?.send(message)
    }
    
    public func subscribeToPrayer(_ prayerId: PrayerID) async throws {
        let message = WebSocketMessage(
            type: .subscribe,
            topic: .prayer(prayerId),
            data: nil
        )
        try await send(message)
    }
    
    public func unsubscribeFromPrayer(_ prayerId: PrayerID) async throws {
        let message = WebSocketMessage(
            type: .unsubscribe,
            topic: .prayer(prayerId),
            data: nil
        )
        try await send(message)
    }
    
    public func subscribeToGroup(_ groupId: GroupID) async throws {
        let message = WebSocketMessage(
            type: .subscribe,
            topic: .group(groupId),
            data: nil
        )
        try await send(message)
    }
    
    public func unsubscribeFromGroup(_ groupId: GroupID) async throws {
        let message = WebSocketMessage(
            type: .unsubscribe,
            topic: .group(groupId),
            data: nil
        )
        try await send(message)
    }
    
    // MARK: - Private Methods
    
    private func receiveMessage() {
        webSocket?.receive { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let message):
                self.handleMessage(message)
                self.receiveMessage() // Continue receiving
                
            case .failure(let error):
                self.handleError(error)
            }
        }
    }
    
    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                
                if let wsMessage = try? decoder.decode(WebSocketMessage.self, from: data) {
                    messageSubject.send(wsMessage)
                    
                    // Route specific message types
                    switch wsMessage.type {
                    case .prayerUpdate:
                        if let update = try? decoder.decode(PrayerUpdate.self, from: wsMessage.data ?? Data()) {
                            prayerUpdateSubject.send(update)
                        }
                        
                    case .groupUpdate:
                        if let update = try? decoder.decode(GroupUpdate.self, from: wsMessage.data ?? Data()) {
                            groupUpdateSubject.send(update)
                        }
                        
                    case .activityUpdate:
                        if let activity = try? decoder.decode(CommunityActivity.self, from: wsMessage.data ?? Data()) {
                            activitySubject.send(activity)
                        }
                        
                    case .connected:
                        connectionState = .connected
                        retryCount = 0
                        
                    case .error:
                        if let errorData = wsMessage.data,
                           let errorMessage = String(data: errorData, encoding: .utf8) {
                            lastError = .serverError(errorMessage)
                        }
                        
                    default:
                        break
                    }
                }
            } catch {
                lastError = .decodingError(error)
            }
            
        case .string(let text):
            // Handle string messages if needed
            print("Received string message: \(text)")
            
        @unknown default:
            break
        }
    }
    
    private func handleError(_ error: Error) {
        connectionState = .disconnected
        lastError = .connectionError(error)
        
        // Attempt reconnection with exponential backoff
        if retryCount < maxRetries {
            retryCount += 1
            let delay = retryDelay * pow(2.0, Double(retryCount - 1))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                if self.connectionState == .disconnected {
                    self.reconnect()
                }
            }
        }
    }
    
    private func reconnect() {
        @Dependency(\.userDefaults) var userDefaults
        
        if let token = userDefaults.authToken {
            connect(authToken: token)
        }
    }
    
    // MARK: - Ping/Pong
    
    private func startPingTimer() {
        stopPingTimer()
        
        pingTimer = Timer.scheduledTimer(withTimeInterval: pingInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }
    
    private func sendPing() {
        guard connectionState == .connected else { return }
        
        webSocket?.sendPing { [weak self] error in
            if let error = error {
                self?.handleError(error)
            }
        }
    }
}

// MARK: - URLSessionWebSocketDelegate
extension WebSocketService: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        connectionState = .connected
        retryCount = 0
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        connectionState = .disconnected
        
        if let reason = reason, let message = String(data: reason, encoding: .utf8) {
            lastError = .connectionClosed(code: closeCode, reason: message)
        }
    }
}

// MARK: - Models
public enum ConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
}

public enum WebSocketError: LocalizedError {
    case notConnected
    case connectionError(Error)
    case connectionClosed(code: URLSessionWebSocketTask.CloseCode, reason: String)
    case serverError(String)
    case decodingError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected"
        case .connectionError(let error):
            return "Connection error: \(error.localizedDescription)"
        case .connectionClosed(let code, let reason):
            return "Connection closed with code \(code.rawValue): \(reason)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}

public struct WebSocketMessage: Codable {
    public let id: UUID
    public let type: MessageType
    public let topic: Topic?
    public let data: Data?
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        type: MessageType,
        topic: Topic? = nil,
        data: Data? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.topic = topic
        self.data = data
        self.timestamp = timestamp
    }
    
    public enum MessageType: String, Codable {
        case subscribe
        case unsubscribe
        case prayerUpdate
        case groupUpdate
        case activityUpdate
        case connected
        case error
        case ping
        case pong
    }
    
    public enum Topic: Codable {
        case prayer(PrayerID)
        case group(GroupID)
        case user(UserID)
        case global
        
        private enum CodingKeys: String, CodingKey {
            case type
            case id
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            
            switch type {
            case "prayer":
                let id = try container.decode(UUID.self, forKey: .id)
                self = .prayer(PrayerID(id))
            case "group":
                let id = try container.decode(UUID.self, forKey: .id)
                self = .group(GroupID(id))
            case "user":
                let id = try container.decode(UUID.self, forKey: .id)
                self = .user(UserID(id))
            case "global":
                self = .global
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown topic type")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            switch self {
            case .prayer(let id):
                try container.encode("prayer", forKey: .type)
                try container.encode(id.rawValue, forKey: .id)
            case .group(let id):
                try container.encode("group", forKey: .type)
                try container.encode(id.rawValue, forKey: .id)
            case .user(let id):
                try container.encode("user", forKey: .type)
                try container.encode(id.rawValue, forKey: .id)
            case .global:
                try container.encode("global", forKey: .type)
            }
        }
    }
}

// MARK: - Update Models
public struct PrayerUpdate: Codable {
    public let prayerId: PrayerID
    public let updateType: UpdateType
    public let updatedBy: UserID
    public let timestamp: Date
    
    public enum UpdateType: String, Codable {
        case created
        case updated
        case prayed
        case answered
        case deleted
    }
}

public struct GroupUpdate: Codable {
    public let groupId: GroupID
    public let updateType: UpdateType
    public let updatedBy: UserID
    public let timestamp: Date
    public let metadata: [String: String]?
    
    public enum UpdateType: String, Codable {
        case memberJoined
        case memberLeft
        case settingsChanged
        case newPrayer
        case deleted
    }
}

// MARK: - Dependency
struct WebSocketServiceKey: DependencyKey {
    static let liveValue = WebSocketService()
}

extension DependencyValues {
    var webSocketService: WebSocketService {
        get { self[WebSocketServiceKey.self] }
        set { self[WebSocketServiceKey.self] = newValue }
    }
}