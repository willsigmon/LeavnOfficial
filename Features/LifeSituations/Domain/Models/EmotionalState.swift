import Foundation

public enum EmotionalState: String, CaseIterable, Codable {
    case anxious = "anxious"
    case peaceful = "peaceful"
    case joyful = "joyful"
    case sad = "sad"
    case grateful = "grateful"
    case overwhelmed = "overwhelmed"
    case hopeful = "hopeful"
    case angry = "angry"
    case fearful = "fearful"
    case lonely = "lonely"
    case confused = "confused"
    case content = "content"
    
    public var displayName: String {
        switch self {
        case .anxious: return "Anxious"
        case .peaceful: return "Peaceful"
        case .joyful: return "Joyful"
        case .sad: return "Sad"
        case .grateful: return "Grateful"
        case .overwhelmed: return "Overwhelmed"
        case .hopeful: return "Hopeful"
        case .angry: return "Angry"
        case .fearful: return "Fearful"
        case .lonely: return "Lonely"
        case .confused: return "Confused"
        case .content: return "Content"
        }
    }
    
    public var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .peaceful: return "😌"
        case .joyful: return "😊"
        case .sad: return "😢"
        case .grateful: return "🙏"
        case .overwhelmed: return "😵"
        case .hopeful: return "🤗"
        case .angry: return "😠"
        case .fearful: return "😨"
        case .lonely: return "😔"
        case .confused: return "😕"
        case .content: return "😊"
        }
    }
    
    public var color: String {
        switch self {
        case .anxious: return "#FF6B6B"
        case .peaceful: return "#4ECDC4"
        case .joyful: return "#FFE66D"
        case .sad: return "#95A5A6"
        case .grateful: return "#A8E6CF"
        case .overwhelmed: return "#FF8B94"
        case .hopeful: return "#B4A7D6"
        case .angry: return "#D32F2F"
        case .fearful: return "#7986CB"
        case .lonely: return "#90A4AE"
        case .confused: return "#FFAB91"
        case .content: return "#81C784"
        }
    }
    
    public var relatedCategories: [LifeSituationCategory] {
        switch self {
        case .anxious, .fearful, .overwhelmed:
            return [.emotional, .spiritual, .physical]
        case .peaceful, .content, .grateful:
            return [.spiritual, .emotional]
        case .joyful, .hopeful:
            return [.spiritual, .emotional, .family]
        case .sad, .lonely:
            return [.emotional, .relational, .spiritual]
        case .angry:
            return [.emotional, .relational]
        case .confused:
            return [.spiritual, .career, .relational]
        }
    }
}

public enum LifeCategory: String, CaseIterable, Codable {
    case relationships = "relationships"
    case work = "work"
    case health = "health"
    case faith = "faith"
    case family = "family"
    case finances = "finances"
    case guidance = "guidance"
    case purpose = "purpose"
    
    public var displayName: String {
        switch self {
        case .relationships: return "Relationships"
        case .work: return "Work & Career"
        case .health: return "Health & Wellness"
        case .faith: return "Faith & Spirituality"
        case .family: return "Family"
        case .finances: return "Finances"
        case .guidance: return "Guidance"
        case .purpose: return "Purpose & Calling"
        }
    }
    
    public var icon: String {
        switch self {
        case .relationships: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .faith: return "sparkles"
        case .family: return "house.fill"
        case .finances: return "dollarsign.circle.fill"
        case .guidance: return "lightbulb.fill"
        case .purpose: return "target"
        }
    }
}