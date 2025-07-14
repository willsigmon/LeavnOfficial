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

// MARK: - Basic Search Types
public struct BibleSearchResult: Codable, Identifiable, Hashable {
    public let id: String
    public let verse: BibleVerse
    public let relevance: Double
    
    public init(id: String, verse: BibleVerse, relevance: Double) {
        self.id = id
        self.verse = verse
        self.relevance = relevance
    }
}

public struct SearchQuery: Codable, Identifiable, Hashable {
    public let id: String
    public let text: String
    public let timestamp: Date
    
    public init(id: String = UUID().uuidString, text: String, timestamp: Date = Date()) {
        self.id = id
        self.text = text
        self.timestamp = timestamp
    }
}

// MARK: - Library Types
public struct LibraryItem: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let type: LibraryItemType
    public let content: String
    public let dateAdded: Date
    
    public init(id: String, title: String, type: LibraryItemType, content: String, dateAdded: Date = Date()) {
        self.id = id
        self.title = title
        self.type = type
        self.content = content
        self.dateAdded = dateAdded
    }
}

public enum LibraryItemType: String, Codable, CaseIterable {
    case bookmark = "Bookmark"
    case note = "Note"
    case favorite = "Favorite"
    case devotion = "Devotion"
}

public struct LibraryCollection: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let items: [LibraryItem]
    public let dateCreated: Date
    
    public init(id: String, name: String, items: [LibraryItem], dateCreated: Date = Date()) {
        self.id = id
        self.name = name
        self.items = items
        self.dateCreated = dateCreated
    }
}

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

public struct LibrarySearchResult: Codable, Identifiable, Hashable {
    public let id: String
    public let item: LibraryItem
    public let relevance: Double
    
    public init(id: String, item: LibraryItem, relevance: Double) {
        self.id = id
        self.item = item
        self.relevance = relevance
    }
}

// MARK: - Community Types
public struct CommunityPost: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let content: String
    public let author: String
    public let dateCreated: Date
    public let likes: Int
    
    public init(id: String, title: String, content: String, author: String, dateCreated: Date = Date(), likes: Int = 0) {
        self.id = id
        self.title = title
        self.content = content
        self.author = author
        self.dateCreated = dateCreated
        self.likes = likes
    }
}

public struct CommunityGroup: Codable, Identifiable, Hashable {
    public let id: String
    public let name: String
    public let description: String
    public let memberCount: Int
    
    public init(id: String, name: String, description: String, memberCount: Int) {
        self.id = id
        self.name = name
        self.description = description
        self.memberCount = memberCount
    }
}

// MARK: - Audio Types (moved to BibleTypes.swift)

public struct BiblePassage: Codable, Identifiable, Hashable {
    public let id: String
    public let reference: String
    public let text: String
    public let verses: [BibleVerse]
    
    public init(id: String, reference: String, text: String, verses: [BibleVerse]) {
        self.id = id
        self.reference = reference
        self.text = text
        self.verses = verses
    }
}

// MARK: - Additional Audio Types
public struct AudioPlayerState: Codable {
    public let isPlaying: Bool
    public let currentChapter: AudioChapter?
    public let progress: Double
    public let volume: Double
    public let speed: Double
    
    public init(isPlaying: Bool = false, currentChapter: AudioChapter? = nil, progress: Double = 0.0, volume: Double = 1.0, speed: Double = 1.0) {
        self.isPlaying = isPlaying
        self.currentChapter = currentChapter
        self.progress = progress
        self.volume = volume
        self.speed = speed
    }
}

public struct ChapterInfo: Codable, Identifiable, Hashable {
    public let id: String
    public let book: String
    public let chapter: Int
    public let title: String
    public let duration: TimeInterval
    
    public init(id: String, book: String, chapter: Int, title: String, duration: TimeInterval) {
        self.id = id
        self.book = book
        self.chapter = chapter
        self.title = title
        self.duration = duration
    }
}

public enum PlaybackSpeed: String, CaseIterable, Codable {
    case slow = "0.5x"
    case normal = "1.0x"
    case fast = "1.5x"
    case faster = "2.0x"
    
    public var value: Double {
        switch self {
        case .slow: return 0.5
        case .normal: return 1.0
        case .fast: return 1.5
        case .faster: return 2.0
        }
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