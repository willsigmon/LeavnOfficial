import SwiftUI

import AuthenticationServices

public struct SignInView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""
    @State private var showingResetPassword = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ds.spacing.l) {
                    // Header
                    VStack(spacing: ds.spacing.m) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(ds.colors.primary)
                            .accessibilityHidden(true)
                        
                        AccessibleText(
                            "Welcome to Leavn",
                            style: .title,
                            alignment: .center
                        )
                        
                        AccessibleText(
                            "Sign in to continue your spiritual journey",
                            style: .body,
                            color: ds.colors.secondaryLabel,
                            alignment: .center
                        )
                    }
                    .padding(.top, ds.spacing.xl)
                    
                    // Sign In Form
                    VStack(spacing: ds.spacing.m) {
                        // Email Field
                        AuthFormField(
                            title: "Email",
                            text: $email,
                            placeholder: "Enter your email",
                            keyboardType: .emailAddress,
                            validation: viewModel.state.emailValidation
                        ) {
                            viewModel.send(.validateEmail(email))
                        }
                        
                        // Password Field
                        AuthFormField(
                            title: "Password",
                            text: $password,
                            placeholder: "Enter your password",
                            isSecure: true,
                            validation: viewModel.state.passwordValidation
                        ) {
                            viewModel.send(.validatePassword(password))
                        }
                        
                        // Forgot Password
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showingResetPassword = true
                            }
                            .font(ds.typography.bodySmall)
                            .foregroundColor(ds.colors.primary)
                            .accessibilityHint("Double tap to reset your password")
                        }
                    }
                    
                    // Error Message
                    if let error = viewModel.state.error {
                        ErrorView(error: error) {
                            viewModel.send(.clearError)
                        }
                    }
                    
                    // Sign In Button
                    AccessibleLeavnButton(
                        "Sign In",
                        style: .primary,
                        size: .large,
                        isLoading: viewModel.state.isLoading,
                        isEnabled: isFormValid && !viewModel.state.isLoading,
                        accessibilityHint: "Double tap to sign in to your account"
                    ) {
                        viewModel.send(.signIn(email: email, password: password))
                    }
                    
                    // Social Sign In
                    VStack(spacing: ds.spacing.m) {
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(ds.colors.separator)
                            
                            AccessibleText(
                                "or",
                                style: .caption,
                                color: ds.colors.secondaryLabel
                            )
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(ds.colors.separator)
                        }
                        
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            handleAppleSignIn(result)
                        }
                        .signInWithAppleButtonStyle(.black)
                        .frame(height: 50)
                        .cornerRadius(ds.cornerRadius.m)
                    }
                    
                    // Sign Up Link
                    Button(action: {
                        viewModel.send(.toggleAuthMode)
                    }) {
                        AccessibleText(
                            "Don't have an account? Sign up",
                            style: .body,
                            color: ds.colors.primary
                        )
                    }
                    .accessibilityHint("Double tap to create a new account")
                    
                    Spacer(minLength: ds.spacing.xl)
                }
                .padding(.horizontal, ds.spacing.l)
            }
            .navigationBarHidden(true)
            .background(ds.colors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showingResetPassword) {
            ResetPasswordView()
        }
        .fullScreenCover(isPresented: .constant(viewModel.state.authMode == .signUp)) {
            SignUpView()
        }
        .fullScreenCover(isPresented: .constant(viewModel.state.needsEmailVerification)) {
            EmailVerificationView()
        }
    }
    
    private var isFormValid: Bool {
        viewModel.state.emailValidation.isValid &&
        viewModel.state.passwordValidation.isValid &&
        !email.isEmpty &&
        !password.isEmpty
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
               let identityToken = credential.identityToken {
                
                let credentials = AppleAuthCredentials(
                    identityToken: identityToken,
                    nonce: "", // In a real app, you'd generate and store a nonce
                    fullName: credential.fullName,
                    email: credential.email
                )
                
                viewModel.send(.signInWithApple(credentials))
            }
            
        case .failure(let error):
            // Handle Apple Sign In error
            print("Apple Sign In failed: \\(error)")
        }
    }
}

// MARK: - Error View
private struct ErrorView: View {
    let error: AuthError
    let onDismiss: () -> Void
    
    var body: some View {
        AccessibleCard(style: .filled) {
            HStack(spacing: ds.spacing.s) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(ds.colors.error)
                    .accessibilityHidden(true)
                
                VStack(alignment: .leading, spacing: ds.spacing.xs) {
                    AccessibleText(
                        error.localizedDescription,
                        style: .callout,
                        color: ds.colors.error
                    )
                    
                    if let recovery = error.recoveryAction {
                        Button(recovery) {
                            // Handle recovery action
                        }
                        .font(ds.typography.labelSmall)
                        .foregroundColor(ds.colors.primary)
                        .accessibilityHint("Double tap to \(recovery.lowercased())")
                    }
                }
                
                Spacer()
                
                AccessibleIconButton(
                    icon: "xmark.circle.fill",
                    size: .small,
                    style: .tertiary,
                    accessibilityLabel: "Dismiss error",
                    action: onDismiss
                )
            }
        }
        .background(ds.colors.error.opacity(0.1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(error.localizedDescription)")
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}