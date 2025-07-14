import Foundation
import LeavnCore
import Factory

// MARK: - Error Recovery Service
public protocol ErrorRecoveryService {
    func handleError(_ error: Error) -> ErrorRecoveryStrategy
    func executeRecovery(for error: Error, using strategy: ErrorRecoveryStrategy) async throws
}

// MARK: - Error Recovery Strategy
public enum ErrorRecoveryStrategy {
    case retry(maxAttempts: Int, delay: TimeInterval)
    case authenticate
    case clearCacheAndRetry
    case showOfflineMode
    case contactSupport
    case ignore
    case custom(handler: () async throws -> Void)
    
    public var userMessage: String {
        switch self {
        case .retry:
            return "We're having trouble connecting. Retrying..."
        case .authenticate:
            return "Please sign in to continue"
        case .clearCacheAndRetry:
            return "Clearing cache and trying again..."
        case .showOfflineMode:
            return "You're offline. Some features may be limited."
        case .contactSupport:
            return "Something went wrong. Please contact support if this persists."
        case .ignore:
            return ""
        case .custom:
            return "Attempting to recover..."
        }
    }
}

// MARK: - Default Error Recovery Service
public final class DefaultErrorRecoveryService: ErrorRecoveryService {
    @Injected(\.networkService) private var networkService: NetworkService
    @Injected(\.authenticationService) private var authService: AuthenticationService
    @Injected(\.analyticsService) private var analyticsService: AnalyticsService
    
    public init() {}
    
    public func handleError(_ error: Error) -> ErrorRecoveryStrategy {
        // Log error to analytics
        analyticsService.trackError(error)
        
        // Determine recovery strategy based on error type
        if let leavnError = error as? LeavnError {
            return handleLeavnError(leavnError)
        } else if let urlError = error as? URLError {
            return handleURLError(urlError)
        } else {
            return .contactSupport
        }
    }
    
    public func executeRecovery(for error: Error, using strategy: ErrorRecoveryStrategy) async throws {
        switch strategy {
        case .retry(let maxAttempts, let delay):
            try await executeRetry(maxAttempts: maxAttempts, delay: delay)
            
        case .authenticate:
            try await executeAuthentication()
            
        case .clearCacheAndRetry:
            try await executeClearCacheAndRetry()
            
        case .showOfflineMode:
            // No action needed, UI should handle offline mode
            break
            
        case .contactSupport:
            // Log detailed error info for support
            logErrorForSupport(error)
            
        case .ignore:
            // No action needed
            break
            
        case .custom(let handler):
            try await handler()
        }
    }
    
    // MARK: - Private Methods
    private func handleLeavnError(_ error: LeavnError) -> ErrorRecoveryStrategy {
        switch error {
        case .networkError:
            return .retry(maxAttempts: 3, delay: 2.0)
            
        case .unauthorized:
            return .authenticate
            
        case .serverError:
            return .retry(maxAttempts: 2, delay: 5.0)
            
        case .localStorageError:
            return .clearCacheAndRetry
            
        case .notFound, .validationError, .invalidInput:
            return .ignore
            
        default:
            return .contactSupport
        }
    }
    
    private func handleURLError(_ error: URLError) -> ErrorRecoveryStrategy {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .showOfflineMode
            
        case .timedOut:
            return .retry(maxAttempts: 2, delay: 1.0)
            
        case .cancelled:
            return .ignore
            
        default:
            return .retry(maxAttempts: 3, delay: 2.0)
        }
    }
    
    private func executeRetry(maxAttempts: Int, delay: TimeInterval) async throws {
        // Retry logic would be implemented by the calling code
        // This just provides the delay
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    private func executeAuthentication() async throws {
        // Trigger authentication flow
        try await authService.signOut()
        // The UI should detect the sign-out and show login screen
    }
    
    private func executeClearCacheAndRetry() async throws {
        // Clear various caches
        if let audioCache = try? Container.shared.audioCacheManager() {
            try audioCache.clearCache()
        }
        
        if let bibleCache = Container.shared.bibleCacheManager() {
            try await bibleCache.clearCache()
        }
        
        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()
    }
    
    private func logErrorForSupport(_ error: Error) {
        let errorInfo: [String: Any] = [
            "error_type": String(describing: type(of: error)),
            "error_description": error.localizedDescription,
            "timestamp": Date().timeIntervalSince1970,
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "Unknown",
            "os_version": ProcessInfo.processInfo.operatingSystemVersionString
        ]
        
        analyticsService.trackError(error, additionalInfo: errorInfo)
    }
}

// MARK: - Error Recovery View Modifier
import SwiftUI

struct ErrorRecoveryModifier: ViewModifier {
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var recoveryStrategy: ErrorRecoveryStrategy = .ignore
    
    let error: Error?
    let recoveryService: ErrorRecoveryService
    let onRetry: (() async throws -> Void)?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: error) { _, newError in
                if let error = newError {
                    handleError(error)
                }
            }
            .alert("Error", isPresented: $showingError) {
                switch recoveryStrategy {
                case .retry:
                    Button("Retry") {
                        Task {
                            try? await onRetry?()
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                    
                case .authenticate:
                    Button("Sign In") {
                        Task {
                            try? await recoveryService.executeRecovery(
                                for: error!,
                                using: recoveryStrategy
                            )
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                    
                case .contactSupport:
                    Button("OK") {}
                    
                default:
                    Button("OK") {}
                }
            } message: {
                Text(errorMessage)
            }
    }
    
    private func handleError(_ error: Error) {
        recoveryStrategy = recoveryService.handleError(error)
        errorMessage = recoveryStrategy.userMessage
        
        if !errorMessage.isEmpty {
            showingError = true
        }
    }
}

extension View {
    public func errorRecovery(
        error: Error?,
        onRetry: (() async throws -> Void)? = nil
    ) -> some View {
        modifier(ErrorRecoveryModifier(
            error: error,
            recoveryService: DefaultErrorRecoveryService(),
            onRetry: onRetry
        ))
    }
}