import Foundation
import AVFoundation
import MediaPlayer

#if canImport(UIKit)
import UIKit
#endif

// MARK: - Audio Service Protocol
public protocol AudioService: ObservableObject {
    var isPlaying: Bool { get }
    var isLoading: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var playbackSpeed: Float { get }
    var currentChapter: AudioChapter? { get }
    var playbackQueue: [AudioChapter] { get }
    
    func loadChapter(_ chapter: AudioChapter) async throws
    func play() async throws
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    func setPlaybackSpeed(_ speed: Float)
    func skipToNext() async throws
    func skipToPrevious() async throws
    func addToQueue(_ chapter: AudioChapter)
    func removeFromQueue(at index: Int)
    func clearQueue()
}

// MARK: - Audio Chapter Model
public struct AudioChapter: Identifiable, Codable, Sendable, Sendable, Sendable {
    public let id: String
    public let book: String
    public let chapter: Int
    public let translation: String
    public let voiceId: String
    public let voiceName: String
    public let verses: [AudioVerse]
    public let audioURL: URL?
    public let isDownloaded: Bool
    public let fileSize: Int64?
    public let duration: TimeInterval?
    public let createdAt: Date
    
    public var title: String {
        "\(book) \(chapter)"
    }
    
    public var fullText: String {
        verses.map { $0.text }.joined(separator: " ")
    }
    
    public init(
        id: String = UUID().uuidString,
        book: String,
        chapter: Int,
        translation: String,
        voiceId: String,
        voiceName: String,
        verses: [AudioVerse],
        audioURL: URL? = nil,
        isDownloaded: Bool = false,
        fileSize: Int64? = nil,
        duration: TimeInterval? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.book = book
        self.chapter = chapter
        self.translation = translation
        self.voiceId = voiceId
        self.voiceName = voiceName
        self.verses = verses
        self.audioURL = audioURL
        self.isDownloaded = isDownloaded
        self.fileSize = fileSize
        self.duration = duration
        self.createdAt = createdAt
    }
}

public struct AudioVerse: Identifiable, Codable, Sendable, Sendable, Sendable, Sendable {
    public let id: String
    public let verseNumber: Int
    public let text: String
    public let startTime: TimeInterval?
    public let endTime: TimeInterval?
    
    public init(
        id: String = UUID().uuidString,
        verseNumber: Int,
        text: String,
        startTime: TimeInterval? = nil,
        endTime: TimeInterval? = nil
    ) {
        self.id = id
        self.verseNumber = verseNumber
        self.text = text
        self.startTime = startTime
        self.endTime = endTime
    }
}

// MARK: - Audio Cache Manager
public protocol AudioCacheManager {
    func cacheAudio(_ data: Data, for chapter: AudioChapter) async throws -> URL
    func getCachedAudioURL(for chapter: AudioChapter) -> URL?
    func isCached(_ chapter: AudioChapter) -> Bool
    func removeCachedAudio(for chapter: AudioChapter) throws
    func getCacheSize() -> Int64
    func clearCache() throws
    func getCachedChapters() -> [AudioChapter]
}

public final class DefaultAudioCacheManager: AudioCacheManager {
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private var cachedChapters: [String: AudioChapter] = [:]
    
    public init() throws {
        // Create cache directory in Documents/Audio
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        cacheDirectory = documentsPath.appendingPathComponent("Audio", isDirectory: true)
        
        try fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        loadCachedChapters()
    }
    
    public func cacheAudio(_ data: Data, for chapter: AudioChapter) async throws -> URL {
        let fileName = "\(chapter.id).mp3"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        try data.write(to: fileURL)
        
        // Update chapter with cached info
        var updatedChapter = chapter
        updatedChapter = AudioChapter(
            id: chapter.id,
            book: chapter.book,
            chapter: chapter.chapter,
            translation: chapter.translation,
            voiceId: chapter.voiceId,
            voiceName: chapter.voiceName,
            verses: chapter.verses,
            audioURL: fileURL,
            isDownloaded: true,
            fileSize: Int64(data.count),
            duration: chapter.duration,
            createdAt: chapter.createdAt
        )
        
        cachedChapters[chapter.id] = updatedChapter
        saveCachedChapters()
        
        return fileURL
    }
    
