import Foundation
import LeavnCore

public struct LifeSituation: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let category: LifeSituationCategory
    public let verses: [BibleReference]
    public let prayers: [Prayer]
    public let resources: [Resource]
    public let iconName: String
    public let tags: [String]
    
    public init(
        id: String,
        title: String,
        description: String,
        category: LifeSituationCategory,
        verses: [BibleReference] = [],
        prayers: [Prayer] = [],
        resources: [Resource] = [],
        iconName: String,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.verses = verses
        self.prayers = prayers
        self.resources = resources
        self.iconName = iconName
        self.tags = tags
    }
}

public enum LifeSituationCategory: String, CaseIterable, Codable {
    case emotional = "Emotional"
    case spiritual = "Spiritual"
    case relational = "Relational"
    case physical = "Physical"
    case financial = "Financial"
    case career = "Career"
    case family = "Family"
    
    public var icon: String {
        switch self {
        case .emotional: return "heart"
        case .spiritual: return "sparkles"
        case .relational: return "person.2"
        case .physical: return "heart.circle"
        case .financial: return "dollarsign.circle"
        case .career: return "briefcase"
        case .family: return "house"
        }
    }
}

public struct BibleReference: Codable, Identifiable {
    public let id: String
    public let reference: String
    public let preview: String?
    
    public init(id: String = UUID().uuidString, reference: String, preview: String? = nil) {
        self.id = id
        self.reference = reference
        self.preview = preview
    }
}

public struct Prayer: Codable, Identifiable {
    public let id: String
    public let title: String
    public let content: String
    public let author: String?
    public let tags: [String]
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        author: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.author = author
        self.tags = tags
    }
}

public struct Resource: Codable, Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let type: ResourceType
    public let url: URL?
    public let content: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        description: String,
        type: ResourceType,
        url: URL? = nil,
        content: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.url = url
        self.content = content
    }
}

public enum ResourceType: String, Codable {
    case article
    case video
    case podcast
    case book
    case meditation
    case exercise
}