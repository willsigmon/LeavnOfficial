import Foundation

public struct UserProfile: Identifiable, Codable, Sendable {
    public let id: String
    public let name: String
    public let email: String?
    public let preferredTranslation: String
    public let fontSize: Double
    public let theme: String
    public let readingPlan: String?
    public let dailyGoal: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        email: String? = nil,
        preferredTranslation: String = "",
        fontSize: Double = 16.0,
        theme: String = "light",
        readingPlan: String? = nil,
        dailyGoal: Int = 15,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.preferredTranslation = preferredTranslation
        self.fontSize = fontSize
        self.theme = theme
        self.readingPlan = readingPlan
        self.dailyGoal = dailyGoal
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

@available(iOS 14.0, *)
public struct CloudSyncStoreDiagnostics: Codable, Sendable {
    public struct Device: Codable, Sendable {
        public let name: String
        public let model: String
        public let systemVersion: String
        public let isCurrentDevice: Bool
    }

    public let isPrimary: Bool
    public let device: Device
    public let syncErrors: [String]
    public let lastZoneFetchDate: Date?
    public let lastTokenFetchDate: Date?
}
