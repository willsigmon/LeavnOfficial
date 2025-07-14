import SwiftUI

public struct AIProvidersView: View {
    @StateObject private var viewModel = AIProvidersViewModel()
    @State private var selectedProvider: AIProvider?
    @State private var showingAPIKeyInput = false
    @State private var showingDocumentation = false
    @State private var documentationURL: String?
    
    public var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    VStack(spacing: 24) {
                        infoSection
                        providersSection
                        settingsSection
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
        }
        .sheet(item: $selectedProvider) { provider in
            APIKeyInputView(
                provider: provider,
                configuration: viewModel.configuration(for: provider),
                onSave: { config in
                    viewModel.updateConfiguration(config, for: provider)
                }
            )
        }
        .sheet(isPresented: $showingDocumentation) {
            if let urlString = documentationURL,
               let url = URL(string: urlString) {
                SafariView(url: url)
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Providers")
                    .font(LeavnTheme.Typography.displayMedium)
                    .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                
                Text("Configure your AI assistants")
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var infoSection: some View {
        VStack(spacing: 16) {
            // TestFlight Demo Key Section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "gift.fill")
                        .font(.title2)
                        .foregroundColor(LeavnTheme.Colors.accent)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Free TestFlight Access")
                            .font(LeavnTheme.Typography.headline)
                        
                        Text("During TestFlight, you have free access to OpenAI's GPT-4.1 models. This may change in the final release.")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Demo Key Toggle
                DemoKeyToggleView()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LeavnTheme.Colors.accent.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(LeavnTheme.Colors.accent.opacity(0.3), lineWidth: 1)
            )
            
            // Bring Your Own Keys Section
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "key.fill")
                        .font(.title2)
                        .foregroundColor(LeavnTheme.Colors.info)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bring Your Own Keys")
                            .font(LeavnTheme.Typography.headline)
                        
                        Text("Use your own API keys for AI-powered Bible study features. Your keys are stored securely on your device.")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 12) {
                    Label("Secure", systemImage: "lock.shield.fill")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.success)
                    
                    Label("Private", systemImage: "eye.slash.fill")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.info)
                    
                    Label("Optional", systemImage: "checkmark.circle.fill")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
    }
    
    private var providersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("PROVIDERS")
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(AIProvider.allCases) { provider in
                    ProviderCard(
                        provider: provider,
                        configuration: viewModel.configuration(for: provider),
                        onTap: {
                            selectedProvider = provider
                        },
                        onToggle: { isEnabled in
                            viewModel.toggleProvider(provider, enabled: isEnabled)
                        },
                        onInfo: {
                            documentationURL = provider.documentationURL
                            showingDocumentation = true
                        }
                    )
                }
            }
        }
    }
    
    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("AI SETTINGS")
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 0) {
                // Preferred Provider
                SettingRow(
                    icon: "star.fill",
                    title: "Preferred Provider",
                    value: viewModel.preferredProviderName
                ) {
                    // Show provider picker
                }
                
                Divider().padding(.horizontal)
                
                // Response Length
                SettingRow(
                    icon: "text.alignleft",
                    title: "Response Length",
                    value: viewModel.settings.responseLength.rawValue
                ) {
                    // Show length picker
                }
                
                Divider().padding(.horizontal)
                
                // Toggle Settings
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text("Auto-Select Best Model")
                            .font(.body)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.settings.autoSelectBestModel)
                            .labelsHidden()
                    }
                    .padding()
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text("Stream Responses")
                            .font(.body)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.settings.streamResponses)
                            .labelsHidden()
                    }
                    .padding()
                    
                    Divider().padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "memorychip")
                            .foregroundColor(.blue)
                            .frame(width: 20)
                        
                        Text("Cache Responses")
                            .font(.body)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.settings.cacheResponses)
                            .labelsHidden()
                    }
                    .padding()
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
}

