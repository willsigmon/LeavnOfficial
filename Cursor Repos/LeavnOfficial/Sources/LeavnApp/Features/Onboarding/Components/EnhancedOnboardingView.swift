import SwiftUI
import ComposableArchitecture

struct EnhancedOnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var hasCompletedSetup = false
    
    var body: some View {
        ZStack {
            // Animated Background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                // Skip Button
                HStack {
                    Spacer()
                    
                    if currentPage < OnboardingPage.allCases.count - 1 {
                        Button("Skip") {
                            withAnimation {
                                currentPage = OnboardingPage.allCases.count - 1
                            }
                        }
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding()
                    }
                }
                
                // Content
                TabView(selection: $currentPage) {
                    ForEach(OnboardingPage.allCases.indices, id: \.self) { index in
                        EnhancedOnboardingPageView(
                            page: OnboardingPage.allCases[index],
                            pageIndex: index
                        )
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Bottom Section
                VStack(spacing: 24) {
                    PageIndicator(
                        numberOfPages: OnboardingPage.allCases.count,
                        currentPage: currentPage
                    )
                    
                    HStack(spacing: 16) {
                        if currentPage > 0 {
                            Button(action: {
                                withAnimation {
                                    currentPage -= 1
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.body.bold())
                                    .foregroundColor(.leavnPrimary)
                                    .frame(width: 50, height: 50)
                                    .background(Color.leavnPrimary.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        
                        if currentPage < OnboardingPage.allCases.count - 1 {
                            Button("Continue") {
                                withAnimation {
                                    currentPage += 1
                                }
                            }
                            .buttonStyle(OnboardingButtonStyle(isPrimary: true))
                            .frame(maxWidth: .infinity)
                        } else {
                            Button("Get Started") {
                                hasCompletedSetup = true
                            }
                            .buttonStyle(OnboardingButtonStyle(isPrimary: true))
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .sheet(isPresented: $hasCompletedSetup) {
            OnboardingSetupView(onComplete: onComplete)
                .interactiveDismissDisabled()
        }
    }
}

enum OnboardingPage: CaseIterable {
    case welcome
    case readListen
    case community
    case library
    case personalization
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome to Leavn"
        case .readListen:
            return "Read & Listen"
        case .community:
            return "Join the Community"
        case .library:
            return "Your Personal Library"
        case .personalization:
            return "Made for You"
        }
    }
    
    var subtitle: String {
        switch self {
        case .welcome:
            return "Your journey with God's Word begins here"
        case .readListen:
            return "Experience Scripture like never before"
        case .community:
            return "Connect with believers worldwide"
        case .library:
            return "Build your spiritual collection"
        case .personalization:
            return "Tailored to your spiritual journey"
        }
    }
    
    var description: String {
        switch self {
        case .welcome:
            return "Dive deep into the Bible with powerful study tools, AI-powered narration, and a vibrant community."
        case .readListen:
            return "Read multiple translations, listen to natural AI voices, and follow along with synchronized highlighting."
        case .community:
            return "Share prayer requests, join study groups, and grow together in faith with believers around the world."
        case .library:
            return "Save verses, take notes, create highlights, and download content for offline study anywhere."
        case .personalization:
            return "Customize your reading experience with themes, fonts, and reading plans that fit your schedule."
        }
    }
    
    var icon: String {
        switch self {
        case .welcome:
            return "hands.sparkles.fill"
        case .readListen:
            return "book.and.wrench.fill"
        case .community:
            return "person.3.fill"
        case .library:
            return "books.vertical.fill"
        case .personalization:
            return "slider.horizontal.3"
        }
    }
    
    var color: Color {
        switch self {
        case .welcome:
            return .blue
        case .readListen:
            return .purple
        case .community:
            return .orange
        case .library:
            return .green
        case .personalization:
            return .pink
        }
    }
}

struct EnhancedOnboardingPageView: View {
    let page: OnboardingPage
    let pageIndex: Int
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animated Icon
            AnimatedOnboardingIcon(
                systemName: page.icon,
                color: page.color
            )
            .scaleEffect(isVisible ? 1 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: isVisible)
            
            // Content
            VStack(spacing: 20) {
                Text(page.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: isVisible)
                
                Text(page.subtitle)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.3), value: isVisible)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: isVisible)
            }
            
            // Feature highlights for specific pages
            if pageIndex > 0 {
                VStack(spacing: 12) {
                    ForEach(featuresForPage(page), id: \.title) { feature in
                        FeatureCard(
                            icon: feature.icon,
                            title: feature.title,
                            description: feature.description,
                            color: page.color
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(x: isVisible ? 0 : -50)
                        .animation(.easeOut(duration: 0.5).delay(0.5 + Double(feature.index) * 0.1), value: isVisible)
                    }
                }
                .padding(.horizontal, 24)
            }
            
            Spacer()
        }
        .padding(.vertical)
        .onAppear {
            isVisible = true
        }
        .onDisappear {
            isVisible = false
        }
    }
    
    private func featuresForPage(_ page: OnboardingPage) -> [(icon: String, title: String, description: String, index: Int)] {
        switch page {
        case .readListen:
            return [
                ("book.fill", "Multiple Translations", "Access ESV, NIV, KJV and more", 0),
                ("speaker.wave.3.fill", "Natural AI Voices", "Listen with lifelike narration", 1),
                ("highlighter", "Smart Highlighting", "Mark and save important verses", 2)
            ]
        case .community:
            return [
                ("hands.clap.fill", "Prayer Wall", "Share and pray for others", 0),
                ("person.2.fill", "Study Groups", "Join topic-based communities", 1),
                ("bubble.left.and.bubble.right.fill", "Discussions", "Engage in meaningful conversations", 2)
            ]
        case .library:
            return [
                ("bookmark.fill", "Smart Bookmarks", "Organize by topic or book", 0),
                ("note.text", "Rich Notes", "Add context to your study", 1),
                ("arrow.down.circle.fill", "Offline Access", "Download for anywhere reading", 2)
            ]
        case .personalization:
            return [
                ("moon.fill", "Dark Mode", "Easy on the eyes at night", 0),
                ("textformat.size", "Custom Fonts", "Choose your reading style", 1),
                ("calendar", "Reading Plans", "Stay consistent with daily goals", 2)
            ]
        default:
            return []
        }
    }
}

struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color.leavnPrimary.opacity(0.1),
                Color.purple.opacity(0.05),
                Color.blue.opacity(0.1)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}