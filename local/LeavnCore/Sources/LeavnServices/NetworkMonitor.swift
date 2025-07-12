import Foundation
import LeavnCore

actor UserDataManager {
    // Removed persistenceService property and initializer parameter

    private var users: [String: User] = [:]

    init() {
        // Removed persistenceService initialization

        // TODO: Persistence logic should be re-evaluated and replaced with an existing cache or persistence mechanism (such as CacheManager)
        /*
        if let savedUsers = try? persistenceService.loadUsers() {
            users = savedUsers
        }
        */
    }

    func addUser(_ user: User) async {
        users[user.id] = user
        // TODO: Persistence logic should be re-evaluated and replaced with an existing cache or persistence mechanism (such as CacheManager)
        /*
        try? await persistenceService.saveUsers(users)
        */
    }

    func getUser(byID id: String) async -> User? {
        return users[id]
    }

    func removeUser(byID id: String) async {
        users.removeValue(forKey: id)
        // TODO: Persistence logic should be re-evaluated and replaced with an existing cache or persistence mechanism (such as CacheManager)
        /*
        try? await persistenceService.saveUsers(users)
        */
    }
}


