import Foundation
import Combine

#if os(macOS)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Global rules and behaviors for the Leavn application
public enum GlobalRules {
    /// Defines the sync behavior across the application
    public enum SyncBehavior {
        /// Sync should be triggered automatically in the background
        case automatic
        /// Sync should be triggered manually
        case manual
        /// Sync should be triggered on specific events
        case eventBased
    }
    
    /// Current sync behavior
    nonisolated(unsafe) public static var syncBehavior: SyncBehavior = .automatic
    
    /// Minimum time between automatic syncs (in seconds)
    nonisolated(unsafe) public static var minimumSyncInterval: TimeInterval = 120
    
    /// Last sync timestamp
    nonisolated(unsafe) public static var lastSyncTimestamp: TimeInterval {
        get {
            UserDefaults.standard.double(forKey: "lastGlobalSyncTimestamp")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "lastGlobalSyncTimestamp")
            NotificationCenter.default.post(name: .syncSettingsChanged, object: nil)
        }
    }
    
    /// Check if enough time has passed since last sync
    public static var shouldSync: Bool {
        Date().timeIntervalSince1970 - lastSyncTimestamp > minimumSyncInterval
    }
    
    /// Trigger a sync operation if needed
    public static func triggerSyncIfNeeded() {
        guard shouldSync else { return }
        syncNow()
    }
    
    /// Force a sync operation immediately
    public static func syncNow() {
        // Update timestamp first to prevent rapid successive syncs
        lastSyncTimestamp = Date().timeIntervalSince1970
        
        // Notify all observers that sync is starting
        NotificationCenter.default.post(name: .syncWillStart, object: nil)
        
        DispatchQueue.global(qos: .utility).async {
            #if os(macOS)
            // Run sync script on macOS only
            let task = Foundation.Process()
            task.launchPath = "/bin/bash"
            task.arguments = ["-c", "~/Desktop/.leavn3_conversation_sync/sync_conversations.sh"]
            task.launch()
            task.waitUntilExit()
            #endif
            
            // Update timestamp and notify completion on main thread
            DispatchQueue.main.async {
                lastSyncTimestamp = Date().timeIntervalSince1970
                NotificationCenter.default.post(name: .syncDidComplete, object: nil)
            }
        }
    }
}

// MARK: - Notifications
public extension Notification.Name {
    /// Posted when a sync operation is about to start
    static let syncWillStart = Notification.Name("com.leavn3.sync.willStart")
    /// Posted when a sync operation has completed
    static let syncDidComplete = Notification.Name("com.leavn3.sync.didComplete")
    /// Posted when sync settings have changed
    static let syncSettingsChanged = Notification.Name("com.leavn3.sync.settingsChanged")
    /// Posted when network reachability changes
    static let reachabilityChanged = Notification.Name("com.leavn3.reachability.changed")
}

// MARK: - Property Wrapper for UserDefaults
@propertyWrapper
public struct UserDefault<T> {
    private let key: String
    private let defaultValue: T
    
    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            // Post notification when sync settings change
            if key.contains("sync") {
                NotificationCenter.default.post(name: .syncSettingsChanged, object: nil)
            }
        }
    }
}

// MARK: - Global Sync Hooks
public protocol Syncable {
    /// Prepare data for sync
    func prepareForSync()
    /// Handle sync completion
    func syncDidComplete()
}

/// Global sync manager that coordinates sync operations
public final class SyncManager: @unchecked Sendable {
    public static let shared = SyncManager()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Platform-agnostic notification names
        #if os(macOS)
        let didBecomeActive = NSApplication.didBecomeActiveNotification
        let willEnterForeground = NSApplication.willBecomeActiveNotification
        #elseif os(iOS) || os(tvOS) || os(watchOS)
        let didBecomeActive = UIApplication.didBecomeActiveNotification
        let willEnterForeground = UIApplication.willEnterForegroundNotification
        #endif
        
        // Sync when app becomes active
        NotificationCenter.default.publisher(for: didBecomeActive)
            .sink { _ in
                GlobalRules.triggerSyncIfNeeded()
            }
            .store(in: &cancellables)
        
        // Sync when network becomes reachable
        NotificationCenter.default.publisher(for: .reachabilityChanged)
            .sink { _ in
                GlobalRules.triggerSyncIfNeeded()
            }
            .store(in: &cancellables)
        
        // Sync when iCloud account changes
        #if os(macOS) || os(iOS)
        NotificationCenter.default.publisher(for: .NSUbiquityIdentityDidChange)
            .sink { _ in
                GlobalRules.syncNow()
            }
            .store(in: &cancellables)
        #endif
    }
}
