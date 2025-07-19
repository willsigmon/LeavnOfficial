import Foundation
import AVFoundation
import Dependencies
import Combine
import MediaPlayer

// MARK: - Enhanced Audio Service
@MainActor
public final class EnhancedAudioService: NSObject {
    // Audio player
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var timeObserver: Any?
    
    // Audio session
    private let audioSession = AVAudioSession.sharedInstance()
    
    // Published properties
    @Published public private(set) var playbackState: PlaybackState = .stopped
    @Published public private(set) var currentTime: TimeInterval = 0
    @Published public private(set) var duration: TimeInterval = 0
    @Published public private(set) var isBuffering = false
    @Published public private(set) var currentPassage: BibleReference?
    @Published public private(set) var playbackSpeed: Float = 1.0
    
    // Audio cache
    private let cacheManager = AudioCacheManager()
    
    // Sleep timer
    private var sleepTimer: Timer?
    private var sleepTimerEndTime: Date?
    
    // Playback queue
    private var playbackQueue: [AudioQueueItem] = []
    private var currentQueueIndex = 0
    
    // Now Playing Info
    private let nowPlayingInfo = MPNowPlayingInfoCenter.default()
    
    public override init() {
        super.init()
        setupAudioSession()
        setupNotifications()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Public Methods
    
    public func playPassage(_ reference: BibleReference, voice: String = "Rachel") async throws {
        // Stop current playback
        await stop()
        
        currentPassage = reference
        
        // Check cache first
        if let cachedURL = await cacheManager.getCachedAudio(for: reference, voice: voice) {
            try await playFromURL(cachedURL)
        } else {
            // Generate audio using ElevenLabs
            @Dependency(\.elevenLabsClient) var elevenLabs
            @Dependency(\.bibleService) var bibleService
            
            // Set state to buffering
            isBuffering = true
            
            // Fetch passage text
            let passage = try await bibleService.fetchPassage(reference)
            
            // Get voice ID
            let voices = try await elevenLabs.getVoices()
            guard let voiceInfo = voices.first(where: { $0.name == voice }) else {
                throw AudioError.voiceNotFound(voice)
            }
            
            // Generate audio with streaming
            let audioStream = try await elevenLabs.streamTextToSpeech(passage.text, voiceInfo.id)
            
            // Create temporary file for streaming
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("mp3")
            
            // Stream audio to file
            var audioData = Data()
            for try await chunk in audioStream {
                audioData.append(chunk)
            }
            
            try audioData.write(to: tempURL)
            
            // Cache the audio
            let cachedURL = try await cacheManager.cacheAudio(audioData, for: reference, voice: voice)
            
            // Play the cached audio
            try await playFromURL(cachedURL)
            
            isBuffering = false
        }
        
        // Update Now Playing info
        updateNowPlayingInfo()
    }
    
    public func playFromURL(_ url: URL) async throws {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Enable time pitch algorithm for variable speed playback
        playerItem?.audioTimePitchAlgorithm = .spectral
        
        // Set playback speed
        player?.rate = playbackSpeed
        
        // Add observers
        addPlayerObservers()
        
        // Start playback
        player?.play()
        playbackState = .playing
    }
    
    public func pause() async {
        player?.pause()
        playbackState = .paused
        updateNowPlayingInfo()
    }
    
    public func resume() async {
        player?.play()
        playbackState = .playing
        updateNowPlayingInfo()
    }
    
    public func stop() async {
        player?.pause()
        player = nil
        playerItem = nil
        removePlayerObservers()
        playbackState = .stopped
        currentTime = 0
        duration = 0
        currentPassage = nil
        nowPlayingInfo.nowPlayingInfo = nil
    }
    
    public func seek(to time: TimeInterval) async {
        let cmTime = CMTime(seconds: time, preferredTimescale: 1000)
        await player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
        updateNowPlayingInfo()
    }
    
    public func skipForward(_ seconds: TimeInterval = 15) async {
        let newTime = min(currentTime + seconds, duration)
        await seek(to: newTime)
    }
    
    public func skipBackward(_ seconds: TimeInterval = 15) async {
        let newTime = max(currentTime - seconds, 0)
        await seek(to: newTime)
    }
    
    public func setPlaybackSpeed(_ speed: Float) {
        playbackSpeed = speed
        player?.rate = playbackState == .playing ? speed : 0
        updateNowPlayingInfo()
    }
    
    public func setSleepTimer(_ duration: AudioSettings.SleepTimer?) {
        // Cancel existing timer
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerEndTime = nil
        
        guard let duration = duration else { return }
        
        let seconds: TimeInterval
        switch duration {
        case .minutes15: seconds = 15 * 60
        case .minutes30: seconds = 30 * 60
        case .minutes45: seconds = 45 * 60
        case .hour1: seconds = 60 * 60
        case .endOfChapter:
            // Will be handled when chapter ends
            return
        }
        
        sleepTimerEndTime = Date().addingTimeInterval(seconds)
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkSleepTimer()
        }
    }
    
