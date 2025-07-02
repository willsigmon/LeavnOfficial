import Foundation
import SwiftUI

// MARK: - VerseTheme for IlluminateService

public enum VerseTheme: String, CaseIterable, Sendable {
    case hope = "Hope"
    case love = "Love"
    case faith = "Faith"
    case peace = "Peace"
    case strength = "Strength"
    case wisdom = "Wisdom"
    case gratitude = "Gratitude"
    case forgiveness = "Forgiveness"
    case courage = "Courage"
    case joy = "Joy"
    case trust = "Trust"
    case compassion = "Compassion"
    case endurance = "Endurance"
    case perseverance = "Perseverance"
    case understanding = "Understanding"
    case praise = "Praise"
    case worship = "Worship"
    case gospel = "Gospel"
}

// Extension to support IlluminateService
extension VerseTheme {
    init(name: String, color: Color, icon: String) {
        // Map name to enum case
        switch name.lowercased() {
        case "faith": self = .faith
        case "trust": self = .trust
        case "love": self = .love
        case "compassion": self = .compassion
        case "endurance": self = .endurance
        case "perseverance": self = .perseverance
        case "wisdom": self = .wisdom
        case "understanding": self = .understanding
        case "praise": self = .praise
        case "worship": self = .worship
        case "gospel": self = .gospel
        default: self = .hope // Default case
        }
    }
}
