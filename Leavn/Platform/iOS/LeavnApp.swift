import SwiftUI

import Factory

@main
struct LeavnApp: App {
    @StateObject private var appState = AppState()
    
    init() {
        // Setup application configuration
        AppConfiguration.shared.setupApplication()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    setupAppearance()
                }
        }
    }
    
    private func setupAppearance() {
        // Configure app-wide appearance
        #if os(iOS)
        UINavigationBar.appearance().prefersLargeTitles = true
        #endif
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Injected(\.authenticationService) private var authService: AuthenticationService
    @Injected(\.settingsViewModel) private var settingsViewModel: SettingsViewModel
    @Injected(\.analyticsService) private var analyticsService: AnalyticsService
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        checkAuthenticationStatus()
    }
    
    private func checkAuthenticationStatus() {
        Task { @MainActor in
            isLoading = true
            defer { isLoading = false }
            
            do {
                if let user = try await authService.getCurrentUser() {
                    self.currentUser = user
                    self.isAuthenticated = true
                    analyticsService.setUserId(user.id)
                }
            } catch {
                self.error = error
                analyticsService.trackError(error)
            }
        }
    }
} 