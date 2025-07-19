import Dependencies
import Foundation
import AVFoundation
import Combine

// MARK: - ElevenLabs Client
@MainActor
public struct ElevenLabsClient: Sendable {
    public var textToSpeech: @Sendable (String, String) async throws -> Data
    public var streamTextToSpeech: @Sendable (String, String) async throws -> AsyncThrowingStream<Data, Error>
    public var getVoices: @Sendable () async throws -> [VoiceInfo]
    public var getVoice: @Sendable (String) async throws -> VoiceInfo
    public var getUserInfo: @Sendable () async throws -> UserInfo
    public var getHistory: @Sendable () async throws -> [HistoryItem]
    public var deleteHistoryItem: @Sendable (String) async throws -> Void
}

// MARK: - Voice Info
public struct VoiceInfo: Identifiable, Equatable, Codable, Sendable {
    public let id: String
    public let name: String
    public let category: String
    public let labels: [String: String]?
    public let description: String?
    public let previewURL: String?
    public let settings: VoiceSettings?
    
    public var gender: String? {
        labels?["gender"]
    }
    
    public var accent: String? {
        labels?["accent"]
    }
    
    public var useCase: String? {
        labels?["use_case"]
    }
}

// MARK: - Voice Settings
public struct VoiceSettings: Codable, Sendable {
    public let stability: Double
    public let similarityBoost: Double
    public let style: Double?
    public let useSpeakerBoost: Bool?
    
    public init(
        stability: Double = 0.5,
        similarityBoost: Double = 0.75,
        style: Double? = 0.0,
        useSpeakerBoost: Bool? = true
    ) {
        self.stability = stability
        self.similarityBoost = similarityBoost
        self.style = style
        self.useSpeakerBoost = useSpeakerBoost
    }
}

// MARK: - User Info
public struct UserInfo: Codable, Sendable {
    public let subscription: Subscription
    public let isNewUser: Bool
    public let xiApiKey: String
    
    public struct Subscription: Codable, Sendable {
        public let tier: String
        public let characterCount: Int
        public let characterLimit: Int
        public let canExtendCharacterLimit: Bool
        public let allowedToExtendCharacterLimit: Bool
        public let nextCharacterCountResetUnix: Int
        public let voiceLimit: Int
        public let professionalVoiceLimit: Int
        public let canExtendVoiceLimit: Bool
        public let canUseInstantVoiceCloning: Bool
        public let canUseProfessionalVoiceCloning: Bool
        public let currency: String?
        public let status: String
    }
}

// MARK: - History Item
public struct HistoryItem: Identifiable, Codable, Sendable {
    public let id: String
    public let voiceId: String
    public let voiceName: String
    public let text: String
    public let dateUnix: Int
    public let characterCountChangeFrom: Int
    public let characterCountChangeTo: Int
    public let contentType: String
    public let state: String
    public let settings: VoiceSettings?
    public let feedback: Feedback?
    
    public struct Feedback: Codable, Sendable {
        public let thumbsUp: Bool
        public let emotion: Bool
        public let inaccurateClone: Bool
        public let glitch: Bool
        public let audioQuality: Bool
        public let other: Bool
        public let reviewStatus: String?
    }
    
    public var date: Date {
        Date(timeIntervalSince1970: TimeInterval(dateUnix))
    }
}

// MARK: - API Client
private struct ElevenLabsAPIClient {
    let baseURL = URL(string: "https://api.elevenlabs.io/v1")!
    
    @Dependency(\.apiKeyManager) var apiKeyManager
    
    func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        streaming: Bool = false
    ) async throws -> (Data, URLResponse) {
        guard let apiKey = try await apiKeyManager.getElevenLabsKey() else {
            throw ElevenLabsError.missingAPIKey
        }
        
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = method
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if streaming {
            request.setValue("audio/mpeg", forHTTPHeaderField: "Accept")
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        return try await URLSession.shared.data(for: request)
    }
}

