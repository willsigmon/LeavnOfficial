import Foundation

// MARK: - AsyncChannel
/// A channel for sending values to an async stream
public final class AsyncChannel<Element> {
    private let continuation: AsyncStream<Element>.Continuation
    public let stream: AsyncStream<Element>
    
    public init(bufferingPolicy: AsyncStream<Element>.Continuation.BufferingPolicy = .unbounded) {
        var continuation: AsyncStream<Element>.Continuation!
        self.stream = AsyncStream(bufferingPolicy: bufferingPolicy) { cont in
            continuation = cont
        }
        self.continuation = continuation
    }
    
    public func send(_ value: Element) {
        continuation.yield(value)
    }
    
    public func finish() {
        continuation.finish()
    }
    
    deinit {
        continuation.finish()
    }
}