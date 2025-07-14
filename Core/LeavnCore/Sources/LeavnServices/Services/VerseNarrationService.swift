import Foundation
import Combine
import LeavnCore

// MARK: - Verse Narration Service Protocol
public protocol VerseNarrationService: ObservableObject {
    var currentVerse: AudioVerse? { get }
    var allVerses: [AudioVerse] { get }
    var currentVerseIndex: Int { get }
    var isNarrationMode: Bool { get }
    var verseTimings: [VerseTimingInfo] { get }
    
    func loadVerseNarration(for chapter: AudioChapter) async throws
    func playVerse(at index: Int) async throws
    func playNextVerse() async throws
    func playPreviousVerse() async throws
    func setNarrationMode(_ enabled: Bool)
    func updateVerseTimings(_ timings: [VerseTimingInfo])
    func getCurrentVerseAt(time: TimeInterval) -> AudioVerse?
}

// MARK: - Verse Timing Information
public struct VerseTimingInfo: Codable, Identifiable {
    public let id: String
    public let verseNumber: Int
    public let startTime: TimeInterval
    public let endTime: TimeInterval
    public let text: String
    
    public var duration: TimeInterval {
        endTime - startTime
    }
    
    public init(
        id: String = UUID().uuidString,
        verseNumber: Int,
        startTime: TimeInterval,
        endTime: TimeInterval,
        text: String
    ) {
        self.id = id
        self.verseNumber = verseNumber
        self.startTime = startTime
        self.endTime = endTime
        self.text = text
    }
    
    public func contains(time: TimeInterval) -> Bool {
        return time >= startTime && time < endTime
    }
}

// MARK: - Narration Configuration
public struct NarrationConfiguration: Codable {
    public let pauseBetweenVerses: TimeInterval
    public let verseNumberAnnouncement: Bool
    public let highlightCurrentVerse: Bool
    public let autoScrollToVerse: Bool
    public let repeatVerse: Bool
    public let verseRepeatCount: Int
    
    public init(
        pauseBetweenVerses: TimeInterval = 1.0,
        verseNumberAnnouncement: Bool = false,
        highlightCurrentVerse: Bool = true,
        autoScrollToVerse: Bool = true,
        repeatVerse: Bool = false,
        verseRepeatCount: Int = 1
    ) {
        self.pauseBetweenVerses = pauseBetweenVerses
        self.verseNumberAnnouncement = verseNumberAnnouncement
        self.highlightCurrentVerse = highlightCurrentVerse
        self.autoScrollToVerse = autoScrollToVerse
        self.repeatVerse = repeatVerse
        self.verseRepeatCount = verseRepeatCount
    }
    
    public static let `default` = NarrationConfiguration()
}

// MARK: - Verse Narration Event
public enum VerseNarrationEvent {
    case verseStarted(AudioVerse)
    case verseCompleted(AudioVerse)
    case chapterCompleted([AudioVerse])
    case narrationPaused(AudioVerse?)
    case narrationResumed(AudioVerse?)
    case timingUpdated(VerseTimingInfo)
}

// MARK: - Verse Narration Service Implementation
@MainActor
public final class DefaultVerseNarrationService: ObservableObject, VerseNarrationService {
    @Published public private(set) var currentVerse: AudioVerse?
    @Published public private(set) var allVerses: [AudioVerse] = []
    @Published public private(set) var currentVerseIndex: Int = 0
    @Published public private(set) var isNarrationMode: Bool = false
    @Published public private(set) var verseTimings: [VerseTimingInfo] = []
    
    // Configuration
    @Published public var configuration: NarrationConfiguration = .default
    
    // Events
    public let narrationEvents = PassthroughSubject<VerseNarrationEvent, Never>()
    
    private let audioService: AudioService
    private let elevenLabsService: ElevenLabsService
    private let voiceConfigService: VoiceConfigurationService
    
