import Foundation
import SwiftUI
import Combine

// MARK: - Loading State
// LoadingState is now defined in Core/LeavnCore/Sources/LeavnCore/ViewModelSupport/ViewModelErrorHandling.swift

// MARK: - Base View Model
// BaseViewModel is now defined in Core/LeavnCore/Sources/LeavnCore/ViewModelSupport/ViewModelErrorHandling.swift

// MARK: - Basic Search Types (Moved to BibleTypes.swift)

// MARK: - Library Types (Moved to BibleTypes.swift)

// LibraryCollection moved to BibleTypes.swift with LibraryItem

// LibraryStatistics moved to Core/LeavnCore/Sources/LeavnCore/LibraryTypes.swift

// LibraryFilter is now defined in Core/LeavnCore/Sources/LeavnCore/LibraryTypes.swift


// MARK: - Community Types (Moved to BibleTypes.swift)

// MARK: - Audio Types (moved to BibleTypes.swift)

// MARK: - Additional Audio Types (moved to BibleTypes.swift)

// Audio Player UI State (different from AudioPlayerState enum)
public struct AudioPlayerUIState: Codable {
    public let isPlaying: Bool
    public let currentTime: Double
    public let duration: Double
    public let playbackSpeed: PlaybackSpeed
    public let isDownloaded: Bool
    public let isLoading: Bool
    
    public init(isPlaying: Bool = false, currentTime: Double = 0.0, duration: Double = 0.0, playbackSpeed: PlaybackSpeed = .normal, isDownloaded: Bool = false, isLoading: Bool = false) {
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.duration = duration
        self.playbackSpeed = playbackSpeed
        self.isDownloaded = isDownloaded
        self.isLoading = isLoading
    }
}

// AudioData and VoiceSettings are now defined in BibleTypes.swift to avoid duplication