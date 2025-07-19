import Foundation

public struct AudioPlaybackState: Equatable, Sendable {
    public let isPlaying: Bool
    public let currentBook: Book?
    public let currentChapter: Int?
    public let currentVerse: Int?
    public let playbackRate: Double
    public let duration: TimeInterval
    public let currentTime: TimeInterval
    
    public init(
        isPlaying: Bool = false,
        currentBook: Book? = nil,
        currentChapter: Int? = nil,
        currentVerse: Int? = nil,
        playbackRate: Double = 1.0,
        duration: TimeInterval = 0,
        currentTime: TimeInterval = 0
    ) {
        self.isPlaying = isPlaying
        self.currentBook = currentBook
        self.currentChapter = currentChapter
        self.currentVerse = currentVerse
        self.playbackRate = playbackRate
        self.duration = duration
        self.currentTime = currentTime
    }
    
    public var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }
    
    public var remainingTime: TimeInterval {
        max(0, duration - currentTime)
    }
}