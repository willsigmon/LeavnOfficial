import Foundation
import SwiftUI
import Combine

// MARK: - Loading State
public enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
}

// MARK: - Base View Model
@MainActor
open class BaseViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public init() {}
    
    public func handleError(_ error: Error) {
        self.error = error
        print("Error: \(error)")
    }
    
    public func execute<T>(_ operation: @escaping () async throws -> T, onError: ((Error) -> Void)? = nil) {
        Task {
            isLoading = true
            do {
                let result = try await operation()
                isLoading = false
                // Successfully executed
            } catch {
                isLoading = false
                if let onError = onError {
                    onError(error)
                } else {
                    handleError(error)
                }
            }
        }
    }
    
    public func handle(error: Error, retry: @escaping () -> Void) {
        handleError(error)
        // Store retry action for potential UI retry buttons
    }
}

// MARK: - Basic Search Types (Moved to BibleTypes.swift)

// MARK: - Library Types (Moved to BibleTypes.swift)

// LibraryCollection moved to BibleTypes.swift with LibraryItem

public struct LibraryStatistics: Codable {
    public let totalItems: Int
    public let bookmarksCount: Int
    public let notesCount: Int
    public let favoritesCount: Int
    
    public init(totalItems: Int, bookmarksCount: Int, notesCount: Int, favoritesCount: Int) {
        self.totalItems = totalItems
        self.bookmarksCount = bookmarksCount
        self.notesCount = notesCount
        self.favoritesCount = favoritesCount
    }
}

public enum LibraryFilter: String, CaseIterable {
    case all = "All"
    case bookmarks = "Bookmarks"
    case notes = "Notes"
    case favorites = "Favorites"
}


// MARK: - Community Types (Moved to BibleTypes.swift)

// MARK: - Audio Types (moved to BibleTypes.swift)

// MARK: - Additional Audio Types (moved to BibleTypes.swift)

// Audio Player UI State (different from AudioPlayerState enum in BibleTypes.swift)
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

public struct AudioData: Codable {
    public let data: Data
    public let format: String
    public let duration: TimeInterval
    
    public init(data: Data, format: String, duration: TimeInterval) {
        self.data = data
        self.format = format
        self.duration = duration
    }
}

public struct VoiceSettings: Codable {
    public let stability: Double
    public let similarityBoost: Double
    public let style: Double
    public let useSpeakerBoost: Bool
    
    public init(stability: Double = 0.75, similarityBoost: Double = 0.75, style: Double = 0.0, useSpeakerBoost: Bool = true) {
        self.stability = stability
        self.similarityBoost = similarityBoost
        self.style = style
        self.useSpeakerBoost = useSpeakerBoost
    }
}