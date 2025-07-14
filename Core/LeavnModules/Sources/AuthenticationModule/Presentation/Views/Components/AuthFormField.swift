import SwiftUI
import LeavnCore
import DesignSystem

public struct AuthFormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    let validation: ValidationState
    let onEditingChanged: () -> Void
    
    @State private var isSecureTextVisible = false
    @FocusState private var isFocused: Bool
    
    public init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        keyboardType: UIKeyboardType = .default,
        isSecure: Bool = false,
        validation: ValidationState = .none,
        onEditingChanged: @escaping () -> Void = {}
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.validation = validation
        self.onEditingChanged = onEditingChanged
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: ds.spacing.xs) {
            // Title
            HStack {
                Text(title)
                    .font(ds.typography.titleSmall)
                    .foregroundColor(ds.colors.label)
                
                if case .valid = validation {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ds.colors.success)
                        .font(.caption)
                }
                
                Spacer()
            }
            
            // Input Field
            HStack {
                Group {
                    if isSecure && !isSecureTextVisible {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                            .keyboardType(keyboardType)
                            .textInputAutocapitalization(keyboardType == .emailAddress ? .never : .sentences)
                            .autocorrectionDisabled(keyboardType == .emailAddress)
                    }
                }
                .font(ds.typography.bodyMedium)
                .focused($isFocused)
                .onChange(of: text) { _ in
                    onEditingChanged()
                }
                .onChange(of: isFocused) { focused in
                    if !focused {
                        onEditingChanged()
                    }
                }
                
                if isSecure {
                    Button(action: {
                        isSecureTextVisible.toggle()
                    }) {
                        Image(systemName: isSecureTextVisible ? "eye.slash" : "eye")
                            .foregroundColor(ds.colors.secondaryLabel)
                    }
                }
            }
            .padding(.horizontal, ds.spacing.m)
            .padding(.vertical, ds.spacing.s)
            .background(
                RoundedRectangle(cornerRadius: ds.cornerRadius.m)
                    .fill(ds.colors.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: ds.cornerRadius.m)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
            )
            
            // Validation Message
            if let errorMessage = validation.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(ds.colors.error)
                        .font(.caption2)
                    
                    Text(errorMessage)
                        .font(ds.typography.labelSmall)
                        .foregroundColor(ds.colors.error)
                    
                    Spacer()
                }
            }
        }
    }
    
    private var borderColor: Color {
        switch validation {
        case .valid:
            return ds.colors.success
        case .invalid:
            return ds.colors.error
        case .none:
            return isFocused ? ds.colors.primary : ds.colors.separator
        }
    }
    
    private var borderWidth: CGFloat {
        switch validation {
        case .valid, .invalid:
            return 2
        case .none:
            return isFocused ? 2 : 1
        }
    }
}

// MARK: - Preview
struct AuthFormField_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            AuthFormField(
                title: "Email",
                text: .constant("test@example.com"),
                placeholder: "Enter your email",
                keyboardType: .emailAddress,
                validation: .valid
            )
            
            AuthFormField(
                title: "Password",
                text: .constant("weak"),
                placeholder: "Enter your password",
                isSecure: true,
                validation: .invalid("Password must be at least 6 characters")
            )
            
            AuthFormField(
                title: "Name",
                text: .constant(""),
                placeholder: "Enter your name",
                validation: .none
            )
        }
        .padding()
        .background(Color(.systemBackground))
    }
}