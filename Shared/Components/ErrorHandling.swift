import SwiftUI

// MARK: - App Error Types
public enum AppError: Error, LocalizedError {
    case networkError(String)
    case dataLoadingError(String)
    case authenticationError(String)
    case validationError(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataLoadingError(let message):
            return "Data Loading Error: \(message)"
        case .authenticationError(let message):
            return "Authentication Error: \(message)"
        case .validationError(let message):
            return "Validation Error: \(message)"
        case .unknownError(let message):
            return "Unknown Error: \(message)"
        }
    }
    
    public var recoverySuggestion: String? {
        switch self {
        case .networkError:
            return "Check your internet connection and try again."
        case .dataLoadingError:
            return "Please try refreshing the data."
        case .authenticationError:
            return "Please sign in again."
        case .validationError:
            return "Please check your input and try again."
        case .unknownError:
            return "Please restart the app and try again."
        }
    }
    
    public var icon: String {
        switch self {
        case .networkError:
            return "wifi.slash"
        case .dataLoadingError:
            return "exclamationmark.triangle"
        case .authenticationError:
            return "lock.slash"
        case .validationError:
            return "exclamationmark.circle"
        case .unknownError:
            return "questionmark.circle"
        }
    }
    
    public var actionTitle: String {
        switch self {
        case .networkError, .dataLoadingError, .unknownError:
            return "Retry"
        case .authenticationError:
            return "Sign In"
        case .validationError:
            return "Fix Issues"
        }
    }
}

// MARK: - Error View Component
public struct ErrorView: View {
    let error: AppError
    let onRetry: () -> Void
    let onDismiss: (() -> Void)?
    
    public init(
        error: AppError,
        onRetry: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        BaseCard(
            style: .elevated,
            shadowStyle: .medium
        ) {
            VStack(spacing: 16) {
                // Error Icon
                Image(systemName: error.icon)
                    .font(.system(size: 48))
                    .foregroundColor(.red)
                
                // Error Message
                VStack(spacing: 8) {
                    Text(error.errorDescription ?? "An error occurred")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if let recoverySuggestion = error.recoverySuggestion {
                        Text(recoverySuggestion)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Action Buttons
                HStack(spacing: 12) {
                    BaseActionButton(
                        title: error.actionTitle,
                        icon: "arrow.clockwise",
                        style: .primary,
                        size: .medium,
                        action: onRetry
                    )
                    
                    if let onDismiss = onDismiss {
                        BaseActionButton(
                            title: "Dismiss",
                            style: .secondary,
                            size: .medium,
                            action: onDismiss
                        )
                    }
                }
            }
        }
        .padding()
    }
}

// MARK: - Inline Error View
public struct InlineErrorView: View {
    let message: String
    let onRetry: (() -> Void)?
    
    public init(message: String, onRetry: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
                .font(.title3)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
            
            Spacer()
            
            if let onRetry = onRetry {
                Button("Retry", action: onRetry)
                    .font(.caption)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Error Banner
public struct ErrorBanner: View {
    let error: AppError
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    public init(
        error: AppError,
        onRetry: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.error = error
        self.onRetry = onRetry
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        HStack {
            Image(systemName: error.icon)
                .foregroundColor(.red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(error.errorDescription ?? "An error occurred")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let recoverySuggestion = error.recoverySuggestion {
                    Text(recoverySuggestion)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button("Retry", action: onRetry)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                
                Button("×", action: onDismiss)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Loading State Handler
public struct LoadingStateView<Content: View>: View {
    let isLoading: Bool
    let error: AppError?
    let isEmpty: Bool
    let emptyTitle: String
    let emptyMessage: String
    let emptyIcon: String
    let onRetry: () -> Void
    let content: Content
    
    public init(
        isLoading: Bool,
        error: AppError? = nil,
        isEmpty: Bool = false,
        emptyTitle: String = "No Data",
        emptyMessage: String = "There's nothing to display right now.",
        emptyIcon: String = "tray",
        onRetry: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.isLoading = isLoading
        self.error = error
        self.isEmpty = isEmpty
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyIcon = emptyIcon
        self.onRetry = onRetry
        self.content = content()
    }
    
    public var body: some View {
        Group {
            if isLoading {
                BaseLoadingView(message: "Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                ErrorView(error: error, onRetry: onRetry)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if isEmpty {
                BaseEmptyStateView(
                    title: emptyTitle,
                    message: emptyMessage,
                    icon: emptyIcon,
                    actionTitle: "Refresh",
                    action: onRetry
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                content
            }
        }
    }
}

// MARK: - Error Handling View Modifier
public struct ErrorHandlingModifier: ViewModifier {
    @Binding var error: AppError?
    let onRetry: () -> Void
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                Group {
                    if let error = error {
                        VStack {
                            ErrorBanner(
                                error: error,
                                onRetry: onRetry,
                                onDismiss: { self.error = nil }
                            )
                            .padding()
                            
                            Spacer()
                        }
                    }
                }
            )
    }
}

extension View {
    /// Adds error handling overlay
    public func errorHandling(
        error: Binding<AppError?>,
        onRetry: @escaping () -> Void
    ) -> some View {
        modifier(ErrorHandlingModifier(error: error, onRetry: onRetry))
    }
}

// MARK: - Preview
struct ErrorHandling_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                ErrorView(
                    error: .networkError("Unable to connect to server"),
                    onRetry: {},
                    onDismiss: {}
                )
                
                InlineErrorView(
                    message: "Failed to load data",
                    onRetry: {}
                )
                
                ErrorBanner(
                    error: .authenticationError("Session expired"),
                    onRetry: {},
                    onDismiss: {}
                )
                
                LoadingStateView(
                    isLoading: false,
                    error: .dataLoadingError("Failed to load content"),
                    isEmpty: false,
                    onRetry: {}
                ) {
                    Text("Content goes here")
                }
            }
            .padding()
        }
    }
}