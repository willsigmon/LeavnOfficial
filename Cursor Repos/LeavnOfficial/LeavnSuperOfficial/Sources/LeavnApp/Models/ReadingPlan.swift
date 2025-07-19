import Foundation
import Tagged

// MARK: - Type-Safe IDs
public typealias ReadingPlanID = Tagged<ReadingPlan, UUID>
public typealias ReadingDayID = Tagged<ReadingDay, UUID>

// MARK: - Reading Plan Model
public struct ReadingPlan: Equatable, Codable, Sendable, Identifiable {
    public let id: ReadingPlanID
    public let name: String
    public let description: String
    public let duration: PlanDuration
    public let category: PlanCategory
    public let imageURL: URL?
    public let startDate: Date?
    public let currentDay: Int
    public let completedDays: Set<Int>
    public let days: [ReadingDay]
    
    public init(
        id: ReadingPlanID = ReadingPlanID(UUID()),
        name: String,
        description: String,
        duration: PlanDuration,
        category: PlanCategory,
        imageURL: URL? = nil,
        startDate: Date? = nil,
        currentDay: Int = 1,
        completedDays: Set<Int> = [],
        days: [ReadingDay]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.category = category
        self.imageURL = imageURL
        self.startDate = startDate
        self.currentDay = currentDay
        self.completedDays = completedDays
        self.days = days
    }
    
    public var progress: Double {
        guard !days.isEmpty else { return 0 }
        return Double(completedDays.count) / Double(days.count)
    }
    
    public var isActive: Bool {
        startDate != nil
    }
    
    public var isCompleted: Bool {
        completedDays.count == days.count
    }
}

// MARK: - Plan Duration
public enum PlanDuration: Equatable, Codable, Sendable {
    case days(Int)
    case weeks(Int)
    case months(Int)
    case year
    case custom(Int)
    
    public var displayText: String {
        switch self {
        case .days(let count):
            return "\(count) Day\(count == 1 ? "" : "s")"
        case .weeks(let count):
            return "\(count) Week\(count == 1 ? "" : "s")"
        case .months(let count):
            return "\(count) Month\(count == 1 ? "" : "s")"
        case .year:
            return "1 Year"
        case .custom(let days):
            return "\(days) Day\(days == 1 ? "" : "s")"
        }
    }
    
    public var totalDays: Int {
        switch self {
        case .days(let count):
            return count
        case .weeks(let count):
            return count * 7
        case .months(let count):
            return count * 30
        case .year:
            return 365
        case .custom(let days):
            return days
        }
    }
}

// MARK: - Plan Category
public enum PlanCategory: String, CaseIterable, Codable, Sendable {
    case wholeBible = "Whole Bible"
    case newTestament = "New Testament"
    case oldTestament = "Old Testament"
    case gospels = "Gospels"
    case psalms = "Psalms"
    case proverbs = "Proverbs"
    case topical = "Topical"
    case chronological = "Chronological"
    case beginner = "Beginner"
    case family = "Family"
    case youth = "Youth"
    case devotional = "Devotional"
    
    public var icon: String {
        switch self {
        case .wholeBible: return "book.closed.fill"
        case .newTestament: return "cross.fill"
        case .oldTestament: return "scroll.fill"
        case .gospels: return "person.3.fill"
        case .psalms: return "music.note"
        case .proverbs: return "lightbulb.fill"
        case .topical: return "tag.fill"
        case .chronological: return "calendar"
        case .beginner: return "star.fill"
        case .family: return "house.fill"
        case .youth: return "graduationcap.fill"
        case .devotional: return "heart.fill"
        }
    }
}

// MARK: - Reading Day
public struct ReadingDay: Equatable, Codable, Sendable, Identifiable {
    public let id: ReadingDayID
    public let dayNumber: Int
    public let title: String?
    public let passages: [ReadingPassage]
    public let devotional: Devotional?
    public let prayer: String?
    
    public init(
        id: ReadingDayID = ReadingDayID(UUID()),
        dayNumber: Int,
        title: String? = nil,
        passages: [ReadingPassage],
        devotional: Devotional? = nil,
        prayer: String? = nil
    ) {
        self.id = id
        self.dayNumber = dayNumber
        self.title = title
        self.passages = passages
        self.devotional = devotional
        self.prayer = prayer
    }
}

// MARK: - Reading Passage
public struct ReadingPassage: Equatable, Codable, Sendable {
    public let reference: BibleReference
    public let endReference: BibleReference?
    public let note: String?
    
    public init(
        reference: BibleReference,
        endReference: BibleReference? = nil,
        note: String? = nil
    ) {
        self.reference = reference
        self.endReference = endReference
        self.note = note
    }
    
    public var displayText: String {
        if let endReference = endReference {
            if reference.book == endReference.book {
                if reference.chapter == endReference.chapter {
                    return "\(reference.book.name) \(reference.chapter.rawValue):\(reference.verse?.rawValue ?? 1)-\(endReference.verse?.rawValue ?? 1)"
                } else {
                    return "\(reference.book.name) \(reference.chapter.rawValue)-\(endReference.chapter.rawValue)"
                }
            } else {
                return "\(reference.displayText) - \(endReference.displayText)"
            }
        } else {
            return reference.displayText
        }
    }
}

// MARK: - Devotional
public struct Devotional: Equatable, Codable, Sendable {
    public let title: String
    public let content: String
    public let author: String?
    public let reflection: String?
    
    public init(
        title: String,
        content: String,
        author: String? = nil,
        reflection: String? = nil
    ) {
        self.title = title
        self.content = content
        self.author = author
        self.reflection = reflection
    }
}