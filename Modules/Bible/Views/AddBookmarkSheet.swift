import SwiftUI
import LeavnCore
import LeavnServices

struct AddBookmarkSheet: View {
    let verse: BibleVerse
    let verseText: String
    @State private var bookmarkTitle = ""
    @State private var bookmarkNote = ""
    @State private var selectedColor = Color.blue
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var diContainer: DIContainer
    
    let colors: [Color] = [.blue, .green, .orange, .red, .purple, .pink, .yellow]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Bookmark Details") {
                    TextField("Title (optional)", text: $bookmarkTitle)
                        .accessibilityLabel("Bookmark Title Field")
                    
                    TextField("Note (optional)", text: $bookmarkNote, axis: .vertical)
                        .lineLimit(3...6)
                        .accessibilityLabel("Bookmark Note Field")
                }
                
                Section("Color") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                        ForEach(colors, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .onTapGesture {
                                    selectedColor = color
                                }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .accessibilityLabel("Bookmark Color Picker")
                
                Section("Verse") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(verse.bookName) \(verse.chapter):\(verse.verse)")
                            .font(.headline)
                        Text(verseText)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .accessibilityLabel("Verse Info")
            }
            .navigationTitle("Add Bookmark")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel Bookmark")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            await saveBookmark()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(isSaving)
                    .accessibilityLabel("Save Bookmark")
                    .accessibilityHint("Save this bookmark for the verse.")
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func saveBookmark() async {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        
        do {
            guard let libraryService = diContainer.libraryService else {
                print("⚠️ LibraryService not available")
                return
            }
            
            // Convert SwiftUI Color to string representation
            let colorString = colorToString(selectedColor)
            
            // Create bookmark with optional title and note
            let bookmark = Bookmark(
                verse: verse,
                note: bookmarkNote.isEmpty ? nil : bookmarkNote,
                tags: bookmarkTitle.isEmpty ? [] : [bookmarkTitle],
                color: colorString
            )
            
            try await libraryService.addBookmark(bookmark)
            print("✅ Bookmark saved successfully")
            dismiss()
            
        } catch {
            print("❌ Failed to save bookmark: \(error)")
            // TODO: Show error alert to user
        }
    }
    
    private func colorToString(_ color: Color) -> String {
        switch color {
        case .blue: return "blue"
        case .green: return "green"
        case .orange: return "orange"
        case .red: return "red"
        case .purple: return "purple"
        case .pink: return "pink"
        case .yellow: return "yellow"
        default: return "blue"
        }
    }
}