    public func getCachedAudioURL(for chapter: AudioChapter) -> URL? {
        let fileName = "\(chapter.id).mp3"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    public func isCached(_ chapter: AudioChapter) -> Bool {
        return getCachedAudioURL(for: chapter) != nil
    }
    
    public func removeCachedAudio(for chapter: AudioChapter) throws {
        let fileName = "\(chapter.id).mp3"
        let fileURL = cacheDirectory.appendingPathComponent(fileName)
        
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
        
        cachedChapters.removeValue(forKey: chapter.id)
        saveCachedChapters()
    }
    
    public func getCacheSize() -> Int64 {
        let resourceKeys: [URLResourceKey] = [.fileSizeKey]
        var totalSize: Int64 = 0
        
        do {
            let contents = try fileManager.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: resourceKeys
            )
            
            for fileURL in contents {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                totalSize += Int64(resourceValues.fileSize ?? 0)
            }
        } catch {
            print("Error calculating cache size: \(error)")
        }
        
        return totalSize
    }
    
    public func clearCache() throws {
        let contents = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        
        for fileURL in contents {
            try fileManager.removeItem(at: fileURL)
        }
        
        cachedChapters.removeAll()
        saveCachedChapters()
    }
    
    public func getCachedChapters() -> [AudioChapter] {
        return Array(cachedChapters.values).sorted { $0.createdAt > $1.createdAt }
    }
    
    private func loadCachedChapters() {
        let metadataURL = cacheDirectory.appendingPathComponent("metadata.json")
        
        guard fileManager.fileExists(atPath: metadataURL.path),
              let data = try? Data(contentsOf: metadataURL),
              let chapters = try? JSONDecoder().decode([String: AudioChapter].self, from: data) else {
            return
        }
        
        cachedChapters = chapters
    }
    
    private func saveCachedChapters() {
        let metadataURL = cacheDirectory.appendingPathComponent("metadata.json")
        
        do {
            let data = try JSONEncoder().encode(cachedChapters)
            try data.write(to: metadataURL)
        } catch {
            print("Error saving cached chapters metadata: \(error)")
        }
    }
}

// MARK: - Audio Service Implementation
@MainActor
public final class DefaultAudioService: NSObject, AudioService, AVAudioPlayerDelegate {
    @Published public private(set) var isPlaying = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var playbackSpeed: Float = 1.0
    @Published public private(set) var currentChapter: AudioChapter?
    @Published public private(set) var playbackQueue: [AudioChapter] = []
    
    private var audioPlayer: AVAudioPlayer?
    private var timeObserver: Timer?
    private let elevenLabsService: ElevenLabsService
    private let cacheManager: AudioCacheManager
    private let bibleService: BibleService
    
    public init(
        elevenLabsService: ElevenLabsService,
        cacheManager: AudioCacheManager,
        bibleService: BibleService
    ) {
        self.elevenLabsService = elevenLabsService
        self.cacheManager = cacheManager
        self.bibleService = bibleService
        super.init()
        
        setupAudioSession()
        setupRemoteTransportControls()
    }
    
    // MARK: - Public Methods
    public func loadChapter(_ chapter: AudioChapter) async throws {
        isLoading = true
        currentChapter = chapter
        
        defer { isLoading = false }
        
        do {
            // Check if audio is cached
            if let cachedURL = cacheManager.getCachedAudioURL(for: chapter) {
                try await loadAudioFromURL(cachedURL)
                return
            }
            
            // Generate audio if not cached
            let audioData = try await generateChapterAudio(chapter)
            let cachedURL = try await cacheManager.cacheAudio(audioData.data, for: chapter)
            try await loadAudioFromURL(cachedURL)
            
        } catch {
            isLoading = false
            throw error
        }
    }
    
    public func play() async throws {
        guard let player = audioPlayer else {
            throw AudioError.noAudioLoaded
        }
        
        try setupAudioSession()
        
        if player.play() {
            isPlaying = true
            startTimeObserver()
            updateNowPlayingInfo()
        } else {
            throw AudioError.playbackFailed
        }
    }
    
