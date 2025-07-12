import Foundation
import LeavnCore
import AuthenticationServices

// MARK: - Simple Production User Service Implementation

@MainActor
public final class SimpleUserService: UserServiceProtocol {
    
    // MARK: - Properties
    
    private let cacheService: CacheServiceProtocol
    private var currentUser: LeavnCore.User?
    private var isInitialized = false
    
    // User defaults keys
    private enum UserKeys {
        static let currentUser = "current_user"
        static let isSignedIn = "is_signed_in"
        static let userPreferences = "user_preferences"
    }
    
    // MARK: - Initialization
    
    public init(cacheService: CacheServiceProtocol) {
        self.cacheService = cacheService
    }
    
    public func initialize() async throws {
        // Load cached user
        currentUser = await cacheService.get(UserKeys.currentUser, type: LeavnCore.User.self)
        
        // Create default user if none exists
        if currentUser == nil {
            currentUser = createDefaultUser()
            await saveUser()
        }
        
        isInitialized = true
        print("👤 SimpleUserService initialized")
    }
    
    // MARK: - UserServiceProtocol Implementation
    
    public func getCurrentUser() async throws -> LeavnCore.User? {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        return currentUser
    }
    
    public func updateUser(_ user: LeavnCore.User) async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        currentUser = user
        await saveUser()
    }
    
    public func updatePreferences(_ preferences: UserPreferences) async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        guard let user = currentUser else {
            throw ServiceError.auth(.required)
        }
        
        // Create new user with updated preferences
        let updatedUser = LeavnCore.User(
            id: user.id,
            name: user.name,
            email: user.email,
            preferences: preferences
        )
        
        currentUser = updatedUser
        await saveUser()
    }
    
    public func deleteUser() async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        currentUser = nil
        await cacheService.remove(UserKeys.currentUser)
        await cacheService.remove(UserKeys.isSignedIn)
        await cacheService.remove(UserKeys.userPreferences)
        
        // Create new default user
        currentUser = createDefaultUser()
        await saveUser()
    }
    
    // MARK: - Authentication Methods
    
    public func signIn() async throws -> LeavnCore.User {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        // For now, return the current user or create one
        if let user = currentUser {
            await cacheService.set(UserKeys.isSignedIn, value: true, expirationDate: nil)
            return user
        } else {
            return try await createAndSignInUser()
        }
    }
    
    public func signOut() async throws {
        guard isInitialized else {
            throw ServiceError.system(.notInitialized)
        }
        
        await cacheService.set(UserKeys.isSignedIn, value: false, expirationDate: nil)
    }
    
    public func isSignedIn() async -> Bool {
        return await cacheService.get(UserKeys.isSignedIn, type: Bool.self) ?? false
    }
    
    // MARK: - Private Methods
    
    private func createDefaultUser() -> LeavnCore.User {
        let defaultPreferences = UserPreferences(
            defaultTranslation: "KJV",
            fontSize: 18.0,
            theme: .system,
            dailyVerseEnabled: true,
            dailyVerseTime: Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        )
        
        return LeavnCore.User(
            name: "Bible Reader",
            preferences: defaultPreferences
        )
    }
    
    private func createAndSignInUser() async throws -> LeavnCore.User {
        let newUser = createDefaultUser()
        currentUser = newUser
        await saveUser()
        await cacheService.set(UserKeys.isSignedIn, value: true, expirationDate: nil)
        
        return newUser
    }
    
    private func saveUser() async {
        guard let user = currentUser else { return }
        await cacheService.set(UserKeys.currentUser, value: user, expirationDate: nil)
        await cacheService.set(UserKeys.userPreferences, value: user.preferences, expirationDate: nil)
    }
}
