import Foundation
import SwiftUI
import Combine

@MainActor
public final class AuthViewModel: BaseViewModel<AuthViewState, AuthViewEvent> {
    // Dependencies injected through initializer
    private let authRepository: AuthRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // Use Cases
    private let signInUseCase: SignInUseCaseProtocol
    private let signUpUseCase: SignUpUseCaseProtocol
    private let signOutUseCase: SignOutUseCaseProtocol
    private let resetPasswordUseCase: ResetPasswordUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    private let verifyEmailUseCase: VerifyEmailUseCaseProtocol
    
    private var authStateTask: Task<Void, Never>?
    
    public init(
        authRepository: AuthRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        signInUseCase: SignInUseCaseProtocol,
        signUpUseCase: SignUpUseCaseProtocol,
        signOutUseCase: SignOutUseCaseProtocol,
        resetPasswordUseCase: ResetPasswordUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol,
        verifyEmailUseCase: VerifyEmailUseCaseProtocol,
        initialState: AuthViewState = .init()
    ) {
        self.authRepository = authRepository
        self.analyticsService = analyticsService
        self.signInUseCase = signInUseCase
        self.signUpUseCase = signUpUseCase
        self.signOutUseCase = signOutUseCase
        self.resetPasswordUseCase = resetPasswordUseCase
        self.updateProfileUseCase = updateProfileUseCase
        self.verifyEmailUseCase = verifyEmailUseCase
        
        super.init(initialState: initialState)
        
        observeAuthState()
    }
    
    deinit {
        authStateTask?.cancel()
    }
    
    // MARK: - Event Handling
    
    public override func handle(event: AuthViewEvent) {
        switch event {
        case .updateEmail(let email):
            updateEmail(email)
        case .updatePassword(let password):
            updatePassword(password)
        case .updateConfirmPassword(let confirmPassword):
            updateConfirmPassword(confirmPassword)
        case .updateDisplayName(let displayName):
            updateDisplayName(displayName)
        case .togglePasswordVisibility:
            togglePasswordVisibility()
        case .toggleTermsAcceptance:
            toggleTermsAcceptance()
        case .switchMode(let mode):
            switchMode(mode)
        case .signIn:
            signIn()
        case .signInWithApple:
            signInWithApple()
        case .signInWithGoogle:
            signInWithGoogle()
        case .signUp:
            signUp()
        case .signOut:
            signOut()
        case .resetPassword:
            resetPassword()
        case .resendVerificationEmail:
            resendVerificationEmail()
        case .deleteAccount:
            deleteAccount()
        }
    }
    
    // MARK: - Private Methods
    
    private func observeAuthState() {
        authStateTask = Task {
            for await state in authRepository.authState {
                await updateState { viewState in
                    switch state {
                    case .unknown:
                        viewState.isAuthenticated = false
                        viewState.user = nil
                    case .unauthenticated:
                        viewState.isAuthenticated = false
                        viewState.user = nil
                    case .authenticated(let user):
                        viewState.isAuthenticated = true
                        viewState.user = user
                    case .refreshing:
                        viewState.isLoading = true
                    }
                }
            }
        }
    }
    
    private func updateEmail(_ email: String) {
        Task {
            await updateState { state in
                state.email = email
                state.validationErrors.removeAll { $0 == .invalidEmail }
                if !email.isEmpty && !email.isValidEmail {
                    state.validationErrors.append(.invalidEmail)
                }
            }
        }
    }
    
    private func updatePassword(_ password: String) {
        Task {
            await updateState { state in
                state.password = password
                state.validationErrors.removeAll { $0 == .passwordTooShort }
                if !password.isEmpty && password.count < 6 {
                    state.validationErrors.append(.passwordTooShort)
                }
            }
        }
    }
    
    private func updateConfirmPassword(_ confirmPassword: String) {
        Task {
            await updateState { state in
                state.confirmPassword = confirmPassword
                state.validationErrors.removeAll { $0 == .passwordsDontMatch }
                if !confirmPassword.isEmpty && confirmPassword != state.password {
                    state.validationErrors.append(.passwordsDontMatch)
                }
            }
        }
    }
    
