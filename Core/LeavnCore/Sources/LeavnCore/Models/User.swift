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

// MARK: - Auth User Model
public struct AuthUser: Codable {
    public let id: String
    public let email: String
    public var displayName: String?
    public var photoURL: String?
    public var isEmailVerified: Bool
    public var authProvider: AuthProvider
    public let createdAt: Date
    
    public init(
        id: String,
        email: String,
        displayName: String? = nil,
        photoURL: String? = nil,
        isEmailVerified: Bool = false,
        authProvider: AuthProvider = .email,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.isEmailVerified = isEmailVerified
        self.authProvider = authProvider
        self.createdAt = createdAt
    }
}

// MARK: - Auth Provider
public enum AuthProvider: String, Codable {
    case email
    case apple
    case google
    case passkey
}

// MARK: - Voice Configuration
public struct VoiceConfiguration: Codable {
    public let id: String
    public let name: String
    public var speed: Double
    public var pitch: Double
    public var volume: Double
    
    public init(
        id: String,
        name: String,
        speed: Double = 1.0,
        pitch: Double = 1.0,
        volume: Double = 1.0
    ) {
        self.id = id
        self.name = name
        self.speed = speed
        self.pitch = pitch
        self.volume = volume
    }
    
    public static let defaultVoice = VoiceConfiguration(
        id: "default",
        name: "Default Voice",
        speed: 1.0,
        pitch: 1.0,
        volume: 1.0
    )
}