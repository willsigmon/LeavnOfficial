// SharedTypes.swift
// Additional types not in BibleModels.swift

import Foundation
import SwiftUI
import Combine
import OSLog

// MARK: - Service Types

public enum SearchType: String, CaseIterable {
    case all = "All"
    case exact = "Exact"  
    case phrase = "Phrase"
    case fullText = "Full Text"
}

// MARK: - Library Types

public enum HighlightColor: String, CaseIterable, Codable {
    case yellow, blue, green, pink, orange
}

// MARK: - Error Types

public enum ServiceError: LocalizedError, Sendable {
    // Network Group
    case network(NetworkErrorType)
    
    // Data Group
    case data(DataErrorType)
    
    // Auth Group
    case auth(AuthErrorType)
    
    // System Group
    case system(SystemErrorType)
    
    // User Group
    case user(UserErrorType)
    
    public enum NetworkErrorType: Sendable {
        case notConnected
        case timeout
        case serverError(statusCode: Int, message: String)
        case rateLimited
    }
    
    public enum DataErrorType: Sendable {
        case notFound
        case corrupted
        case invalidResponse
        case decodingError(Error)
    }
    
    public enum AuthErrorType: Sendable {
        case required
        case permissionDenied
        case expired
    }
    
    public enum SystemErrorType: Sendable {
        case notInitialized
        case resourceUnavailable
        case unknown(Error)
    }
    
    public enum UserErrorType: Sendable {
        case invalidParameters
        case invalidInput(field: String?)
    }
    
    public var errorDescription: String? {
        switch self {
        case .network(let type):
            switch type {
            case .notConnected: return "No internet connection"
            case .timeout: return "Request timed out"
            case .serverError(let code, let msg): return "Server error (\(code)): \(msg)"
            case .rateLimited: return "Too many requests. Please try again later"
            }
            
        case .data(let type):
            switch type {
            case .notFound: return "Resource not found"
            case .corrupted: return "Data corrupted"
            case .invalidResponse: return "Invalid server response"
            case .decodingError(let error): return "Data error: \(error.localizedDescription)"
            }
            
        case .auth(let type):
            switch type {
            case .required: return "Authentication required"
            case .permissionDenied: return "Permission denied"
            case .expired: return "Session expired"
            }
            
        case .system(let type):
            switch type {
            case .notInitialized: return "Service not initialized"
            case .resourceUnavailable: return "Resource temporarily unavailable"
            case .unknown(let error): return "System error: \(error.localizedDescription)"
            }
            
        case .user(let type):
            switch type {
            case .invalidParameters: return "Invalid parameters"
            case .invalidInput(let field): 
                return field != nil ? "Invalid \(field!)" : "Invalid input"
            }
        }
    }
}

public struct AppError: LocalizedError {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
    
    public var errorDescription: String? { message }
    
    public static let notFound = AppError(message: "Not found")
}

// MARK: - View Constants

public enum Theme: String, CaseIterable {
    case light = "Light"
    case dark = "Dark" 
    case system = "System"
}

// MARK: - App-wide Type Aliases

public typealias CompletionHandler = () -> Void
public typealias ErrorHandler = (Error) -> Void
public typealias SuccessHandler<T> = (T) -> Void

// MARK: - Community Types

public struct CommunityPost: Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let userName: String
    public let userAvatar: String?
    public let text: String
    public let verseReference: String?
    public let groupId: String?
    public let timestamp: Date
    public var likes: [String]
    public var comments: [Comment]
    public var isLikedByUser: Bool
    
    public init(
        id: String,
        userId: String,
        userName: String,
        userAvatar: String?,
        text: String,
        verseReference: String?,
        groupId: String?,
        timestamp: Date,
        likes: [String],
        comments: [Comment],
        isLikedByUser: Bool
    ) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.userAvatar = userAvatar
        self.text = text
        self.verseReference = verseReference
        self.groupId = groupId
        self.timestamp = timestamp
        self.likes = likes
        self.comments = comments
        self.isLikedByUser = isLikedByUser
    }
}

public struct Comment: Identifiable, Sendable {
    public let id: String
    public let userId: String
    public let userName: String
    public let text: String
    public let timestamp: Date
    
    public init(id: String, userId: String, userName: String, text: String, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.userName = userName
        self.text = text
        self.timestamp = timestamp
    }
}

public struct StudyGroup: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let memberCount: Int
    public var memberIds: [String]
    public var isJoined: Bool
    public let lastActivity: Date
    public let icon: String
    public let color: String // Changed from Color to String for Firestore compatibility
    
    public init(id: String, name: String, description: String, memberCount: Int, memberIds: [String], isJoined: Bool, lastActivity: Date, icon: String, color: String) {
        self.id = id
        self.name = name
        self.description = description
        self.memberCount = memberCount
        self.memberIds = memberIds
        self.isJoined = isJoined
        self.lastActivity = lastActivity
        self.icon = icon
        self.color = color
    }
}

public struct Challenge: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let description: String
    public let duration: String
    public let participantCount: Int
    public var participantIds: [String]
    public let progress: Double
    public var isJoined: Bool
    public let startDate: Date
    public let endDate: Date
    public let icon: String
    public let color: String // Changed from Color to String for Firestore compatibility
    
    public init(
        id: String,
        title: String,
        description: String,
        duration: String,
        participantCount: Int,
        participantIds: [String],
        progress: Double,
        isJoined: Bool,
        startDate: Date,
        endDate: Date,
        icon: String,
        color: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.duration = duration
        self.participantCount = participantCount
        self.participantIds = participantIds
        self.progress = progress
        self.isJoined = isJoined
        self.startDate = startDate
        self.endDate = endDate
        self.icon = icon
        self.color = color
    }
}
