import SwiftUI

/// Standard loading view used throughout the app
public struct LoadingView: View {
    let message: String?
    let style: LoadingStyle
    
    public enum LoadingStyle {
        case standard
        case fullScreen
        case inline
    }
    
    public init(message: String? = nil, style: LoadingStyle = .standard) {
        self.message = message
        self.style = style
    }
    
    public var body: some View {
        switch style {
        case .standard:
            standardView
        case .fullScreen:
            fullScreenView
        case .inline:
            inlineView
        }
    }
    
    private var standardView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            if let message = message {
                Text(message)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(AppColors.Default.secondaryBackground)
        .cornerRadius(12)
    }
    
    private var fullScreenView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            if let message = message {
                Text(message)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.Default.background.ignoresSafeArea())
    }
    
    private var inlineView: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}