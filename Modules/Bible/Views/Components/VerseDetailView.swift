import SwiftUI
import LeavnCore

struct VerseDetailView: View {
    let verse: BibleVerse
    @Environment(\.dismiss) private var dismiss
    @State private var isCopied = false
    @State private var noteText: String = ""
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Verse text
                    Text(verse.text)
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    
                    // Reference
                    Text("\(verse.bookName) \(verse.chapter):\(verse.verse)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Actions
                    VStack(spacing: 15) {
                        ActionButton(icon: "doc.on.doc", title: isCopied ? "Copied!" : "Copy", color: .blue) {
                            UIPasteboard.general.string = "\"\(verse.text)\" - \(verse.bookName) \(verse.chapter):\(verse.verse)"
                            withAnimation { isCopied = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation { isCopied = false }
                            }
                        }
                        
                        ActionButton(icon: "square.and.arrow.up", title: "Share", color: .green) {
                            showShareSheet = true
                        }
                        
                        ActionButton(icon: "bookmark", title: "Bookmark", color: .purple) {
                            // TODO: Implement bookmark functionality
                        }
                        
                        ActionButton(icon: "note.text", title: "Add Note", color: .orange) {
                            // TODO: Implement note functionality
                        }
                    }
                    .padding(.top)
                    
                    // Notes section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        TextEditor(text: $noteText)
                            .frame(minHeight: 100)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .shadow(radius: 1)
                    }
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Verse \(verse.verse)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: ["\"\(verse.text)\" - \(verse.bookName) \(verse.chapter):\(verse.verse)"])
            }
        }
    }
}

// MARK: - Share Sheet Wrapper
// Using unified ShareSheet component from Components

#Preview {
    VerseDetailView(verse: BibleVerse(
        id: "gen-1-1",
        bookName: "Genesis",
        bookId: "gen",
        chapter: 1,
        verse: 1,
        text: "In the beginning, God created the heavens and the earth.",
        translation: "KJV"
    ))
}
