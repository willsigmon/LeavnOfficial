import Foundation
import AVFoundation

// MARK: - Audio Models

/// Represents different voice styles for emotional audio rendering
public enum VoiceStyle: String, Codable, Sendable {
    case neutral = "neutral"
    case joyful = "joyful"
    case sorrowful = "sorrowful"
    case contemplative = "contemplative"
    case triumphant = "triumphant"
    case peaceful = "peaceful"
    case urgent = "urgent"
    case compassionate = "compassionate"
    case hopeful = "hopeful"
    case reverent = "reverent"
}

/// Audio configuration for Bible narration
public struct AudioConfiguration: Codable, Sendable {
    public let voiceId: String
    public let speed: Double
    public let pitch: Double
    public let volume: Double
    public let style: VoiceStyle
    public let modelId: String?
    public let stability: Double
    public let similarityBoost: Double
    public let useSSML: Bool
    
    public init(
        voiceId: String = "default",
        speed: Double = 1.0,
        pitch: Double = 1.0,
        volume: Double = 1.0,
        style: VoiceStyle = .neutral,
        modelId: String? = nil,
        stability: Double = 0.75,
        similarityBoost: Double = 0.75,
        useSSML: Bool = true
    ) {
        self.voiceId = voiceId
        self.speed = speed
        self.pitch = pitch
        self.volume = volume
        self.style = style
        self.modelId = modelId
        self.stability = stability
        self.similarityBoost = similarityBoost
        self.useSSML = useSSML
    }
}

/// Represents an audio narration session
public struct AudioNarration: Identifiable, Codable, Sendable {
    public let id: String
    public let verse: BibleVerse
    public let audioData: Data?
    public let audioURL: URL?
    public let configuration: AudioConfiguration
    public let duration: TimeInterval?
    public let createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        verse: BibleVerse,
        audioData: Data? = nil,
        audioURL: URL? = nil,
        configuration: AudioConfiguration,
        duration: TimeInterval? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.verse = verse
        self.audioData = audioData
        self.audioURL = audioURL
        self.configuration = configuration
        self.duration = duration
        self.createdAt = createdAt
    }
}

/// SSML (Speech Synthesis Markup Language) builder for prosody
public struct SSMLBuilder {
    private var content: String = ""
    
    public init() {}
    
    public mutating func addText(_ text: String, style: VoiceStyle = .neutral) {
        let prosody = prosodyAttributes(for: style)
        content += "<prosody \(prosody)>\(text)</prosody>"
    }
    
    public mutating func addPause(duration: TimeInterval) {
        content += "<break time=\"\(Int(duration * 1000))ms\"/>"
    }
    
    public mutating func addEmphasis(_ text: String, level: String = "moderate") {
        content += "<emphasis level=\"\(level)\">\(text)</emphasis>"
    }
    
    public func build() -> String {
        return "<speak>\(content)</speak>"
    }
    
    private func prosodyAttributes(for style: VoiceStyle) -> String {
        switch style {
        case .neutral:
            return "rate=\"1.0\" pitch=\"+0%\""
        case .joyful:
            return "rate=\"1.1\" pitch=\"+10%\" volume=\"+5dB\""
        case .sorrowful:
            return "rate=\"0.9\" pitch=\"-5%\" volume=\"-2dB\""
        case .contemplative:
            return "rate=\"0.85\" pitch=\"-2%\""
        case .triumphant:
            return "rate=\"1.15\" pitch=\"+15%\" volume=\"+8dB\""
        case .peaceful:
            return "rate=\"0.9\" pitch=\"+2%\" volume=\"-3dB\""
        case .urgent:
            return "rate=\"1.2\" pitch=\"+5%\" volume=\"+5dB\""
        case .compassionate:
            return "rate=\"0.95\" pitch=\"+3%\" volume=\"+2dB\""
        case .hopeful:
            return "rate=\"1.05\" pitch=\"+8%\" volume=\"+3dB\""
        case .reverent:
            return "rate=\"0.88\" pitch=\"-3%\" volume=\"-1dB\""
        }
    }
}

/// Voice metadata for ElevenLabs integration
public struct ElevenLabsVoice: Codable, Sendable {
    public let voiceId: String
    public let name: String
    public let category: String
    public let labels: [String: String]
    
    public init(voiceId: String, name: String, category: String = "premade", labels: [String: String] = [:]) {
        self.voiceId = voiceId
        self.name = name
        self.category = category
        self.labels = labels
    }
}

/// Default ElevenLabs voices for Bible narration
public struct ElevenLabsVoices {
    public static let matthew = ElevenLabsVoice(
        voiceId: "ErXwobaYiN019PkySvjV",
        name: "Matthew",
        labels: ["use_case": "narration", "accent": "american"]
    )
    
    public static let rachel = ElevenLabsVoice(
        voiceId: "21m00Tcm4TlvDq8ikWAM",
        name: "Rachel",
        labels: ["use_case": "narration", "accent": "american", "gender": "female"]
    )
    
    public static let clyde = ElevenLabsVoice(
        voiceId: "2EiwWnXFnvU5JabPnv8n",
        name: "Clyde",
        labels: ["use_case": "narration", "accent": "american", "age": "middle_aged"]
    )
    
    public static let allVoices = [matthew, rachel, clyde]
}