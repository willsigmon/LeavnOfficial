import Foundation
import LeavnCore

// MARK: - Sign Up Use Case Implementation
public final class SignUpUseCase: SignUpUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(credentials: SignUpCredentials) async throws -> AuthUser {
        // Validate credentials
        guard credentials.isValid else {
            if !credentials.email.isValidEmail {
                throw AuthenticationError.invalidEmail
            } else if credentials.password.count < 6 {
                throw AuthenticationError.weakPassword
            } else if credentials.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw AuthenticationError.missingDisplayName
            } else if !credentials.acceptsTerms {
                throw AuthenticationError.operationNotAllowed
            }
            throw AuthenticationError.invalidCredentials
        }
        
        // Attempt sign up
        do {
            let user = try await authRepository.signUp(credentials: credentials)
            
            // Track successful sign up
            analyticsService?.track(event: "auth_sign_up_success", properties: [
                "provider": "email",
                "user_id": user.id
            ])
            
            // Identify user for analytics
            analyticsService?.identify(userId: user.id, traits: [
                "email": user.email,
                "name": user.displayName,
                "created_at": user.createdAt.timeIntervalSince1970
            ])
            
            return user
        } catch {
            // Track failed sign up
            analyticsService?.trackError(error, properties: [
                "action": "sign_up",
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
}

// MARK: - Other Authentication Use Cases

public final class SignOutUseCase: SignOutUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func execute() async throws {
        do {
            try await authRepository.signOut()
            
            // Track sign out
            analyticsService?.track(event: "auth_sign_out", properties: nil)
            
            // Reset analytics user
            analyticsService?.reset()
        } catch {
            // Track error but still attempt to clear local state
            analyticsService?.trackError(error, properties: [
                "action": "sign_out"
            ])
            throw error
        }
    }
}

public final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(email: String) async throws {
        // Validate email
        guard email.isValidEmail else {
            throw AuthenticationError.invalidEmail
        }
        
        do {
            try await authRepository.resetPassword(email: email)
            
            // Track password reset request
            analyticsService?.track(event: "auth_password_reset_requested", properties: [
                "email": email
            ])
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "reset_password"
            ])
            throw error
        }
    }
}

public final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func execute(request: ProfileUpdateRequest) async throws -> AuthUser {
        do {
            let updatedUser = try await authRepository.updateProfile(request: request)
            
            // Track profile update
            analyticsService?.track(event: "auth_profile_updated", properties: [
                "user_id": updatedUser.id,
                "has_display_name": request.displayName != nil,
                "has_photo": request.photoURL != nil
            ])
            
            return updatedUser
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "update_profile"
            ])
            throw error
        }
    }
    
    public func uploadPhoto(imageData: Data) async throws -> URL {
        do {
            let photoURL = try await authRepository.uploadProfilePhoto(imageData: imageData)
            
            // Track photo upload
            analyticsService?.track(event: "auth_profile_photo_uploaded", properties: [
                "size": imageData.count
            ])
            
            return photoURL
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "upload_profile_photo"
            ])
            throw error
        }
    }
}

public final class VerifyEmailUseCase: VerifyEmailUseCaseProtocol {
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
    }
    
    public func sendVerification() async throws {
        do {
            try await authRepository.sendEmailVerification()
            
            // Track verification sent
            analyticsService?.track(event: "auth_email_verification_sent", properties: nil)
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "send_email_verification"
            ])
            throw error
        }
    }
    
    public func verify(code: String) async throws {
        do {
            try await authRepository.verifyEmail(code: code)
            
            // Track verification completed
            analyticsService?.track(event: "auth_email_verified", properties: nil)
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "verify_email"
            ])
            throw error
        }
    }
    
    public func resendVerification() async throws {
        do {
            try await authRepository.resendEmailVerification()
            
            // Track resend
            analyticsService?.track(event: "auth_email_verification_resent", properties: nil)
        } catch {
            // Track error
            analyticsService?.trackError(error, properties: [
                "action": "resend_email_verification"
            ])
            throw error
        }
    }
}