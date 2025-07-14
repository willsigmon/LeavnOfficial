import Foundation
import Combine

@MainActor
public final class SyncManager: ObservableObject {
    public static let shared = SyncManager()
    
    @Published public var isSyncing = false
    @Published public var lastSyncDate: Date?
    @Published public var syncError: Error?
    
    private var syncTask: Task<Void, Never>?
    private let syncInterval: TimeInterval = 300 // 5 minutes
    
    private init() {
        startPeriodicSync()
    }
    
    deinit {
        syncTask?.cancel()
        syncTask = nil
    }
    
    public func syncNow() {
        guard !isSyncing else { return }
        
        Task { [weak self] in
            await self?.performSync()
        }
    }
    
    public func startPeriodicSync() {
        syncTask?.cancel()
        syncTask = Task { [weak self] in
            while !Task.isCancelled {
                await self?.performSync()
                guard let self = self else { break }
                try? await Task.sleep(nanoseconds: UInt64(self.syncInterval * 1_000_000_000))
            }
        }
    }
    
    public func stopPeriodicSync() {
        syncTask?.cancel()
        syncTask = nil
    }
    
    private func performSync() async {
        isSyncing = true
        syncError = nil
        
        do {
            // Perform sync operations here
            // For now, just simulate with a delay
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            lastSyncDate = Date()
            print("Sync completed successfully")
        } catch {
            syncError = error
            print("Sync failed: \(error)")
        }
        
        isSyncing = false
    }
}