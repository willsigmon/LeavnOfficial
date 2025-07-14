import Foundation
import SwiftUI

// MARK: - Onboarding-Specific Types
// This file contains only onboarding-specific types that extend the canonical models from LeavnCore

// MARK: - Theological Perspective
public enum OnboardingTheologicalPerspective: String, CaseIterable, Identifiable {
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
    
    var description: String {
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
    
    var icon: String {
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
    
    var color: Color {
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
    
    // Convert to canonical type
    var canonical: TheologicalPerspective {
        switch self {
        case .reformed: return .reformed
        case .catholic: return .catholic
        case .orthodox: return .orthodox
        case .evangelical: return .evangelical
        case .charismatic: return .charismatic
        case .mainline: return .mainline
        case .nonDenominational: return .nonDenominational
        case .messianic: return .messianic
        case .anglican: return .anglican
        case .lutheran: return .lutheran
        case .baptist: return .baptist
        case .pentecostal: return .pentecostal
        case .presbyterian: return .presbyterian
        case .methodist: return .methodist
        case .adventist: return .adventist
        case .quaker: return .quaker
        }
    }
}

// MARK: - Onboarding Reading Goal
public enum OnboardingReadingGoal: String, CaseIterable {
    case daily = "Daily Chapter"
    case weekly = "Weekly Book"
    case monthly = "Monthly Theme"
    case yearly = "Year-long Plan"
    case custom = "Custom Plan"
    
    var description: String {
        switch self {
        case .daily:
            return "Read one chapter each day"
        case .weekly:
            return "Complete a book each week"
        case .monthly:
            return "Focus on monthly themes"
        case .yearly:
            return "Read the entire Bible in a year"
        case .custom:
            return "Create your own reading schedule"
        }
    }
    
    var icon: String {
        switch self {
        case .daily: return "calendar.day.timeline.left"
        case .weekly: return "calendar.badge.plus"
        case .monthly: return "calendar"
        case .yearly: return "calendar.circle"
        case .custom: return "square.and.pencil"
        }
    }
    
    // Convert to canonical type
    var canonical: ReadingGoal {
        switch self {
        case .daily: return .daily
        case .weekly: return .weekly
        case .monthly: return .monthly
        case .yearly: return .yearly
        case .custom: return .custom
        }
    }
}

// MARK: - Onboarding Extensions
public extension UserPreferencesData {
    static let onboardingNotificationTimes = [
        NotificationTime(hour: 6, minute: 0, label: "Early Morning"),
        NotificationTime(hour: 8, minute: 0, label: "Morning"),
        NotificationTime(hour: 12, minute: 0, label: "Noon"),
        NotificationTime(hour: 18, minute: 0, label: "Evening"),
        NotificationTime(hour: 21, minute: 0, label: "Night")
    ]
    
    static let onboardingTranslations = [
        BibleTranslation(
            abbreviation: "NIV",
            name: "New International Version",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "ESV",
            name: "English Standard Version",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "KJV",
            name: "King James Version",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "NLT",
            name: "New Living Translation",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "MSG",
            name: "The Message",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "NASB",
            name: "New American Standard Bible",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "CSB",
            name: "Christian Standard Bible",
            language: "English",
            languageCode: "en"
        ),
        BibleTranslation(
            abbreviation: "AMP",
            name: "Amplified Bible",
            language: "English",
            languageCode: "en"
        )
    ]
}

// MARK: - Color Extension Helper
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

extension TheologicalPerspective {
    var icon: String {
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
    
    var color: Color {
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
    
    var description: String {
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
}
