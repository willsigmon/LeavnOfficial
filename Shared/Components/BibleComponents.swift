import SwiftUI

// MARK: - Bible Verse Card
public struct BibleVerseCard: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    let isBookmarked: Bool
    let showActions: Bool
    let onHighlight: (() -> Void)?
    let onBookmark: (() -> Void)?
    let onShare: (() -> Void)?
    let onNote: (() -> Void)?
    
    public init(
        verse: BibleVerse,
        isHighlighted: Bool = false,
        isBookmarked: Bool = false,
        showActions: Bool = true,
        onHighlight: (() -> Void)? = nil,
        onBookmark: (() -> Void)? = nil,
        onShare: (() -> Void)? = nil,
        onNote: (() -> Void)? = nil
    ) {
        self.verse = verse
        self.isHighlighted = isHighlighted
        self.isBookmarked = isBookmarked
        self.showActions = showActions
        self.onHighlight = onHighlight
        self.onBookmark = onBookmark
        self.onShare = onShare
        self.onNote = onNote
    }
    
    public var body: some View {
        BaseCard(
            style: .elevated,
            shadowStyle: .medium
        ) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
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
                    
                    if isBookmarked {
                        Image(systemName: "bookmark.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                    }
                }
                
                // Verse Text
                Text(verse.text)
                    .font(.body)
                    .lineSpacing(4)
                    .padding(.vertical, 8)
                    .padding(.horizontal, isHighlighted ? 12 : 0)
                    .background(
                        isHighlighted ? 
                        Color.yellow.opacity(0.3) : 
                        Color.clear
                    )
                    .cornerRadius(8)
                
                // Actions
                if showActions {
                    HStack(spacing: 8) {
                        if let onHighlight = onHighlight {
                            BaseIconButton(
                                icon: "highlighter",
                                style: .plain,
                                size: .small,
                                action: onHighlight
                            )
                        }
                        
                        if let onBookmark = onBookmark {
                            BaseIconButton(
                                icon: isBookmarked ? "bookmark.fill" : "bookmark",
                                style: .plain,
                                size: .small,
                                action: onBookmark
                            )
                        }
                        
                        if let onShare = onShare {
                            BaseIconButton(
                                icon: "square.and.arrow.up",
                                style: .plain,
                                size: .small,
                                action: onShare
                            )
                        }
                        
                        if let onNote = onNote {
                            BaseIconButton(
                                icon: "note.text",
                                style: .plain,
                                size: .small,
                                action: onNote
                            )
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

// MARK: - Reading Plan Card (moved to ReadingPlanCard.swift)

// MARK: - Life Situation Card (moved to LifeSituationsHomeSection.swift)

// MARK: - Book Selection Card
public struct BookSelectionCard: View {
    let book: BibleBook
    let isSelected: Bool
    let onTap: () -> Void
    
    public struct BibleBook {
        public let id: UUID
        public let name: String
        public let testament: Testament
        public let chapterCount: Int
        public let summary: String?
        
        public enum Testament {
            case old
            case new
            
            var displayName: String {
                switch self {
                case .old: return "Old Testament"
                case .new: return "New Testament"
                }
            }
        }
        
        public init(
            id: UUID = UUID(),
            name: String,
            testament: Testament,
            chapterCount: Int,
            summary: String? = nil
        ) {
            self.id = id
            self.name = name
            self.testament = testament
            self.chapterCount = chapterCount
            self.summary = summary
        }
    }
    
    public init(
        book: BibleBook,
        isSelected: Bool = false,
        onTap: @escaping () -> Void
    ) {
        self.book = book
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        BaseCard(
            style: isSelected ? .filled : .outlined,
            shadowStyle: isSelected ? .medium : .light,
            tapAction: onTap
        ) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(book.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                
                HStack {
                    Text(book.testament.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(book.chapterCount) chapters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let summary = book.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
        }
    }
}

// MARK: - Chapter Navigation Card
public struct ChapterNavigationCard: View {
    let currentChapter: Int
    let totalChapters: Int
    let bookName: String
    let onPrevious: (() -> Void)?
    let onNext: (() -> Void)?
    let onChapterSelect: (() -> Void)?
    
    public init(
        currentChapter: Int,
        totalChapters: Int,
        bookName: String,
        onPrevious: (() -> Void)? = nil,
        onNext: (() -> Void)? = nil,
        onChapterSelect: (() -> Void)? = nil
    ) {
        self.currentChapter = currentChapter
        self.totalChapters = totalChapters
        self.bookName = bookName
        self.onPrevious = onPrevious
        self.onNext = onNext
        self.onChapterSelect = onChapterSelect
    }
    
    public var body: some View {
        BaseCard(
            style: .filled,
            shadowStyle: .light
        ) {
            HStack {
                // Previous Button
                if let onPrevious = onPrevious {
                    BaseIconButton(
                        icon: "chevron.left",
                        style: .outlined,
                        size: .medium,
                        isEnabled: currentChapter > 1,
                        action: onPrevious
                    )
                }
                
                Spacer()
                
                // Chapter Info
                VStack(spacing: 4) {
                    Text(bookName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Button(action: onChapterSelect ?? {}) {
                        Text("Chapter \(currentChapter) of \(totalChapters)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .disabled(onChapterSelect == nil)
                }
                
                Spacer()
                
                // Next Button
                if let onNext = onNext {
                    BaseIconButton(
                        icon: "chevron.right",
                        style: .outlined,
                        size: .medium,
                        isEnabled: currentChapter < totalChapters,
                        action: onNext
                    )
                }
            }
        }
    }
}

// MARK: - Preview
struct BibleComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                BibleVerseCard(
                    verse: BibleVerse(
                        id: "john-3-16",
                        bookId: "JOH",
                        bookName: "John",
                        chapter: 3,
                        verse: 16,
                        text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                        translation: "NIV"
                    ),
                    isHighlighted: true,
                    isBookmarked: true,
                    onHighlight: {},
                    onBookmark: {},
                    onShare: {},
                    onNote: {}
                )
                
                // ReadingPlanCard preview moved to ReadingPlanCard.swift
                Text("Reading Plan Card Preview - See ReadingPlanCard.swift")
                    .foregroundColor(.secondary)
                
                LifeSituationCard(
                    situation: LifeSituationCard.LifeSituation(
                        title: "Anxiety",
                        description: "Find peace and comfort in God's promises",
                        icon: "heart.fill",
                        accentColor: .blue,
                        verseCount: 25
                    ),
                    onTap: {}
                )
                
                BookSelectionCard(
                    book: BookSelectionCard.BibleBook(
                        name: "Genesis",
                        testament: .old,
                        chapterCount: 50,
                        summary: "The book of beginnings"
                    ),
                    isSelected: true,
                    onTap: {}
                )
                
                ChapterNavigationCard(
                    currentChapter: 3,
                    totalChapters: 50,
                    bookName: "Genesis",
                    onPrevious: {},
                    onNext: {},
                    onChapterSelect: {}
                )
            }
            .padding()
        }
    }
}