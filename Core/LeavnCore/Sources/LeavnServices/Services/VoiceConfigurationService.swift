import Foundation
import Combine
import LeavnCore

// MARK: - Voice Configuration Service Protocol
public protocol VoiceConfigurationService: ObservableObject {
    var selectedVoices: [String: String] { get } // Book -> VoiceID mapping
    var userPreferences: VoicePreferences { get }
    var availableVoices: [Voice] { get }
    
    func setVoice(_ voiceId: String, for book: String)
    func getVoice(for book: String) -> String
    func resetToDefaults()
    func updatePreferences(_ preferences: VoicePreferences)
    func loadVoices() async
    func previewVoice(_ voiceId: String, text: String) async throws
}

// MARK: - Voice Preferences
public struct VoicePreferences: Codable {
    public var autoSelectByGenre: Bool
    public var defaultMaleVoice: String
    public var defaultFemaleVoice: String
    public var playbackSpeed: Float
    public var useBackgroundPlayback: Bool
    public var downloadQuality: AudioQuality
    public var autoDownload: Bool
    public var maxCacheSize: Int64 // In bytes
    
    public enum AudioQuality: String, Codable, CaseIterable {
        case standard = "mp3_44100_128"
        case high = "mp3_44100_192"
        case premium = "mp3_44100_320"
        
        public var displayName: String {
            switch self {
            case .standard: return "Standard (128 kbps)"
            case .high: return "High (192 kbps)"
            case .premium: return "Premium (320 kbps)"
            }
        }
        
        public var elevenLabsFormat: String {
            return self.rawValue
        }
    }
    
    public init(
        autoSelectByGenre: Bool = true,
        defaultMaleVoice: String = "ErXwobaYiN019PkySvjV", // Antoni
        defaultFemaleVoice: String = "21m00Tcm4TlvDq8ikWAM", // Rachel
        playbackSpeed: Float = 1.0,
        useBackgroundPlayback: Bool = true,
        downloadQuality: AudioQuality = .standard,
        autoDownload: Bool = false,
        maxCacheSize: Int64 = 2_000_000_000 // 2GB
    ) {
        self.autoSelectByGenre = autoSelectByGenre
        self.defaultMaleVoice = defaultMaleVoice
        self.defaultFemaleVoice = defaultFemaleVoice
        self.playbackSpeed = playbackSpeed
        self.useBackgroundPlayback = useBackgroundPlayback
        self.downloadQuality = downloadQuality
        self.autoDownload = autoDownload
        self.maxCacheSize = maxCacheSize
    }
}

// MARK: - Book Voice Configuration
public struct BookVoiceConfiguration: Codable {
    public let book: String
    public let preferredVoiceId: String
    public let alternativeVoiceIds: [String]
    public let lastUsed: Date
    public let userSelected: Bool // True if manually selected, false if auto-assigned
    
    public init(
        book: String,
        preferredVoiceId: String,
        alternativeVoiceIds: [String] = [],
        lastUsed: Date = Date(),
        userSelected: Bool = false
    ) {
        self.book = book
        self.preferredVoiceId = preferredVoiceId
        self.alternativeVoiceIds = alternativeVoiceIds
        self.lastUsed = lastUsed
        self.userSelected = userSelected
    }
}

// MARK: - Voice Configuration Service Implementation
@MainActor
public final class DefaultVoiceConfigurationService: ObservableObject, VoiceConfigurationService {
    @Published public private(set) var selectedVoices: [String: String] = [:]
    @Published public var userPreferences: VoicePreferences
    @Published public private(set) var availableVoices: [Voice] = []
    
    private let elevenLabsService: ElevenLabsService
    private let userDefaults = UserDefaults.standard
    private let preferencesKey = "VoicePreferences"
    private let voiceConfigKey = "BookVoiceConfigurations"
    
    private var bookConfigurations: [String: BookVoiceConfiguration] = [:]
    
    public init(elevenLabsService: ElevenLabsService) {
        self.elevenLabsService = elevenLabsService
        self.userPreferences = VoicePreferences()
        
        loadPreferences()
        loadVoiceConfigurations()
        setupDefaultVoices()
    }
    
    // MARK: - Public Methods
    public func setVoice(_ voiceId: String, for book: String) {
        selectedVoices[book] = voiceId
        
        // Update or create book configuration
        let configuration = BookVoiceConfiguration(
            book: book,
            preferredVoiceId: voiceId,
            alternativeVoiceIds: bookConfigurations[book]?.alternativeVoiceIds ?? [],
            lastUsed: Date(),
            userSelected: true
        )
        
        bookConfigurations[book] = configuration
        saveVoiceConfigurations()
    }
    
