import SwiftUI

/// A collection of loading views for different contexts and platforms
public struct LoadingView: View {
    let message: String?
    let style: LoadingStyle
    
    public enum LoadingStyle {
        case standard
        case compact
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
            StandardLoadingView(message: message)
        case .compact:
            CompactLoadingView(message: message)
        case .fullScreen:
            FullScreenLoadingView(message: message)
        case .inline:
            InlineLoadingView(message: message)
        }
    }
}

// MARK: - Standard Loading View
private struct StandardLoadingView: View {
    let message: String?
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
            
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Compact Loading View
private struct CompactLoadingView: View {
    let message: String?
    
    var body: some View {
        HStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Full Screen Loading View
private struct FullScreenLoadingView: View {
    let message: String?
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Custom animated loader
                ZStack {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 20, height: 20)
                            .scaleEffect(isAnimating ? 1.0 : 0.5)
                            .offset(y: isAnimating ? -30 : 0)
                            .rotationEffect(.degrees(Double(index) * 120))
                            .animation(
                                Animation.easeInOut(duration: 1.0)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: isAnimating
                            )
                    }
                }
                .frame(width: 60, height: 60)
                .onAppear {
                    isAnimating = true
                }
                
                if let message = message {
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Inline Loading View
private struct InlineLoadingView: View {
    let message: String?
    
    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(0.8)
            
            if let message = message {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Skeleton Loading View
public struct SkeletonLoadingView: View {
    @State private var isAnimating = false
    let rows: Int
    
    public init(rows: Int = 3) {
        self.rows = rows
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(0..<rows, id: \.self) { _ in
                VStack(alignment: .leading, spacing: 8) {
                    // Title skeleton
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity)
                        .shimmer(isAnimating: isAnimating)
                    
                    // Subtitle skeleton
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 16)
                        .frame(maxWidth: 200)
                        .shimmer(isAnimating: isAnimating)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
            }
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Shimmer Effect
private extension View {
    func shimmer(isAnimating: Bool) -> some View {
        self.overlay(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.clear,
                    Color.white.opacity(0.5),
                    Color.clear
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .offset(x: isAnimating ? 300 : -300)
            .mask(self)
        )
    }
}

// MARK: - Preview
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 32) {
            LoadingView(message: "Loading your data...", style: .standard)
            
            LoadingView(message: "Please wait", style: .compact)
            
            LoadingView(style: .inline)
            
            SkeletonLoadingView(rows: 2)
                .padding()
        }
        .padding()
        .background(Color(.systemGray6))
        
        LoadingView(message: "Fetching leave requests...", style: .fullScreen)
    }
}