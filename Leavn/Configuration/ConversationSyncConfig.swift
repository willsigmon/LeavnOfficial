import Foundation

public enum ConversationSyncConfig {
    #if os(macOS)
    public static let syncDirectory: URL = {
        // First check the standard app support location
        let appSupportURL = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent("Leavn/ConversationSync")
        
        // Fall back to desktop location
        let desktopURL = FileManager.default.urls(
            for: .desktopDirectory,
            in: .userDomainMask
        ).first?.appendingPathComponent(".leavn_conversation_sync")
        
        // Check which one exists
        if let appSupportURL = appSupportURL,
           FileManager.default.fileExists(atPath: appSupportURL.path) {
            return appSupportURL
        } else if let desktopURL = desktopURL,
                  FileManager.default.fileExists(atPath: desktopURL.path) {
            return desktopURL
        }
        
        // Default to app support location if neither exists yet
        return appSupportURL ?? desktopURL ?? URL(fileURLWithPath: "~/Library/Application Support/Leavn/ConversationSync")
    }()
    #else
    // For iOS, watchOS, tvOS, etc.
    public static let syncDirectory: URL = {
        guard let url = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.leavn3.conversationsync"
        )?.appendingPathComponent("ConversationSync") else {
            fatalError("Could not create shared container URL")
        }
        return url
    }()
    #endif
}