    public func getVoice(for book: String) -> String {
        // First check if user has manually selected a voice
        if let voiceId = selectedVoices[book] {
            return voiceId
        }
        
        // Check saved configurations
        if let configuration = bookConfigurations[book] {
            selectedVoices[book] = configuration.preferredVoiceId
            return configuration.preferredVoiceId
        }
        
        // Auto-select based on genre if enabled
        if userPreferences.autoSelectByGenre {
            let voiceId = autoSelectVoice(for: book)
            selectedVoices[book] = voiceId
            return voiceId
        }
        
        // Fallback to default male voice
        let voiceId = userPreferences.defaultMaleVoice
        selectedVoices[book] = voiceId
        return voiceId
    }
    
    public func resetToDefaults() {
        selectedVoices.removeAll()
        bookConfigurations.removeAll()
        userPreferences = VoicePreferences()
        
        setupDefaultVoices()
        savePreferences()
        saveVoiceConfigurations()
    }
    
    public func updatePreferences(_ preferences: VoicePreferences) {
        userPreferences = preferences
        savePreferences()
        
        // Re-evaluate auto-selected voices if genre selection changed
        if preferences.autoSelectByGenre {
            refreshAutoSelectedVoices()
        }
    }
    
    public func loadVoices() async {
        do {
            availableVoices = try await elevenLabsService.getAvailableVoices()
        } catch {
            print("Failed to load available voices: \(error)")
            // Fallback to predefined biblical voices
            availableVoices = DefaultElevenLabsService.biblicalNarratorVoices
        }
    }
    
    public func previewVoice(_ voiceId: String, text: String = "The Lord is my shepherd; I shall not want.") async throws {
        let audioData = try await elevenLabsService.synthesizeText(
            text,
            voiceId: voiceId,
            settings: VoiceSettings(stability: 0.6, similarity_boost: 0.8)
        )
        
        // Play preview audio
        try await playPreviewAudio(audioData.data)
    }
    
    // MARK: - Private Methods
    private func autoSelectVoice(for book: String) -> String {
        let category = BibleVoiceCategory.category(for: book)
        let recommendedVoices = category.recommendedVoices
        
        // Find first available recommended voice
        for voiceId in recommendedVoices {
            if availableVoices.contains(where: { $0.id == voiceId }) {
                return voiceId
            }
        }
        
        // Fallback to default based on book characteristics
        switch category {
        case .wisdom, .psalms:
            return userPreferences.defaultFemaleVoice
        default:
            return userPreferences.defaultMaleVoice
        }
    }
    
    private func setupDefaultVoices() {
        // Set up intelligent defaults based on biblical book categories
        let bibleBooks = [
            // Old Testament
            "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
            "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
            "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
            "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
            "Ecclesiastes", "Song of Songs", "Isaiah", "Jeremiah",
            "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel",
            "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
            "Zephaniah", "Haggai", "Zechariah", "Malachi",
            
            // New Testament
            "Matthew", "Mark", "Luke", "John", "Acts", "Romans",
            "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
            "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
            "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews",
            "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
            "Jude", "Revelation"
        ]
        
        for book in bibleBooks {
            if selectedVoices[book] == nil && bookConfigurations[book] == nil {
                let voiceId = autoSelectVoice(for: book)
                
                let configuration = BookVoiceConfiguration(
                    book: book,
                    preferredVoiceId: voiceId,
                    alternativeVoiceIds: [],
                    userSelected: false
                )
                
                bookConfigurations[book] = configuration
            }
        }
        
        saveVoiceConfigurations()
    }
    
    private func refreshAutoSelectedVoices() {
        for (book, configuration) in bookConfigurations {
            // Only refresh auto-selected voices, not user-selected ones
            if !configuration.userSelected {
                let newVoiceId = autoSelectVoice(for: book)
                
                let updatedConfiguration = BookVoiceConfiguration(
                    book: book,
                    preferredVoiceId: newVoiceId,
                    alternativeVoiceIds: configuration.alternativeVoiceIds,
                    lastUsed: configuration.lastUsed,
                    userSelected: false
                )
                
                bookConfigurations[book] = updatedConfiguration
                selectedVoices[book] = newVoiceId
            }
        }
        
        saveVoiceConfigurations()
    }
    
    private func loadPreferences() {
        guard let data = userDefaults.data(forKey: preferencesKey),
              let preferences = try? JSONDecoder().decode(VoicePreferences.self, from: data) else {
            return
        }
        
        userPreferences = preferences
    }
    
    private func savePreferences() {
        guard let data = try? JSONEncoder().encode(userPreferences) else { return }
        userDefaults.set(data, forKey: preferencesKey)
    }
    
