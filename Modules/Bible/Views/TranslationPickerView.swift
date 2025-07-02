import SwiftUI
import LeavnCore

struct TranslationPickerView: View {
    let selectedTranslation: BibleTranslation
    let onSelection: (BibleTranslation) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(TranslationCategory.allCases, id: \.self) { category in
                    Section(category.displayName) {
                        ForEach(BibleTranslation.defaultTranslations.filter { $0.category == category }, id: \.self) { translation in
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
                                onSelection(translation)
                                dismiss()
                            }
                        }
                    }
                }
            }
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
}

#Preview {
    TranslationPickerView(
        selectedTranslation: .kjv,
        onSelection: { _ in }
    )
} 