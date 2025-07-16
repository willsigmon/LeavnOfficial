import Foundation

// MARK: - Base Types
public protocol UseCase {
    associatedtype Input
    associatedtype Output
    func execute(_ input: Input) async throws -> Output
}

public protocol ViewState {}

public protocol AnalyticsEvent {
    var name: String { get }
    var parameters: [String: Any]? { get }
}

// MARK: - Base View Model for Generic State/Event Pattern
// Use the BaseViewModel from ViewModelErrorHandling.swift for non-generic inheritance
// This pattern is for ViewModels that need strongly-typed state and events

// MARK: - Repository Protocol
public protocol Repository {}

// MARK: - Common Analytics Event
public enum CommonAnalyticsEvent: AnalyticsEvent {
    case search(query: String, category: String)
    
    public var name: String {
        switch self {
        case .search: return "search_performed"
        }
    }
    
    public var parameters: [String: Any]? {
        switch self {
        case .search(let query, let category):
            return ["query": query, "category": category]
        }
    }
}