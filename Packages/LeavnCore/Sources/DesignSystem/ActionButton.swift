import SwiftUI

/// A reusable button component with consistent styling
public struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    public init(icon: String, title: String, color: Color = .accentColor, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Button Style
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Previews
#Preview {
    VStack(spacing: 16) {
        ActionButton(icon: "doc.on.doc", title: "Copy", color: .blue) {}
        ActionButton(icon: "square.and.arrow.up", title: "Share", color: .green) {}
        ActionButton(icon: "bookmark", title: "Bookmark", color: .purple) {}
        ActionButton(icon: "note.text", title: "Add Note", color: .orange) {}
    }
    .padding()
}
