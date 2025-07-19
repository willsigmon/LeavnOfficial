import Foundation

public struct ContentIssue: Identifiable, Codable, Hashable, Equatable {
    public let id: String
    public let type: IssueType
    public let severity: Severity
    public let title: String
    public let description: String
    public let affectedContent: AffectedContent
    public let reportedBy: String?
    public let status: Status
    public let createdAt: Date
    public let updatedAt: Date
    public let resolvedAt: Date?
    
    public enum IssueType: String, Codable, CaseIterable {
        case missingContent = "Missing Content"
        case incorrectTranslation = "Incorrect Translation"
        case formattingError = "Formatting Error"
        case brokenReference = "Broken Reference"
        case audioSync = "Audio Sync Issue"
        case typographical = "Typographical Error"
        case technicalError = "Technical Error"
        case other = "Other"
    }
    
    public enum Severity: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
    
    public enum Status: String, Codable, CaseIterable {
        case reported = "Reported"
        case acknowledged = "Acknowledged"
        case inProgress = "In Progress"
        case resolved = "Resolved"
        case closed = "Closed"
        case wontFix = "Won't Fix"
    }
    
    public struct AffectedContent: Codable, Hashable, Equatable {
        public let book: String?
        public let chapter: Int?
        public let verse: Int?
        public let translation: String?
        public let contentId: String?
        public let contentType: ContentType
        
        public enum ContentType: String, Codable {
            case verse = "Verse"
            case audio = "Audio"
            case note = "Note"
            case crossReference = "Cross Reference"
            case commentary = "Commentary"
            case other = "Other"
        }
        
        public init(
            book: String? = nil,
            chapter: Int? = nil,
            verse: Int? = nil,
            translation: String? = nil,
            contentId: String? = nil,
            contentType: ContentType
        ) {
            self.book = book
            self.chapter = chapter
            self.verse = verse
            self.translation = translation
            self.contentId = contentId
            self.contentType = contentType
        }
    }
    
    public init(
        id: String? = nil,
        type: IssueType,
        severity: Severity,
        title: String,
        description: String,
        affectedContent: AffectedContent,
        reportedBy: String? = nil,
        status: Status = .reported,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        resolvedAt: Date? = nil
    ) {
        self.id = id ?? UUID().uuidString
        self.type = type
        self.severity = severity
        self.title = title
        self.description = description
        self.affectedContent = affectedContent
        self.reportedBy = reportedBy
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.resolvedAt = resolvedAt
    }
}