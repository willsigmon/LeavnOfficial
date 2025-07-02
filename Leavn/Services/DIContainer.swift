import Foundation
import SwiftUI
import LeavnCore
import LeavnServices

@MainActor
final class DIContainer: ObservableObject {
    static let shared = DIContainer()
    @Published var isInitialized = false
    
    private init() {}
    
    func initialize() async {
        // Initialize services
        isInitialized = true
    }
}

// MARK: - Placeholder Models
struct BibleBook: Identifiable {
    let id: String
    let name: String
}

@MainActor
struct GlobalRules {
    static var shouldSync: Bool { false }
    static func syncNow() {}
    static func triggerSyncIfNeeded() {}
}

@MainActor
final class SyncManager {
    static let shared = SyncManager()
    private init() {}
}
