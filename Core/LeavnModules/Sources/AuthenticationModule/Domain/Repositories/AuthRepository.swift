import Foundation

// MARK: - Authentication Repository Protocol Extension
// The main AuthRepositoryProtocol is defined in LeavnCore
// This file contains module-specific extensions

public extension AuthRepositoryProtocol {
    // Default implementations for optional methods
    
    func sendPasswordResetEmail(email: String) async throws {
        try await resetPassword(email: email)
    }
    
    func verifyPasswordResetCode(email: String, code: String) async throws -> String {
        // Default implementation
        return code
    }
    
    func confirmPasswordReset(email: String, code: String, newPassword: String) async throws {
        // Default implementation
        try await updatePassword(request: PasswordUpdateRequest(
            currentPassword: "", 
            newPassword: newPassword
        ))
    }
    
    func linkAppleAccount(credentials: AppleAuthCredentials) async throws {
        // Default implementation
        _ = try await signInWithApple(credentials: credentials)
    }
    
    func linkGoogleAccount(idToken: String) async throws {
        // Default implementation
        _ = try await signInWithGoogle(idToken: idToken)
    }
    
    func unlinkProvider(provider: AuthProvider) async throws {
        // Default implementation - throw not implemented
        throw AuthenticationError.operationNotAllowed
    }
}

// MARK: - Repository Implementation Requirements
public protocol AuthRepositoryImplementation: AuthRepositoryProtocol {
    var configuration: AuthenticationConfiguration { get }
}

// MARK: - Repository State Management
public final class AuthRepositoryState {
    private var loginAttempts: [String: Int] = [:]
    private let maxAttempts: Int
    
    public init(maxAttempts: Int = 5) {
        self.maxAttempts = maxAttempts
    }
    
    public func recordLoginAttempt(for email: String) {
        loginAttempts[email, default: 0] += 1
    }
    
    public func resetLoginAttempts(for email: String) {
        loginAttempts.removeValue(forKey: email)
    }
    
    public func isBlocked(email: String) -> Bool {
        return loginAttempts[email, default: 0] >= maxAttempts
    }
    
    public func remainingAttempts(for email: String) -> Int {
        let attempts = loginAttempts[email, default: 0]
        return max(0, maxAttempts - attempts)
    }
}