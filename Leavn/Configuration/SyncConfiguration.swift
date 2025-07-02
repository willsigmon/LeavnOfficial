import Foundation

/// Global configuration for Leavn sync services
public struct SyncConfiguration {
    /// Shared instance
    public static let shared = SyncConfiguration()
    
    /// Base directory for sync operations
    public let baseDirectory: URL = {
        #if os(macOS)
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?
            .appendingPathComponent("Leavn/ConversationSync") ?? 
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Desktop/.leavn_conversation_sync")
        #else
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.leavn.conversationsync")?
            .appendingPathComponent("ConversationSync") ?? 
            FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        #endif
    }()
    
    /// Directory for conversation data
    public var conversationsDirectory: URL {
        baseDirectory.appendingPathComponent("conversations")
    }
    
    /// Directory for extension data
    public var extensionsDirectory: URL {
        baseDirectory.appendingPathComponent("extensions")
    }
    
    /// Configuration file URL
    public var configFile: URL {
        baseDirectory.appendingPathComponent("config.json")
    }
    
    /// Minimum time between syncs (in seconds)
    public var minimumSyncInterval: TimeInterval = 60
    
    /// Maximum number of log files to keep
    public var maxLogFiles: Int = 10
    
    private init() {
        // Ensure directories exist
        try? FileManager.default.createDirectory(at: conversationsDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: extensionsDirectory, withIntermediateDirectories: true)
        
        // Initialize config file if it doesn't exist
        if !FileManager.default.fileExists(atPath: configFile.path) {
            let initialConfig: [String: Any] = [
                "lastSync": 0,
                "version": 1,
                "enabled": true
            ]
            try? JSONSerialization.data(withJSONObject: initialConfig)
                .write(to: configFile)
        }
    }
    
    /// Check if sync is enabled
    public var isEnabled: Bool {
        guard let data = try? Data(contentsOf: configFile),
              let config = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return true // Default to enabled if config can't be read
        }
        return config["enabled"] as? Bool ?? true
    }
    
    /// Update last sync timestamp
    public func updateLastSync() {
        guard var config = (try? JSONSerialization.jsonObject(with: Data(contentsOf: configFile))) as? [String: Any] else {
            return
        }
        config["lastSync"] = Date().timeIntervalSince1970
        try? JSONSerialization.data(withJSONObject: config)
            .write(to: configFile)
    }
}
