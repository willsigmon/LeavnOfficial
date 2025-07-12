import SwiftUI

public struct ErrorView: View {
    let error: Error
    let retry: (() -> Void)?
    
    public init(error: Error, retry: (() -> Void)? = nil) {
        self.error = error
        self.retry = retry
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Something went wrong")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let retry = retry {
                Button(action: retry) {
                    Label("Try Again", systemImage: "arrow.clockwise")
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
    }
}