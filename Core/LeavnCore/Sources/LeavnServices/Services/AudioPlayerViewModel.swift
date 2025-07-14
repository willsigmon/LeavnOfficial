import Foundation
import Combine

// MARK: - Audio Player View Model
@MainActor
public final class AudioPlayerViewModel: ObservableObject {
    // Published properties for UI binding
    @Published public private(set) var audioState: AudioPlayerState = AudioPlayerState()
    @Published public private(set) var currentChapter: ChapterInfo?
    @Published public private(set) var isInitializing = false
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var playbackQueue: [ChapterInfo] = []
    @Published public private(set) var currentVerse: Int?
    @Published public private(set) var downloadProgress: Double = 0
    @Published public private(set) var isDownloading = false
    
    // Services
    private let audioService: any AudioService
    private let bibleService: BibleService
    private let voiceConfigService: any VoiceConfigurationService
    private let elevenLabsService: ElevenLabsService
    private let cacheManager: AudioCacheManager
    
    // Cancellables for Combine subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        audioService: any AudioService,
        bibleService: BibleService,
        voiceConfigService: any VoiceConfigurationService,
        elevenLabsService: ElevenLabsService,
        cacheManager: AudioCacheManager
    ) {
        self.audioService = audioService
        self.bibleService = bibleService
        self.voiceConfigService = voiceConfigService
        self.elevenLabsService = elevenLabsService
        self.cacheManager = cacheManager
        
        setupBindings()
    }
    
    // MARK: - Public Methods
    
    /// Load and prepare a Bible chapter for narration
    public func loadChapter(book: String, chapter: Int, translation: String = "ESV") async {
        isInitializing = true
        errorMessage = nil
        
        do {
            // Fetch Bible chapter content
            let bibleChapter = try await bibleService.fetchChapter(
                book: book,
                chapter: chapter,
                translation: translation
            )
            
            // Get appropriate voice for this book
            let voiceId = voiceConfigService.getVoice(for: book)
            let voice = await getVoiceInfo(voiceId: voiceId)
            
            // Create audio chapter
            let audioChapter = createAudioChapter(
                from: bibleChapter,
                voiceId: voiceId,
                voiceName: voice?.name ?? "Unknown"
            )
            
            // Create chapter info for UI
            let chapterInfo = ChapterInfo(
                book: book,
                chapter: chapter,
                narrator: voice?.name ?? "Unknown",
                translation: translation
            )
            
            // Load audio
            try await audioService.loadChapter(audioChapter)
            
            // Update UI state
            currentChapter = chapterInfo
            updateAudioState()
            
        } catch {
            errorMessage = "Failed to load chapter: \(error.localizedDescription)"
            print("Error loading chapter: \(error)")
        }
        
        isInitializing = false
    }
    
    /// Play or pause audio
    public func togglePlayPause() async {
        do {
            if audioService.isPlaying {
                audioService.pause()
            } else {
                try await audioService.play()
            }
            updateAudioState()
        } catch {
            errorMessage = "Playback error: \(error.localizedDescription)"
        }
    }
    
    /// Skip to previous chapter
    public func skipToPrevious() async {
        guard let current = currentChapter else { return }
        
        let previousChapter = max(1, current.chapter - 1)
        if previousChapter != current.chapter {
            await loadChapter(
                book: current.book,
                chapter: previousChapter,
                translation: current.translation
            )
        }
    }
    
    /// Skip to next chapter
    public func skipToNext() async {
        guard let current = currentChapter else { return }
        
        // For simplicity, assume max 150 chapters (covers most books)
        let nextChapter = current.chapter + 1
        await loadChapter(
            book: current.book,
            chapter: nextChapter,
            translation: current.translation
        )
    }
    
    /// Seek to specific time
    public func seek(to time: TimeInterval) {
        audioService.seek(to: time)
        updateAudioState()
    }
    
    /// Change playback speed
    public func changePlaybackSpeed(_ speed: PlaybackSpeed) {
        audioService.setPlaybackSpeed(speed.rawValue)
        updateAudioState()
    }
    
    /// Add chapter to queue
    public func addToQueue(book: String, chapter: Int, translation: String = "ESV") async {
        do {
            let bibleChapter = try await bibleService.fetchChapter(
                book: book,
                chapter: chapter,
                translation: translation
            )
            
            let voiceId = voiceConfigService.getVoice(for: book)
            let voice = await getVoiceInfo(voiceId: voiceId)
            
            let audioChapter = createAudioChapter(
                from: bibleChapter,
                voiceId: voiceId,
                voiceName: voice?.name ?? "Unknown"
            )
            
            let chapterInfo = ChapterInfo(
                book: book,
                chapter: chapter,
                narrator: voice?.name ?? "Unknown",
                translation: translation
            )
            
            audioService.addToQueue(audioChapter)
            playbackQueue.append(chapterInfo)
            
        } catch {
            errorMessage = "Failed to add to queue: \(error.localizedDescription)"
        }
    }
    
    /// Remove chapter from queue
    public func removeFromQueue(at index: Int) {
        guard index >= 0 && index < playbackQueue.count else { return }
        
        audioService.removeFromQueue(at: index)
        playbackQueue.remove(at: index)
    }
    
    /// Clear playback queue
    public func clearQueue() {
        audioService.clearQueue()
        playbackQueue.removeAll()
    }
    
    /// Check if chapter is downloaded
    public func isChapterDownloaded(book: String, chapter: Int, translation: String = "ESV") -> Bool {
        let audioChapter = AudioChapter(
            book: book,
            chapter: chapter,
            translation: translation,
            voiceId: voiceConfigService.getVoice(for: book),
            voiceName: "Unknown",
            verses: []
        )
        
        return cacheManager.isCached(audioChapter)
    }
    
    /// Download chapter for offline use
    public func downloadChapter(book: String, chapter: Int, translation: String = "ESV") async {
        isDownloading = true
        downloadProgress = 0
        
        do {
            let bibleChapter = try await bibleService.fetchChapter(
                book: book,
                chapter: chapter,
                translation: translation
            )
            
            let voiceId = voiceConfigService.getVoice(for: book)
            let voice = await getVoiceInfo(voiceId: voiceId)
            
            let audioChapter = createAudioChapter(
                from: bibleChapter,
                voiceId: voiceId,
                voiceName: voice?.name ?? "Unknown"
            )
            
            // Update progress
            downloadProgress = 0.3
            
            // Load the chapter to generate audio with verse timing
            try await audioService.loadChapter(audioChapter)
            
            // Update progress
            downloadProgress = 0.8
            
            // The audio service will cache it automatically
            downloadProgress = 1.0
            
            // Small delay to show completion
            try await Task.sleep(nanoseconds: 500_000_000)
            
        } catch {
            errorMessage = "Download failed: \(error.localizedDescription)"
        }
        
        isDownloading = false
        downloadProgress = 0
    }
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        // Observe audio service changes
        audioService.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateAudioState()
                self?.updateCurrentVerse()
            }
            .store(in: &cancellables)
        
        // Update verse highlighting based on playback time
        Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateCurrentVerse()
            }
            .store(in: &cancellables)
    }
    
    private func updateAudioState() {
        let currentSpeed = PlaybackSpeed.allCases.first { $0.rawValue == audioService.playbackSpeed } ?? .normal
        
        audioState = AudioPlayerState(
            isPlaying: audioService.isPlaying,
            isLoading: audioService.isLoading,
            currentTime: audioService.currentTime,
            duration: audioService.duration,
            playbackSpeed: currentSpeed,
            isDownloaded: currentChapter.map { isChapterDownloaded(book: $0.book, chapter: $0.chapter, translation: $0.translation) } ?? false
        )
    }
    
    private func createAudioChapter(from bibleChapter: BibleChapter, voiceId: String, voiceName: String) -> AudioChapter {
        let audioVerses = bibleChapter.verses.map { verse in
            AudioVerse(
                verseNumber: verse.verse,
                text: verse.text
            )
        }
        
        return AudioChapter(
            book: bibleChapter.book,
            chapter: bibleChapter.chapter,
            translation: bibleChapter.translation,
            voiceId: voiceId,
            voiceName: voiceName,
            verses: audioVerses
        )
    }
    
    private func getVoiceInfo(voiceId: String) async -> Voice? {
        do {
            let voices = try await elevenLabsService.getAvailableVoices()
            return voices.first { $0.id == voiceId }
        } catch {
            // Fallback to predefined voices
            return DefaultElevenLabsService.biblicalNarratorVoices.first { $0.id == voiceId }
        }
    }
    
    private func updateCurrentVerse() {
        guard let chapter = audioService.currentChapter,
              audioService.isPlaying else {
            return
        }
        
        let currentTime = audioService.currentTime
        
        // Find the current verse based on playback time
        for verse in chapter.verses {
            if let startTime = verse.startTime,
               let endTime = verse.endTime,
               currentTime >= startTime && currentTime < endTime {
                if currentVerse != verse.verseNumber {
                    currentVerse = verse.verseNumber
                }
                break
            }
        }
    }
}

