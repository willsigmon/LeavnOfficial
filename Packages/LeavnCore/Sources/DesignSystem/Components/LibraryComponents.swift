import SwiftUI

// MARK: - Library-specific UI Components

public struct AnimatedGradientBackground: View {
    public init() {}
    
    public var body: some View {
        LinearGradient(colors: [Color.black.opacity(0.8), Color.black], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}

public struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    public init(icon: String, action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Circle().fill(Color.blue))
                .shadow(radius: 4)
        }
    }
}

public struct PlayfulEmptyState: View {
    let icon: String
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void
    
    public init(icon: String, title: String, message: String, buttonTitle: String, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(title)
                .font(.title2.bold())
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
