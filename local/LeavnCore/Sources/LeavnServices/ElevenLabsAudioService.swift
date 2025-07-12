import Foundation
@preconcurrency import AVFoundation
import LeavnCore
import Combine

/// Production implementation of AudioService using ElevenLabs API
@MainActor
public final class ElevenLabsAudioService: AudioServiceProtocol {
    
    // MARK: - Properties
    
    private let apiKey: String
    private let baseURL = "https://api.elevenlabs.io/v1" // v3 endpoints are under v1 path structure
    private let session: URLSession
    private let cacheService: CacheServiceProtocol
    private let lifeSituationsEngine: LifeSituationsEngineProtocol?
    
    private var audioPlayer: AVAudioPlayer?
    private var currentNarration: AudioNarration?
    private var currentEmotionalContext: EmotionalState = .peace
    
    // Cache configuration
    private let cachePrefix = "audio_cache"
    private let cacheDuration: TimeInterval = 86400 * 7 // 7 days
    
    // MARK: - Initialization
    
    @MainActor
    public init(
        apiKey: String,
        cacheService: CacheServiceProtocol,
        lifeSituationsEngine: LifeSituationsEngineProtocol? = nil
    ) {
        self.apiKey = apiKey
        self.cacheService = cacheService
        self.lifeSituationsEngine = lifeSituationsEngine
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = [
            "xi-api-key": apiKey,
            "Content-Type": "application/json"
        ]
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - ServiceProtocol
    
    public func initialize() async throws {
        // Verify API key is valid by fetching voices
        _ = try await getAvailableVoices()
        print("🎙️ ElevenLabs Audio Service initialized")
    }
    
    // MARK: - AudioServiceProtocol
    
    public func narrate(_ verse: BibleVerse, configuration: AudioConfiguration) async throws -> AudioNarration {
        // Check cache first
        let cacheKey = "\(cachePrefix)_\(verse.id)_\(configuration.voiceId)_\(configuration.style.rawValue)"
        if let cached: AudioNarration = await cacheService.get(cacheKey, type: AudioNarration.self) {
            return cached
        }
        
        // Determine voice style based on emotional context and verse content
        var config = configuration
        if lifeSituationsEngine != nil {
            let emotionalStyle = await determineVoiceStyle(for: verse)
            config = AudioConfiguration(
                voiceId: configuration.voiceId,
                speed: configuration.speed,
                pitch: configuration.pitch,
                volume: configuration.volume,
                style: emotionalStyle,
                modelId: configuration.modelId,
                stability: configuration.stability,
                similarityBoost: configuration.similarityBoost,
                useSSML: configuration.useSSML
            )
        }
        
        // Generate SSML if enabled
        let textToNarrate: String
        if config.useSSML {
            textToNarrate = generateSSML(for: verse.text, style: config.style)
        } else {
            textToNarrate = verse.text
        }
        
        // Generate audio using ElevenLabs API
        let audioData = try await generateAudio(
            text: textToNarrate,
            voiceId: config.voiceId,
            modelId: config.modelId ?? "eleven_turbo_v2_5",
            voiceSettings: [
                "stability": config.stability,
                "similarity_boost": config.similarityBoost,
                "style": config.style == .neutral ? 0.0 : styleValue(for: config.style),
                "use_speaker_boost": true
            ]
        )
        
        // Create narration object
        let narration = AudioNarration(
            verse: verse,
            audioData: audioData,
            configuration: config
        )
        
        // Cache the result
        let expirationDate = Date().addingTimeInterval(cacheDuration)
        await cacheService.set(cacheKey, value: narration, expirationDate: expirationDate)
        
        return narration
    }
    
    public func narrateChapter(_ chapter: BibleChapter, configuration: AudioConfiguration) async throws -> [AudioNarration] {
        var narrations: [AudioNarration] = []
        
        for verse in chapter.verses {
            let narration = try await narrate(verse, configuration: configuration)
            narrations.append(narration)
        }
        
        return narrations
    }
    
    public func getAvailableVoices() async throws -> [ElevenLabsVoice] {
        let url = URL(string: "\(baseURL)/voices")!
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AudioError.apiError("Failed to fetch voices")
        }
        
        let voicesResponse = try JSONDecoder().decode(VoicesResponse.self, from: data)
        return voicesResponse.voices.map { voice in
            ElevenLabsVoice(
                voiceId: voice.voice_id,
                name: voice.name,
                category: voice.category ?? "custom",
                labels: voice.labels ?? [:]
            )
        }
    }
    
    public func preloadAudio(for verses: [BibleVerse], configuration: AudioConfiguration) async {
        // Preload audio in background
        for verse in verses {
            Task {
                _ = try? await narrate(verse, configuration: configuration)
            }
        }
    }
    
    public func stopNarration() async {
        audioPlayer?.stop()
        audioPlayer = nil
        currentNarration = nil
    }
    
