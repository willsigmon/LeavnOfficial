import SwiftUI
import LeavnCore
import LeavnServices

struct NoteEditorSheet: View {
    let verse: BibleVerse
    let verseText: String
    @State private var noteTitle = ""
    @State private var noteContent = ""
    @State private var noteType = NoteType.personal
    @State private var isSaving = false
    @FocusState private var isNoteFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var diContainer: DIContainer
    
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
                        Task {
                            await saveNote()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(noteContent.isEmpty || isSaving)
                    .accessibilityLabel("Save Note")
                    .accessibilityHint("Save this note for the verse.")
                }
            }
            .onAppear {
                isNoteFocused = true
            }
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func saveNote() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        
        do {
            guard let libraryService = diContainer.libraryService else {
                print("⚠️ LibraryService not available")
                return
            }
            
            // Create a bookmark with note content
            // Using the note type color and including both title and type in tags
            var tags: [String] = [noteType.rawValue]
            if !noteTitle.isEmpty {
                tags.append(noteTitle)
            }
            tags.append("note") // Tag to identify this as a note
            
            let bookmark = Bookmark(
                verse: verse,
                note: noteContent,
                tags: tags,
                color: noteTypeToColorString(noteType)
            )
            
            try await libraryService.addBookmark(bookmark)
            print("✅ Note saved successfully")
            dismiss()
            
        } catch {
            print("❌ Failed to save note: \(error)")
            // TODO: Show error alert to user
        }
    }
    
    private func noteTypeToColorString(_ type: NoteType) -> String {
        switch type {
        case .personal: return "blue"
        case .study: return "green"
        case .prayer: return "purple"
        case .question: return "orange"
        }
    }
}