    // Timing tracking
    private var timingTracker: VerseTimingTracker?
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        audioService: AudioService,
        elevenLabsService: ElevenLabsService,
        voiceConfigService: VoiceConfigurationService
    ) {
        self.audioService = audioService
        self.elevenLabsService = elevenLabsService
        self.voiceConfigService = voiceConfigService
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    public func loadVerseNarration(for chapter: AudioChapter) async throws {
        allVerses = chapter.verses
        currentVerseIndex = 0
        currentVerse = allVerses.first
        
        // Initialize verse timings if not provided
        if verseTimings.isEmpty {
            verseTimings = await estimateVerseTimings(for: chapter.verses, voiceId: chapter.voiceId)
        }
        
        // Create timing tracker
        timingTracker = VerseTimingTracker(timings: verseTimings)
        
        narrationEvents.send(.verseStarted(currentVerse!))
    }
    
    public func playVerse(at index: Int) async throws {
        guard index >= 0 && index < allVerses.count else {
            throw VerseNarrationError.invalidVerseIndex
        }
        
        currentVerseIndex = index
        currentVerse = allVerses[index]
        
        if isNarrationMode {
            // In narration mode, seek to verse start time
            if let timing = verseTimings.first(where: { $0.verseNumber == currentVerse!.verseNumber }) {
                audioService.seek(to: timing.startTime)
            }
        } else {
            // Generate and play individual verse audio
            try await generateAndPlayVerse(currentVerse!)
        }
        
        narrationEvents.send(.verseStarted(currentVerse!))
    }
    
    public func playNextVerse() async throws {
        let nextIndex = currentVerseIndex + 1
        
        if nextIndex < allVerses.count {
            try await playVerse(at: nextIndex)
        } else {
            // Chapter completed
            narrationEvents.send(.chapterCompleted(allVerses))
        }
    }
    
    public func playPreviousVerse() async throws {
        let previousIndex = currentVerseIndex - 1
        
        if previousIndex >= 0 {
            try await playVerse(at: previousIndex)
        }
    }
    
    public func setNarrationMode(_ enabled: Bool) {
        isNarrationMode = enabled
        
        if enabled {
            // Start tracking verse timings
            startTimingTracking()
        } else {
            // Stop tracking
            stopTimingTracking()
        }
    }
    
    public func updateVerseTimings(_ timings: [VerseTimingInfo]) {
        verseTimings = timings
        timingTracker = VerseTimingTracker(timings: timings)
    }
    
    public func getCurrentVerseAt(time: TimeInterval) -> AudioVerse? {
        guard let timing = verseTimings.first(where: { $0.contains(time: time) }) else {
            return nil
        }
        
        return allVerses.first { $0.verseNumber == timing.verseNumber }
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Listen for audio service time updates
        audioService.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCurrentVerseFromTime()
            }
            .store(in: &cancellables)
    }
    
    private func updateCurrentVerseFromTime() {
        guard isNarrationMode else { return }
        
        let currentTime = audioService.currentTime
        
        // Check if we've moved to a different verse
        if let newVerse = getCurrentVerseAt(time: currentTime),
           newVerse.id != currentVerse?.id {
            
            // Update current verse
            let previousVerse = currentVerse
            currentVerse = newVerse
            
            if let index = allVerses.firstIndex(where: { $0.id == newVerse.id }) {
                currentVerseIndex = index
            }
            
            // Send events
            if let previous = previousVerse {
                narrationEvents.send(.verseCompleted(previous))
            }
            narrationEvents.send(.verseStarted(newVerse))
        }
    }
    
    private func generateAndPlayVerse(_ verse: AudioVerse) async throws {
        // Get appropriate voice for the verse
        guard let chapter = audioService.currentChapter else {
            throw VerseNarrationError.noChapterLoaded
        }
        
        let voiceId = voiceConfigService.getVoice(for: chapter.book)
        
        // Generate audio for individual verse
        let audioData = try await elevenLabsService.synthesizeText(
            verse.text,
            voiceId: voiceId,
            settings: VoiceSettings(stability: 0.6, similarity_boost: 0.8)
        )
        
        // Create temporary audio chapter for single verse
        let verseChapter = AudioChapter(
            book: chapter.book,
            chapter: chapter.chapter,
            translation: chapter.translation,
            voiceId: voiceId,
            voiceName: chapter.voiceName,
            verses: [verse]
        )
        
        try await audioService.loadChapter(verseChapter)
        try await audioService.play()
    }
    
    private func estimateVerseTimings(for verses: [AudioVerse], voiceId: String) async -> [VerseTimingInfo] {
        var timings: [VerseTimingInfo] = []
        var currentTime: TimeInterval = 0
        
        for verse in verses {
            let estimatedDuration = estimateVerseDuration(verse.text)
            let startTime = currentTime
            let endTime = currentTime + estimatedDuration
            
            let timing = VerseTimingInfo(
                verseNumber: verse.verseNumber,
                startTime: startTime,
                endTime: endTime,
                text: verse.text
            )
            
            timings.append(timing)
            currentTime = endTime + configuration.pauseBetweenVerses
        }
        
        return timings
    }
    
    private func estimateVerseDuration(_ text: String) -> TimeInterval {
        // Estimate based on word count and average speaking rate
        let words = text.split(separator: " ").count
        let wordsPerMinute: Double = 150 // Average speaking rate
        let minutes = Double(words) / wordsPerMinute
        return minutes * 60
    }
    
    private func startTimingTracking() {
        // Implementation for tracking actual verse timings during playback
        // This would help improve timing accuracy over time
    }
    
    private func stopTimingTracking() {
        // Stop timing tracking
    }
}

