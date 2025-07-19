import Foundation
import IdentifiedCollections
import Tagged

// MARK: - Type-Safe IDs
public typealias UserID = Tagged<User, UUID>
public typealias GroupID = Tagged<Group, UUID>
public typealias PrayerID = Tagged<Prayer, UUID>

// MARK: - User Model
public struct User: Equatable, Codable, Sendable, Identifiable {
    public let id: UserID
    public let username: String
    public let displayName: String
    public let email: String?
    public let avatarURL: URL?
    public let joinedAt: Date
    public let isVerified: Bool
    public let bio: String?
    
    public init(
        id: UserID = UserID(UUID()),
        username: String,
        displayName: String,
        email: String? = nil,
        avatarURL: URL? = nil,
        joinedAt: Date = Date(),
        isVerified: Bool = false,
        bio: String? = nil
    ) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.avatarURL = avatarURL
        self.joinedAt = joinedAt
        self.isVerified = isVerified
        self.bio = bio
    }
}

// MARK: - Community Activity
public struct CommunityActivity: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let type: ActivityType
    public let userId: UserID
    public let timestamp: Date
    public let metadata: [String: String]
    
    public enum ActivityType: String, Codable, Sendable {
        case joinedGroup
        case leftGroup
        case postedPrayer
        case answeredPrayer
        case startedReadingPlan
        case completedReadingPlan
        case sharedVerse
        case createdNote
    }
    
    public init(
        id: UUID = UUID(),
        type: ActivityType,
        userId: UserID,
        timestamp: Date = Date(),
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.type = type
        self.userId = userId
        self.timestamp = timestamp
        self.metadata = metadata
    }
}