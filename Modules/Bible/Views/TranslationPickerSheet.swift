import Foundation
import SwiftUI
import LeavnCore

struct TranslationPickerSheet: View {
    @Binding var selectedTranslation: BibleTranslation
    @Environment(\.dismiss) private var dismiss
    
    let translations = BibleTranslation.defaultTranslations
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(TranslationCategory.allCases, id: \.self) { category in
                    Section(category.rawValue) {
                        ForEach(translations.filter { $0.category == category }, id: \.self) { translation in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(translation.displayName)
                                        .font(.headline)
                                    Text(translation.fullName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedTranslation == translation {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedTranslation = translation
                                dismiss()
                            }
                            .accessibilityLabel("Select \(translation.displayName)")
                        }
                    }
                }
            }
            .accessibilityLabel("Translation Format Picker")
            .navigationTitle("Bible Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Translation Picker")
                }
            }
        }
        .accessibilityLabel("Translation Picker Sheet")
    }
}

enum TranslationCategory: String, CaseIterable {
    case literal = "Word-for-Word"
    case dynamic = "Thought-for-Thought"
    case paraphrase = "Paraphrase"
}