    public func pauseNarration() async {
        audioPlayer?.pause()
    }
    
    public func resumeNarration() async {
        audioPlayer?.play()
    }
    
    public func setEmotionalContext(_ context: EmotionalState) async {
        currentEmotionalContext = context
    }
    
    nonisolated public func generateSSML(for text: String, style: VoiceStyle) -> String {
        var builder = SSMLBuilder()
        
        // Split text into sentences for better prosody control
        let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        for (index, sentence) in sentences.enumerated() {
            builder.addText(sentence + ".", style: style)
            
            // Add appropriate pauses between sentences
            if index < sentences.count - 1 {
                let pauseDuration = pauseDuration(for: style)
                builder.addPause(duration: pauseDuration)
            }
        }
        
        return builder.build()
    }
    
    // MARK: - Private Methods
    
    private func generateAudio(text: String, voiceId: String, modelId: String, voiceSettings: [String: Any]) async throws -> Data {
        let url = URL(string: "\(baseURL)/text-to-speech/\(voiceId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Build emotion parameters based on voice settings
        var emotionPrompt: [String: Any] = [:]
        if let style = voiceSettings["style"] as? Double, style != 0.0 {
            emotionPrompt = emotionParameters(for: style)
        }
        
        let body: [String: Any] = [
            "text": text,
            "model_id": modelId,
            "voice_settings": voiceSettings,
            "output_format": "mp3_44100_128",
            "optimize_streaming_latency": 0,
            "style": emotionPrompt["style"] ?? 0,
            "emotion": emotionPrompt["emotion"] ?? "neutral"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw AudioError.apiError("Failed to generate audio: \(response)")
        }
        
        return data
    }
    
    private func determineVoiceStyle(for verse: BibleVerse) async -> VoiceStyle {
        // Analyze verse content with life situations engine
        if let engine = lifeSituationsEngine {
            let situation = await engine.analyzeSituation(verse.text)
            
            switch situation.dominantEmotion {
            case .joy:
                return .joyful
            case .struggle:
                return .contemplative
            case .peace:
                return .peaceful
            case .growth:
                return .triumphant
            case .worship:
                return .compassionate
            }
        }
        
        // Fallback to basic keyword analysis
        let text = verse.text.lowercased()
        if text.contains("rejoice") || text.contains("joy") || text.contains("praise") {
            return .joyful
        } else if text.contains("weep") || text.contains("mourn") || text.contains("sorrow") {
            return .sorrowful
        } else if text.contains("fear not") || text.contains("peace") || text.contains("still") {
            return .peaceful
        } else if text.contains("arise") || text.contains("go") || text.contains("quickly") {
            return .urgent
        }
        
        return .contemplative
    }
    
    private func styleValue(for style: VoiceStyle) -> Double {
        switch style {
        case .neutral: return 0.0
        case .joyful: return 0.8
        case .sorrowful: return -0.6
        case .contemplative: return 0.2
        case .triumphant: return 1.0
        case .peaceful: return -0.3
        case .urgent: return 0.6
        case .compassionate: return 0.4
        case .hopeful: return 0.5
        case .reverent: return 0.1
        }
    }
    
    nonisolated private func pauseDuration(for style: VoiceStyle) -> TimeInterval {
        switch style {
        case .contemplative, .peaceful, .reverent:
            return 1.0
        case .urgent:
            return 0.3
        case .sorrowful:
            return 0.8
        case .joyful, .hopeful, .triumphant:
            return 0.4
        case .neutral, .compassionate:
            return 0.5
        }
    }
    
    private func emotionParameters(for styleValue: Double) -> [String: Any] {
        // Map style values to emotion parameters for v3 API
        switch styleValue {
        case 0.7...1.0:
            return ["emotion": "excited", "style": 1, "intensity": styleValue]
        case 0.4...0.7:
            return ["emotion": "happy", "style": 1, "intensity": styleValue]
        case -0.3...0.3:
            return ["emotion": "neutral", "style": 0, "intensity": 0.5]
        case -0.6...(-0.3):
            return ["emotion": "calm", "style": 0, "intensity": abs(styleValue)]
        case -1.0...(-0.6):
            return ["emotion": "sad", "style": 0, "intensity": abs(styleValue)]
        default:
            return ["emotion": "neutral", "style": 0, "intensity": 0.5]
        }
    }
}

// MARK: - Supporting Types

private struct VoicesResponse: Codable {
    let voices: [Voice]
}

private struct Voice: Codable {
    let voice_id: String
    let name: String
    let category: String?
    let labels: [String: String]?
}

// MARK: - Audio Errors

public enum AudioError: LocalizedError {
    case apiError(String)
    case noApiKey
    case networkError(Error)
    case invalidResponse
    
    public var errorDescription: String? {
        switch self {
        case .apiError(let message):
            return "Audio API Error: \(message)"
        case .noApiKey:
            return "ElevenLabs API key not configured"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from audio service"
        }
    }
}

