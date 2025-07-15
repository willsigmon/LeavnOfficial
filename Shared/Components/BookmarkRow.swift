import SwiftUI

/// A reusable row component for displaying bookmarked verses
/// Works across all platforms with adaptive layouts
public struct BookmarkRow: View {
    let bookmark: BibleBookmark
    let showNotes: Bool
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    @Environment(\.hapticManager) private var hapticManager
    
    public struct BibleBookmark {
        let id: UUID
        let reference: String // e.g., "John 3:16"
        let verseText: String
        let dateCreated: Date
        let note: String?
        let tags: [String]
        let translation: String
        
        public init(
            id: UUID = UUID(),
            reference: String,
            verseText: String,
            dateCreated: Date = Date(),
            note: String? = nil,
            tags: [String] = [],
            translation: String = "NIV"
        ) {
            self.id = id
            self.reference = reference
            self.verseText = verseText
            self.dateCreated = dateCreated
            self.note = note
            self.tags = tags
            self.translation = translation
        }
    }
    
    public init(
        bookmark: BibleBookmark,
        showNotes: Bool = true,
        onTap: @escaping () -> Void,
        onDelete: (() -> Void)? = nil
    ) {
        self.bookmark = bookmark
        self.showNotes = showNotes
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Bookmark icon
            Image(systemName: "bookmark.fill")
                .foregroundColor(Color("BookmarkBlue"))
                .font(.title3)
                .frame(width: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                // Reference and date
                HStack {
                    Text(bookmark.reference)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(bookmark.dateCreated, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Verse preview
                Text(bookmark.verseText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                // Note preview (if exists and showing notes)
                if showNotes, let note = bookmark.note, !note.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundColor(Color("NotesPurple"))
                        
                        Text(note)
                            .font(.caption)
                            .foregroundColor(Color("NotesPurple"))
                            .lineLimit(1)
                    }
                    .padding(.top, 2)
                }
                
                // Tags
                if !bookmark.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(bookmark.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.horizontal, 1)
                    }
                }
            }
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            hapticManager.triggerFeedback()
            onTap()
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if let onDelete = onDelete {
                Button("Delete", role: .destructive) {
                    hapticManager.triggerFeedback()
                    onDelete()
                }
            }
        }
    }
}

// MARK: - Compact Bookmark Row for Apple Watch
public struct CompactBookmarkRow: View {
    let bookmark: BookmarkRow.BibleBookmark
    let onTap: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public init(bookmark: BookmarkRow.BibleBookmark, onTap: @escaping () -> Void) {
        self.bookmark = bookmark
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: { 
            hapticManager.triggerFeedback()
            onTap() 
        }) {
            HStack(spacing: 8) {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(Color("BookmarkBlue"))
                    .font(.caption)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(bookmark.reference)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(bookmark.verseText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Bookmark Category Header
public struct BookmarkCategoryHeader: View {
    let title: String
    let count: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public init(title: String, count: Int, isExpanded: Bool, onToggle: @escaping () -> Void) {
        self.title = title
        self.count = count
        self.isExpanded = isExpanded
        self.onToggle = onToggle
    }
    
    public var body: some View {
        Button(action: { 
            hapticManager.triggerFeedback()
            onToggle() 
        }) {
            HStack {
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("(\(count))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct BookmarkRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            BookmarkCategoryHeader(
                title: "Favorites",
                count: 3,
                isExpanded: true,
                onToggle: {}
            )
            
            BookmarkRow(
                bookmark: BookmarkRow.BibleBookmark(
                    reference: "John 3:16",
                    verseText: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                    note: "My favorite verse about God's love",
                    tags: ["Love", "Salvation", "Favorite"]
                ),
                onTap: {},
                onDelete: {}
            )
            
            Divider()
                .padding(.leading, 52)
            
            BookmarkRow(
                bookmark: BookmarkRow.BibleBookmark(
                    reference: "Psalm 23:1",
                    verseText: "The Lord is my shepherd, I lack nothing.",
                    tags: ["Comfort", "Trust"]
                ),
                onTap: {},
                onDelete: {}
            )
            
            Divider()
                .padding(.leading, 52)
            
            BookmarkRow(
                bookmark: BookmarkRow.BibleBookmark(
                    reference: "Romans 8:28",
                    verseText: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
                    note: "Remember this during difficult times"
                ),
                showNotes: false,
                onTap: {},
                onDelete: {}
            )
            
            // Compact version
            VStack(alignment: .leading, spacing: 4) {
                Text("Compact Version:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                    .padding(.top, 20)
                
                CompactBookmarkRow(
                    bookmark: BookmarkRow.BibleBookmark(
                        reference: "Phil 4:13",
                        verseText: "I can do all this through him who gives me strength."
                    ),
                    onTap: {}
                )
            }
            .background(Color(.systemGray6))
        }
        .background(Color(.systemBackground))
    }
}