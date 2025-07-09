import Foundation
import LeavnCore

/// User data manager with integrated caching using the production cache service
actor UserDataManager {
    private var users: [String: User] = [:]
    private let cacheService: CacheServiceProtocol?
    private let usersKey = "cached_users"

    init(cacheService: CacheServiceProtocol? = nil) {
        self.cacheService = cacheService
        
        // Load users from cache on initialization
        Task {
            await loadUsersFromCache()
        }
    }

    func addUser(_ user: User) async {
        users[user.id] = user
        await persistUsers()
    }

    func getUser(byID id: String) async -> User? {
        return users[id]
    }

    func removeUser(byID id: String) async {
        users.removeValue(forKey: id)
        await persistUsers()
    }
    
    func getAllUsers() async -> [User] {
        return Array(users.values)
    }
    
    // MARK: - Private Cache Integration
    
    private func loadUsersFromCache() async {
        guard let cacheService = cacheService else { return }
        
        if let cachedUsers = await cacheService.get(usersKey, type: [String: User].self) {
            users = cachedUsers
        }
    }
    
    private func persistUsers() async {
        guard let cacheService = cacheService else { return }
        
        await cacheService.set(usersKey, value: users, expirationDate: nil)
    }
}


