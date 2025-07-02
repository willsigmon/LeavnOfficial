import SwiftUI

/// Standard error view used throughout the app
public struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    public init(error: Error, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.warning)
            
            Text("Something went wrong")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            if let retryAction = retryAction {
                PrimaryButton(
                    title: "Try Again",
                    icon: "arrow.clockwise",
                    style: .primary,
                    action: retryAction
                )
                .frame(maxWidth: 200)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}