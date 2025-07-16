import Foundation
import SwiftUI
import CoreData

// MARK: - Date Range
public struct DateRange: Codable, Sendable {
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

// SortOrder is defined in SearchModels.swift

// MARK: - Theological Perspective
public enum TheologicalPerspective: String, CaseIterable, Identifiable, Codable {
    case reformed = "Reformed"
    case catholic = "Catholic"
    case orthodox = "Orthodox"
    case evangelical = "Evangelical"
    case charismatic = "Charismatic"
    case mainline = "Mainline Protestant"
    case nonDenominational = "Non-Denominational"
    case messianic = "Messianic"
    case anglican = "Anglican/Episcopal"
    case lutheran = "Lutheran"
    case baptist = "Baptist"
    case pentecostal = "Pentecostal"
    case presbyterian = "Presbyterian"
    case methodist = "Methodist"
    case adventist = "Adventist"
    case quaker = "Quaker/Friends"
    
    public var id: String { rawValue }
    
    public var description: String {
        switch self {
        case .reformed:
            return "Emphasizes God's sovereignty, grace, and Scripture alone"
        case .catholic:
            return "Tradition, sacraments, and apostolic succession"
        case .orthodox:
            return "Ancient traditions, liturgy, and mystical theology"
        case .evangelical:
            return "Personal relationship with Jesus and evangelism"
        case .charismatic:
            return "Spiritual gifts, healing, and Holy Spirit's work"
        case .mainline:
            return "Social justice, inclusive theology, and tradition"
        case .nonDenominational:
            return "Bible-centered without specific denominational ties"
        case .messianic:
            return "Jewish roots of faith and Hebrew perspective"
        case .anglican:
            return "Via media tradition, sacramental but reformed"
        case .lutheran:
            return "Justification by faith, sacramental theology"
        case .baptist:
            return "Believer's baptism, congregational governance"
        case .pentecostal:
            return "Speaking in tongues, divine healing, and spiritual gifts"
        case .presbyterian:
            return "Reformed theology with Presbyterian polity"
        case .methodist:
            return "Wesleyan tradition, prevenient grace, and holiness"
        case .adventist:
            return "Sabbath observance, prophetic emphasis, and health"
        case .quaker:
            return "Inner light, peace testimony, and silent worship"
        }
    }
    
    public var icon: String {
        switch self {
        case .reformed: return "book.closed.fill"
        case .catholic: return "plus"
        case .orthodox: return "sparkles"
        case .evangelical: return "heart.fill"
        case .charismatic: return "flame.fill"
        case .mainline: return "building.columns.fill"
        case .nonDenominational: return "book.fill"
        case .messianic: return "star.fill"
        case .anglican: return "crown.fill"
        case .lutheran: return "cross.fill"
        case .baptist: return "drop.fill"
        case .pentecostal: return "wind"
        case .presbyterian: return "building.2.fill"
        case .methodist: return "figure.walk"
        case .adventist: return "calendar.badge.clock"
        case .quaker: return "light.min"
        }
    }
    
    public var color: Color {
        switch self {
        case .reformed: return Color(hex: "4A5568")
        case .catholic: return Color(hex: "9B2C2C")
        case .orthodox: return Color(hex: "744210")
        case .evangelical: return Color(hex: "2B6CB0")
        case .charismatic: return Color(hex: "D69E2E")
        case .mainline: return Color(hex: "38A169")
        case .nonDenominational: return Color(hex: "5A67D8")
        case .messianic: return Color(hex: "9F7AEA")
        case .anglican: return Color(hex: "6B46C1")
        case .lutheran: return Color(hex: "1E40AF")
        case .baptist: return Color(hex: "0891B2")
        case .pentecostal: return Color(hex: "DC2626")
        case .presbyterian: return Color(hex: "7C2D12")
        case .methodist: return Color(hex: "059669")
        case .adventist: return Color(hex: "4338CA")
        case .quaker: return Color(hex: "71717A")
        }
    }
}

// MARK: - Color extension for hex support
// Color(hex:) initializer is now defined in Color+Theme.swift to avoid duplication


// MARK: - Supporting Types
public enum ReadingGoal: String, CaseIterable, Codable {
    case daily = "Daily Chapter"
    case weekly = "Weekly Book"
    case monthly = "Monthly Theme"
    case yearly = "Year-long Plan"
    case custom = "Custom Plan"
}

public struct NotificationTime: Codable {
    public let hour: Int
    public let minute: Int
    public let label: String
    
    public init(hour: Int, minute: Int, label: String) {
        self.hour = hour
        self.minute = minute
        self.label = label
    }
}