// MARK: - Provider Card
struct ProviderCard: View {
    let provider: AIProvider
    let configuration: APIKeyConfiguration
    let onTap: () -> Void
    let onToggle: (Bool) -> Void
    let onInfo: () -> Void
    
    private var isConfigured: Bool {
        !configuration.apiKey.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Provider Icon
                ZStack {
                    Circle()
                        .fill(provider.color.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: provider.icon)
                        .font(.title2)
                        .foregroundColor(provider.color)
                }
                
                // Provider Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(provider.rawValue)
                            .font(.headline)
                        
                        if isConfigured {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    
                    Text(provider.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Toggle
                Toggle("", isOn: .init(
                    get: { configuration.isEnabled },
                    set: { onToggle($0) }
                ))
                .labelsHidden()
                .disabled(!isConfigured)
                .accessibilityLabel("Enable \(provider.rawValue)")
                .accessibilityHint(isConfigured ? "Toggle to enable or disable this AI provider" : "Add an API key first to enable this provider")
            }
            .padding()
            
            // Actions
            HStack(spacing: 16) {
                Button(action: onInfo) {
                    Label("Get API Key", systemImage: "questionmark.circle")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: onTap) {
                    Text(isConfigured ? "Update Key" : "Add Key")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(provider.color)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Demo Key Toggle View
struct DemoKeyToggleView: View {
    @State private var useDemoKey: Bool = true
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Use Demo OpenAI Key")
                        .font(.headline)
                    
                    Text(useDemoKey ? "Currently using free TestFlight access" : "Using your custom OpenAI key")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $useDemoKey)
                    .labelsHidden()
                    .onChange(of: useDemoKey) { oldValue, newValue in
                        AppConfiguration.APIKeys.setUseDemoKey(newValue)
                        HapticManager.shared.buttonTap()
                        
                        // Note: The models property in AIProvider will automatically 
                        // refresh when UserDefaults changes, triggering UI update
                    }
            }
            
            if !useDemoKey {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    Text("Configure your OpenAI key in the providers section below")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            useDemoKey = AppConfiguration.APIKeys.isUsingDemoKey
        }
    }
}

// MARK: - View Model
class AIProvidersViewModel: ObservableObject {
    @Published var settings = AISettings()
    
    init() {
        loadSettings()
    }
    
    var preferredProviderName: String {
        if let providerName = settings.preferredProvider,
           let provider = AIProvider.allCases.first(where: { $0.rawValue == providerName }) {
            return provider.rawValue
        }
        return "None"
    }
    
    func configuration(for provider: AIProvider) -> APIKeyConfiguration {
        settings.configurations.first { $0.provider == provider.rawValue } ?? APIKeyConfiguration(provider: provider)
    }
    
    func updateConfiguration(_ config: APIKeyConfiguration, for provider: AIProvider) {
        if let index = settings.configurations.firstIndex(where: { $0.provider == provider.rawValue }) {
            settings.configurations[index] = config
        } else {
            settings.configurations.append(config)
        }
        saveSettings()
    }
    
    func toggleProvider(_ provider: AIProvider, enabled: Bool) {
        guard var config = settings.configurations.first(where: { $0.provider == provider.rawValue }) else { return }
        config.isEnabled = enabled
        updateConfiguration(config, for: provider)
    }
    
    private func loadSettings() {
        // Load from Keychain/UserDefaults
        if let data = UserDefaults.standard.data(forKey: "AISettings"),
           let decoded = try? JSONDecoder().decode(AISettings.self, from: data) {
            settings = decoded
            
            // Load API keys from Keychain
            for configIndex in 0..<settings.configurations.count {
                let provider = settings.configurations[configIndex].provider
                if let apiKey = KeychainHelper.load(for: "\(provider)_APIKey") {
                    settings.configurations[configIndex].apiKey = apiKey
                }
            }
        }
    }
    
    private func saveSettings() {
        // Save to Keychain/UserDefaults
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "AISettings")
        }
    }
}
