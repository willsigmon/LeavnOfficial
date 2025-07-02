import SwiftUI
import LeavnCore

struct VerseOptionsSheet: View {
    let verse: BibleVerse
    let verseText: String
    @Binding var showBookmarkSheet: Bool
    @Binding var showNoteEditor: Bool
    @Binding var showShareSheet: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    Button(action: {
                        showBookmarkSheet = true
                        dismiss()
                    }) {
                        Label("Add Bookmark", systemImage: "bookmark")
                    }
                    .accessibilityLabel("Add Bookmark")
                    .accessibilityHint("Add this verse to your bookmarks")
                    
                    Button(action: {
                        showNoteEditor = true
                        dismiss()
                    }) {
                        Label("Add Note", systemImage: "note.text")
                    }
                    .accessibilityLabel("Add Note")
                    .accessibilityHint("Add a note for this verse")
                    
                    Button(action: {
                        showShareSheet = true
                        dismiss()
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share Verse")
                    .accessibilityHint("Share this verse with others")
                    
                    Button(action: {
                        UIPasteboard.general.string = verseText
                        dismiss()
                    }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    .accessibilityLabel("Copy Verse")
                    .accessibilityHint("Copy this verse text to clipboard")
                }
                
                Section("Verse") {
                    Text(verseText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Verse Text")
                }
            }
            .navigationTitle("\(verse.bookName) \(verse.chapter):\(verse.verse)")
            .accessibilityLabel("Verse Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Verse Options")
                }
            }
        }
    }
}
