import SwiftUI

// MARK: - Library-specific UI Components

public struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    public init() {}
    
    public var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.1, green: 0.2, blue: 0.45).opacity(0.9),
                Color(red: 0.2, green: 0.1, blue: 0.4).opacity(0.9),
                Color(red: 0.1, green: 0.15, blue: 0.5).opacity(0.9)
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
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
