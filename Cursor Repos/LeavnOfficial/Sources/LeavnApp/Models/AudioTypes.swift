import Foundation

// MARK: - Enhanced Audio Playback State for Reducer

public enum AudioPlaybackState: Equatable, Sendable {
    case idle
    case loading
    case playing(progress: TimeInterval, duration: TimeInterval)
    case paused(progress: TimeInterval, duration: TimeInterval)
    case error(String)
    
    public var isPlaying: Bool {
        if case .playing = self {
            return true
        }
        return false
    }
    
    public var isPaused: Bool {
        if case .paused = self {
            return true
        }
        return false
    }
    
    public var progress: TimeInterval {
        switch self {
        case .playing(let progress, _), .paused(let progress, _):
            return progress
        default:
            return 0
        }
    }
    
    public var duration: TimeInterval {
        switch self {
        case .playing(_, let duration), .paused(_, let duration):
            return duration
        default:
            return 0
        }
    }
    
    public var errorMessage: String? {
        if case .error(let message) = self {
            return message
        }
        return nil
    }
}

// MARK: - Voice Configuration

public struct VoiceConfiguration: Equatable, Codable, Sendable {
    public let id: String
    public let name: String
    public let language: String
    public let gender: Gender
    public let stability: Double
    public let similarityBoost: Double
    
    public enum Gender: String, Codable, Sendable {
        case male
        case female
        case neutral
    }
    
    public init(
        id: String,
        name: String,
        language: String = "en",
        gender: Gender,
        stability: Double = 0.5,
        similarityBoost: Double = 0.75
    ) {
        self.id = id
        self.name = name
        self.language = language
        self.gender = gender
        self.stability = stability
        self.similarityBoost = similarityBoost
    }
}

// MARK: - Audio Download Progress

public struct AudioDownloadProgress: Equatable, Sendable {
    public let id: String
    public let reference: BibleReference
    public let totalBytes: Int64
    public let downloadedBytes: Int64
    public let status: DownloadStatus
    
    public enum DownloadStatus: Equatable, Sendable {
        case pending
        case downloading
        case completed
        case failed(String)
        case cancelled
    }
    
    public var progress: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(downloadedBytes) / Double(totalBytes)
    }
    
    public init(
        id: String,
        reference: BibleReference,
        totalBytes: Int64 = 0,
        downloadedBytes: Int64 = 0,
        status: DownloadStatus = .pending
    ) {
        self.id = id
        self.reference = reference
        self.totalBytes = totalBytes
        self.downloadedBytes = downloadedBytes
        self.status = status
    }
}