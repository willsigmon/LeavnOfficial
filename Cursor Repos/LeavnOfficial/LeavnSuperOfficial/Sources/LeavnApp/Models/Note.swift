import Foundation
import Tagged
import IdentifiedCollections

// MARK: - Type-Safe IDs
public typealias NoteID = Tagged<Note, UUID>

// MARK: - Note Model
public struct Note: Identifiable, Equatable, Codable, Sendable {
    public let id: NoteID
    public let reference: BibleReference
    public let title: String?
    public var content: String
    public let createdAt: Date
    public var updatedAt: Date
    public var tags: [String]
    public let isPrivate: Bool
    public var linkedVerses: [BibleReference]
    public var attachments: [NoteAttachment]
    
    public init(
        id: NoteID = NoteID(UUID()),
        reference: BibleReference,
        title: String? = nil,
        content: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        tags: [String] = [],
        isPrivate: Bool = true,
        linkedVerses: [BibleReference] = [],
        attachments: [NoteAttachment] = []
    ) {
        self.id = id
        self.reference = reference
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.tags = tags
        self.isPrivate = isPrivate
        self.linkedVerses = linkedVerses
        self.attachments = attachments
    }
}

// MARK: - Note Attachment
public struct NoteAttachment: Equatable, Codable, Sendable, Identifiable {
    public let id: UUID
    public let type: AttachmentType
    public let url: URL
    public let name: String
    public let sizeInBytes: Int64
    
    public enum AttachmentType: String, Codable, Sendable {
        case image
        case audio
        case document
    }
    
    public init(
        id: UUID = UUID(),
        type: AttachmentType,
        url: URL,
        name: String,
        sizeInBytes: Int64
    ) {
        self.id = id
        self.type = type
        self.url = url
        self.name = name
        self.sizeInBytes = sizeInBytes
    }
}