    public func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimeObserver()
        updateNowPlayingInfo()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer?.currentTime = 0
        isPlaying = false
        currentTime = 0
        stopTimeObserver()
        updateNowPlayingInfo()
    }
    
    public func seek(to time: TimeInterval) {
        guard let player = audioPlayer else { return }
        
        player.currentTime = min(max(0, time), player.duration)
        currentTime = player.currentTime
        updateNowPlayingInfo()
    }
    
    public func setPlaybackSpeed(_ speed: Float) {
        audioPlayer?.rate = speed
        playbackSpeed = speed
    }
    
    public func skipToNext() async throws {
        guard !playbackQueue.isEmpty else { return }
        
        let nextChapter = playbackQueue.removeFirst()
        try await loadChapter(nextChapter)
        try await play()
    }
    
    public func skipToPrevious() async throws {
        // Implementation for previous chapter logic
        // Could involve history or navigation logic
    }
    
    public func addToQueue(_ chapter: AudioChapter) {
        playbackQueue.append(chapter)
    }
    
    public func removeFromQueue(at index: Int) {
        guard index >= 0 && index < playbackQueue.count else { return }
        playbackQueue.remove(at: index)
    }
    
    public func clearQueue() {
        playbackQueue.removeAll()
    }
    
    // MARK: - Private Methods
    private func generateChapterAudio(_ chapter: AudioChapter) async throws -> AudioData {
        // Generate audio verse by verse for better control and timing
        var versesAudioData: [(verse: AudioVerse, data: Data, duration: TimeInterval)] = []
        
        // Process verses in batches for efficiency
        let batchSize = 5
        for i in stride(from: 0, to: chapter.verses.count, by: batchSize) {
            let endIndex = min(i + batchSize, chapter.verses.count)
            let verseBatch = Array(chapter.verses[i..<endIndex])
            
            // Generate audio for each verse in parallel
            let audioResults = try await withThrowingTaskGroup(of: (AudioVerse, Data, TimeInterval).self) { group in
                for verse in verseBatch {
                    group.addTask {
                        let verseText = "\(verse.verseNumber). \(verse.text)"
                        let audioData = try await self.elevenLabsService.synthesizeText(
                            verseText,
                            voiceId: chapter.voiceId,
                            settings: VoiceSettings(
                                stability: 0.6,
                                similarity_boost: 0.8,
                                style: 0.5 // Slightly more expressive for Bible narration
                            )
                        )
                        return (verse, audioData.data, audioData.duration ?? 0)
                    }
                }
                
                var results: [(AudioVerse, Data, TimeInterval)] = []
                for try await result in group {
                    results.append(result)
                }
                return results
            }
            
            versesAudioData.append(contentsOf: audioResults)
        }
        
        // Sort by verse number to maintain order
        versesAudioData.sort { $0.verse.verseNumber < $1.verse.verseNumber }
        
        // Update verse timing information
        var currentTime: TimeInterval = 0
        var updatedVerses: [AudioVerse] = []
        
        for (verse, _, duration) in versesAudioData {
            let updatedVerse = AudioVerse(
                id: verse.id,
                verseNumber: verse.verseNumber,
                text: verse.text,
                startTime: currentTime,
                endTime: currentTime + duration
            )
            updatedVerses.append(updatedVerse)
            currentTime += duration + 0.5 // Add small pause between verses
        }
        
        // Update chapter with timing info
        var updatedChapter = chapter
        updatedChapter = AudioChapter(
            id: chapter.id,
            book: chapter.book,
            chapter: chapter.chapter,
            translation: chapter.translation,
            voiceId: chapter.voiceId,
            voiceName: chapter.voiceName,
            verses: updatedVerses,
            audioURL: chapter.audioURL,
            isDownloaded: chapter.isDownloaded,
            fileSize: chapter.fileSize,
            duration: currentTime,
            createdAt: chapter.createdAt
        )
        
        // Store the updated chapter
        currentChapter = updatedChapter
        
        // Combine audio data with proper silence between verses
        let combinedData = combineAudioDataWithSilence(
            versesAudioData.map { $0.data },
            silenceDuration: 0.5
        )
        
        return AudioData(
            data: combinedData,
            format: .mp3,
            duration: currentTime
        )
    }
    
    private func splitTextIntoChunks(_ text: String, maxLength: Int) -> [String] {
        guard text.count > maxLength else { return [text] }
        
        var chunks: [String] = []
        var currentIndex = text.startIndex
        
        while currentIndex < text.endIndex {
            let endIndex = text.index(currentIndex, offsetBy: maxLength, limitedBy: text.endIndex) ?? text.endIndex
            
            // Try to break at sentence boundary
            var breakIndex = endIndex
            if endIndex < text.endIndex {
                if let lastPeriod = text[currentIndex..<endIndex].lastIndex(of: ".") {
                    breakIndex = text.index(after: lastPeriod)
                } else if let lastSpace = text[currentIndex..<endIndex].lastIndex(of: " ") {
                    breakIndex = lastSpace
                }
            }
            
            chunks.append(String(text[currentIndex..<breakIndex]))
            currentIndex = breakIndex
        }
        
        return chunks
    }
    
    private func combineAudioData(_ chunks: [Data]) -> Data {
        // Simple concatenation - in production, proper audio splicing would be needed
        var combinedData = Data()
        for chunk in chunks {
            combinedData.append(chunk)
        }
        return combinedData
    }
    
    private func combineAudioDataWithSilence(_ chunks: [Data], silenceDuration: TimeInterval) -> Data {
        // Create silent audio data for pauses between verses
        let silenceData = createSilenceData(duration: silenceDuration)
        
        var combinedData = Data()
        for (index, chunk) in chunks.enumerated() {
            combinedData.append(chunk)
            
            // Add silence between verses (not after the last one)
            if index < chunks.count - 1 {
                combinedData.append(silenceData)
            }
        }
        
        return combinedData
    }
    
    private func createSilenceData(duration: TimeInterval) -> Data {
        // Create MP3-compatible silence
        // For a simple implementation, we'll use a minimal silent MP3 frame
        // In production, use proper audio libraries to generate silence
        let silentMP3Frame = Data([
            0xFF, 0xFB, 0x90, 0x00, // MP3 header
            0x00, 0x00, 0x00, 0x00  // Silent data
        ])
        
        // Repeat the frame to approximate the desired duration
        // MP3 frame duration at 44.1kHz is roughly 26ms
        let frameCount = Int(duration * 38.5) // ~38.5 frames per second
        var silenceData = Data()
        
        for _ in 0..<frameCount {
            silenceData.append(silentMP3Frame)
        }
        
        return silenceData
    }
    
    private func loadAudioFromURL(_ url: URL) async throws {
        let data = try Data(contentsOf: url)
        audioPlayer = try AVAudioPlayer(data: data)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        
        duration = audioPlayer?.duration ?? 0
        currentTime = 0
    }
    
    private func setupAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.AVAudioSession.CategoryOptions.allowBluetoothHFP, .allowAirPlay])
        try audioSession.setActive(true)
        
        // Enable background audio on iOS
        #if canImport(UIKit)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        #endif
    }
    
    private func startTimeObserver() {
        timeObserver = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.audioPlayer else { return }
            self.currentTime = player.currentTime
        }
    }
    
    private func stopTimeObserver() {
        timeObserver?.invalidate()
        timeObserver = nil
    }
    
    // MARK: - Remote Control
    private func setupRemoteTransportControls() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                try? await self?.play()
            }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] event in
            guard let self = self,
                  let skipEvent = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            
            let newTime = self.currentTime + skipEvent.interval
            self.seek(to: newTime)
            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] event in
            guard let self = self,
                  let skipEvent = event as? MPSkipIntervalCommandEvent else { return .commandFailed }
            
            let newTime = self.currentTime - skipEvent.interval
            self.seek(to: newTime)
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let self = self,
                  let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            
            self.seek(to: positionEvent.positionTime)
            return .success
        }
    }
    
    private func updateNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        
        if let chapter = currentChapter {
            nowPlayingInfo[MPMediaItemPropertyTitle] = chapter.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = chapter.voiceName
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = chapter.translation
        }
        
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = duration
        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? playbackSpeed : 0
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    // MARK: - AVAudioPlayerDelegate
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlaying = false
        stopTimeObserver()
        
        // Auto-play next chapter if available
        if !playbackQueue.isEmpty {
            Task {
                try? await skipToNext()
            }
        }
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlaying = false
        stopTimeObserver()
        print("Audio decode error: \(error?.localizedDescription ?? "Unknown error")")
    }
}

// MARK: - Audio Errors
public enum AudioError: LocalizedError {
    case noAudioLoaded
    case playbackFailed
    case audioSessionSetupFailed
    case fileNotFound
    case unsupportedFormat
    
    public var errorDescription: String? {
        switch self {
        case .noAudioLoaded:
            return "No audio file is currently loaded"
        case .playbackFailed:
            return "Failed to start audio playback"
        case .audioSessionSetupFailed:
            return "Failed to setup audio session"
        case .fileNotFound:
            return "Audio file not found"
        case .unsupportedFormat:
            return "Unsupported audio format"
        }
    }
}
