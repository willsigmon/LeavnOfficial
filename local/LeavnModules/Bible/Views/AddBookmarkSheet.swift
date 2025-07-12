import SwiftUI
import LeavnCore

struct AddBookmarkSheet: View {
    let verse: BibleVerse
    let verseText: String
    @State private var bookmarkTitle = ""
    @State private var bookmarkNote = ""
    @State private var selectedColor = Color.blue
    @Environment(\.dismiss) private var dismiss
    
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
                        // TODO: Save bookmark
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .accessibilityLabel("Save Bookmark")
                    .accessibilityHint("Save this bookmark for the verse.")
                }
            }
        }
    }
}

