import Foundation
import SwiftUI

// MARK: - Emotional State

public enum EmotionalState: String, CaseIterable, Sendable {
    case anxious = "anxious"
    case depressed = "depressed"
    case angry = "angry"
    case fearful = "fearful"
    case joyful = "joyful"
    case grateful = "grateful"
    case confused = "confused"
    case hopeful = "hopeful"
    case lonely = "lonely"
    case overwhelmed = "overwhelmed"
    case peaceful = "peaceful"
    case sad = "sad"
    case stressed = "stressed"
    case worried = "worried"
    case content = "content"
    case uncertain = "uncertain"
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .depressed: return "😔"
        case .angry: return "😤"
        case .fearful: return "😨"
        case .joyful: return "😊"
        case .grateful: return "🙏"
        case .confused: return "😕"
        case .hopeful: return "🤗"
        case .lonely: return "😢"
        case .overwhelmed: return "😵"
        case .peaceful: return "😌"
        case .sad: return "😢"
        case .stressed: return "😣"
        case .worried: return "😟"
        case .content: return "😊"
        case .uncertain: return "🤔"
        }
    }
    
    public var color: String {
        switch self {
        case .anxious: return "#FFA500"
        case .depressed: return "#4B0082"
        case .angry: return "#DC143C"
        case .fearful: return "#8B4513"
        case .joyful: return "#FFD700"
        case .grateful: return "#32CD32"
        case .confused: return "#708090"
        case .hopeful: return "#87CEEB"
        case .lonely: return "#191970"
        case .overwhelmed: return "#B22222"
        case .peaceful: return "#98FB98"
        case .sad: return "#4682B4"
        case .stressed: return "#FF6347"
        case .worried: return "#DDA0DD"
        case .content: return "#90EE90"
        case .uncertain: return "#D3D3D3"
        }
    }
}

// MARK: - Life Category

public enum LifeCategory: String, CaseIterable, Sendable {
    case relationships = "relationships"
    case work = "work"
    case health = "health"
    case finances = "finances"
    case family = "family"
    case purpose = "purpose"
    case faith = "faith"
    case future = "future"
    case loss = "loss"
    case decisions = "decisions"
    case growth = "growth"
    case community = "community"
    case justice = "justice"
    case worship = "worship"
    case guidance = "guidance"
    
    public var displayName: String {
        rawValue.capitalized
    }
    
    public var icon: String {
        switch self {
        case .relationships: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .finances: return "dollarsign.circle.fill"
        case .family: return "house.fill"
        case .purpose: return "star.fill"
        case .faith: return "cross.fill"
        case .future: return "arrow.forward.circle.fill"
        case .loss: return "heart.slash.fill"
        case .decisions: return "questionmark.circle.fill"
        case .growth: return "arrow.up.circle.fill"
        case .community: return "person.3.fill"
        case .justice: return "scale.3d"
        case .worship: return "hands.sparkles.fill"
        case .guidance: return "compass.drawing"
        }
    }
    
    public var color: Color {
        switch self {
        case .relationships: return .pink
        case .work: return .blue
        case .health: return .green
        case .finances: return .orange
        case .family: return .purple
        case .purpose: return .indigo
        case .faith: return .yellow
        case .future: return .mint
        case .loss: return .gray
        case .decisions: return .brown
        case .growth: return .cyan
        case .community: return .red
        case .justice: return .teal
        case .worship: return Color(red: 1.0, green: 0.84, blue: 0)
        case .guidance: return Color(red: 0, green: 0, blue: 0.5)
        }
    }
}

// MARK: - Life Situation

public struct LifeSituation: Sendable {
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