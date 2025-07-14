import Foundation
import CoreData
import Combine

// MARK: - Default User Data Manager
public final class DefaultUserDataManager: UserDataManagerProtocol {
    @Published private var _currentUser: User?
    private let context: NSManagedObjectContext
    private let secureStorage: SecureStorage
    private let userDefaults = UserDefaults.standard
    
    public var currentUser: User? {
        _currentUser
    }
    
    public init(context: NSManagedObjectContext, secureStorage: SecureStorage) {
        self.context = context
        self.secureStorage = secureStorage
        
        // Load cached user on init
        Task {
            await loadCachedUser()
        }
    }
    
    public func updateUser(_ user: User) async throws {
        _currentUser = user
        
        // Save to secure storage
        try await secureStorage.save(user, forKey: "current_user")
        
        // Save to Core Data
        try await context.perform {
            let request: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", user.id)
            
            let existingUser = try self.context.fetch(request).first
            let cachedUser = existingUser ?? CachedUser(context: self.context)
            
            cachedUser.id = user.id
            cachedUser.email = user.email
            cachedUser.name = user.name
            cachedUser.profileImageURL = user.profileImageURL
            cachedUser.isPremium = user.isPremium
            cachedUser.lastUpdated = Date()
            
            try self.context.save()
        }
    }
    
    public func clearUserData() async throws {
        _currentUser = nil
        
        // Clear from secure storage
        try await secureStorage.remove(forKey: "current_user")
        
        // Clear from Core Data
        try await context.perform {
            let request: NSFetchRequest<NSFetchRequestResult> = CachedUser.fetchRequest()
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try self.context.execute(deleteRequest)
            try self.context.save()
        }
        
        // Clear user defaults
        userDefaults.removeObject(forKey: "user_preferences")
    }
    
    private func loadCachedUser() async {
        // Try to load from secure storage first
        if let cachedUser: User = try? await secureStorage.load(User.self, forKey: "current_user") {
            _currentUser = cachedUser
            return
        }
        
        // Fallback to Core Data
        do {
            try await context.perform {
                let request: NSFetchRequest<CachedUser> = CachedUser.fetchRequest()
                request.fetchLimit = 1
                request.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: false)]
                
                if let cachedUser = try self.context.fetch(request).first {
                    self._currentUser = User(
                        id: cachedUser.id ?? "",
                        email: cachedUser.email ?? "",
                        name: cachedUser.name ?? "",
                        profileImageURL: cachedUser.profileImageURL,
                        isPremium: cachedUser.isPremium
                    )
                }
            }
        } catch {
            print("Failed to load cached user: \(error)")
        }
    }
}

// MARK: - Core Data Entity
@objc(CachedUser)
public class CachedUser: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var email: String?
    @NSManaged public var name: String?
    @NSManaged public var profileImageURL: String?
    @NSManaged public var isPremium: Bool
    @NSManaged public var lastUpdated: Date?
}

extension CachedUser {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedUser> {
        return NSFetchRequest<CachedUser>(entityName: "CachedUser")
    }
}