import SwiftUI
import LeavnCore

struct NoteEditorSheet: View {
    let verse: BibleVerse
    let verseText: String
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var noteType = NoteType.personal
    @FocusState private var isNoteFocused: Bool
    @Environment(\.dismiss) private var dismiss
    
    enum NoteType: String, CaseIterable {
        case personal = "Personal"
        case study = "Study"
        case prayer = "Prayer"
        case question = "Question"
        
        var icon: String {
            switch self {
            case .personal: return "person.fill"
            case .study: return "book.fill"
            case .prayer: return "hands.sparkles.fill"
            case .question: return "questionmark.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .personal: return .blue
            case .study: return .green
            case .prayer: return .purple
            case .question: return .orange
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Note Type") {
                    Picker("Type", selection: $noteType) {
                        ForEach(NoteType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .foregroundColor(type.color)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Note Type Picker")
                }
                
                Section("Note Details") {
                    TextField("Title", text: $noteTitle)
                        .accessibilityLabel("Note Title Field")
                    
                    TextEditor(text: $noteContent)
                        .focused($isNoteFocused)
                        .frame(minHeight: 150)
                        .accessibilityLabel("Note Content Field")
                }
                
                Section("Related Verse") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(verse.bookName) \(verse.chapter):\(verse.verse)")
                            .font(.headline)
                        Text(verseText)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Related Verse Info")
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel Note")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        // TODO: Save note
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(noteContent.isEmpty)
                    .accessibilityLabel("Save Note")
                    .accessibilityHint("Save this note for the verse.")
                }
            }
            .onAppear {
                isNoteFocused = true
            }
        }
    }
}