// MARK: - Supporting Models for AudioPlayerView

/// Audio player state for UI binding
public struct AudioPlayerState {
    public let isPlaying: Bool
    public let isLoading: Bool
    public let currentTime: TimeInterval
    public let duration: TimeInterval
    public let playbackSpeed: PlaybackSpeed
    public let isDownloaded: Bool
    
    public var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    public var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }
    
    public init(
        isPlaying: Bool = false,
        isLoading: Bool = false,
        currentTime: TimeInterval = 0,
        duration: TimeInterval = 0,
        playbackSpeed: PlaybackSpeed = .normal,
        isDownloaded: Bool = false
    ) {
        self.isPlaying = isPlaying
        self.isLoading = isLoading
        self.currentTime = currentTime
        self.duration = duration
        self.playbackSpeed = playbackSpeed
        self.isDownloaded = isDownloaded
    }
}

/// Chapter information for UI display
public struct ChapterInfo {
    public let book: String
    public let chapter: Int
    public let narrator: String
    public let translation: String
    
    public init(book: String, chapter: Int, narrator: String, translation: String) {
        self.book = book
        self.chapter = chapter
        self.narrator = narrator
        self.translation = translation
    }
}

/// Playback speed options
public enum PlaybackSpeed: Float, CaseIterable {
    case half = 0.5
    case threeQuarters = 0.75
    case normal = 1.0
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case double = 2.0
    
    public var title: String {
        switch self {
        case .half: return "0.5×"
        case .threeQuarters: return "0.75×"
        case .normal: return "1×"
        case .oneAndQuarter: return "1.25×"
        case .oneAndHalf: return "1.5×"
        case .double: return "2×"
        }
    }
}
