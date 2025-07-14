import SwiftUI

struct TranslationPickerView: View {
    @Binding var selectedTranslation: BibleTranslation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(BibleTranslation.defaultTranslations, id: \.id) { translation in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(translation.abbreviation)
                                .font(.system(size: 17, weight: .medium))
                            Text(translation.name)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedTranslation == translation {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTranslation = translation
                        HapticManager.shared.impact(.light)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Translation")
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