// MARK: - Dependency Implementation
extension ElevenLabsClient: DependencyKey {
    public static let liveValue = Self(
        textToSpeech: { text, voiceId in
            let client = ElevenLabsAPIClient()
            
            let requestBody = TextToSpeechRequest(
                text: text,
                modelId: "eleven_multilingual_v2",
                voiceSettings: VoiceSettings()
            )
            
            let body = try JSONEncoder().encode(requestBody)
            let (data, response) = try await client.makeRequest(
                endpoint: "text-to-speech/\(voiceId)",
                method: "POST",
                body: body,
                streaming: true
            )
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                if let errorData = try? JSONDecoder().decode(APIError.self, from: data) {
                    throw ElevenLabsError.apiError(errorData.detail)
                }
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
            
            return data
        },
        streamTextToSpeech: { text, voiceId in
            AsyncThrowingStream { continuation in
                Task {
                    do {
                        let client = ElevenLabsAPIClient()
                        
                        let requestBody = TextToSpeechRequest(
                            text: text,
                            modelId: "eleven_multilingual_v2",
                            voiceSettings: VoiceSettings()
                        )
                        
                        let body = try JSONEncoder().encode(requestBody)
                        let (data, response) = try await client.makeRequest(
                            endpoint: "text-to-speech/\(voiceId)/stream",
                            method: "POST",
                            body: body,
                            streaming: true
                        )
                        
                        guard let httpResponse = response as? HTTPURLResponse else {
                            throw ElevenLabsError.invalidResponse
                        }
                        
                        guard httpResponse.statusCode == 200 else {
                            throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
                        }
                        
                        // For streaming, we'd normally parse chunks
                        // For now, return the full data
                        continuation.yield(data)
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        },
        getVoices: {
            let client = ElevenLabsAPIClient()
            let (data, response) = try await client.makeRequest(endpoint: "voices")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let voicesResponse = try JSONDecoder().decode(VoicesResponse.self, from: data)
            return voicesResponse.voices
        },
        getVoice: { voiceId in
            let client = ElevenLabsAPIClient()
            let (data, response) = try await client.makeRequest(endpoint: "voices/\(voiceId)")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
            
            return try JSONDecoder().decode(VoiceInfo.self, from: data)
        },
        getUserInfo: {
            let client = ElevenLabsAPIClient()
            let (data, response) = try await client.makeRequest(endpoint: "user")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
            
            return try JSONDecoder().decode(UserInfo.self, from: data)
        },
        getHistory: {
            let client = ElevenLabsAPIClient()
            let (data, response) = try await client.makeRequest(endpoint: "history")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
            
            let historyResponse = try JSONDecoder().decode(HistoryResponse.self, from: data)
            return historyResponse.history
        },
        deleteHistoryItem: { historyId in
            let client = ElevenLabsAPIClient()
            let (_, response) = try await client.makeRequest(
                endpoint: "history/\(historyId)",
                method: "DELETE"
            )
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw ElevenLabsError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw ElevenLabsError.httpError(statusCode: httpResponse.statusCode)
            }
        }
    )
    
    public static let testValue = Self(
        textToSpeech: { _, _ in Data() },
        streamTextToSpeech: { _, _ in
            AsyncThrowingStream { continuation in
                continuation.yield(Data())
                continuation.finish()
            }
        },
        getVoices: { [] },
        getVoice: { _ in
            VoiceInfo(
                id: "test",
                name: "Test Voice",
                category: "general",
                labels: [:],
                description: nil,
                previewURL: nil,
                settings: nil
            )
        },
        getUserInfo: {
            UserInfo(
                subscription: UserInfo.Subscription(
                    tier: "free",
                    characterCount: 0,
                    characterLimit: 10000,
                    canExtendCharacterLimit: false,
                    allowedToExtendCharacterLimit: false,
                    nextCharacterCountResetUnix: 0,
                    voiceLimit: 3,
                    professionalVoiceLimit: 0,
                    canExtendVoiceLimit: false,
                    canUseInstantVoiceCloning: false,
                    canUseProfessionalVoiceCloning: false,
                    currency: nil,
                    status: "active"
                ),
                isNewUser: false,
                xiApiKey: "test"
            )
        },
        getHistory: { [] },
        deleteHistoryItem: { _ in }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var elevenLabsClient: ElevenLabsClient {
        get { self[ElevenLabsClient.self] }
        set { self[ElevenLabsClient.self] = newValue }
    }
}

// MARK: - API Models
private struct TextToSpeechRequest: Encodable {
    let text: String
    let modelId: String
    let voiceSettings: VoiceSettings
    
    enum CodingKeys: String, CodingKey {
        case text
        case modelId = "model_id"
        case voiceSettings = "voice_settings"
    }
}

private struct VoicesResponse: Decodable {
    let voices: [VoiceInfo]
}

private struct HistoryResponse: Decodable {
    let history: [HistoryItem]
}

private struct APIError: Decodable {
    let detail: String
}

// MARK: - Errors
public enum ElevenLabsError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(String)
    case audioPlaybackError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "ElevenLabs API key not configured. Please add your API key in Settings."
        case .invalidResponse:
            return "Invalid response from ElevenLabs API"
        case .httpError(let statusCode):
            return "ElevenLabs API error: HTTP \(statusCode)"
        case .apiError(let detail):
            return "ElevenLabs API error: \(detail)"
        case .audioPlaybackError(let error):
            return "Audio playback error: \(error.localizedDescription)"
        }
    }
}