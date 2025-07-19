import Foundation

public struct ActivityItem: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let type: ActivityType
    public let userId: UUID
    public let userName: String
    public let content: String
    public let timestamp: Date
    
    public init(
        id: UUID = UUID(),
        type: ActivityType,
        userId: UUID,
        userName: String,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.userId = userId
        self.userName = userName
        self.content = content
        self.timestamp = timestamp
    }
}

public enum ActivityType: String, Codable, Sendable {
    case prayer
    case highlight
    case note
    case bookmark
    case readingPlan
    case groupJoined
    case verseShared
}