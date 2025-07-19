import XCTest
import ComposableArchitecture
import Dependencies
@testable import LeavnApp

// MARK: - XCTestCase Extensions
extension XCTestCase {
    /// Creates a test store with default dependencies
    @MainActor
    func makeTestStore<State, Action>(
        initialState: State,
        reducer: @escaping () -> Reduce<State, Action>,
        dependencies: @escaping (inout DependencyValues) -> Void = { _ in }
    ) -> TestStore<State, Action, State, Action, ()> {
        TestStore(initialState: initialState, reducer: reducer, withDependencies: dependencies)
    }
    
    /// Waits for async expectations with timeout
    func waitForAsync(
        timeout: TimeInterval = 1.0,
        file: StaticString = #file,
        line: UInt = #line,
        _ work: () async throws -> Void
    ) async {
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    try await work()
                }
                
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                    throw TestError.timeout
                }
                
                _ = try await group.next()
                group.cancelAll()
            }
        } catch {
            if error is TestError {
                XCTFail("Async operation timed out", file: file, line: line)
            } else {
                XCTFail("Async operation failed: \(error)", file: file, line: line)
            }
        }
    }
}

// MARK: - Test Errors
enum TestError: Error {
    case timeout
    case invalidState
    case missingDependency
}

// MARK: - Performance Testing
extension XCTestCase {
    func measureAsync(
        iterations: Int = 10,
        file: StaticString = #file,
        line: UInt = #line,
        _ block: @escaping () async throws -> Void
    ) {
        measure {
            let expectation = expectation(description: "async measure")
            Task {
                try await block()
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10)
        }
    }
}