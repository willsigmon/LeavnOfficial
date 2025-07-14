import SwiftUI

struct APIKeyInputView: View {
    let provider: AIProvider
    @State var configuration: APIKeyConfiguration
    let onSave: (APIKeyConfiguration) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = ""
    @State private var showAPIKey = false
    @State private var isValidating = false
    @State private var isSaving = false
    @State private var validationError: String?
    @State private var selectedModelId: String = ""
    
    init(provider: AIProvider, configuration: APIKeyConfiguration, onSave: @escaping (APIKeyConfiguration) -> Void) {
        self.provider = provider
        self._configuration = State(initialValue: configuration)
        self.onSave = onSave
        self._apiKey = State(initialValue: configuration.apiKey)
        self._selectedModelId = State(initialValue: configuration.selectedModel ?? provider.models.first?.id ?? "")
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        apiKeySection
                        modelSection
                        securityNote
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Configure \(provider.rawValue)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !configuration.apiKey.isEmpty && configuration.apiKey != apiKey {
                        Menu {
                            Button("Save Changes") {
                                saveConfiguration()
                            }
                            .disabled(apiKey.isEmpty || isValidating || isSaving)
                            
                            Button("Delete API Key", role: .destructive) {
                                deleteConfiguration()
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    } else {
                        Button("Save") {
                            saveConfiguration()
                        }
                        .disabled(apiKey.isEmpty || isValidating || isSaving)
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(provider.color.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: provider.icon)
                    .font(.system(size: 40))
                    .foregroundColor(provider.color)
            }
            
            Text(provider.rawValue)
                .font(LeavnTheme.Typography.titleLarge)
            
            Text(provider.description)
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Link(destination: URL(string: provider.documentationURL)!) {
                HStack {
                    Image(systemName: "arrow.up.right.square")
                    Text("Get your API key")
                }
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(provider.color)
            }
        }
    }
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("API Key", systemImage: "key.fill")
                .font(LeavnTheme.Typography.headline)
            
            HStack {
                if showAPIKey {
                    TextField("Enter your API key", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                } else {
                    SecureField("Enter your API key", text: $apiKey)
                        .textFieldStyle(.plain)
                        .font(.system(.body, design: .monospaced))
                }
                
                Button(action: { showAPIKey.toggle() }) {
                    Image(systemName: showAPIKey ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel(showAPIKey ? "Hide API key" : "Show API key")
                
                if !apiKey.isEmpty {
                    Button(action: { apiKey = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Clear API key")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            )
            
            Text("Example: \(provider.keyPlaceholder)")
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
            
            if let error = validationError {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                }
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(LeavnTheme.Colors.error)
            }
        }
    }
    
    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Preferred Model", systemImage: "cpu")
                .font(LeavnTheme.Typography.headline)
            
            VStack(spacing: 8) {
                ForEach(provider.models) { model in
                    ModelOption(
                        model: model,
                        isSelected: selectedModelId == model.id,
                        action: { selectedModelId = model.id }
                    )
                }
            }
        }
    }
    
    private var securityNote: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.title2)
                    .foregroundColor(LeavnTheme.Colors.success)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Your API key is secure")
                        .font(LeavnTheme.Typography.headline)
                    
                    Text("• Stored locally on your device\n• Never sent to our servers\n• Encrypted in secure storage")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(LeavnTheme.Colors.success.opacity(0.1))
        )
    }
    
    private func saveConfiguration() {
        guard !apiKey.isEmpty else {
            validationError = "API key cannot be empty"
            return
        }
        
        // Clear previous error
        validationError = nil
        isSaving = true
        
        // Validate API key format
        if !validateKeyFormat() {
            validationError = "Invalid API key format for \(provider.rawValue)"
            isSaving = false
            return
        }
        
        // Save configuration
        var newConfig = configuration
        newConfig.apiKey = apiKey
        newConfig.selectedModel = selectedModelId
        newConfig.isEnabled = true
        
        // Store in Keychain (secure storage)
        KeychainHelper.save(apiKey, for: "\(provider.rawValue)_APIKey")
        
        onSave(newConfig)
        dismiss()
    }
    
    private func deleteConfiguration() {
        // Delete from Keychain
        KeychainHelper.delete(for: "\(provider.rawValue)_APIKey")
        
        // Update configuration
        var newConfig = configuration
        newConfig.apiKey = ""
        newConfig.isEnabled = false
        
        onSave(newConfig)
        dismiss()
    }
    
    private func validateKeyFormat() -> Bool {
        switch provider {
        case .openAI:
            // OpenAI keys can start with sk- or sk-proj-
            return (apiKey.hasPrefix("sk-") || apiKey.hasPrefix("sk-proj-")) && apiKey.count > 20
        case .anthropic:
            return apiKey.hasPrefix("sk-ant-") && apiKey.count > 20
        case .google:
            return apiKey.hasPrefix("AIza") && apiKey.count > 20
        case .xAI:
            // xAI keys format to be confirmed - accepting any non-empty key for now
            return apiKey.count > 10
        }
    }
}

// MARK: - Model Option
struct ModelOption: View {
    let model: AIModel
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(model.name)
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(model.description)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? LeavnTheme.Colors.accent.opacity(0.1) : Color(.tertiarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Safari View
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Keychain Helper
enum KeychainHelper {
    private static let serviceName = "com.leavn.api-keys"
    
    static func save(_ value: String, for key: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Error saving to keychain: \(status)")
        }
    }
    
    static func load(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    static func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}