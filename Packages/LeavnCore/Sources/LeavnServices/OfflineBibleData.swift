import Foundation
import LeavnCore

// MARK: - Offline Bible Data for Plane Testing

public struct OfflineBibleData {
    
    // MARK: - Popular Verses for Offline Access
    
    public static let popularVerses: [String: BibleVerse] = [
        "john-3-16": BibleVerse(
            id: "john-3-16-esv",
            bookName: "John",
            bookId: "john",
            chapter: 3,
            verse: 16,
            text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.",
            translation: "ESV"
        ),
        "romans-8-28": BibleVerse(
            id: "romans-8-28-esv",
            bookName: "Romans",
            bookId: "romans",
            chapter: 8,
            verse: 28,
            text: "And we know that for those who love God all things work together for good, for those who are called according to his purpose.",
            translation: "ESV"
        ),
        "philippians-4-13": BibleVerse(
            id: "philippians-4-13-esv",
            bookName: "Philippians",
            bookId: "philippians",
            chapter: 4,
            verse: 13,
            text: "I can do all things through him who strengthens me.",
            translation: "ESV"
        ),
        "psalms-23-1": BibleVerse(
            id: "psalms-23-1-esv",
            bookName: "Psalms",
            bookId: "psalms",
            chapter: 23,
            verse: 1,
            text: "The Lord is my shepherd; I shall not want.",
            translation: "ESV"
        ),
        "jeremiah-29-11": BibleVerse(
            id: "jeremiah-29-11-esv",
            bookName: "Jeremiah",
            bookId: "jeremiah",
            chapter: 29,
            verse: 11,
            text: "For I know the plans I have for you, declares the Lord, plans for welfare and not for evil, to give you a future and a hope.",
            translation: "ESV"
        ),
        "proverbs-3-5": BibleVerse(
            id: "proverbs-3-5-esv",
            bookName: "Proverbs",
            bookId: "proverbs",
            chapter: 3,
            verse: 5,
            text: "Trust in the Lord with all your heart, and do not lean on your own understanding.",
            translation: "ESV"
        ),
        "isaiah-40-31": BibleVerse(
            id: "isaiah-40-31-esv",
            bookName: "Isaiah",
            bookId: "isaiah",
            chapter: 40,
            verse: 31,
            text: "But they who wait for the Lord shall renew their strength; they shall mount up with wings like eagles; they shall run and not be weary; they shall walk and not faint.",
            translation: "ESV"
        ),
        "matthew-6-33": BibleVerse(
            id: "matthew-6-33-esv",
            bookName: "Matthew",
            bookId: "matthew",
            chapter: 6,
            verse: 33,
            text: "But seek first the kingdom of God and his righteousness, and all these things will be added to you.",
            translation: "ESV"
        ),
        "joshua-1-9": BibleVerse(
            id: "joshua-1-9-esv",
            bookName: "Joshua",
            bookId: "joshua",
            chapter: 1,
            verse: 9,
            text: "Have I not commanded you? Be strong and courageous. Do not be frightened, and do not be dismayed, for the Lord your God is with you wherever you go.",
            translation: "ESV"
        ),
        "ephesians-2-8": BibleVerse(
            id: "ephesians-2-8-esv",
            bookName: "Ephesians",
            bookId: "ephesians",
            chapter: 2,
            verse: 8,
            text: "For by grace you have been saved through faith. And this is not your own doing; it is the gift of God.",
            translation: "ESV"
        )
    ]
    
    // MARK: - Sample Chapters for Offline Reading
    
    public static let sampleChapters: [String: BibleChapter] = [
        "genesis-1": BibleChapter(
            bookName: "Genesis",
            bookId: "genesis",
            chapterNumber: 1,
            verses: [
                BibleVerse(id: "genesis-1-1-esv", bookName: "Genesis", bookId: "genesis", chapter: 1, verse: 1, text: "In the beginning, God created the heavens and the earth.", translation: "ESV"),
                BibleVerse(id: "genesis-1-2-esv", bookName: "Genesis", bookId: "genesis", chapter: 1, verse: 2, text: "The earth was without form and void, and darkness was over the face of the deep. And the Spirit of God was hovering over the face of the waters.", translation: "ESV"),
                BibleVerse(id: "genesis-1-3-esv", bookName: "Genesis", bookId: "genesis", chapter: 1, verse: 3, text: "And God said, \"Let there be light,\" and there was light.", translation: "ESV"),
                BibleVerse(id: "genesis-1-4-esv", bookName: "Genesis", bookId: "genesis", chapter: 1, verse: 4, text: "And God saw that the light was good. And God separated the light from the darkness.", translation: "ESV"),
                BibleVerse(id: "genesis-1-5-esv", bookName: "Genesis", bookId: "genesis", chapter: 1, verse: 5, text: "God called the light Day, and the darkness he called Night. And there was evening and there was morning, the first day.", translation: "ESV")
            ]
        ),
        "psalms-23": BibleChapter(
            bookName: "Psalms",
            bookId: "psalms",
            chapterNumber: 23,
            verses: [
                BibleVerse(id: "psalms-23-1-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 1, text: "The Lord is my shepherd; I shall not want.", translation: "ESV"),
                BibleVerse(id: "psalms-23-2-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 2, text: "He makes me lie down in green pastures. He leads me beside still waters.", translation: "ESV"),
                BibleVerse(id: "psalms-23-3-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 3, text: "He restores my soul. He leads me in paths of righteousness for his name's sake.", translation: "ESV"),
                BibleVerse(id: "psalms-23-4-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 4, text: "Even though I walk through the valley of the shadow of death, I will fear no evil, for you are with me; your rod and your staff, they comfort me.", translation: "ESV"),
                BibleVerse(id: "psalms-23-5-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 5, text: "You prepare a table before me in the presence of my enemies; you anoint my head with oil; my cup overflows.", translation: "ESV"),
                BibleVerse(id: "psalms-23-6-esv", bookName: "Psalms", bookId: "psalms", chapter: 23, verse: 6, text: "Surely goodness and mercy shall follow me all the days of my life, and I shall dwell in the house of the Lord forever.", translation: "ESV")
            ]
        ),
        "john-3": BibleChapter(
            bookName: "John",
            bookId: "john",
            chapterNumber: 3,
            verses: [
                BibleVerse(id: "john-3-16-esv", bookName: "John", bookId: "john", chapter: 3, verse: 16, text: "For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.", translation: "ESV"),
                BibleVerse(id: "john-3-17-esv", bookName: "John", bookId: "john", chapter: 3, verse: 17, text: "For God did not send his Son into the world to condemn the world, but in order that the world might be saved through him.", translation: "ESV")
            ]
        )
    ]
    
    // MARK: - Helper Methods
    
    public static func getOfflineVerse(bookId: String, chapter: Int, verse: Int) -> BibleVerse? {
        let key = "\(bookId)-\(chapter)-\(verse)"
        return popularVerses[key]
    }
    
    public static func getOfflineChapter(bookId: String, chapter: Int) -> BibleChapter? {
        let key = "\(bookId)-\(chapter)"
        return sampleChapters[key]
    }
    
    public static func searchOfflineVerses(query: String) -> [BibleVerse] {
        return popularVerses.values.filter { verse in
            verse.text.localizedCaseInsensitiveContains(query) ||
            verse.bookName.localizedCaseInsensitiveContains(query)
        }
    }
    
    public static func getDailyOfflineVerse() -> BibleVerse {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let verses = Array(popularVerses.values)
        let index = (dayOfYear - 1) % verses.count
        return verses[index]
    }
} 