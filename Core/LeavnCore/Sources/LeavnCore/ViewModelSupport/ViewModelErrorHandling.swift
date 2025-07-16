import Foundation
import SwiftUI

// MARK: - Loading State
public enum LoadingState<T> {
    case idle
    case loading
    case loaded(T)
    case error(Error)
    
    public var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }
    
    public var error: Error? {
        if case .error(let error) = self {
            return error
        }
        return nil
    }
    
    public var value: T? {
        if case .loaded(let value) = self {
            return value
        }
        return nil
    }
}

// MARK: - Error Alert
public struct ErrorAlert: Identifiable {
    public let id = UUID()
    public let title: String
    public let message: String
    public let primaryButton: String
    public let primaryAction: (() -> Void)?
    public let secondaryButton: String?
    public let secondaryAction: (() -> Void)?
    
    public init(
        title: String = "Error",
        message: String,
        primaryButton: String = "OK",
        primaryAction: (() -> Void)? = nil,
        secondaryButton: String? = nil,
        secondaryAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.primaryAction = primaryAction
        self.secondaryButton = secondaryButton
        self.secondaryAction = secondaryAction
    }
    
    public init(from error: Error, retryAction: (() -> Void)? = nil) {
        self.title = "Error"
        self.message = error.localizedDescription
        self.primaryButton = retryAction != nil ? "Retry" : "OK"
        self.primaryAction = retryAction
        self.secondaryButton = retryAction != nil ? "Cancel" : nil
        self.secondaryAction = nil
    }
}

// MARK: - Base View Model
@MainActor
open class BaseViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var errorAlert: ErrorAlert?
    @Published public var infoMessage: String?
    
    public init() {}
    
    public func handle(error: Error, retryAction: (() -> Void)? = nil) {
        isLoading = false
        
        // Log the error
        print("[ViewModel Error] \(type(of: self)): \(error)")
        
        // Create appropriate error alert
        if let leavnError = error as? LeavnError {
            errorAlert = ErrorAlert(
                title: leavnError.title,
                message: leavnError.userMessage,
                primaryButton: retryAction != nil ? "Retry" : "OK",
                primaryAction: retryAction
            )
        } else {
            errorAlert = ErrorAlert(from: error, retryAction: retryAction)
        }
    }
    
    public func showInfo(_ message: String) {
        infoMessage = message
        
        // Auto-dismiss after 3 seconds
        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            if infoMessage == message {
                infoMessage = nil
            }
        }
    }
    
    public func execute<T>(
        _ operation: @escaping () async throws -> T,
        onSuccess: ((T) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        showLoading: Bool = true
    ) {
        Task {
            if showLoading {
                isLoading = true
            }
            
            do {
                let result = try await operation()
                isLoading = false
                onSuccess?(result)
            } catch {
                isLoading = false
                if let onError = onError {
                    onError(error)
                } else {
                    handle(error: error)
                }
            }
        }
    }
}

// MARK: - Leavn Error
extension LeavnError {
    public var title: String {
        switch self {
        case .networkError:
            return "Network Error"
        case .unauthorized:
            return "Authentication Error"
        case .notFound:
            return "Not Found"
        case .invalidInput:
            return "Invalid Input"
        case .serverError:
            return "Server Error"
        case .localStorageError:
            return "Storage Error"
        case .decodingError:
            return "Data Error"
        case .notImplemented:
            return "Not Available"
        case .validationError:
            return "Validation Error"
        case .systemError:
            return "System Error"
        case .unknown:
            return "Error"
        }
    }
    
    public var userMessage: String {
        switch self {
        case .networkError(let underlying):
            if let error = underlying {
                return "Network connection failed: \(error.localizedDescription)"
            }
            return "Please check your internet connection and try again."
            
        case .unauthorized:
            return "Please sign in to continue."
            
        case .notFound:
            return "The requested content could not be found."
            
        case .invalidInput(let message):
            return message
            
        case .serverError(let code):
            return "Server error (\(code)). Please try again later."
            
        case .localStorageError(let error):
            return "Storage error: \(error.localizedDescription)"
            
        case .decodingError(let error):
            return "Unable to process the response: \(error.localizedDescription)"
            
        case .notImplemented(let feature):
            return "\(feature) is not yet available."
            
        case .validationError(let message):
            return message
            
        case .systemError(let message):
            return "System error: \(message)"
            
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

// MARK: - View Extensions
public extension View {
    func errorAlert<VM: BaseViewModel>(from viewModel: VM) -> some View {
        self.alert(isPresented: Binding(
            get: { viewModel.errorAlert != nil },
            set: { if !$0 { viewModel.errorAlert = nil } }
        )) {
            if let alert = viewModel.errorAlert {
                if let secondaryButton = alert.secondaryButton {
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        primaryButton: .default(Text(alert.primaryButton), action: alert.primaryAction),
                        secondaryButton: .cancel(Text(secondaryButton), action: alert.secondaryAction)
                    )
                } else {
                    return Alert(
                        title: Text(alert.title),
                        message: Text(alert.message),
                        dismissButton: .default(Text(alert.primaryButton), action: alert.primaryAction)
                    )
                }
            } else {
                return Alert(title: Text("Error"))
            }
        }
    }
    
    func loadingOverlay(isLoading: Bool) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Loading...")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                    }
                }
            }
        )
    }
    
    func infoMessage(from viewModel: BaseViewModel) -> some View {
        self.overlay(
            Group {
                if let message = viewModel.infoMessage {
                    VStack {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            
                            Text(message)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        
                        Spacer()
                    }
                }
            }
            .animation(.easeInOut, value: viewModel.infoMessage)
        )
    }
}