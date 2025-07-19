import Foundation

public struct SearchResult: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let reference: BibleReference
    public let text: String
    public let context: String
    
    public init(
        id: UUID = UUID(),
        reference: BibleReference,
        text: String,
        context: String
    ) {
        self.id = id
        self.reference = reference
        self.text = text
        self.context = context
    }
}