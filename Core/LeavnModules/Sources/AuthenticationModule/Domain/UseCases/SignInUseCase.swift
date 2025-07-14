import Foundation
import LeavnCore

// MARK: - Sign In Use Case Implementation
public final class SignInUseCase: SignInUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(credentials: AuthCredentials) async throws -> AuthUser {
        // Validate credentials
        guard credentials.isValid else {
            throw AuthenticationError.invalidCredentials
        }
        
        // Attempt sign in
        do {
            let user = try await authRepository.signIn(credentials: credentials)
            
            // Track successful sign in
            analyticsService?.track(event: "auth_sign_in_success", properties: [
                "provider": "email",
                "user_id": user.id
            ])
            
            return user
        } catch {
            // Track failed sign in
            analyticsService?.trackError(error, properties: [
                "action": "sign_in",
                "provider": "email"
            ])
            
            // Map errors
            if let authError = error as? AuthenticationError {
                throw authError
            } else {
                throw AuthenticationError.networkError
            }
        }
    }
    
    public func executeWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser {
        do {
            let user = try await authRepository.signInWithApple(credentials: credentials)
            
            // Track successful sign in
            analyticsService?.track(event: "auth_sign_in_success", properties: [
                "provider": "apple",
                "user_id": user.id
            ])
            
            return user
        } catch {
            // Track failed sign in
            analyticsService?.trackError(error, properties: [
                "action": "sign_in",
                "provider": "apple"
            ])
            
            throw error
        }
    }
    
    public func executeWithGoogle(idToken: String) async throws -> AuthUser {
        do {
            let user = try await authRepository.signInWithGoogle(idToken: idToken)
            
            // Track successful sign in
            analyticsService?.track(event: "auth_sign_in_success", properties: [
                "provider": "google",
                "user_id": user.id
            ])
            
            return user
        } catch {
            // Track failed sign in
            analyticsService?.trackError(error, properties: [
                "action": "sign_in",
                "provider": "google"
            ])
            
            throw error
        }
    }
}