import Foundation
import Tagged

// MARK: - Type-Safe IDs
public typealias DownloadID = Tagged<Download, UUID>

// MARK: - Download Model
public struct Download: Identifiable, Equatable, Codable, Sendable {
    public let id: DownloadID
    public let title: String
    public let type: DownloadType
    public let book: Book
    public let chapters: [Int]
    public var progress: Double
    public var status: DownloadStatus
    public let sizeInBytes: Int64
    public var downloadedBytes: Int64
    public let createdAt: Date
    public var completedAt: Date?
    public var error: String?
    
    public enum DownloadType: String, Codable, Sendable {
        case book
        case chapter
        case selection
        case readingPlan
    }
    
    public init(
        id: UUID = UUID(),
        title: String,
        type: DownloadType,
        book: Book,
        chapters: [Int],
        progress: Double = 0,
        status: DownloadStatus = .queued,
        sizeInBytes: Int64,
        downloadedBytes: Int64 = 0,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        error: String? = nil
    ) {
        self.id = DownloadID(id)
        self.title = title
        self.type = type
        self.book = book
        self.chapters = chapters
        self.progress = progress
        self.status = status
        self.sizeInBytes = sizeInBytes
        self.downloadedBytes = downloadedBytes
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.error = error
    }
    
    public var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: sizeInBytes, countStyle: .file)
    }
    
    public var formattedDownloadedSize: String {
        ByteCountFormatter.string(fromByteCount: downloadedBytes, countStyle: .file)
    }
    
    public var isCompleted: Bool {
        status == .completed
    }
    
    public var canPause: Bool {
        status == .downloading
    }
    
    public var canResume: Bool {
        status == .paused || status == .failed
    }
    
    public var canRetry: Bool {
        status == .failed
    }
    
    // Sample download for testing
    public static let sample = Download(
        title: "Genesis",
        type: .book,
        book: .genesis,
        chapters: Array(1...50),
        sizeInBytes: 1024 * 1024 * 5
    )
}

// MARK: - Download Status
public enum DownloadStatus: String, Codable, CaseIterable, Sendable {
    case queued = "queued"
    case downloading = "downloading"
    case paused = "paused"
    case completed = "completed"
    case failed = "failed"
    
    public var displayText: String {
        switch self {
        case .queued:
            return "Waiting"
        case .downloading:
            return "Downloading"
        case .paused:
            return "Paused"
        case .completed:
            return "Downloaded"
        case .failed:
            return "Failed"
        }
    }
    
    public var icon: String {
        switch self {
        case .queued:
            return "clock"
        case .downloading:
            return "arrow.down.circle"
        case .paused:
            return "pause.circle"
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.circle"
        }
    }
}