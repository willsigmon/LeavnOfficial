import SwiftUI

public struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @State private var showPermissions = false
    @State private var showCustomization = false
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var progress = OnboardingProgress()
    @State private var slideAnimations: [Bool] = Array(repeating: false, count: OnboardingData.slides.count)
    @State private var hapticTrigger = false
    
    // User preferences
    @State private var userPreferences = UserPreferencesData()
    
    // Managers
    @StateObject private var userDataManager = UserDataManager.shared
    private let haptics = UIImpactFeedbackGenerator(style: .light)
    
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            if showCustomization {
                CustomizationFlow(
                    preferences: $userPreferences,
                    onComplete: {
                        savePreferences()
                        onComplete()
                    }
                )
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                    removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                ))
            } else if showPermissions {
                PermissionsView(onComplete: {
                    withAnimation {
                        showCustomization = true
                    }
                })
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                    removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                onboardingSlides
            }
        }
        .accessibilityIdentifier("onboardingView")
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showPermissions)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showCustomization)
    }
    
    private func savePreferences() {
        Task {
            // Save preferences to UserDataManager
            userDataManager.userPreferences = userPreferences
            
            // Update user profile if exists
            if let currentUser = userDataManager.currentUser {
                // Update preferences in Core Data
                if let preferences = currentUser.preferences {
                    userPreferences.update(coreData: preferences)
                    try? userDataManager.context.save()
                }
            }
            
            // Track completion
            trackEvent(.completed)
        }
    }
    
    private func trackEvent(_ event: OnboardingEvent, properties: [String: Any]? = nil) {
        var eventProperties = properties ?? [:]
        eventProperties["progress"] = progress.completionPercentage
        eventProperties["time_spent"] = Date().timeIntervalSince(progress.startTime)
        
        // Track with analytics service
        // DIContainer.shared.analytics?.track(event: event.rawValue, properties: eventProperties)
    }
    
    private var onboardingSlides: some View {
        VStack(spacing: 0) {
            // Slides
            TabView(selection: $currentPage) {
                ForEach(0..<OnboardingData.slides.count, id: \.self) { index in
                    let slide = OnboardingData.slides[index]
                    OnboardingSlideView(
                        slide: slide,
                        isCurrentSlide: currentPage == index,
                        hasAppeared: slideAnimations[index]
                    )
                    .tag(index)
                    .onAppear {
                        if !slideAnimations[index] {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                                slideAnimations[index] = true
                            }
                            trackEvent(.slideViewed, properties: ["slide_index": index, "slide_title": slide.title])
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
            
            // Bottom controls overlay
            VStack(spacing: 0) {
                Spacer()
                
                // Enhanced page indicators with progress
                ZStack {
                    // Progress background
                    Capsule()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: CGFloat(OnboardingData.slides.count * 12 + (OnboardingData.slides.count - 1) * 8), height: 8)
                    
                    // Progress fill
                    HStack(spacing: 0) {
                        Capsule()
                            .fill(Color.white)
                            .frame(width: calculateProgressWidth(), height: 8)
                        Spacer()
                    }
                    .frame(width: CGFloat(OnboardingData.slides.count * 12 + (OnboardingData.slides.count - 1) * 8))
                    
                    // Individual indicators
                    HStack(spacing: 8) {
                        ForEach(0..<OnboardingData.slides.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage >= index ? Color.white : Color.clear)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 1.5)
                                )
                                .scaleEffect(currentPage == index ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                }
                
                // Action buttons
                HStack {
                    Button(action: {
                        haptics.prepare()
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            trackEvent(.skipped, properties: ["skipped_at_slide": currentPage])
                            showPermissions = true
                        }
                        haptics.impactOccurred()
                    }) {
                        HStack(spacing: 4) {
                            Text("Skip")
                            Image(systemName: "arrow.right.circle")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .opacity(currentPage < OnboardingData.slides.count - 1 ? 1 : 0)
                    .accessibilityIdentifier("skipOnboardingButton")
                    
                    Spacer()
                    
                    Button(action: nextAction) {
                        HStack(spacing: 8) {
                            Text(currentPage == OnboardingData.slides.count - 1 ? "Get Started" : "Next")
                                .font(.headline)
                            
                            Image(systemName: currentPage == OnboardingData.slides.count - 1 ? "arrow.right.circle.fill" : "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .rotationEffect(.degrees(currentPage == OnboardingData.slides.count - 1 ? 0 : 0))
                                .scaleEffect(hapticTrigger ? 1.2 : 1.0)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            Capsule()
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                        .foregroundColor(OnboardingData.slides[min(currentPage, OnboardingData.slides.count - 1)].accentColor)
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                        )
                    }
                    .accessibilityIdentifier(currentPage == OnboardingData.slides.count - 1 ? "completeOnboardingButton" : "onboardingContinueButton")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    private func previousPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage = max(0, currentPage - 1)
        }
    }
    
    private func nextAction() {
        haptics.prepare()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            hapticTrigger = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                hapticTrigger = false
            }
        }
        
        if currentPage == OnboardingData.slides.count - 1 {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                progress.markStepCompleted("welcome")
                showPermissions = true
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage = min(OnboardingData.slides.count - 1, currentPage + 1)
            }
        }
        
        haptics.impactOccurred()
    }
    
    private func calculateProgressWidth() -> CGFloat {
        let totalWidth = CGFloat(OnboardingData.slides.count * 12 + (OnboardingData.slides.count - 1) * 8)
        let progressPercentage = CGFloat(currentPage + 1) / CGFloat(OnboardingData.slides.count)
        return totalWidth * progressPercentage
    }
}

// MARK: - Welcome Screen (Entry Point)
public struct WelcomeView: View {
    @State private var showOnboarding = false
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var pulseAnimation = false
    
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingContainerView(onComplete: onComplete)
                    .transition(.asymmetric(
                        insertion: AnyTransition.scale(scale: 1.1).combined(with: .opacity),
                        removal: AnyTransition.scale(scale: 0.9).combined(with: .opacity)
                    ))
            } else {
                splashScreen
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: showOnboarding)
        .onAppear {
            animateSplash()
        }
    }
    
    private func animateSplash() {
        // Logo animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
        
        // Title animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            titleOffset = 0
        }
        
        // Subtitle animation
        withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
            subtitleOpacity = 1.0
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.6)) {
            pulseAnimation = true
        }
        
        // Transition to onboarding
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showOnboarding = true
            }
        }
    }
    
    private var splashScreen: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.827, green: 0.827, blue: 1),
                    Color(red: 0.71, green: 0.65, blue: 0.97)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .overlay(
                // Subtle animated overlay
                RadialGradient(
                    colors: [
                        Color.white.opacity(pulseAnimation ? 0.1 : 0.05),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: 100,
                    endRadius: 400
                )
                .ignoresSafeArea()
            )
            
            VStack(spacing: 24) {
                // Logo with glow effect
                ZStack {
                    // Glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 80
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 20)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    
                    // Icon container
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                            .symbolRenderingMode(.hierarchical)
                    }
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 120, height: 120)
                    )
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
                
                // Title
                Text("Leavn")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .offset(y: titleOffset)
                
                // Subtitle
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(.white.opacity(0.6))
                        .frame(width: 20, height: 1)
                    
                    Text("Bible Study Reimagined")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .tracking(2)
                    
                    Rectangle()
                        .fill(.white.opacity(0.6))
                        .frame(width: 20, height: 1)
                }
                .opacity(subtitleOpacity)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
                    .opacity(subtitleOpacity)
                    .padding(.top, 40)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    WelcomeView(onComplete: {})
}