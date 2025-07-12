import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem
import AuthenticationServices

public struct SignInView: View {
    @State private var isSigningIn = false
    @State private var error: Error?
    @State private var animateElements = false
    @State private var floatingAnimation = false
    
    let onSignIn: (User) -> Void
    
    public init(onSignIn: @escaping (User) -> Void) {
        self.onSignIn = onSignIn
    }
    
    public var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
            
            // Floating elements
            floatingElements
            
            VStack(spacing: 40) {
                Spacer()
                
                // App Icon and Title
                VStack(spacing: 20) {
                    // Animated logo
                    ZStack {
                        Circle()
                            .fill(LeavnTheme.Colors.primaryGradient)
                            .frame(width: 120, height: 120)
                            .blur(radius: 20)
                            .offset(y: floatingAnimation ? -10 : 10)
                            .animation(
                                .easeInOut(duration: 3)
                                    .repeatForever(autoreverses: true),
                                value: floatingAnimation
                            )
                        
                        Image(systemName: "book.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, .white.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: LeavnTheme.Colors.accent.opacity(0.5), radius: 20)
                            .scaleEffect(animateElements ? 1 : 0)
                            .animation(
                                LeavnTheme.Motion.delightful.delay(0.2),
                                value: animateElements
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Leavn")
                            .font(LeavnTheme.Typography.displayLarge)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeavnTheme.Colors.accentLight, LeavnTheme.Colors.accent],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(animateElements ? 1 : 0)
                            .offset(y: animateElements ? 0 : 20)
                            .animation(
                                LeavnTheme.Motion.smoothSpring.delay(0.3),
                                value: animateElements
                            )
                        
                        Text("Your Personal Bible Study Companion")
                            .font(LeavnTheme.Typography.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .opacity(animateElements ? 1 : 0)
                            .animation(
                                LeavnTheme.Motion.smoothSpring.delay(0.4),
                                value: animateElements
                            )
                    }
                }
                
                Spacer()
                
                // Benefits with staggered animation
                VStack(alignment: .leading, spacing: 20) {
                    FeatureRow(
                        icon: "icloud.fill",
                        title: "Sync Across Devices",
                        description: "Access your notes and highlights anywhere",
                        color: LeavnTheme.Colors.info,
                        delay: 0.5
                    )
                    
                    FeatureRow(
                        icon: "lock.shield.fill",
                        title: "Private & Secure",
                        description: "Your data is protected with Apple's security",
                        color: LeavnTheme.Colors.success,
                        delay: 0.6
                    )
                    
                    FeatureRow(
                        icon: "person.2.fill",
                        title: "Join the Community",
                        description: "Share insights with other Bible readers",
                        color: LeavnTheme.Colors.warning,
                        delay: 0.7
                    )
                }
                .padding(.horizontal, 30)
                
                Spacer()
                
                // Sign In Button - APPLE ONLY!
                VStack(spacing: 16) {
                    AppleSignInButton { user in
                        onSignIn(user)
                    }
                    .frame(maxWidth: 280)
                    .frame(height: 56)
                    .disabled(isSigningIn)
                    .opacity(animateElements ? 1 : 0)
                    .scaleEffect(animateElements ? 1 : 0.8)
                    .animation(
                        LeavnTheme.Motion.delightful.delay(0.8),
                        value: animateElements
                    )
                    
                    Text("Sign in with your Apple ID to get started")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .opacity(animateElements ? 1 : 0)
                        .animation(
                            LeavnTheme.Motion.smoothSpring.delay(0.9),
                            value: animateElements
                        )
                }
                
                Spacer()
            }
            .padding()
        }
        .alert("Sign In Error", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error?.localizedDescription ?? "Unable to sign in")
        }
        .onAppear {
            withAnimation {
                animateElements = true
                floatingAnimation = true
            }
        }
    }
    
    private var floatingElements: some View {
        ZStack {
            // Floating book icons
            ForEach(0..<5) { index in
                Image(systemName: "book.fill")
                    .font(.system(size: 30))
                    .foregroundColor(LeavnTheme.Colors.accent.opacity(0.1))
                    .offset(
                        x: CGFloat.random(in: -150...150),
                        y: CGFloat.random(in: -300...300)
                    )
                    .rotationEffect(.degrees(Double.random(in: -45...45)))
                    .scaleEffect(floatingAnimation ? 1.1 : 0.9)
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...5))
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                        value: floatingAnimation
                    )
            }
        }
    }
}

// MARK: - Enhanced Apple Sign In Button
public struct AppleSignInButton: View {
    @State private var error: Error?
    @State private var isPressed = false
    let onSuccess: (User) -> Void
    
    public init(onSuccess: @escaping (User) -> Void) {
        self.onSuccess = onSuccess
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            SignInWithAppleButton { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                handleSignInResult(result)
            }
            .signInWithAppleButtonStyle(.white)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(LeavnTheme.Colors.accent.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .shadow(
                color: LeavnTheme.Colors.accent.opacity(0.3),
                radius: isPressed ? 5 : 15,
                x: 0,
                y: isPressed ? 2 : 8
            )
        }
        .alert("Sign In Failed", isPresented: .constant(error != nil)) {
            Button("OK") { error = nil }
        } message: {
            Text(error?.localizedDescription ?? "Unable to sign in")
        }
    }
    
    private func handleSignInResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                // Store credentials
                UserDefaults.standard.set(appleIDCredential.user, forKey: "appleUserIdentifier")
                
                if let email = appleIDCredential.email {
                    UserDefaults.standard.set(email, forKey: "appleUserEmail")
                }
                
                if let fullName = appleIDCredential.fullName {
                    let formatter = PersonNameComponentsFormatter()
                    let name = formatter.string(from: fullName)
                    UserDefaults.standard.set(name, forKey: "appleUserName")
                }
                
                // Create user
                let user = User(
                    id: appleIDCredential.user,
                    name: UserDefaults.standard.string(forKey: "appleUserName") ?? "Bible Reader",
                    email: appleIDCredential.email ?? "",
                    preferences: UserPreferences()
                )
                
                onSuccess(user)
            }
        case .failure(let error):
            self.error = error
        }
    }
}

// MARK: - Authentication Check View with Loading Animation
public struct AuthenticationCheckView<Content: View>: View {
    @StateObject private var authService = AppleAuthService.shared
    @State private var isCheckingAuth = true
    @State private var isAuthenticated = false
    @State private var animateLoader = false
    
    let content: () -> Content
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        Group {
            if isCheckingAuth {
                ZStack {
                    AnimatedGradientBackground()
                    
                    VStack(spacing: 32) {
                        // Animated logo
                        Image(systemName: "book.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                            .scaleEffect(animateLoader ? 1.1 : 0.9)
                            .animation(
                                LeavnTheme.Motion.smoothSpring
                                    .repeatForever(autoreverses: true),
                                value: animateLoader
                            )
                        
                        Text("Preparing your experience...")
                            .font(LeavnTheme.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                }
            } else if isAuthenticated {
                content()
            } else {
                SignInView { user in
                    withAnimation {
                        isAuthenticated = true
                    }
                }
            }
        }
        .task {
            animateLoader = true
            await checkAuthentication()
        }
    }
    
    private func checkAuthentication() async {
        do {
            try await authService.initialize()
            isAuthenticated = await authService.isSignedIn()
        } catch {
            print("Auth check failed: \(error)")
            isAuthenticated = false
        }
        
        withAnimation {
            isCheckingAuth = false
        }
    }
}
