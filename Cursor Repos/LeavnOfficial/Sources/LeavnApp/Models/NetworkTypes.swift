import Foundation

// MARK: - API Response Types

public struct ESVResponse: Codable {
    public let query: String
    public let canonical: String
    public let parsed: [[Int]]
    public let passages: [String]
    public let passageMeta: [PassageMeta]
    
    public struct PassageMeta: Codable {
        public let canonical: String
        public let chapterStart: [Int]
        public let chapterEnd: [Int]
        public let prevVerse: Int?
        public let nextVerse: Int?
        public let prevChapter: [Int]?
        public let nextChapter: [Int]?
    }
}

public struct ElevenLabsVoiceResponse: Codable {
    public let voices: [ElevenLabsVoice]
}

public struct ElevenLabsVoice: Codable {
    public let voiceId: String
    public let name: String
    public let samples: [Sample]?
    public let category: String?
    public let labels: [String: String]?
    public let description: String?
    public let previewUrl: String?
    
    public struct Sample: Codable {
        public let sampleId: String
        public let fileName: String
        public let mimeType: String
        public let sizeBytes: Int
        public let hash: String
    }
    
    enum CodingKeys: String, CodingKey {
        case voiceId = "voice_id"
        case name
        case samples
        case category
        case labels
        case description
        case previewUrl = "preview_url"
    }
}

public struct AudioStreamResponse {
    public let audioData: Data
    public let contentType: String
    public let duration: TimeInterval?
}

// MARK: - Request Types

public struct ESVRequest: Codable {
    public let query: String
    public let includePassageReferences: Bool
    public let includeVerseNumbers: Bool
    public let includeFirstVerseNumbers: Bool
    public let includeFootnotes: Bool
    public let includeFootnoteBody: Bool
    public let includeHeadings: Bool
    public let includeShortCopyright: Bool
    public let includeCopyright: Bool
    public let includePassageHorizontalLines: Bool
    public let includeHeadingHorizontalLines: Bool
    public let horizontalLineLength: Int
    public let includeSelahs: Bool
    public let indentUsing: String
    public let indentParagraphs: Int
    public let indentPoetry: Bool
    public let indentPoetryLines: Int
    public let indentDeclares: Int
    public let indentPsalmDoxology: Int
    public let lineLength: Int
    
    public init(
        query: String,
        includePassageReferences: Bool = true,
        includeVerseNumbers: Bool = true,
        includeFirstVerseNumbers: Bool = false,
        includeFootnotes: Bool = true,
        includeFootnoteBody: Bool = true,
        includeHeadings: Bool = true,
        includeShortCopyright: Bool = false,
        includeCopyright: Bool = false,
        includePassageHorizontalLines: Bool = false,
        includeHeadingHorizontalLines: Bool = false,
        horizontalLineLength: Int = 55,
        includeSelahs: Bool = true,
        indentUsing: String = "space",
        indentParagraphs: Int = 2,
        indentPoetry: Bool = true,
        indentPoetryLines: Int = 4,
        indentDeclares: Int = 40,
        indentPsalmDoxology: Int = 30,
        lineLength: Int = 0
    ) {
        self.query = query
        self.includePassageReferences = includePassageReferences
        self.includeVerseNumbers = includeVerseNumbers
        self.includeFirstVerseNumbers = includeFirstVerseNumbers
        self.includeFootnotes = includeFootnotes
        self.includeFootnoteBody = includeFootnoteBody
        self.includeHeadings = includeHeadings
        self.includeShortCopyright = includeShortCopyright
        self.includeCopyright = includeCopyright
        self.includePassageHorizontalLines = includePassageHorizontalLines
        self.includeHeadingHorizontalLines = includeHeadingHorizontalLines
        self.horizontalLineLength = horizontalLineLength
        self.includeSelahs = includeSelahs
        self.indentUsing = indentUsing
        self.indentParagraphs = indentParagraphs
        self.indentPoetry = indentPoetry
        self.indentPoetryLines = indentPoetryLines
        self.indentDeclares = indentDeclares
        self.indentPsalmDoxology = indentPsalmDoxology
        self.lineLength = lineLength
    }
}

public struct ElevenLabsTTSRequest: Codable {
    public let text: String
    public let modelId: String
    public let voiceSettings: VoiceSettings?
    
    public struct VoiceSettings: Codable {
        public let stability: Double
        public let similarityBoost: Double
        public let style: Double?
        public let useSpeakerBoost: Bool?
        
        public init(
            stability: Double = 0.5,
            similarityBoost: Double = 0.5,
            style: Double? = nil,
            useSpeakerBoost: Bool? = nil
        ) {
            self.stability = stability
            self.similarityBoost = similarityBoost
            self.style = style
            self.useSpeakerBoost = useSpeakerBoost
        }
        
        enum CodingKeys: String, CodingKey {
            case stability
            case similarityBoost = "similarity_boost"
            case style
            case useSpeakerBoost = "use_speaker_boost"
        }
    }
    
    public init(
        text: String,
        modelId: String = "eleven_multilingual_v2",
        voiceSettings: VoiceSettings? = nil
    ) {
        self.text = text
        self.modelId = modelId
        self.voiceSettings = voiceSettings
    }
    
    enum CodingKeys: String, CodingKey {
        case text
        case modelId = "model_id"
        case voiceSettings = "voice_settings"
    }
}

// MARK: - Error Types

public enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case networkUnavailable
    case timeout
    case unauthorized
    case rateLimited
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error \(code): \(message ?? "Unknown error")"
        case .networkUnavailable:
            return "Network connection unavailable"
        case .timeout:
            return "Request timed out"
        case .unauthorized:
            return "Unauthorized access"
        case .rateLimited:
            return "Rate limit exceeded"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}