    private func updateDisplayName(_ displayName: String) {
        Task {
            await updateState { state in
                state.displayName = displayName
                state.validationErrors.removeAll { $0 == .displayNameEmpty }
                if state.authMode == .signUp && displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    state.validationErrors.append(.displayNameEmpty)
                }
            }
        }
    }
    
    private func togglePasswordVisibility() {
        Task {
            await updateState { state in
                state.isPasswordVisible.toggle()
            }
        }
    }
    
    private func toggleTermsAcceptance() {
        Task {
            await updateState { state in
                state.acceptsTerms.toggle()
                state.validationErrors.removeAll { $0 == .termsNotAccepted }
                if state.authMode == .signUp && !state.acceptsTerms {
                    state.validationErrors.append(.termsNotAccepted)
                }
            }
        }
    }
    
    private func switchMode(_ mode: AuthMode) {
        Task {
            await updateState { state in
                state.authMode = mode
                state.validationErrors.removeAll()
                state.error = nil
            }
        }
    }
    
    private func signIn() {
        Task {
            await updateState { state in
                state.isLoading = true
                state.error = nil
            }
            
            do {
                let credentials = AuthCredentials(
                    email: currentState.email,
                    password: currentState.password
                )
                
                guard credentials.isValid else {
                    await updateState { state in
                        state.isLoading = false
                        state.error = AuthenticationError.invalidCredentials
                    }
                    return
                }
                
                let user = try await signInUseCase.execute(credentials: credentials)
                
                await updateState { state in
                    state.isLoading = false
                    state.user = user
                    state.isAuthenticated = true
                }
                
                analyticsService.track(event: "user_signed_in", properties: [
                    "method": "email",
                    "user_id": user.id
                ])
            } catch {
                await updateState { state in
                    state.isLoading = false
                    state.error = error
                }
                
                analyticsService.trackError(error, properties: [
                    "action": "sign_in"
                ])
            }
        }
    }
    
    private func signInWithApple() {
        // Implementation would require Apple Sign In SDK
        analyticsService.track(event: "sign_in_with_apple_tapped", properties: nil)
    }
    
    private func signInWithGoogle() {
        // Implementation would require Google Sign In SDK
        analyticsService.track(event: "sign_in_with_google_tapped", properties: nil)
    }
    
    private func signUp() {
        Task {
            await updateState { state in
                state.isLoading = true
                state.error = nil
            }
            
            do {
                let credentials = SignUpCredentials(
                    email: currentState.email,
                    password: currentState.password,
                    displayName: currentState.displayName,
                    acceptsTerms: currentState.acceptsTerms
                )
                
                guard credentials.isValid else {
                    await updateState { state in
                        state.isLoading = false
                        state.error = AuthenticationError.missingEmail
                    }
                    return
                }
                
                let user = try await signUpUseCase.execute(credentials: credentials)
                
                await updateState { state in
                    state.isLoading = false
                    state.user = user
                    state.isAuthenticated = true
                }
                
                analyticsService.track(event: "user_signed_up", properties: [
                    "method": "email",
                    "user_id": user.id
                ])
            } catch {
                await updateState { state in
                    state.isLoading = false
                    state.error = error
                }
                
                analyticsService.trackError(error, properties: [
                    "action": "sign_up"
                ])
            }
        }
    }
    
    private func signOut() {
        Task {
            do {
                try await signOutUseCase.execute()
                
                await updateState { state in
                    state.user = nil
                    state.isAuthenticated = false
                    state.email = ""
                    state.password = ""
                    state.confirmPassword = ""
                    state.displayName = ""
                    state.acceptsTerms = false
                }
                
                analyticsService.track(event: "user_signed_out", properties: nil)
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func resetPassword() {
        Task {
            await updateState { state in
                state.isLoading = true
                state.error = nil
            }
            
            do {
                try await resetPasswordUseCase.execute(email: currentState.email)
                
                await updateState { state in
                    state.isLoading = false
                }
                
                analyticsService.track(event: "password_reset_requested", properties: [
                    "email": currentState.email
                ])
            } catch {
                await updateState { state in
                    state.isLoading = false
                    state.error = error
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        Task {
            do {
                try await verifyEmailUseCase.resendVerification()
                
                analyticsService.track(event: "verification_email_resent", properties: nil)
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func deleteAccount() {
        Task {
            await updateState { state in
                state.isLoading = true
                state.error = nil
            }
            
            do {
                try await authRepository.deleteAccount()
                
                await updateState { state in
                    state.isLoading = false
                    state.user = nil
                    state.isAuthenticated = false
                }
                
                analyticsService.track(event: "account_deleted", properties: nil)
            } catch {
                await updateState { state in
                    state.isLoading = false
                    state.error = error
                }
            }
        }
    }
}