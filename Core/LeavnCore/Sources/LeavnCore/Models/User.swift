import Foundation

// MARK: - User Model
public struct User: Codable, Identifiable {
    public let id: String
    public let email: String
    public var name: String
    public var profileImageURL: String?
    public var isPremium: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: String,
        email: String,
        name: String,
        profileImageURL: String? = nil,
        isPremium: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.name = name
        self.profileImageURL = profileImageURL
        self.isPremium = isPremium
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// AuthUser and AuthProvider are defined in AuthenticationTypes.swift

// MARK: - Voice Configuration
// VoiceConfiguration is now defined in BibleTypes.swift to avoid duplication