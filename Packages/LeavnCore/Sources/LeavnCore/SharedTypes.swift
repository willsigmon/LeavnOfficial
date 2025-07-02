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
    case notInitialized
    case networkError(String)
    case serverError(statusCode: Int, message: String)
    case authenticationRequired
    case permissionDenied
    case notFound
    case rateLimited
    case dataCorrupted
    case invalidResponse
    case decodingError(Error)
    case notConnected
    case invalidParameters
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .notInitialized:
            return "Service not initialized"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .authenticationRequired:
            return "Authentication required"
        case .permissionDenied:
            return "Permission denied"
        case .notFound:
            return "Resource not found"
        case .rateLimited:
            return "Rate limited"
        case .dataCorrupted:
            return "Data corrupted"
        case .invalidResponse:
            return "Invalid response"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .notConnected:
            return "No internet connection"
        case .invalidParameters:
            return "Invalid parameters"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
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
