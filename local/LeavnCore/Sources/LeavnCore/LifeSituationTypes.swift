import Foundation
import SwiftUI

// MARK: - Emotional State

public enum EmotionalState: String, CaseIterable, Sendable {
    case joy = "joy"         // Covers: joyful, grateful, content, hopeful
    case peace = "peace"     // Covers: peaceful, content, calm
    case struggle = "struggle" // Covers: anxious, stressed, overwhelmed, worried, uncertain, confused
    case growth = "growth"   // Covers: hopeful, learning, changing
    case worship = "worship" // Covers: grateful, praising, connected to God
    
    // Legacy mappings for backward compatibility
    public static func from(legacy: String) -> EmotionalState {
        switch legacy.lowercased() {
        case "joyful", "grateful", "content", "hopeful":
            return .joy
        case "peaceful", "calm":
            return .peace
        case "anxious", "depressed", "angry", "fearful", "lonely", "overwhelmed", "sad", "stressed", "worried", "uncertain", "confused":
            return .struggle
        case "growth", "learning", "changing":
            return .growth
        case "worship", "praising":
            return .worship
        default:
            return .peace
        }
    }
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public var detailedDescription: String {
        switch self {
        case .joy: return "Experiencing happiness, gratitude, or contentment"
        case .peace: return "Feeling calm, centered, and at rest"
        case .struggle: return "Facing challenges, anxiety, or difficult emotions"
        case .growth: return "In a season of learning and transformation"
        case .worship: return "Seeking connection with God through praise"
        }
    }
    
    public var emoji: String {
        switch self {
        case .joy: return "😊"
        case .peace: return "😌"
        case .struggle: return "💪"
        case .growth: return "🌱"
        case .worship: return "🙏"
        }
    }
    
    public var color: String {
        switch self {
        case .joy: return "#FFD700"      // Gold
        case .peace: return "#98FB98"     // Pale green
        case .struggle: return "#87CEEB"  // Sky blue (supportive, not negative)
        case .growth: return "#90EE90"    // Light green
        case .worship: return "#DDA0DD"   // Plum
        }
    }
}

// MARK: - Life Category

public enum LifeCategory: String, CaseIterable, Sendable {
    case relationships = "relationships" // Covers: relationships, family, community
    case growth = "growth"              // Covers: growth, work, health, finances
    case challenges = "challenges"      // Covers: loss, decisions, future uncertainties
    case purpose = "purpose"            // Covers: purpose, guidance, life direction
    case spiritual = "spiritual"        // Covers: faith, worship, justice
    
    // Legacy mappings for backward compatibility
    public static func from(legacy: String) -> LifeCategory {
        switch legacy.lowercased() {
        case "relationships", "family", "community":
            return .relationships
        case "growth", "work", "health", "finances":
            return .growth
        case "loss", "decisions", "future":
            return .challenges
        case "purpose", "guidance":
            return .purpose
        case "faith", "worship", "justice":
            return .spiritual
        default:
            return .spiritual
        }
    }
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public var detailedDescription: String {
        switch self {
        case .relationships: return "Family, friendships, and community connections"
        case .growth: return "Personal development, career, health, and resources"
        case .challenges: return "Difficulties, decisions, and life transitions"
        case .purpose: return "Life direction, calling, and meaning"
        case .spiritual: return "Faith journey, worship, and divine connection"
        }
    }
    
    public var icon: String {
        switch self {
        case .relationships: return "person.2.fill"
        case .growth: return "arrow.up.circle.fill"
        case .challenges: return "exclamationmark.triangle.fill"
        case .purpose: return "star.fill"
        case .spiritual: return "hands.sparkles.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .relationships: return .pink
        case .growth: return .green
        case .challenges: return .orange
        case .purpose: return .indigo
        case .spiritual: return Color(red: 1.0, green: 0.84, blue: 0) // Gold
        }
    }
}

// MARK: - Life Situation

public struct LifeSituation: Identifiable, Sendable {
    public let id = UUID()
    public let text: String
    public let detectedEmotions: [EmotionalState]
    public let dominantEmotion: EmotionalState
    public let confidence: Double
    public let timestamp: Date
    public let suggestedVerses: [BibleVerse]
    public let guidancePrompt: String
    
    public init(
        text: String,
        detectedEmotions: [EmotionalState],
        dominantEmotion: EmotionalState,
        confidence: Double,
        timestamp: Date,
        suggestedVerses: [BibleVerse],
        guidancePrompt: String
    ) {
        self.text = text
        self.detectedEmotions = detectedEmotions
        self.dominantEmotion = dominantEmotion
        self.confidence = confidence
        self.timestamp = timestamp
        self.suggestedVerses = suggestedVerses
        self.guidancePrompt = guidancePrompt
    }
}

// MARK: - Verse Recommendation

public struct VerseRecommendation: Identifiable, Sendable {
    public let id = UUID()
    public let verse: BibleVerse
    public let relevanceScore: Double
    public let reason: String
    public let application: String
    public let category: LifeCategory?
    public let mood: EmotionalState
    
    public init(
        verse: BibleVerse,
        relevanceScore: Double,
        reason: String,
        application: String,
        category: LifeCategory?,
        mood: EmotionalState
    ) {
        self.verse = verse
        self.relevanceScore = relevanceScore
        self.reason = reason
        self.application = application
        self.category = category
        self.mood = mood
    }
} 