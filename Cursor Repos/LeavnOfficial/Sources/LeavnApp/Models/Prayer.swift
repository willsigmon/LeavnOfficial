import Foundation
import Tagged

// MARK: - Prayer Model
public struct Prayer: Identifiable, Equatable, Codable, Sendable {
    public let id: PrayerID
    public let title: String
    public let content: String
    public let authorId: UserID
    public let authorName: String
    public let createdAt: Date
    public let updatedAt: Date
    public let status: PrayerStatus
    public let prayerCount: Int
    public let category: PrayerCategory
    public let isAnonymous: Bool
    public let groupId: GroupID?
    public let scriptureReferences: [BibleReference]
    
    public enum PrayerStatus: String, Codable, Sendable {
        case active
        case answered
        case ongoing
        case archived
    }
    
    public init(
        id: PrayerID = PrayerID(UUID()),
        title: String,
        content: String,
        authorId: UserID,
        authorName: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        status: PrayerStatus = .active,
        prayerCount: Int = 0,
        category: PrayerCategory,
        isAnonymous: Bool = false,
        groupId: GroupID? = nil,
        scriptureReferences: [BibleReference] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorId = authorId
        self.authorName = authorName
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.status = status
        self.prayerCount = prayerCount
        self.category = category
        self.isAnonymous = isAnonymous
        self.groupId = groupId
        self.scriptureReferences = scriptureReferences
    }
}

// MARK: - Prayer Category
public enum PrayerCategory: String, CaseIterable, Codable, Sendable {
    case personal = "Personal"
    case family = "Family"
    case health = "Health"
    case financial = "Financial"
    case spiritual = "Spiritual Growth"
    case relationships = "Relationships"
    case work = "Work/Career"
    case ministry = "Ministry"
    case praise = "Praise"
    case thanksgiving = "Thanksgiving"
    case general = "General"
    
    public var icon: String {
        switch self {
        case .personal: return "person.fill"
        case .family: return "house.fill"
        case .health: return "heart.fill"
        case .financial: return "dollarsign.circle.fill"
        case .spiritual: return "sparkles"
        case .relationships: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .ministry: return "hands.sparkles.fill"
        case .praise: return "star.fill"
        case .thanksgiving: return "gift.fill"
        case .general: return "ellipsis.circle.fill"
        }
    }
    
    public var color: String {
        switch self {
        case .personal: return "blue"
        case .family: return "green"
        case .health: return "red"
        case .financial: return "orange"
        case .spiritual: return "purple"
        case .relationships: return "pink"
        case .work: return "brown"
        case .ministry: return "indigo"
        case .praise: return "yellow"
        case .thanksgiving: return "teal"
        case .general: return "gray"
        }
    }
}

// MARK: - Prayer Interaction
public struct PrayerInteraction: Equatable, Codable, Sendable {
    public let prayerId: PrayerID
    public let userId: UserID
    public let type: InteractionType
    public let timestamp: Date
    public let note: String?
    
    public enum InteractionType: String, Codable, Sendable {
        case prayed
        case answered
        case commented
        case shared
    }
    
    public init(
        prayerId: PrayerID,
        userId: UserID,
        type: InteractionType,
        timestamp: Date = Date(),
        note: String? = nil
    ) {
        self.prayerId = prayerId
        self.userId = userId
        self.type = type
        self.timestamp = timestamp
        self.note = note
    }
}