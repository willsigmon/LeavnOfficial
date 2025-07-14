import Foundation

public struct Devotion: Identifiable, Codable, Sendable {
    public let id: String
    public let title: String
    public let author: String
    public let content: String
    public let preview: String
    public let scripture: String
    public let date: Date
    public var imageURL: String?
    public var tags: [String] = []
    public var readingTime: Int = 5 // minutes
    
    public init(
        id: String,
        title: String,
        author: String,
        content: String,
        preview: String,
        scripture: String,
        date: Date,
        imageURL: String? = nil,
        tags: [String] = [],
        readingTime: Int = 5
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.content = content
        self.preview = preview
        self.scripture = scripture
        self.date = date
        self.imageURL = imageURL
        self.tags = tags
        self.readingTime = readingTime
    }
}