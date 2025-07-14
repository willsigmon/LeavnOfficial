import Foundation
import AVFoundation
import LeavnCore
import NetworkingKit

// MARK: - ElevenLabs Service Protocol
public protocol ElevenLabsService {
    func synthesizeText(_ text: String, voiceId: String, settings: VoiceSettings?) async throws -> AudioData
    func getAvailableVoices() async throws -> [Voice]
    func getVoiceSettings(voiceId: String) async throws -> VoiceSettings
    func getUserSubscription() async throws -> SubscriptionInfo
}

// MARK: - Voice Models
public struct Voice: Codable, Identifiable {
    public let id: String
    public let name: String
    public let category: String
    public let description: String?
    public let preview_url: String?
    public let available_for_tiers: [String]
    public let settings: VoiceSettings?
    public let sharing: VoiceSharing?
    public let high_quality_base_model_ids: [String]?
    
    public var isHighQuality: Bool {
        high_quality_base_model_ids?.isEmpty == false
    }
    
    public init(
        id: String,
        name: String,
        category: String = "premade",
        description: String? = nil,
        preview_url: String? = nil,
        available_for_tiers: [String] = ["free"],
        settings: VoiceSettings? = nil,
        sharing: VoiceSharing? = nil,
        high_quality_base_model_ids: [String]? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.description = description
        self.preview_url = preview_url
        self.available_for_tiers = available_for_tiers
        self.settings = settings
        self.sharing = sharing
        self.high_quality_base_model_ids = high_quality_base_model_ids
    }
}

public struct VoiceSettings: Codable {
    public let stability: Double
    public let similarity_boost: Double
    public let style: Double?
    public let use_speaker_boost: Bool?
    
    public init(
        stability: Double = 0.5,
        similarity_boost: Double = 0.75,
        style: Double? = nil,
        use_speaker_boost: Bool? = nil
    ) {
        self.stability = stability
        self.similarity_boost = similarity_boost
        self.style = style
        self.use_speaker_boost = use_speaker_boost
    }
}

public struct VoiceSharing: Codable {
    public let status: String
    public let history_item_sample_id: String?
    public let original_voice_id: String?
    public let public_owner_id: String?
    public let liked_by_count: Int?
    public let cloned_by_count: Int?
}

public struct AudioData {
    public let data: Data
    public let format: AudioFormat
    public let duration: TimeInterval?
    
    public enum AudioFormat: String {
        case mp3 = "mp3_44100_128"
        case pcm = "pcm_16000"
        case pcm22050 = "pcm_22050"
        case pcm44100 = "pcm_44100"
        case ulaw = "ulaw_8000"
    }
    
    public init(data: Data, format: AudioFormat, duration: TimeInterval? = nil) {
        self.data = data
        self.format = format
        self.duration = duration
    }
}

public struct SubscriptionInfo: Codable {
    public let tier: String
    public let character_count: Int
    public let character_limit: Int
    public let can_extend_character_limit: Bool
    public let allowed_to_extend_character_limit: Bool
    public let next_character_count_reset_unix: Int
    public let voice_limit: Int
    public let max_voice_add_edits: Int
    public let voice_add_edit_counter: Int
    public let professional_voice_limit: Int
    public let can_extend_voice_limit: Bool
    public let can_use_instant_voice_cloning: Bool
    public let can_use_professional_voice_cloning: Bool
    public let currency: String
    public let status: String
    
    public var charactersRemaining: Int {
        max(0, character_limit - character_count)
    }
    
    public var usagePercentage: Double {
        guard character_limit > 0 else { return 0 }
        return Double(character_count) / Double(character_limit)
    }
}

// MARK: - ElevenLabs Service Implementation
public final class DefaultElevenLabsService: ElevenLabsService {
    private let networkService: NetworkService
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io"
    
    // Cached voices to avoid repeated API calls
    @Published private var cachedVoices: [Voice] = []
    private var lastVoicesFetch: Date?
    private let voicesCacheInterval: TimeInterval = 300 // 5 minutes
    
    public init(networkService: NetworkService, apiKey: String) {
        self.networkService = networkService
        self.apiKey = apiKey
    }
    
