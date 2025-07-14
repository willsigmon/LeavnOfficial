import Foundation
import Combine

// MARK: - ViewModel Protocol
@MainActor
public protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Event
    
    var state: State { get }
    func send(_ event: Event)
}

// MARK: - Base ViewModel Implementation
@MainActor
open class BaseViewModel<State, Event>: ObservableObject {
    @Published public private(set) var currentState: State
    private var cancellables = Set<AnyCancellable>()
    
    public init(initialState: State) {
        self.currentState = initialState
    }
    
    // Legacy property name for compatibility
    public var state: State {
        currentState
    }
    
    open func handle(event: Event) {
        // Override in subclasses
    }
    
    // Legacy method name for compatibility
    open func send(_ event: Event) {
        handle(event: event)
    }
    
    public func updateState(_ update: (inout State) -> Void) async {
        await MainActor.run {
            update(&currentState)
        }
    }
    
    public func updateState(_ update: (inout State) -> Void) {
        update(&currentState)
    }
    
    public func updateState(_ newState: State) {
        currentState = newState
    }
}

// MARK: - View State Protocol
public protocol ViewState {
    var isLoading: Bool { get }
    var error: Error? { get }
}

// MARK: - Common View States
public struct LoadableViewState<Content>: ViewState {
    public var isLoading: Bool
    public var error: Error?
    public var content: Content?
    
    public init(
        isLoading: Bool = false,
        error: Error? = nil,
        content: Content? = nil
    ) {
        self.isLoading = isLoading
        self.error = error
        self.content = content
    }
    
    public static var initial: LoadableViewState {
        LoadableViewState()
    }
    
    public static func loading() -> LoadableViewState {
        LoadableViewState(isLoading: true)
    }
    
    public static func loaded(_ content: Content) -> LoadableViewState {
        LoadableViewState(content: content)
    }
    
    public static func failed(_ error: Error) -> LoadableViewState {
        LoadableViewState(error: error)
    }
}

// MARK: - Async Command
public struct AsyncCommand<Input, Output> {
    private let operation: (Input) async throws -> Output
    
    public init(operation: @escaping (Input) async throws -> Output) {
        self.operation = operation
    }
    
    public func execute(_ input: Input) async throws -> Output {
        try await operation(input)
    }
}

// MARK: - View Model Error Handling
public extension BaseViewModel {
    func handle<T>(_ operation: @escaping () async throws -> T) async -> Result<T, Error> {
        do {
            let result = try await operation()
            return .success(result)
        } catch {
            return .failure(error)
        }
    }
    
    func handleWithLoading<T>(
        _ operation: @escaping () async throws -> T,
        onStart: @escaping () -> Void,
        onComplete: @escaping (Result<T, Error>) -> Void
    ) {
        Task {
            await MainActor.run { onStart() }
            let result = await handle(operation)
            await MainActor.run { onComplete(result) }
        }
    }
}