import SwiftUI

public struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    public init() {}
    
    public var body: some View {
        LinearGradient(
            colors: [
                LeavnTheme.Colors.accent.opacity(0.15),
                LeavnTheme.Colors.accentDark.opacity(0.10),
                LeavnTheme.Colors.categoryColors[5].opacity(0.15), // Pink
                LeavnTheme.Colors.categoryColors[7].opacity(0.10)  // Orange
            ],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: animateGradient)
        .onAppear {
            animateGradient = true
        }
        .ignoresSafeArea()
    }
}

#if DEBUG
struct AnimatedGradientBackground_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedGradientBackground()
    }
}
#endif
