import Foundation
import SwiftUI
import Combine

@MainActor
public class AudioPlayerViewModel: BaseViewModel {
    @Published var isPlaying = false
    @Published var currentVerse: BibleVerse?
    @Published var playbackProgress: Double = 0.0
    @Published var volume: Double = 1.0
    @Published var playbackSpeed: Double = 1.0
    
    private let analyticsService: AnalyticsServiceProtocol
    
    public init(analyticsService: AnalyticsServiceProtocol? = nil) {
        let container = DIContainer.shared
        self.analyticsService = analyticsService ?? container.analyticsService
        
        super.init()
    }
    
    func playVerse(_ verse: BibleVerse) {
        currentVerse = verse
        isPlaying = true
        
        analyticsService.track(event: "verse_audio_played", properties: [
            "reference": verse.reference,
            "translation": verse.translation
        ])
    }
    
    func pausePlayback() {
        isPlaying = false
        
        analyticsService.track(event: "audio_paused", properties: [:])
    }
    
    func stopPlayback() {
        isPlaying = false
        currentVerse = nil
        playbackProgress = 0.0
        
        analyticsService.track(event: "audio_stopped", properties: [:])
    }
    
    func setVolume(_ volume: Double) {
        self.volume = volume
    }
    
    func setPlaybackSpeed(_ speed: Double) {
        self.playbackSpeed = speed
        
        analyticsService.track(event: "audio_speed_changed", properties: [
            "speed": speed
        ])
    }
}