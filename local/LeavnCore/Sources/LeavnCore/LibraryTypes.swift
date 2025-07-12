import Foundation
import SwiftUI

// MARK: - VerseTheme for IlluminateService

public enum VerseTheme: String, CaseIterable, Sendable {
    case hope = "Hope"       // Covers: hope, joy, peace, gratitude
    case wisdom = "Wisdom"   // Covers: wisdom, understanding, guidance
    case love = "Love"       // Covers: love, compassion, forgiveness
    case strength = "Strength" // Covers: strength, courage, endurance, perseverance
    case faith = "Faith"     // Covers: faith, trust, praise, worship, gospel
    
    // Legacy mappings for backward compatibility
    public static func from(legacy: String) -> VerseTheme {
        switch legacy.lowercased() {
        case "hope", "joy", "peace", "gratitude":
            return .hope
        case "wisdom", "understanding", "guidance":
            return .wisdom
        case "love", "compassion", "forgiveness":
            return .love
        case "strength", "courage", "endurance", "perseverance":
            return .strength
        case "faith", "trust", "praise", "worship", "gospel":
            return .faith
        default:
            return .hope
        }
    }
    
    public var detailedDescription: String {
        switch self {
        case .hope: return "Hope, joy, peace, and gratitude"
        case .wisdom: return "Wisdom, understanding, and divine guidance"
        case .love: return "Love, compassion, and forgiveness"
        case .strength: return "Strength, courage, and perseverance"
        case .faith: return "Faith, trust, worship, and the Gospel"
        }
    }
}

// Extension to support IlluminateService
extension VerseTheme {
    init(name: String, color: Color, icon: String) {
        self = VerseTheme.from(legacy: name)
    }
}
