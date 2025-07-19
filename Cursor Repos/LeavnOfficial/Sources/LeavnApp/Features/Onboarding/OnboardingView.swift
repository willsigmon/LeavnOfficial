import SwiftUI
import ComposableArchitecture

public struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var currentPage = 0
    @State private var esvAPIKey = ""
    @State private var elevenLabsAPIKey = ""
    
    private let pages = [
        OnboardingPage(
            title: "Welcome to Leavn",
            subtitle: "Your personal Bible companion",
            description: "Read, listen, and connect with God's Word like never before.",
            imageName: "book.fill"
        ),
        OnboardingPage(
            title: "Read & Listen",
            subtitle: "Immerse yourself in Scripture",
            description: "Access the ESV Bible with audio narration powered by AI voices.",
            imageName: "speaker.wave.3.fill"
        ),
        OnboardingPage(
            title: "Community",
            subtitle: "Connect with believers",
            description: "Share prayer requests, join study groups, and grow together.",
            imageName: "person.3.fill"
        ),
        OnboardingPage(
            title: "Your Library",
            subtitle: "Never lose a moment",
            description: "Save bookmarks, take notes, and download content for offline reading.",
            imageName: "books.vertical.fill"
        )
    ]
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingPageView(page: pages[index])
                        .tag(index)
                }
                
                // API Keys Setup Page
                APIKeysSetupView(
                    esvAPIKey: $esvAPIKey,
                    elevenLabsAPIKey: $elevenLabsAPIKey,
                    onComplete: onComplete
                )
                .tag(pages.count)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)
            
            // Custom page indicator and navigation
            VStack(spacing: 20) {
                HStack(spacing: 8) {
                    ForEach(0...pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.easeInOut, value: currentPage)
                    }
                }
                
                HStack {
                    if currentPage > 0 {
                        Button("Back") {
                            withAnimation {
                                currentPage -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentPage < pages.count {
                        Button("Next") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: page.imageName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .symbolRenderingMode(.hierarchical)
            
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(page.subtitle)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Text(page.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct APIKeysSetupView: View {
    @Binding var esvAPIKey: String
    @Binding var elevenLabsAPIKey: String
    let onComplete: () -> Void
    
    @State private var isLoading = false
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Setup API Keys")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("To get started, you'll need API keys for Bible text and audio narration.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ESV API Key")
                            .font(.headline)
                        
                        Spacer()
                        
                        Link("Get Key", destination: URL(string: "https://api.esv.org")!)
                            .font(.caption)
                    }
                    
                    TextField("Enter ESV API Key", text: $esvAPIKey)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("Free API key for accessing Bible text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("ElevenLabs API Key (Optional)")
                            .font(.headline)
                        
                        Spacer()
                        
                        Link("Get Key", destination: URL(string: "https://elevenlabs.io")!)
                            .font(.caption)
                    }
                    
                    TextField("Enter ElevenLabs API Key", text: $elevenLabsAPIKey)
                        .textFieldStyle(.roundedBorder)
                    
                    Text("For AI-powered audio narration")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            VStack(spacing: 16) {
                Button(action: saveKeysAndComplete) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .scaleEffect(0.8)
                    } else {
                        Text("Get Started")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(esvAPIKey.isEmpty || isLoading)
                .frame(minWidth: 200)
                
                Button("Skip for Now") {
                    onComplete()
                }
                .buttonStyle(.bordered)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .alert("Error", isPresented: $showingError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveKeysAndComplete() {
        isLoading = true
        
        Task {
            do {
                @Dependency(\.apiKeyManager) var apiKeyManager
                
                if !esvAPIKey.isEmpty {
                    try await apiKeyManager.saveESVKey(esvAPIKey)
                }
                
                if !elevenLabsAPIKey.isEmpty {
                    try await apiKeyManager.saveElevenLabsKey(elevenLabsAPIKey)
                }
                
                await MainActor.run {
                    isLoading = false
                    onComplete()
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
        }
    }
}