    // MARK: - Text to Speech
    public func synthesizeText(_ text: String, voiceId: String, settings: VoiceSettings? = nil) async throws -> AudioData {
        // Use v3 API endpoint with enhanced features
        let endpoint = Endpoint(
            path: "/v1/text-to-speech/\(voiceId)/stream",
            method: .POST,
            headers: [
                "Accept": "audio/mpeg",
                "Content-Type": "application/json",
                "xi-api-key": apiKey
            ],
            encoding: JSONEncoding.default
        )
        
        let requestBody = TextToSpeechRequest(
            text: text,
            model_id: "eleven_multilingual_v2", // v3 model with better quality
            voice_settings: settings ?? VoiceSettings(),
            optimize_streaming_latency: 2, // Balanced latency/quality
            output_format: "mp3_44100_128"
        )
        
        let encoder = JSONEncoder()
        let bodyData = try encoder.encode(requestBody)
        
        // Create manual request for streaming
        let url = URL(string: baseURL)!.appendingPathComponent(endpoint.path)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = bodyData
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.name) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AudioError.synthesisError(message: "Failed to synthesize audio")
        }
        
        // Get actual duration from audio data
        let duration = try getAudioDuration(from: data)
        
        return AudioData(
            data: data,
            format: .mp3,
            duration: duration
        )
    }
    
    // MARK: - Voice Management
    public func getAvailableVoices() async throws -> [Voice] {
        // Return cached voices if recent
        if let lastFetch = lastVoicesFetch,
           Date().timeIntervalSince(lastFetch) < voicesCacheInterval,
           !cachedVoices.isEmpty {
            return cachedVoices
        }
        
        let endpoint = Endpoint(
            path: "/v1/voices",
            headers: [
                "Accept": "application/json",
                "xi-api-key": apiKey
            ]
        )
        
        let response: VoicesResponse = try await networkService.request(endpoint)
        cachedVoices = response.voices
        lastVoicesFetch = Date()
        
        return response.voices
    }
    
    public func getVoiceSettings(voiceId: String) async throws -> VoiceSettings {
        let endpoint = Endpoint(
            path: "/v1/voices/\(voiceId)/settings",
            headers: [
                "Accept": "application/json",
                "xi-api-key": apiKey
            ]
        )
        
        return try await networkService.request(endpoint)
    }
    
    // MARK: - User Information
    public func getUserSubscription() async throws -> SubscriptionInfo {
        let endpoint = Endpoint(
            path: "/v1/user/subscription",
            headers: [
                "Accept": "application/json",
                "xi-api-key": apiKey
            ]
        )
        
        return try await networkService.request(endpoint)
    }
    
    // MARK: - Helper Methods
    private func estimateAudioDuration(for text: String) -> TimeInterval {
        // Rough estimation: average speaking rate is ~150 words per minute
        let words = text.split(separator: " ").count
        let wordsPerMinute: Double = 150
        let minutes = Double(words) / wordsPerMinute
        return minutes * 60
    }
    
    private func getAudioDuration(from data: Data) throws -> TimeInterval {
        // Create AVAudioPlayer to get accurate duration
        do {
            let player = try AVAudioPlayer(data: data)
            return player.duration
        } catch {
            // Fallback to estimation if we can't parse the audio
            return 0
        }
    }
}

// MARK: - Request/Response Models
private struct TextToSpeechRequest: Codable {
    let text: String
    let model_id: String
    let voice_settings: VoiceSettings
    let optimize_streaming_latency: Int?
    let output_format: String?
}

private struct VoicesResponse: Codable {
    let voices: [Voice]
}

// MARK: - Predefined Voices for Bible Narration
public extension DefaultElevenLabsService {
    static let biblicalNarratorVoices: [Voice] = [
        Voice(
            id: "21m00Tcm4TlvDq8ikWAM",
            name: "Rachel",
            description: "Calm, clear female voice perfect for scripture reading"
        ),
        Voice(
            id: "AZnzlk1XvdvUeBnXmlld",
            name: "Domi",
            description: "Confident, warm female voice with excellent diction"
        ),
        Voice(
            id: "EXAVITQu4vr4xnSDxMaL",
            name: "Bella",
            description: "Gentle, soothing female voice ideal for meditation"
        ),
        Voice(
            id: "ErXwobaYiN019PkySvjV",
            name: "Antoni",
            description: "Deep, resonant male voice perfect for Old Testament"
        ),
        Voice(
            id: "VR6AewLTigWG4xSOukaG",
            name: "Arnold",
            description: "Authoritative male voice suitable for prophetic books"
        ),
        Voice(
            id: "pNInz6obpgDQGcFmaJgB",
            name: "Adam",
            description: "Clear, professional male voice for New Testament"
        ),
        Voice(
            id: "onwK4e9ZLuTAKqWW03F9",
            name: "Daniel",
            description: "Warm, conversational male voice for Gospels"
        ),
        Voice(
            id: "IKne3meq5aSn9XLyUdCD",
            name: "Charlie",
            description: "Friendly, engaging voice perfect for Psalms"
        )
    ]
    
