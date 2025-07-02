import SwiftUI

public struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let delay: Double
    
    @State private var appear = false
    
    public init(icon: String, title: String, description: String, color: Color, delay: Double) {
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
        self.delay = delay
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .shadow(color: color, radius: 5, x: 0, y: 5)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(LeavnTheme.Typography.headline)
                
                Text(description)
                    .font(LeavnTheme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            .opacity(appear ? 1 : 0)
            .offset(x: appear ? 0 : -20)
            .animation(
                LeavnTheme.Motion.smoothSpring.delay(delay + 0.1),
                value: appear
            )
            
            Spacer()
        }
        .onAppear {
            appear = true
        }
    }
}
