import Foundation
import SwiftUI
import Combine

@MainActor
public final class SettingsViewModel: BaseViewModel {
    @Published public var selectedTranslation: String = "ESV"
    @Published public var fontSize: Double = 16.0
    @Published public var enableNotifications: Bool = true
    @Published public var enableHaptics: Bool = true
    @Published public var darkModeEnabled: Bool = false
    @Published public var readingPlanReminders: Bool = true
    @Published public var dailyVerseNotifications: Bool = true
    
    private let userDataManager: UserDataManagerProtocol
    
    public init(userDataManager: UserDataManagerProtocol, analyticsService: AnalyticsServiceProtocol? = nil) {
        self.userDataManager = userDataManager
        super.init(analyticsService: analyticsService)
        
        loadSettings()
    }
    
    private func loadSettings() {
        // Load settings from UserDefaults through userDataManager
        selectedTranslation = UserDefaults.standard.string(forKey: "selectedTranslation") ?? "ESV"
        fontSize = UserDefaults.standard.double(forKey: "fontSize") != 0 ? UserDefaults.standard.double(forKey: "fontSize") : 16.0
        enableNotifications = UserDefaults.standard.bool(forKey: "enableNotifications")
        enableHaptics = UserDefaults.standard.bool(forKey: "enableHaptics")
        darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
        readingPlanReminders = UserDefaults.standard.bool(forKey: "readingPlanReminders")
        dailyVerseNotifications = UserDefaults.standard.bool(forKey: "dailyVerseNotifications")
        
        setupBindings()
    }
    
    private func setupBindings() {
        $selectedTranslation
            .sink { translation in
                UserDefaults.standard.set(translation, forKey: "selectedTranslation")
            }
            .store(in: &cancellables)
        
        $fontSize
            .sink { size in
                UserDefaults.standard.set(size, forKey: "fontSize")
            }
            .store(in: &cancellables)
        
        $enableNotifications
            .sink { enabled in
                UserDefaults.standard.set(enabled, forKey: "enableNotifications")
            }
            .store(in: &cancellables)
        
        $enableHaptics
            .sink { enabled in
                UserDefaults.standard.set(enabled, forKey: "enableHaptics")
            }
            .store(in: &cancellables)
        
        $darkModeEnabled
            .sink { enabled in
                UserDefaults.standard.set(enabled, forKey: "darkModeEnabled")
            }
            .store(in: &cancellables)
        
        $readingPlanReminders
            .sink { enabled in
                UserDefaults.standard.set(enabled, forKey: "readingPlanReminders")
            }
            .store(in: &cancellables)
        
        $dailyVerseNotifications
            .sink { enabled in
                UserDefaults.standard.set(enabled, forKey: "dailyVerseNotifications")
            }
            .store(in: &cancellables)
    }
    
    public func resetToDefaults() {
        selectedTranslation = "ESV"
        fontSize = 16.0
        enableNotifications = true
        enableHaptics = true
        darkModeEnabled = false
        readingPlanReminders = true
        dailyVerseNotifications = true
    }
    
    public func clearAllData() async {
        do {
            // Clear user data through userDataManager
            try await userDataManager.clearAllData()
            resetToDefaults()
        } catch {
            handleError(error)
        }
    }
}