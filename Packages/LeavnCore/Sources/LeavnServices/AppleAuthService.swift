import Foundation
import LeavnCore
import AuthenticationServices

// APPLE SIGN-IN ONLY - No password storage, maximum privacy!
@MainActor
public final class AppleAuthService: NSObject, ObservableObject, @unchecked Sendable {
    
    // MARK: - Properties
    private var currentUser: LeavnCore.User?
    private var isInitialized = false
    
    // MARK: - Singleton
    public static let shared = AppleAuthService()
    
    private override init() {
        super.init()
    }
}

// MARK: - UserServiceProtocol Conformance
extension AppleAuthService: UserServiceProtocol {
    
    public func initialize() async throws {
        // Load saved Apple Sign In credentials
        if let userID = UserDefaults.standard.string(forKey: "appleUserIdentifier") {
            currentUser = LeavnCore.User(
                id: userID,
                name: UserDefaults.standard.string(forKey: "appleUserName") ?? "Bible Reader",
                email: UserDefaults.standard.string(forKey: "appleUserEmail"),
                preferences: loadUserPreferences(),
                createdAt: Date(),
                updatedAt: Date()
            )
        }
        
        isInitialized = true
        print("🍎 AppleAuthService initialized")
    }
    
    public func getCurrentUser() async throws -> LeavnCore.User? {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return currentUser
    }
    
    public func updateUser(_ user: LeavnCore.User) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Only allow updating preferences and name
        currentUser = user
        UserDefaults.standard.set(user.name, forKey: "appleUserName")
        saveUserPreferences(user.preferences)
    }
    
    public func updatePreferences(_ preferences: LeavnCore.UserPreferences) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let oldUser = currentUser else {
            throw ServiceError.authenticationRequired
        }
        let updatedUser = LeavnCore.User(
            id: oldUser.id,
            name: oldUser.name,
            email: oldUser.email,
            preferences: preferences,
            createdAt: oldUser.createdAt,
            updatedAt: Date()
        )
        currentUser = updatedUser
        saveUserPreferences(preferences)
    }
    
    public func deleteUser() async throws {
        // Clear local data only - Apple handles account deletion
        UserDefaults.standard.removeObject(forKey: "appleUserIdentifier")
        UserDefaults.standard.removeObject(forKey: "appleUserEmail")
        UserDefaults.standard.removeObject(forKey: "appleUserName")
        UserDefaults.standard.removeObject(forKey: "userPreferences")
        
        currentUser = nil
    }
    
    public func signIn() async throws -> LeavnCore.User {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // If already signed in, return current user
        if let user = currentUser {
            return user
        }
        
        // Perform Apple Sign In
        return try await performAppleSignIn()
    }
    
    public func signOut() async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Don't clear Apple credentials, just mark as signed out
        UserDefaults.standard.set(false, forKey: "isSignedIn")
    }
    
    public func isSignedIn() async -> Bool {
        return currentUser != nil && UserDefaults.standard.bool(forKey: "isSignedIn")
    }
    
    // MARK: - Apple Sign In Implementation
    
    @MainActor
    private func performAppleSignIn() async throws -> LeavnCore.User {
        return try await withCheckedThrowingContinuation { continuation in
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let controller = ASAuthorizationController(authorizationRequests: [request])
            
            let delegate = SignInDelegate { result in
                switch result {
                case .success(let user):
                    continuation.resume(returning: user)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            
            controller.delegate = delegate
            controller.presentationContextProvider = delegate
            controller.performRequests()
            
            // Keep delegate alive during sign in
            objc_setAssociatedObject(controller, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadUserPreferences() -> LeavnCore.UserPreferences {
        guard let data = UserDefaults.standard.data(forKey: "userPreferences"),
              let preferences = try? JSONDecoder().decode(LeavnCore.UserPreferences.self, from: data) else {
            return LeavnCore.UserPreferences()
        }
        return preferences
    }
    
    private func saveUserPreferences(_ preferences: LeavnCore.UserPreferences) {
        if let data = try? JSONEncoder().encode(preferences) {
            UserDefaults.standard.set(data, forKey: "userPreferences")
        }
    }
}

// MARK: - Sign In Delegate
private class SignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    private let completion: (Result<LeavnCore.User, Error>) -> Void
    
    init(completion: @escaping (Result<LeavnCore.User, Error>) -> Void) {
        self.completion = completion
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.failure(ServiceError.authenticationRequired))
            return
        }
        
        // Store credentials
        UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserIdentifier")
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        
        if let email = appleIDCredential.email {
            UserDefaults.standard.set(email, forKey: "appleUserEmail")
        }
        
        let name: String
        if let fullName = appleIDCredential.fullName {
            name = PersonNameComponentsFormatter().string(from: fullName)
        } else {
            name = UserDefaults.standard.string(forKey: "appleUserName") ?? "Bible Reader"
        }
        
        UserDefaults.standard.set(name, forKey: "appleUserName")
        
        // Create user
        let user = LeavnCore.User(
            id: appleIDCredential.user,
            name: name,
            email: appleIDCredential.email ?? UserDefaults.standard.string(forKey: "appleUserEmail"),
            preferences: LeavnCore.UserPreferences(),
            createdAt: Date(),
            updatedAt: Date()
        )
        
        completion(.success(user))
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
        #elseif os(macOS)
        return NSApplication.shared.windows.first ?? NSWindow()
        #else
        fatalError("Apple Sign In not supported on this platform")
        #endif
    }
}

// MARK: - SwiftUI Sign In Button
import SwiftUI

public struct AppleSignInButton: View {
    @State private var error: Error?
    let onSuccess: (LeavnCore.User) -> Void
    
    public init(onSuccess: @escaping (LeavnCore.User) -> Void) {
        self.onSuccess = onSuccess
    }
    
    public var body: some View {
        SignInWithAppleButton { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            Task { @MainActor in
                switch result {
                case .success(let auth):
                    if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                        let user = handleCredential(appleIDCredential)
                        onSuccess(user)
                    }
                case .failure(let error):
                    self.error = error
                }
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
        .cornerRadius(8)
        .alert("Sign In Failed", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error?.localizedDescription ?? "Unable to sign in with Apple")
        }
    }
    
    private func handleCredential(_ credential: ASAuthorizationAppleIDCredential) -> LeavnCore.User {
        // Store credentials
        UserDefaults.standard.set(credential.user, forKey: "appleUserIdentifier")
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        
        if let email = credential.email {
            UserDefaults.standard.set(email, forKey: "appleUserEmail")
        }
        
        let name: String
        if let fullName = credential.fullName {
            name = PersonNameComponentsFormatter().string(from: fullName)
            UserDefaults.standard.set(name, forKey: "appleUserName")
        } else {
            name = UserDefaults.standard.string(forKey: "appleUserName") ?? "Bible Reader"
        }
        
        return LeavnCore.User(
            id: credential.user,
            name: name,
            email: credential.email ?? UserDefaults.standard.string(forKey: "appleUserEmail"),
            preferences: LeavnCore.UserPreferences(),
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