    // MARK: - Queue Management
    
    public func queuePassages(_ references: [BibleReference], voice: String = "Rachel") {
        playbackQueue = references.map { AudioQueueItem(reference: $0, voice: voice) }
        currentQueueIndex = 0
    }
    
    public func playNext() async throws {
        guard currentQueueIndex < playbackQueue.count - 1 else { return }
        
        currentQueueIndex += 1
        let item = playbackQueue[currentQueueIndex]
        try await playPassage(item.reference, voice: item.voice)
    }
    
    public func playPrevious() async throws {
        guard currentQueueIndex > 0 else { return }
        
        currentQueueIndex -= 1
        let item = playbackQueue[currentQueueIndex]
        try await playPassage(item.reference, voice: item.voice)
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification,
            object: audioSession
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification,
            object: audioSession
        )
    }
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Play/Pause
        commandCenter.playCommand.addTarget { [weak self] _ in
            Task { await self?.resume() }
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            Task { await self?.pause() }
            return .success
        }
        
        // Skip forward/backward
        commandCenter.skipForwardCommand.preferredIntervals = [15]
        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
            Task { await self?.skipForward() }
            return .success
        }
        
        commandCenter.skipBackwardCommand.preferredIntervals = [15]
        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
            Task { await self?.skipBackward() }
            return .success
        }
        
        // Next/Previous track
        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
            Task { try? await self?.playNext() }
            return .success
        }
        
        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
            Task { try? await self?.playPrevious() }
            return .success
        }
        
        // Seek
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            Task { await self?.seek(to: event.positionTime) }
            return .success
        }
        
        // Playback rate
        commandCenter.changePlaybackRateCommand.supportedPlaybackRates = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]
        commandCenter.changePlaybackRateCommand.addTarget { [weak self] event in
            guard let event = event as? MPChangePlaybackRateCommandEvent else { return .commandFailed }
            self?.setPlaybackSpeed(event.playbackRate)
            return .success
        }
    }
    
    private func addPlayerObservers() {
        // Time observer
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            self?.currentTime = time.seconds
            self?.updateNowPlayingInfo()
        }
        
        // Duration observer
        playerItem?.publisher(for: \.duration)
            .filter { !$0.isIndefinite }
            .map { $0.seconds }
            .assign(to: &$duration)
        
        // Buffering observer
        playerItem?.publisher(for: \.isPlaybackBufferEmpty)
            .assign(to: &$isBuffering)
        
        // Status observer
        playerItem?.publisher(for: \.status)
            .sink { [weak self] status in
                if status == .failed {
                    self?.playbackState = .error(self?.playerItem?.error?.localizedDescription ?? "Unknown error")
                }
            }
            .store(in: &cancellables)
        
        // End of playback observer
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private func removePlayerObservers() {
        if let timeObserver = timeObserver {
            player?.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        
        cancellables.removeAll()
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func updateNowPlayingInfo() {
        guard let passage = currentPassage else {
            nowPlayingInfo.nowPlayingInfo = nil
            return
        }
        
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: passage.displayText,
            MPMediaItemPropertyArtist: "Leavn Bible",
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: playbackState == .playing ? Double(playbackSpeed) : 0,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
        
        if duration > 0 {
            info[MPMediaItemPropertyPlaybackDuration] = duration
        }
        
        // Add artwork if available
        if let image = UIImage(named: "AppIcon") {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        
        nowPlayingInfo.nowPlayingInfo = info
    }
    
    @objc private func handleInterruption(_ notification: Notification) {
        guard let info = notification.userInfo,
              let typeValue = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeValue) else { return }
        
        switch type {
        case .began:
            Task { await pause() }
        case .ended:
            if let optionsValue = info[AVAudioSessionInterruptionOptionKey] as? UInt {
                let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)
                if options.contains(.shouldResume) {
                    Task { await resume() }
                }
            }
        @unknown default:
            break
        }
    }
    
    @objc private func handleRouteChange(_ notification: Notification) {
        guard let info = notification.userInfo,
              let reasonValue = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else { return }
        
        switch reason {
        case .oldDeviceUnavailable:
            Task { await pause() }
        default:
            break
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        Task {
            // Check for sleep timer end of chapter
            if sleepTimerEndTime == nil {
                @Dependency(\.settingsService) var settings
                let audioSettings = await settings.getAudioSettings()
                
                if audioSettings.sleepTimer == .endOfChapter {
                    await stop()
                    return
                }
            }
            
            // Check if auto-play next is enabled
            @Dependency(\.settingsService) var settings
            let audioSettings = await settings.getAudioSettings()
            
            if audioSettings.autoPlayNext && currentQueueIndex < playbackQueue.count - 1 {
                try? await playNext()
            } else {
                await stop()
            }
        }
    }
    
    private func checkSleepTimer() {
        guard let endTime = sleepTimerEndTime else { return }
        
        if Date() >= endTime {
            Task {
                await stop()
                sleepTimer?.invalidate()
                sleepTimer = nil
                sleepTimerEndTime = nil
            }
        }
    }
}

// MARK: - Models
public enum PlaybackState: Equatable {
    case stopped
    case playing
    case paused
    case buffering
    case error(String)
}

public struct AudioQueueItem {
    let reference: BibleReference
    let voice: String
}

public enum AudioError: LocalizedError {
    case voiceNotFound(String)
    case downloadFailed
    case cacheFailed
    case playbackFailed(Error)
    
    public var errorDescription: String? {
        switch self {
        case .voiceNotFound(let voice):
            return "Voice '\(voice)' not found"
        case .downloadFailed:
            return "Failed to download audio"
        case .cacheFailed:
            return "Failed to cache audio"
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Audio Cache Manager
private actor AudioCacheManager {
    private let cacheDirectory: URL
    private let maxCacheSize: Int64 = 500 * 1024 * 1024 // 500 MB
    
    init() {
        let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheDirectory = cachesPath.appendingPathComponent("AudioCache")
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    func getCachedAudio(for reference: BibleReference, voice: String) -> URL? {
        let filename = cacheKey(for: reference, voice: voice) + ".mp3"
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            // Update access time
            try? FileManager.default.setAttributes([.modificationDate: Date()], ofItemAtPath: fileURL.path)
            return fileURL
        }
        
        return nil
    }
    
    func cacheAudio(_ data: Data, for reference: BibleReference, voice: String) throws -> URL {
        let filename = cacheKey(for: reference, voice: voice) + ".mp3"
        let fileURL = cacheDirectory.appendingPathComponent(filename)
        
        try data.write(to: fileURL)
        
        // Clean up old cache if needed
        Task {
            try? await cleanupCacheIfNeeded()
        }
        
        return fileURL
    }
    
    private func cacheKey(for reference: BibleReference, voice: String) -> String {
        let refString = "\(reference.book.rawValue)_\(reference.chapter.rawValue)"
        if let verse = reference.verse {
            return "\(refString)_\(verse.rawValue)_\(voice)"
        }
        return "\(refString)_\(voice)"
    }
    
    private func cleanupCacheIfNeeded() async throws {
        let contents = try FileManager.default.contentsOfDirectory(
            at: cacheDirectory,
            includingPropertiesForKeys: [.fileSizeKey, .contentAccessDateKey]
        )
        
        var totalSize: Int64 = 0
        var files: [(url: URL, size: Int64, accessDate: Date)] = []
        
        for url in contents {
            let attributes = try url.resourceValues(forKeys: [.fileSizeKey, .contentAccessDateKey])
            if let size = attributes.fileSize,
               let accessDate = attributes.contentAccessDate {
                totalSize += Int64(size)
                files.append((url, Int64(size), accessDate))
            }
        }
        
        // If cache is too large, remove oldest files
        if totalSize > maxCacheSize {
            // Sort by access date (oldest first)
            files.sort { $0.accessDate < $1.accessDate }
            
            var currentSize = totalSize
            for file in files {
                if currentSize <= maxCacheSize { break }
                
                try FileManager.default.removeItem(at: file.url)
                currentSize -= file.size
            }
        }
    }
}

// MARK: - Dependency
struct EnhancedAudioServiceKey: DependencyKey {
    static let liveValue = EnhancedAudioService()
}

extension DependencyValues {
    var enhancedAudioService: EnhancedAudioService {
        get { self[EnhancedAudioServiceKey.self] }
        set { self[EnhancedAudioServiceKey.self] = newValue }
    }
}