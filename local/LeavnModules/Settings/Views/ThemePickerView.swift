import SwiftUI
import DesignSystem
import LeavnCore

struct ThemePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTheme: String
    
    private let themes = [
        ("System", "rectangle.3.offgrid", "Follow system appearance"),
        ("Light", "sun.max.fill", "Always light mode"),
        ("Dark", "moon.fill", "Always dark mode"),
        ("Vibrant", "sparkles", "Colorful and dynamic")
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(themes, id: \.0) { theme in
                    ThemeOptionRow(
                        name: theme.0,
                        icon: theme.1,
                        description: theme.2,
                        isSelected: selectedTheme == theme.0
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedTheme = theme.0
                        }
                        
                        // Apply theme immediately
                        applyTheme(theme.0)
                        
                        // Haptic feedback
                        #if os(iOS)
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        #endif
                        
                        // Dismiss after selection
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Choose Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func applyTheme(_ themeName: String) {
        #if os(iOS)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch themeName {
        case "Light":
            window.overrideUserInterfaceStyle = .light
        case "Dark":
            window.overrideUserInterfaceStyle = .dark
        case "System", "Vibrant":
            window.overrideUserInterfaceStyle = .unspecified
        default:
            break
        }
        #endif
    }
}

struct ThemeOptionRow: View {
    let name: String
    let icon: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemePickerView(selectedTheme: .constant("Vibrant"))
}