import Foundation
import Tagged

// MARK: - Group Model (moved from User.swift for clarity)
public struct Group: Equatable, Codable, Sendable, Identifiable {
    public let id: GroupID
    public let name: String
    public let description: String
    public let imageURL: URL?
    public let createdBy: UserID
    public let createdAt: Date
    public let memberCount: Int
    public let isPrivate: Bool
    public let category: GroupCategory
    public let tags: [String]
    
    public init(
        id: GroupID = GroupID(UUID()),
        name: String,
        description: String,
        imageURL: URL? = nil,
        createdBy: UserID,
        createdAt: Date = Date(),
        memberCount: Int = 1,
        isPrivate: Bool = false,
        category: GroupCategory,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.imageURL = imageURL
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.memberCount = memberCount
        self.isPrivate = isPrivate
        self.category = category
        self.tags = tags
    }
}

public enum GroupCategory: String, CaseIterable, Codable, Sendable {
    case bibleStudy = "Bible Study"
    case prayer = "Prayer"
    case worship = "Worship"
    case community = "Community"
    case support = "Support"
    case youth = "Youth"
    case missions = "Missions"
    case general = "General"
    
    public var icon: String {
        switch self {
        case .bibleStudy: return "book.circle.fill"
        case .prayer: return "hands.sparkles.fill"
        case .worship: return "music.note.house.fill"
        case .community: return "person.3.fill"
        case .support: return "heart.circle.fill"
        case .youth: return "star.circle.fill"
        case .missions: return "globe.americas.fill"
        case .general: return "circle.grid.3x3.fill"
        }
    }
}