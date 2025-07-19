import Foundation
import SwiftUI
import Tagged

// MARK: - Type-Safe IDs
public typealias HighlightID = Tagged<Highlight, UUID>

// MARK: - Highlight Model
public struct Highlight: Equatable, Codable, Sendable, Identifiable {
    public let id: HighlightID
    public let reference: BibleReference
    public let text: String
    public let color: HighlightColor
    public let createdAt: Date
    public let updatedAt: Date
    public let note: String?
    public let tags: [String]
    
    public init(
        id: HighlightID = HighlightID(UUID()),
        reference: BibleReference,
        text: String,
        color: HighlightColor,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        note: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.reference = reference
        self.text = text
        self.color = color
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.note = note
        self.tags = tags
    }
}

// MARK: - Highlight Color
public enum HighlightColor: String, CaseIterable, Codable, Sendable {
    case yellow
    case orange
    case red
    case purple
    case blue
    case green
    case pink
    case gray
    
    public var swiftUIColor: Color {
        switch self {
        case .yellow: return .yellow.opacity(0.3)
        case .orange: return .orange.opacity(0.3)
        case .red: return .red.opacity(0.3)
        case .purple: return .purple.opacity(0.3)
        case .blue: return .blue.opacity(0.3)
        case .green: return .green.opacity(0.3)
        case .pink: return .pink.opacity(0.3)
        case .gray: return .gray.opacity(0.3)
        }
    }
    
    public var name: String {
        rawValue.capitalized
    }
}