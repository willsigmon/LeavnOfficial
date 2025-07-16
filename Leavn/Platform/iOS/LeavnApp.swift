import SwiftUI

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
    private let authService: AuthenticationServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    init() {
        let container = DIContainer.shared
        self.authService = container.authenticationService
        self.analyticsService = container.analyticsService
        
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