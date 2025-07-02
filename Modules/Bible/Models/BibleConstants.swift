import Foundation
import LeavnCore
import SwiftUI

/// Constants specific to the Bible module
public enum BibleConstants {
    // MARK: - Default Values
    public static let defaultBook = BibleBook.genesis
    public static let defaultTranslation = BibleTranslation.kjv
    
    // MARK: - UI Constants
    public enum UI {
        public static let defaultFontSize: CGFloat = 17.0
        public static let minimumFontSize: CGFloat = 12.0
        public static let maximumFontSize: CGFloat = 32.0
        public static let fontStep: CGFloat = 1.0
        
        public static let defaultLineSpacing: CGFloat = 6.0
        public static let defaultParagraphSpacing: CGFloat = 8.0
        
        public static let verseNumberFontWeight: Font.Weight = .semibold
        public static let verseNumberColor = Color.blue
        
        public static let highlightColors: [Color] = [
            .yellow.opacity(0.3),
            .green.opacity(0.3),
            .blue.opacity(0.3),
            .pink.opacity(0.3),
            .purple.opacity(0.3)
        ]
    }
    
    // MARK: - Storage Keys
    public enum StorageKeys {
        public static let lastReadBook = "lastReadBook"
        public static let lastReadChapter = "lastReadChapter"
        public static let preferredTranslation = "preferredTranslation"
        public static let fontSize = "bibleReaderFontSize"
        public static let lineSpacing = "bibleReaderLineSpacing"
        public static let paragraphSpacing = "bibleReaderParagraphSpacing"
        public static let theme = "bibleReaderTheme"
    }
    
    // MARK: - Analytics Events
    public enum AnalyticsEvents {
        public static let chapterViewed = "bible_chapter_viewed"
        public static let verseHighlighted = "bible_verse_highlighted"
        public static let noteAdded = "bible_note_added"
        public static let translationChanged = "bible_translation_changed"
        public static let fontSizeChanged = "bible_font_size_changed"
    }
    
    // MARK: - Sample Data
    public enum SampleData {
        public static let sampleVerse = BibleVerse(
            id: "JHN-3-16-ESV",
            bookName: "John",
            bookId: "JHN",
            chapter: 3,
            verse: 16,
            text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
            translation: "ESV"
        )
        
        public static let sampleChapter: [BibleVerse] = [
            BibleVerse(
                id: "JHN-3-1-ESV",
                bookName: "John",
                bookId: "JHN",
                chapter: 3,
                verse: 1,
                text: "Now there was a man of the Pharisees named Nicodemus, a ruler of the Jews.",
                translation: "ESV"
            ),
            BibleVerse(
                id: "JHN-3-2-ESV",
                bookName: "John",
                bookId: "JHN",
                chapter: 3,
                verse: 2,
                text: "This man came to Jesus by night and said to him, 'Rabbi, we know that you are a teacher come from God, for no one can do these signs that you do unless God is with him.'",
                translation: "ESV"
            )
        ]
    }
    
    // MARK: - Helper Methods
    
    /// Gets the next book in canonical order
    public static func nextBook(after book: BibleBook) -> BibleBook? {
        guard let index = BibleBook.allCases.firstIndex(of: book),
              index < BibleBook.allCases.count - 1 else {
            return nil
        }
        return BibleBook.allCases[index + 1]
    }
    
    /// Gets the previous book in canonical order
    public static func previousBook(before book: BibleBook) -> BibleBook? {
        guard let index = BibleBook.allCases.firstIndex(of: book),
              index > 0 else {
            return nil
        }
        return BibleBook.allCases[index - 1]
    }
    
    /// Gets a book by its ID
    public static func book(withId id: String) -> BibleBook? {
        return BibleBook.allCases.first { $0.id == id }
    }
    
    /// Gets a book by its name or abbreviation
    public static func book(named name: String) -> BibleBook? {
        return BibleBook.allCases.first { 
            $0.name.lowercased() == name.lowercased() || 
            $0.abbreviation.lowercased() == name.lowercased() 
        }
    }
    
    /// Gets a translation by its abbreviation
    public static func translation(withAbbreviation abbreviation: String) -> BibleTranslation? {
        return BibleTranslation.defaultTranslations.first { $0.abbreviation.lowercased() == abbreviation.lowercased() }
    }
}