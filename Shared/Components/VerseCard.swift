import SwiftUI

/// A reusable card component for displaying Bible verses
/// Works across all platforms (iOS, macOS, visionOS, watchOS)
public struct VerseCard: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    let showBookmark: Bool
    let onHighlight: (() -> Void)?
    let onBookmark: (() -> Void)?
    let onNote: (() -> Void)?
    
    // TODO: Fix Environment access when LeavnCore module structure is resolved
    // @Environment(\.hapticManager) private var hapticManager
    
    public struct BibleVerse {
        let reference: String // e.g., "John 3:16"
        let text: String
        let translation: String // e.g., "NIV", "ESV"
        let book: String
        let chapter: Int
        let verse: Int
        
        public init(reference: String, text: String, translation: String, book: String, chapter: Int, verse: Int) {
            self.reference = reference
            self.text = text
            self.translation = translation
            self.book = book
            self.chapter = chapter
            self.verse = verse
        }
    }
    
    public init(
        verse: BibleVerse,
        isHighlighted: Bool = false,
        showBookmark: Bool = false,
        onHighlight: (() -> Void)? = nil,
        onBookmark: (() -> Void)? = nil,
        onNote: (() -> Void)? = nil
    ) {
        self.verse = verse
        self.isHighlighted = isHighlighted
        self.showBookmark = showBookmark
        self.onHighlight = onHighlight
        self.onBookmark = onBookmark
        self.onNote = onNote
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with reference and translation
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verse.reference)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(verse.translation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showBookmark {
                    Image(systemName: "bookmark.fill")
                        .foregroundColor(Color("BookmarkBlue"))
                        .font(.title3)
                }
            }
            
            // Verse text
            Text(verse.text)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
                .padding(.vertical, 8)
                .padding(.horizontal, isHighlighted ? 12 : 0)
                .background(
                    isHighlighted ? 
                    Color("HighlightYellow").opacity(0.3) : 
                    Color.clear
                )
                .cornerRadius(8)
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: { 
                    // TODO: Restore haptic feedback when manager is available
                    // hapticManager.triggerFeedback(.light)
                    onHighlight?() 
                }) {
                    Label("Highlight", systemImage: isHighlighted ? "highlighter" : "highlighter")
                        .font(.caption)
                        .foregroundColor(isHighlighted ? Color("HighlightYellow") : .secondary)
                }
                
                Button(action: { 
                    // TODO: Restore haptic feedback when manager is available
                    // hapticManager.triggerFeedback(.light)
                    onBookmark?() 
                }) {
                    Label("Bookmark", systemImage: showBookmark ? "bookmark.fill" : "bookmark")
                        .font(.caption)
                        .foregroundColor(showBookmark ? Color("BookmarkBlue") : .secondary)
                }
                
                Button(action: { 
                    // TODO: Restore haptic feedback when manager is available
                    // hapticManager.triggerFeedback(.light)
                    onNote?() 
                }) {
                    Label("Note", systemImage: "note.text")
                        .font(.caption)
                        .foregroundColor(Color("NotesPurple"))
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Compact Version for Apple Watch
public struct CompactVerseCard: View {
    let verse: VerseCard.BibleVerse
    let isHighlighted: Bool
    
    public init(verse: VerseCard.BibleVerse, isHighlighted: Bool = false) {
        self.verse = verse
        self.isHighlighted = isHighlighted
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Text(verse.text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(8)
        .background(
            isHighlighted ? 
            Color("HighlightYellow").opacity(0.2) : 
            Color(.systemGray6)
        )
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct VerseCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            VerseCard(
                verse: VerseCard.BibleVerse(
                    reference: "John 3:16",
                    text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                    translation: "NIV",
                    book: "John",
                    chapter: 3,
                    verse: 16
                ),
                isHighlighted: true,
                showBookmark: true
            )
            
            VerseCard(
                verse: VerseCard.BibleVerse(
                    reference: "Psalm 23:1",
                    text: "The Lord is my shepherd, I lack nothing.",
                    translation: "NIV",
                    book: "Psalms",
                    chapter: 23,
                    verse: 1
                ),
                isHighlighted: false,
                showBookmark: false
            )
            
            CompactVerseCard(
                verse: VerseCard.BibleVerse(
                    reference: "Romans 8:28",
                    text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
                    translation: "NIV",
                    book: "Romans",
                    chapter: 8,
                    verse: 28
                ),
                isHighlighted: true
            )
        }
        .padding()
    }
}