import SwiftUI

// MARK: - Button Style
public enum LeavnButtonStyle {
    case primary
    case secondary
    case tertiary
    case destructive
}

public enum LeavnButtonSize {
    case small
    case medium
    case large
}

// MARK: - Leavn Button
public struct LeavnButton: View {
    let title: String
    let style: LeavnButtonStyle
    let size: LeavnButtonSize
    let isLoading: Bool
    let action: () -> Void
    
    public init(
        _ title: String,
        style: LeavnButtonStyle = .primary,
        size: LeavnButtonSize = .medium,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.size = size
        self.isLoading = isLoading
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: ds.spacing.s) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
                
                Text(title)
                    .font(buttonFont)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .frame(height: buttonHeight)
            .foregroundColor(foregroundColor)
            .background(backgroundColor)
            .cornerRadius(ds.cornerRadius.m)
            .overlay(
                RoundedRectangle(cornerRadius: ds.cornerRadius.m)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.6 : 1.0)
    }
    
    // MARK: - Computed Properties
    private var buttonFont: Font {
        switch size {
        case .small:
            return ds.typography.labelMedium
        case .medium:
            return ds.typography.titleMedium
        case .large:
            return ds.typography.titleLarge
        }
    }
    
    private var buttonHeight: CGFloat {
        switch size {
        case .small:
            return 36
        case .medium:
            return 44
        case .large:
            return 56
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary:
            return ds.colors.primary
        case .tertiary:
            return ds.colors.primary
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ds.colors.primary
        case .secondary:
            return ds.colors.primary.opacity(0.1)
        case .tertiary:
            return .clear
        case .destructive:
            return ds.colors.error
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return ds.colors.primary.opacity(0.2)
        case .tertiary:
            return ds.colors.primary
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary:
            return 1
        case .tertiary:
            return 2
        }
    }
}

// MARK: - Icon Button
public struct LeavnIconButton: View {
    let icon: String
    let size: LeavnButtonSize
    let style: LeavnButtonStyle
    let action: () -> Void
    
    public init(
        icon: String,
        size: LeavnButtonSize = .medium,
        style: LeavnButtonStyle = .secondary,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.size = size
        self.style = style
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(iconFont)
                .foregroundColor(foregroundColor)
                .frame(width: buttonSize, height: buttonSize)
                .background(backgroundColor)
                .cornerRadius(ds.cornerRadius.m)
        }
    }
    
    private var iconFont: Font {
        switch size {
        case .small:
            return .system(size: 16)
        case .medium:
            return .system(size: 20)
        case .large:
            return .system(size: 24)
        }
    }
    
    private var buttonSize: CGFloat {
        switch size {
        case .small:
            return 36
        case .medium:
            return 44
        case .large:
            return 56
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return .white
        case .secondary, .tertiary:
            return ds.colors.primary
        case .destructive:
            return .white
        }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return ds.colors.primary
        case .secondary:
            return ds.colors.primary.opacity(0.1)
        case .tertiary:
            return .clear
        case .destructive:
            return ds.colors.error
        }
    }
}

// MARK: - Preview
struct LeavnButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            LeavnButton("Primary Button", style: .primary) {}
            LeavnButton("Secondary Button", style: .secondary) {}
            LeavnButton("Tertiary Button", style: .tertiary) {}
            LeavnButton("Destructive Button", style: .destructive) {}
            LeavnButton("Loading Button", isLoading: true) {}
            
            HStack(spacing: 16) {
                LeavnIconButton(icon: "heart.fill", style: .primary) {}
                LeavnIconButton(icon: "share", style: .secondary) {}
                LeavnIconButton(icon: "trash", style: .destructive) {}
            }
        }
        .padding()
    }
}