// MARK: - Verse Timing Tracker
private class VerseTimingTracker {
    private let timings: [VerseTimingInfo]
    
    init(timings: [VerseTimingInfo]) {
        self.timings = timings
    }
    
    func getVerseAt(time: TimeInterval) -> VerseTimingInfo? {
        return timings.first { $0.contains(time: time) }
    }
    
    func getProgress(for verseNumber: Int, at time: TimeInterval) -> Double {
        guard let timing = timings.first(where: { $0.verseNumber == verseNumber }),
              timing.contains(time: time) else {
            return 0
        }
        
        let progress = (time - timing.startTime) / timing.duration
        return max(0, min(1, progress))
    }
}

// MARK: - Verse Narration Errors
public enum VerseNarrationError: LocalizedError {
    case invalidVerseIndex
    case noChapterLoaded
    case noVersesAvailable
    case timingGenerationFailed
    
    public var errorDescription: String? {
        switch self {
        case .invalidVerseIndex:
            return "Invalid verse index"
        case .noChapterLoaded:
            return "No chapter is currently loaded"
        case .noVersesAvailable:
            return "No verses available for narration"
        case .timingGenerationFailed:
            return "Failed to generate verse timings"
        }
    }
}

// MARK: - Verse Narration Extensions
public extension DefaultVerseNarrationService {
    /// Generate enhanced verse timings using ElevenLabs for more accuracy
    func generatePreciseTimings(for verses: [AudioVerse], voiceId: String) async throws -> [VerseTimingInfo] {
        var timings: [VerseTimingInfo] = []
        var currentTime: TimeInterval = 0
        
        for verse in verses {
            // Generate actual audio to get precise timing
            let audioData = try await elevenLabsService.synthesizeText(
                verse.text,
                voiceId: voiceId,
                settings: VoiceSettings(stability: 0.6, similarity_boost: 0.8)
            )
            
            let actualDuration = audioData.duration ?? estimateVerseDuration(verse.text)
            let startTime = currentTime
            let endTime = currentTime + actualDuration
            
            let timing = VerseTimingInfo(
                verseNumber: verse.verseNumber,
                startTime: startTime,
                endTime: endTime,
                text: verse.text
            )
            
            timings.append(timing)
            currentTime = endTime + configuration.pauseBetweenVerses
        }
        
        return timings
    }
    
    /// Export verse timings for caching
    func exportTimings() -> Data? {
        return try? JSONEncoder().encode(verseTimings)
    }
    
    /// Import verse timings from cache
    func importTimings(_ data: Data) throws {
        verseTimings = try JSONDecoder().decode([VerseTimingInfo].self, from: data)
        timingTracker = VerseTimingTracker(timings: verseTimings)
    }
}