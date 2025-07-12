import SwiftUI
import LeavnCore

struct TranslationPickerView: View {
    let selectedTranslation: BibleTranslation
    let onSelection: (BibleTranslation) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            translationsList
                .navigationTitle("Bible Translation")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
    }
    
    private var translationsList: some View {
        List {
            Section("English Translations") {
                ForEach(BibleTranslation.defaultTranslations, id: \.self) { translation in
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
            onSelection(translation)
            dismiss()
        }
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

#Preview {
    TranslationPickerView(
        selectedTranslation: .kjv,
        onSelection: { _ in }
    )
} 