    func getBiblicalVoices() -> [Voice] {
        return Self.biblicalNarratorVoices
    }
}

// MARK: - Voice Categories for Bible Books
public enum BibleVoiceCategory {
    case oldTestamentNarrative // Genesis, Exodus, Kings, Chronicles
    case law // Leviticus, Deuteronomy
    case wisdom // Proverbs, Ecclesiastes, Job
    case psalms // Psalms, Song of Songs
    case prophecy // Isaiah, Jeremiah, Ezekiel, Daniel, Minor Prophets
    case gospels // Matthew, Mark, Luke, John
    case epistles // Romans through Jude
    case apocalyptic // Revelation
    
    public var recommendedVoices: [String] {
        switch self {
        case .oldTestamentNarrative:
            return ["ErXwobaYiN019PkySvjV", "VR6AewLTigWG4xSOukaG"] // Antoni, Arnold
        case .law:
            return ["VR6AewLTigWG4xSOukaG", "pNInz6obpgDQGcFmaJgB"] // Arnold, Adam
        case .wisdom:
            return ["21m00Tcm4TlvDq8ikWAM", "EXAVITQu4vr4xnSDxMaL"] // Rachel, Bella
        case .psalms:
            return ["IKne3meq5aSn9XLyUdCD", "EXAVITQu4vr4xnSDxMaL"] // Charlie, Bella
        case .prophecy:
            return ["ErXwobaYiN019PkySvjV", "VR6AewLTigWG4xSOukaG"] // Antoni, Arnold
        case .gospels:
            return ["onwK4e9ZLuTAKqWW03F9", "pNInz6obpgDQGcFmaJgB"] // Daniel, Adam
        case .epistles:
            return ["pNInz6obpgDQGcFmaJgB", "onwK4e9ZLuTAKqWW03F9"] // Adam, Daniel
        case .apocalyptic:
            return ["VR6AewLTigWG4xSOukaG", "ErXwobaYiN019PkySvjV"] // Arnold, Antoni
        }
    }
    
    public static func category(for book: String) -> BibleVoiceCategory {
        let bookLower = book.lowercased()
        
        // Old Testament Narrative
        if ["genesis", "exodus", "numbers", "joshua", "judges", "ruth", "1 samuel", "2 samuel", 
            "1 kings", "2 kings", "1 chronicles", "2 chronicles", "ezra", "nehemiah", "esther"].contains(bookLower) {
            return .oldTestamentNarrative
        }
        
        // Law
        if ["leviticus", "deuteronomy"].contains(bookLower) {
            return .law
        }
        
        // Wisdom
        if ["job", "proverbs", "ecclesiastes"].contains(bookLower) {
            return .wisdom
        }
        
        // Psalms
        if ["psalms", "psalm", "song of songs", "song of solomon"].contains(bookLower) {
            return .psalms
        }
        
        // Prophecy
        if ["isaiah", "jeremiah", "lamentations", "ezekiel", "daniel", "hosea", "joel", 
            "amos", "obadiah", "jonah", "micah", "nahum", "habakkuk", "zephaniah", 
            "haggai", "zechariah", "malachi"].contains(bookLower) {
            return .prophecy
        }
        
        // Gospels
        if ["matthew", "mark", "luke", "john"].contains(bookLower) {
            return .gospels
        }
        
        // Epistles
        if ["romans", "1 corinthians", "2 corinthians", "galatians", "ephesians", 
            "philippians", "colossians", "1 thessalonians", "2 thessalonians", 
            "1 timothy", "2 timothy", "titus", "philemon", "hebrews", "james", 
            "1 peter", "2 peter", "1 john", "2 john", "3 john", "jude"].contains(bookLower) {
            return .epistles
        }
        
        // Apocalyptic
        if ["revelation"].contains(bookLower) {
            return .apocalyptic
        }
        
        // Default to narrative
        return .oldTestamentNarrative
    }
}

// MARK: - Audio Errors
public enum AudioError: LocalizedError {
    case synthesisError(message: String)
    case invalidAudioData
    case networkError(underlying: Error?)
    
    public var errorDescription: String? {
        switch self {
        case .synthesisError(let message):
            return "Audio synthesis failed: \(message)"
        case .invalidAudioData:
            return "Invalid audio data received"
        case .networkError(let error):
            return "Network error: \(error?.localizedDescription ?? "Unknown")"
        }
    }
}