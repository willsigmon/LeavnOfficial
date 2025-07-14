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

// MARK: - Base View Model
@MainActor
open class BaseViewModel<State: ViewState, Event>: ObservableObject {
    @Published private(set) var state: State
    
    public init(initialState: State) {
        self.state = initialState
    }
    
    open func send(_ event: Event) {
        // To be overridden by subclasses
    }
    
    public func updateState(_ update: (inout State) -> Void) {
        update(&state)
    }
}

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