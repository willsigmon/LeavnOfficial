import Foundation
import Dependencies
import AVFoundation
import Combine

// MARK: - Audio Service
@MainActor
public struct AudioService: Sendable {
    public var generateAudio: @Sendable (String, String) async throws -> Data
    public var playAudio: @Sendable (Data) async throws -> Void
    public var pauseAudio: @Sendable () async -> Void
    public var resumeAudio: @Sendable () async -> Void
    public var stopAudio: @Sendable () async -> Void
    public var setPlaybackSpeed: @Sendable (Double) async -> Void
    public var audioState: @Sendable () -> AsyncStream<AudioPlaybackState>
}

// MARK: - Audio Playback State
public enum AudioPlaybackState: Equatable, Sendable {
    case idle
    case loading
    case playing(progress: Double, duration: Double)
    case paused(progress: Double, duration: Double)
    case error(String)
}

// MARK: - Audio Player Manager
@MainActor
final class AudioPlayerManager {
    private var player: AVAudioPlayer?
    private var progressTimer: Timer?
    private let stateSubject = PassthroughSubject<AudioPlaybackState, Never>()
    
    var stateStream: AsyncStream<AudioPlaybackState> {
        AsyncStream { continuation in
            let cancellable = stateSubject.sink { state in
                continuation.yield(state)
            }
            
            continuation.onTermination = { _ in
                _ = cancellable
            }
        }
    }
    
    func play(data: Data) async throws {
        do {
            player = try AVAudioPlayer(data: data)
            player?.prepareToPlay()
            
            progressTimer?.invalidate()
            progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                Task { @MainActor in
                    self.updateProgress()
                }
            }
            
            player?.play()
            updateProgress()
        } catch {
            stateSubject.send(.error("Failed to play audio: \(error.localizedDescription)"))
            throw error
        }
    }
    
    func pause() {
        player?.pause()
        updateProgress()
    }
    
    func resume() {
        player?.play()
        updateProgress()
    }
    
    func stop() {
        player?.stop()
        progressTimer?.invalidate()
        progressTimer = nil
        stateSubject.send(.idle)
    }
    
    func setPlaybackSpeed(_ speed: Double) {
        player?.rate = Float(speed)
    }
    
    private func updateProgress() {
        guard let player = player else {
            stateSubject.send(.idle)
            return
        }
        
        let progress = player.currentTime
        let duration = player.duration
        
        if player.isPlaying {
            stateSubject.send(.playing(progress: progress, duration: duration))
        } else {
            stateSubject.send(.paused(progress: progress, duration: duration))
        }
    }
}

// MARK: - Dependency Implementation
extension AudioService: DependencyKey {
    public static let liveValue: Self = {
        let manager = AudioPlayerManager()
        
        return Self(
            generateAudio: { text, voiceId in
                @Dependency(\.elevenLabsClient) var elevenLabsClient
                
                return try await elevenLabsClient.textToSpeech(text, voiceId)
            },
            playAudio: { data in
                try await manager.play(data: data)
            },
            pauseAudio: {
                manager.pause()
            },
            resumeAudio: {
                manager.resume()
            },
            stopAudio: {
                manager.stop()
            },
            setPlaybackSpeed: { speed in
                manager.setPlaybackSpeed(speed)
            },
            audioState: {
                manager.stateStream
            }
        )
    }()
    
    public static let testValue = Self(
        generateAudio: { _, _ in Data() },
        playAudio: { _ in },
        pauseAudio: { },
        resumeAudio: { },
        stopAudio: { },
        setPlaybackSpeed: { _ in },
        audioState: {
            AsyncStream { continuation in
                continuation.yield(.idle)
            }
        }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var audioService: AudioService {
        get { self[AudioService.self] }
        set { self[AudioService.self] = newValue }
    }
}