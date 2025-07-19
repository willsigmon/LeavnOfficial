import SwiftUI
import ComposableArchitecture

struct OnboardingSetupView: View {
    let onComplete: () -> Void
    @State private var currentStep = 0
    @State private var setupData = OnboardingSetupData()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Bar
                ProgressBar(
                    currentStep: currentStep,
                    totalSteps: OnboardingSetupStep.allCases.count
                )
                .padding()
                
                // Content
                TabView(selection: $currentStep) {
                    ForEach(OnboardingSetupStep.allCases.indices, id: \.self) { index in
                        setupViewForStep(OnboardingSetupStep.allCases[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentStep)
                
                // Navigation
                HStack {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    if currentStep < OnboardingSetupStep.allCases.count - 1 {
                        Button("Continue") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!canProceedFromCurrentStep())
                    } else {
                        Button("Finish Setup") {
                            completeSetup()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Skip") {
                        onComplete()
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func setupViewForStep(_ step: OnboardingSetupStep) -> some View {
        switch step {
        case .account:
            AccountSetupView(setupData: $setupData)
        case .apiKeys:
            APIKeysSetupStepView(setupData: $setupData)
        case .preferences:
            PreferencesSetupView(setupData: $setupData)
        case .permissions:
            PermissionsSetupView(setupData: $setupData)
        }
    }
    
    private func canProceedFromCurrentStep() -> Bool {
        switch OnboardingSetupStep.allCases[currentStep] {
        case .account:
            return true // Account is optional
        case .apiKeys:
            return !setupData.esvAPIKey.isEmpty
        case .preferences:
            return true
        case .permissions:
            return true
        }
    }
    
    private func completeSetup() {
        // Save setup data
        Task {
            @Dependency(\.apiKeyManager) var apiKeyManager
            @Dependency(\.userDefaults) var userDefaults
            
            // Save API keys
            if !setupData.esvAPIKey.isEmpty {
                try? await apiKeyManager.saveESVKey(setupData.esvAPIKey)
            }
            
            if !setupData.elevenLabsAPIKey.isEmpty {
                try? await apiKeyManager.saveElevenLabsKey(setupData.elevenLabsAPIKey)
            }
            
            // Save preferences
            userDefaults.setDefaultTranslation(setupData.defaultTranslation)
            userDefaults.setTheme(setupData.theme)
            userDefaults.setFontSize(setupData.fontSize)
            
            // Request permissions
            if setupData.enableNotifications {
                // Request notification permission
            }
            
            await MainActor.run {
                onComplete()
            }
        }
    }
}

// MARK: - Setup Steps
enum OnboardingSetupStep: CaseIterable {
    case account
    case apiKeys
    case preferences
    case permissions
    
    var title: String {
        switch self {
        case .account:
            return "Create Account"
        case .apiKeys:
            return "API Keys"
        case .preferences:
            return "Preferences"
        case .permissions:
            return "Permissions"
        }
    }
}

// MARK: - Setup Data Model
struct OnboardingSetupData {
    // Account
    var email = ""
    var name = ""
    var skipAccount = true
    
    // API Keys
    var esvAPIKey = ""
    var elevenLabsAPIKey = ""
    
    // Preferences
    var defaultTranslation: BibleTranslation = .esv
    var theme: AppTheme = .system
    var fontSize: Double = 18
    var enableDailyVerse = true
    
    // Permissions
    var enableNotifications = true
    var enableLocation = false
}

// MARK: - Progress Bar
struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    private var progress: Double {
        Double(currentStep + 1) / Double(totalSteps)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.caption.bold())
                    .foregroundColor(.leavnPrimary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(Color.leavnPrimary)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Account Setup View
struct AccountSetupView: View {
    @Binding var setupData: OnboardingSetupData
    @State private var isCreatingAccount = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 80))
                    .foregroundColor(.leavnPrimary)
                
                Text("Create Your Account")
                    .font(.largeTitle.bold())
                
                Text("Sync your data across devices and connect with the community")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            if isCreatingAccount {
                // Account Form
                VStack(spacing: 16) {
                    TextField("Name", text: $setupData.name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Email", text: $setupData.email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)
                
                Text("We'll send you a verification email to complete setup")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // Options
                VStack(spacing: 16) {
                    Button("Create Account") {
                        withAnimation {
                            isCreatingAccount = true
                            setupData.skipAccount = false
                        }
                    }
                    .buttonStyle(OnboardingButtonStyle(isPrimary: true))
                    
                    Button("Continue as Guest") {
                        setupData.skipAccount = true
                    }
                    .buttonStyle(OnboardingButtonStyle())
                    
                    Text("You can create an account later in Settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

// MARK: - API Keys Setup View
struct APIKeysSetupStepView: View {
    @Binding var setupData: OnboardingSetupData
    @State private var showingESVInfo = false
    @State private var showingElevenLabsInfo = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.leavnPrimary)
                    
                    Text("Setup API Keys")
                        .font(.largeTitle.bold())
                    
                    Text("Connect to Bible and audio services")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // ESV API Key
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("ESV Bible API", systemImage: "book.fill")
                            .font(.headline)
                        
                        Button(action: { showingESVInfo.toggle() }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.leavnPrimary)
                        }
                        
                        Spacer()
                        
                        Link("Get Free Key", destination: URL(string: "https://api.esv.org")!)
                            .font(.caption)
                    }
                    
                    TextField("Enter ESV API Key", text: $setupData.esvAPIKey)
                        .textFieldStyle(.roundedBorder)
                    
                    if showingESVInfo {
                        Text("Required for accessing Bible text. Free for personal use.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // ElevenLabs API Key
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("ElevenLabs AI Voices", systemImage: "speaker.wave.3.fill")
                            .font(.headline)
                        
                        Button(action: { showingElevenLabsInfo.toggle() }) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.leavnPrimary)
                        }
                        
                        Spacer()
                        
                        Link("Get Key", destination: URL(string: "https://elevenlabs.io")!)
                            .font(.caption)
                    }
                    
                    TextField("Enter ElevenLabs API Key (Optional)", text: $setupData.elevenLabsAPIKey)
                        .textFieldStyle(.roundedBorder)
                    
                    if showingElevenLabsInfo {
                        Text("Optional. Enables natural AI voice narration for Bible audio.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                
                // Info Box
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "lock.shield")
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your keys are secure")
                            .font(.callout.bold())
                        Text("API keys are stored securely in the iOS keychain and never leave your device.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Preferences Setup View
struct PreferencesSetupView: View {
    @Binding var setupData: OnboardingSetupData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 60))
                        .foregroundColor(.leavnPrimary)
                    
                    Text("Personalize Your Experience")
                        .font(.largeTitle.bold())
                    
                    Text("Set up your reading preferences")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Theme Selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Appearance")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(AppTheme.allCases) { theme in
                            ThemeOptionCard(
                                theme: theme,
                                isSelected: setupData.theme == theme
                            ) {
                                setupData.theme = theme
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Font Size
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Reading Font Size")
                            .font(.headline)
                        Spacer()
                        Text("\(Int(setupData.fontSize))pt")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(value: $setupData.fontSize, in: 14...30, step: 1)
                    
                    // Preview
                    Text("In the beginning God created the heavens and the earth.")
                        .font(.system(size: setupData.fontSize))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // Default Translation
                VStack(alignment: .leading, spacing: 16) {
                    Text("Default Translation")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(BibleTranslation.allCases) { translation in
                                TranslationOptionCard(
                                    translation: translation,
                                    isSelected: setupData.defaultTranslation == translation
                                ) {
                                    setupData.defaultTranslation = translation
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Daily Verse
                VStack(alignment: .leading, spacing: 16) {
                    Toggle(isOn: $setupData.enableDailyVerse) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Daily Verse")
                                .font(.headline)
                            Text("Get inspired with a new verse each day")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .leavnPrimary))
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Permissions Setup View
struct PermissionsSetupView: View {
    @Binding var setupData: OnboardingSetupData
    @State private var notificationPermissionGranted = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 60))
                    .foregroundColor(.leavnPrimary)
                
                Text("Enable Features")
                    .font(.largeTitle.bold())
                
                Text("Grant permissions to unlock all features")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.top, 40)
            
            // Permissions List
            VStack(spacing: 16) {
                PermissionRequestCard(
                    permission: PermissionRequestCard.Permission(
                        icon: "bell.fill",
                        title: "Notifications",
                        description: "Daily verses, reading reminders, and prayer updates",
                        color: .red
                    ),
                    isGranted: notificationPermissionGranted,
                    onRequest: {
                        // Request notification permission
                        setupData.enableNotifications = true
                        notificationPermissionGranted = true
                    }
                )
                
                Text("You can change these settings anytime in the app")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

// MARK: - Theme Option Card
struct ThemeOptionCard: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: theme.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(width: 60, height: 60)
                    .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                Text(theme.displayName)
                    .font(.caption)
                    .foregroundColor(isSelected ? .leavnPrimary : .secondary)
            }
        }
    }
}

// MARK: - Translation Option Card
struct TranslationOptionCard: View {
    let translation: BibleTranslation
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(translation.abbreviation)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(translation.fullName)
                    .font(.caption2)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 80)
            .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.1))
            .cornerRadius(12)
        }
    }
}