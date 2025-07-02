import Foundation
import LeavnCore
import Combine

// MARK: - Production Analytics Service Implementation

public actor ProductionAnalyticsService: AnalyticsServiceProtocol {
    
    // MARK: - Properties
    
    private var isInitialized = false
    private var eventQueue: [AnalyticsEvent] = []
    private var userProperties: [String: String] = [:]
    private let maxQueueSize = 100
    private let flushInterval: TimeInterval = 30.0
    private var flushTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    public init() {}
    
    public func initialize() async throws {
        isInitialized = true
        
        // Start periodic flush
        flushTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: UInt64(flushInterval * 1_000_000_000))
                await flush()
            }
        }
        
        print("📊 ProductionAnalyticsService initialized")
    }
    
    deinit {
        flushTask?.cancel()
    }
    
    // MARK: - AnalyticsServiceProtocol Implementation
    
    public func track(event: AnalyticsEvent) async {
        guard isInitialized else { return }
        
        eventQueue.append(event)
        
        // Auto-flush if queue is full
        if eventQueue.count >= maxQueueSize {
            await flush()
        }
    }
    
    public func setUserProperty(_ key: String, value: String) async {
        guard isInitialized else { return }
        
        userProperties[key] = value
    }
    
    public func flush() async {
        guard isInitialized, !eventQueue.isEmpty else { return }
        
        let eventsToSend = eventQueue
        eventQueue.removeAll()
        
        // In production, this would send to an analytics service
        print("📊 Flushing \(eventsToSend.count) analytics events")
        
        for event in eventsToSend {
            print("  - \(event.name): \(event.parameters ?? [:])")
        }
    }
}
