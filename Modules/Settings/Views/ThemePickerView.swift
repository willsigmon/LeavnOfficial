import SwiftUI

struct ThemePickerView: View {
    @Binding var selectedTheme: String
    @Environment(\.dismiss) private var dismiss
    
    let themes = ["System", "Light", "Dark"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(themes, id: \.self) { theme in
                    HStack {
                        Text(theme)
                            .font(.system(size: 17))
                        
                        Spacer()
                        
                        if selectedTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTheme = theme
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Theme")
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
}