import Foundation
import SwiftUI
import LeavnCore

struct TranslationPickerSheet: View {
    @Binding var selectedTranslation: BibleTranslation
    @Environment(\.dismiss) private var dismiss
    
    let translations = BibleTranslation.defaultTranslations
    
    var body: some View {
        NavigationStack {
            translationsList
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
    
    private var translationsList: some View {
        List {
            Section("English Translations") {
                ForEach(translations, id: \.self) { translation in
                    translationRow(for: translation)
                }
            }
        }
    }
    
    private func translationRow(for translation: BibleTranslation) -> some View {
        HStack {
            translationInfo(for: translation)
            Spacer()
            if selectedTranslation == translation {
                checkmarkIcon
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTranslation = translation
            dismiss()
        }
        .accessibilityLabel("Select \(translation.abbreviation)")
    }
    
    private func translationInfo(for translation: BibleTranslation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(translation.abbreviation)
                .font(.headline)
            Text(translation.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var checkmarkIcon: some View {
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.accentColor)
    }
}


