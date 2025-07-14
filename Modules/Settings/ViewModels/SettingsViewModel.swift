import Foundation
import SwiftUI
import Combine

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var userName = "User"
    @Published var userEmail = "user@example.com"
    @Published var appSettings: AppSettings = AppSettings()
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var error: Error?
    @Published var successMessage: String?
    
    // UI State
    @Published var notifications = true
    @Published var dailyReminders = true
    @Published var reminderTime = Date()
    @Published var preferredTranslation = "ESV"
    @Published var appTheme = "System"
    @Published var fontSize: Double = 16
    @Published var theologicalPerspectives: Set<TheologicalPerspective> = []
    
    let themes = ["Light", "Dark", "System"]
    let translations = ["NIV", "ESV", "KJV", "NLT", "NASB", "MSG", "AMP"]
    
    private let settingsRepository: SettingsRepositoryProtocol
    private let userDataManager: UserDataManagerProtocol
    private let authenticationService: AuthenticationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        settingsRepository: SettingsRepositoryProtocol? = nil,
        userDataManager: UserDataManagerProtocol? = nil,
        authenticationService: AuthenticationServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.settingsRepository = settingsRepository ?? container.settingsRepository
        self.userDataManager = userDataManager ?? container.userDataManager
        self.authenticationService = authenticationService ?? container.authenticationService
        self.analyticsService = analyticsService ?? container.analyticsService
        
        Task {
            await loadSettings()
        }
        
        // Observe authentication changes
        authenticationService.currentUser
            .sink { [weak self] user in
                if let user = user {
                    self?.userName = user.displayName
                    self?.userEmail = user.email
                } else {
                    self?.userName = "User"
                    self?.userEmail = "user@example.com"
                }
            }
            .store(in: &cancellables)
    }
    
    func loadSettings() async {
        isLoading = true
        error = nil
        
        do {
            appSettings = try await settingsRepository.getSettings()
            
            // Update UI state from settings
            updateUIFromSettings()
            
            analyticsService.track(event: "settings_loaded", properties: nil)
        } catch {
            self.error = error
            print("Failed to load settings: \(error)")
            
            // Use default settings on error
            appSettings = AppSettings()
            updateUIFromSettings()
        }
        
        isLoading = false
    }
    
    func saveSettings() async {
        isSaving = true
        error = nil
        
        // Update settings from UI state
        updateSettingsFromUI()
        
        do {
            try await settingsRepository.updateSettings(appSettings)
            successMessage = "Settings saved successfully"
            
            analyticsService.track(event: "settings_saved", properties: [
                "theme": appSettings.theme.rawValue,
                "fontSize": appSettings.fontSize.rawValue,
                "notifications": appSettings.notificationsEnabled
            ])
            
            // Clear success message after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.successMessage = nil
            }
        } catch {
            self.error = error
            print("Failed to save settings: \(error)")
        }
        
        isSaving = false
    }
    
    func resetToDefaults() async {
        isLoading = true
        error = nil
        
        do {
            try await settingsRepository.resetToDefaults()
            await loadSettings()
            
            analyticsService.track(event: "settings_reset", properties: nil)
        } catch {
            self.error = error
            print("Failed to reset settings: \(error)")
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await authenticationService.signOut()
            
            analyticsService.track(event: "user_signed_out", properties: nil)
        } catch {
            self.error = error
            print("Failed to sign out: \(error)")
        }
    }
    
    func deleteAccount() async {
        // TODO: Implement account deletion when backend is ready
        analyticsService.track(event: "account_deletion_requested", properties: nil)
    }
    
    func exportSettings() async {
        do {
            let data = try await settingsRepository.exportSettings()
            // TODO: Handle exported data (share sheet, save to files, etc.)
            
            analyticsService.track(event: "settings_exported", properties: nil)
        } catch {
            self.error = error
            print("Failed to export settings: \(error)")
        }
    }
    
    func importSettings(from data: Data) async {
        do {
            try await settingsRepository.importSettings(from: data)
            await loadSettings()
            
            analyticsService.track(event: "settings_imported", properties: nil)
        } catch {
            self.error = error
            print("Failed to import settings: \(error)")
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateUIFromSettings() {
        appTheme = appSettings.theme.rawValue.capitalized
        fontSize = fontSizeToDouble(appSettings.fontSize)
        notifications = appSettings.notificationsEnabled
        dailyReminders = appSettings.offlineModeEnabled // Using offline mode as proxy for daily reminders
        
        // Load user preferences if available
        loadUserPreferences()
    }
    
    private func updateSettingsFromUI() {
        appSettings = AppSettings(
            theme: Theme(rawValue: appTheme.lowercased()) ?? .system,
            fontSize: doubleToFontSize(fontSize),
            notificationsEnabled: notifications,
            offlineModeEnabled: dailyReminders
        )
    }
    
    private func loadUserPreferences() {
        // This would load from UserDataManager in a real implementation
        // For now, using defaults
    }
    
    private func fontSizeToDouble(_ fontSize: FontSize) -> Double {
        switch fontSize {
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        }
    }
    
    private func doubleToFontSize(_ value: Double) -> FontSize {
        switch value {
        case ..<15: return .small
        case 15..<17: return .medium
        case 17..<19: return .large
        default: return .extraLarge
        }
    }
}

// MARK: - Theological Perspective (for compatibility)
struct TheologicalPerspective: Hashable {
    let id: String
    let name: String
}

// MARK: - User Preferences Extension (temporary for migration)
extension UserDataManager {
    var userPreferences: UserPreferences? {
        // Return mock preferences for now
        return UserPreferences(
            preferredTranslation: "ESV",
            selectedTheme: "System",
            fontSize: 16,
            theologicalPerspectives: [],
            enableNotifications: true,
            dailyReadingReminder: true,
            reminderTime: Date()
        )
    }
    
    var currentUser: MockUser? {
        // Return mock user for now
        return MockUser(name: "Bible Reader", email: "reader@example.com")
    }
}

struct UserPreferences {
    let preferredTranslation: String?
    let selectedTheme: String?
    let fontSize: Int
    let theologicalPerspectives: Set<TheologicalPerspective>
    let enableNotifications: Bool
    let dailyReadingReminder: Bool
    let reminderTime: Date?
}

struct MockUser {
    let name: String?
    let email: String?
}