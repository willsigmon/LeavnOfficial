import Foundation
import AVFoundation
import Combine

// MARK: - Default Audio Service
public final class DefaultAudioService: NSObject, AudioServiceProtocol {
    private let elevenLabsAPIKey: String
    private let cacheManager: AudioCacheManagerProtocol
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let progressSubject = CurrentValueSubject<Double, Never>(0.0)
    private var progressTimer: Timer?
    
    public var isPlaying: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }
    
    public var progress: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }
    
    public init(elevenLabsAPIKey: String, cacheManager: AudioCacheManagerProtocol) {
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.cacheManager = cacheManager
        self.audioSession = AVAudioSession.sharedInstance()
        super.init()
        
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.allowBluetooth, .allowAirPlay])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    public func playVerse(_ verse: BibleVerse, voice: VoiceConfiguration?) async throws {
        // Stop any current playback
        stop()
        
        let cacheKey = "\(verse.reference)-\(verse.translation)-\(voice?.id ?? "default")"
        
        // Check cache first
        if let cachedURL = try await cacheManager.getCachedAudioURL(for: cacheKey) {
            try await playAudioFromURL(cachedURL)
            return
        }
        
        // Generate audio if not cached
        let audioData = try await generateAudio(
            text: verse.text,
            voice: voice ?? VoiceConfiguration.defaultVoice
        )
        
        // Cache the audio
        try await cacheManager.cacheAudio(for: cacheKey, data: audioData)
        
        // Play the audio
        if let url = try await cacheManager.getCachedAudioURL(for: cacheKey) {
            try await playAudioFromURL(url)
        }
    }
    
    public func pause() {
        audioPlayer?.pause()
        isPlayingSubject.send(false)
        progressTimer?.invalidate()
    }
    
    public func resume() {
        audioPlayer?.play()
        isPlayingSubject.send(true)
        startProgressTimer()
    }
    
    public func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlayingSubject.send(false)
        progressSubject.send(0.0)
        progressTimer?.invalidate()
    }
    
    public func generateAudio(text: String, voice: VoiceConfiguration) async throws -> URL {
        // For now, use system speech synthesis as fallback
        // In production, this would call ElevenLabs API
        let synthesizer = AVSpeechSynthesizer()
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure voice settings
        utterance.rate = Float(voice.speed)
        utterance.pitchMultiplier = Float(voice.pitch)
        utterance.volume = Float(voice.volume)
        
        // Use system voice
        if let systemVoice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = systemVoice
        }
        
        // Generate temporary file URL
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("caf")
        
        // This is a simplified implementation
        // In production, you would properly generate and save the audio file
        
        return tempURL
    }
    
    private func playAudioFromURL(_ url: URL) async throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        audioPlayer?.delegate = self
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
        
        isPlayingSubject.send(true)
        startProgressTimer()
    }
    
    private func startProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer,
                  player.duration > 0 else { return }
            
            let progress = player.currentTime / player.duration
            self.progressSubject.send(progress)
        }
    }
    
    private func generateAudioData(text: String, voice: VoiceConfiguration) async throws -> Data {
        // This would normally call ElevenLabs API
        // For now, return empty data as placeholder
        return Data()
    }
}

// MARK: - AVAudioPlayerDelegate
extension DefaultAudioService: AVAudioPlayerDelegate {
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        isPlayingSubject.send(false)
        progressSubject.send(0.0)
        progressTimer?.invalidate()
    }
    
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        isPlayingSubject.send(false)
        progressSubject.send(0.0)
        progressTimer?.invalidate()
        
        if let error = error {
            print("Audio decode error: \(error)")
        }
    }
}

// MARK: - Audio Cache Manager Protocol
public protocol AudioCacheManagerProtocol {
    func cacheAudio(for key: String, data: Data) async throws
    func getCachedAudio(for key: String) async throws -> Data?
    func getCachedAudioURL(for key: String) async throws -> URL?
    func removeCachedAudio(for key: String) async throws
    func clearCache() async throws
    func getCacheSize() async throws -> Int64
}

// MARK: - In-Memory Audio Cache Manager
public final class InMemoryAudioCacheManager: AudioCacheManagerProtocol {
    private var cache: [String: Data] = [:]
    private let queue = DispatchQueue(label: "audio.cache", attributes: .concurrent)
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    
    public init() {
        let tempDir = fileManager.temporaryDirectory
        self.cacheDirectory = tempDir.appendingPathComponent("AudioCache", isDirectory: true)
        
        // Create cache directory if needed
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    public func cacheAudio(for key: String, data: Data) async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.cache[key] = data
                
                // Also save to disk
                let fileURL = self.cacheDirectory.appendingPathComponent(key).appendingPathExtension("audio")
                try? data.write(to: fileURL)
                
                continuation.resume()
            }
        }
    }
    
    public func getCachedAudio(for key: String) async throws -> Data? {
        return await withCheckedContinuation { continuation in
            queue.async {
                if let data = self.cache[key] {
                    continuation.resume(returning: data)
                } else {
                    // Try to load from disk
                    let fileURL = self.cacheDirectory.appendingPathComponent(key).appendingPathExtension("audio")
                    if let data = try? Data(contentsOf: fileURL) {
                        self.cache[key] = data // Cache in memory
                        continuation.resume(returning: data)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    public func getCachedAudioURL(for key: String) async throws -> URL? {
        let fileURL = cacheDirectory.appendingPathComponent(key).appendingPathExtension("audio")
        
        // Check if file exists
        if fileManager.fileExists(atPath: fileURL.path) {
            return fileURL
        }
        
        // If we have data in memory, write it to disk
        if let data = try await getCachedAudio(for: key) {
            try data.write(to: fileURL)
            return fileURL
        }
        
        return nil
    }
    
    public func removeCachedAudio(for key: String) async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.cache.removeValue(forKey: key)
                
                // Remove from disk
                let fileURL = self.cacheDirectory.appendingPathComponent(key).appendingPathExtension("audio")
                try? self.fileManager.removeItem(at: fileURL)
                
                continuation.resume()
            }
        }
    }
    
    public func clearCache() async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.cache.removeAll()
                
                // Clear disk cache
                if let files = try? self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: nil) {
                    for file in files {
                        try? self.fileManager.removeItem(at: file)
                    }
                }
                
                continuation.resume()
            }
        }
    }
    
    public func getCacheSize() async throws -> Int64 {
        return await withCheckedContinuation { continuation in
            queue.async {
                var totalSize: Int64 = 0
                
                // Memory cache size
                totalSize += Int64(self.cache.values.reduce(0) { $0 + $1.count })
                
                // Disk cache size
                if let files = try? self.fileManager.contentsOfDirectory(at: self.cacheDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
                    for file in files {
                        if let fileSize = try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                            totalSize += Int64(fileSize)
                        }
                    }
                }
                
                continuation.resume(returning: totalSize)
            }
        }
    }
}