    private func loadVoiceConfigurations() {
        guard let data = userDefaults.data(forKey: voiceConfigKey),
              let configurations = try? JSONDecoder().decode([String: BookVoiceConfiguration].self, from: data) else {
            return
        }
        
        bookConfigurations = configurations
        
        // Populate selectedVoices from configurations
        for (book, configuration) in configurations {
            selectedVoices[book] = configuration.preferredVoiceId
        }
    }
    
    private func saveVoiceConfigurations() {
        guard let data = try? JSONEncoder().encode(bookConfigurations) else { return }
        userDefaults.set(data, forKey: voiceConfigKey)
    }
    
    private func playPreviewAudio(_ audioData: Data) async throws {
        // Create temporary file for preview
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("voice_preview_\(UUID().uuidString).mp3")
        
        try audioData.write(to: tempURL)
        
        // Play using AVAudioPlayer
        let audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        
        // Clean up after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            try? FileManager.default.removeItem(at: tempURL)
        }
    }
}

// MARK: - Voice Recommendation Engine
public struct VoiceRecommendationEngine {
    private let elevenLabsService: ElevenLabsService
    
    public init(elevenLabsService: ElevenLabsService) {
        self.elevenLabsService = elevenLabsService
    }
    
    public func recommendVoices(for book: String, userPreferences: VoicePreferences) async -> [Voice] {
        let category = BibleVoiceCategory.category(for: book)
        let recommendedIds = category.recommendedVoices
        
        do {
            let availableVoices = try await elevenLabsService.getAvailableVoices()
            
            return availableVoices.filter { voice in
                recommendedIds.contains(voice.id)
            }.sorted { voice1, voice2 in
                // Prioritize based on recommendation order
                guard let index1 = recommendedIds.firstIndex(of: voice1.id),
                      let index2 = recommendedIds.firstIndex(of: voice2.id) else {
                    return false
                }
                return index1 < index2
            }
        } catch {
            // Fallback to predefined voices
            return DefaultElevenLabsService.biblicalNarratorVoices.filter { voice in
                recommendedIds.contains(voice.id)
            }
        }
    }
    
    public func getVoiceCharacteristics(for voiceId: String) -> VoiceCharacteristics? {
        let voiceCharacteristics: [String: VoiceCharacteristics] = [
            "21m00Tcm4TlvDq8ikWAM": VoiceCharacteristics( // Rachel
                gender: .female,
                tone: .calm,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.wisdom, .psalms, .epistles]
            ),
            "ErXwobaYiN019PkySvjV": VoiceCharacteristics( // Antoni
                gender: .male,
                tone: .authoritative,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.oldTestamentNarrative, .prophecy, .apocalyptic]
            ),
            "onwK4e9ZLuTAKqWW03F9": VoiceCharacteristics( // Daniel
                gender: .male,
                tone: .warm,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.gospels, .epistles]
            ),
            "EXAVITQu4vr4xnSDxMaL": VoiceCharacteristics( // Bella
                gender: .female,
                tone: .gentle,
                pace: .slow,
                clarity: .high,
                suitableFor: [.wisdom, .psalms]
            ),
            "VR6AewLTigWG4xSOukaG": VoiceCharacteristics( // Arnold
                gender: .male,
                tone: .commanding,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.law, .prophecy, .apocalyptic]
            ),
            "pNInz6obpgDQGcFmaJgB": VoiceCharacteristics( // Adam
                gender: .male,
                tone: .professional,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.epistles, .gospels, .law]
            ),
            "IKne3meq5aSn9XLyUdCD": VoiceCharacteristics( // Charlie
                gender: .male,
                tone: .friendly,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.psalms, .wisdom]
            ),
            "AZnzlk1XvdvUeBnXmlld": VoiceCharacteristics( // Domi
                gender: .female,
                tone: .confident,
                pace: .moderate,
                clarity: .high,
                suitableFor: [.oldTestamentNarrative, .epistles]
            )
        ]
        
        return voiceCharacteristics[voiceId]
    }
}

public struct VoiceCharacteristics {
    public let gender: Gender
    public let tone: Tone
    public let pace: Pace
    public let clarity: Clarity
    public let suitableFor: [BibleVoiceCategory]
    
    public enum Gender {
        case male, female, neutral
    }
    
    public enum Tone {
        case authoritative, warm, gentle, calm, commanding, professional, friendly, confident
    }
    
    public enum Pace {
        case slow, moderate, fast
    }
    
    public enum Clarity {
        case low, medium, high
    }
    
    public init(gender: Gender, tone: Tone, pace: Pace, clarity: Clarity, suitableFor: [BibleVoiceCategory]) {
        self.gender = gender
        self.tone = tone
        self.pace = pace
        self.clarity = clarity
        self.suitableFor = suitableFor
    }
}