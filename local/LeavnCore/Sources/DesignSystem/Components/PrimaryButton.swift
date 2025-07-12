import SwiftUI

/// Primary button style used throughout the app
public struct PrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    @Binding var isLoading: Bool
    let isEnabled: Bool
    
    public enum ButtonStyle {
        case primary
        case secondary
        case tertiary
        case destructive
    }
    
    public init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isLoading: Binding<Bool> = .constant(false),
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self._isLoading = isLoading
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(textColor)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                
                Text(title)
                    .font(.body)
                    .fontWeight(.semibold)
            }
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(backgroundColor)
            .cornerRadius(12)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled || isLoading)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return AppColors.Default.primary
        case .secondary:
            return AppColors.Default.secondaryBackground
        case .tertiary:
            return Color.clear
        case .destructive:
            return AppColors.error
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return AppColors.Default.primary
        case .tertiary:
            return AppColors.Default.primary
        }
    }
}

// MARK: - Button Style Modifier

public struct PrimaryButtonStyle: ButtonStyle {
    let style: PrimaryButton.ButtonStyle
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}