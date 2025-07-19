import Foundation
import Dependencies
import IdentifiedCollections

// MARK: - Bible Service
@MainActor
public struct BibleService: Sendable {
    public var fetchPassage: @Sendable (BibleReference) async throws -> Chapter
    public var searchPassages: @Sendable (String) async throws -> IdentifiedArrayOf<SearchResult>
    public var fetchChapterInfo: @Sendable (Book, Int) async throws -> ChapterInfo
    public var getVerseOfTheDay: @Sendable () async throws -> Verse
    public var getCrossReferences: @Sendable (BibleReference) async throws -> [BibleReference]
}

// MARK: - Chapter Info
public struct ChapterInfo: Equatable, Sendable {
    public let book: Book
    public let chapter: Int
    public let verseCount: Int
    public let headings: [ChapterHeading]
    public let hasPrevious: Bool
    public let hasNext: Bool
    
    public init(
        book: Book,
        chapter: Int,
        verseCount: Int,
        headings: [ChapterHeading] = [],
        hasPrevious: Bool,
        hasNext: Bool
    ) {
        self.book = book
        self.chapter = chapter
        self.verseCount = verseCount
        self.headings = headings
        self.hasPrevious = hasPrevious
        self.hasNext = hasNext
    }
}

// MARK: - Dependency Implementation
extension BibleService: DependencyKey {
    public static let liveValue = Self(
        fetchPassage: { reference in
            @Dependency(\.esvClient) var esvClient
            
            let response = try await esvClient.getPassage(
                reference.book,
                reference.chapter.rawValue,
                reference.verse?.rawValue
            )
            
            // Parse the ESV response into verses
            let verses = parseVersesFromText(
                response.text,
                book: reference.book,
                chapter: reference.chapter.rawValue
            )
            
            return Chapter(
                book: reference.book,
                number: reference.chapter.rawValue,
                verses: verses,
                headings: []
            )
        },
        searchPassages: { query in
            @Dependency(\.esvClient) var esvClient
            
            let results = try await esvClient.search(query)
            return IdentifiedArray(uniqueElements: results)
        },
        fetchChapterInfo: { book, chapter in
            // Get verse count from static data
            let verseCount = getVerseCount(for: book, chapter: chapter)
            
            return ChapterInfo(
                book: book,
                chapter: chapter,
                verseCount: verseCount,
                headings: [],
                hasPrevious: chapter > 1,
                hasNext: chapter < book.chapterCount
            )
        },
        getVerseOfTheDay: {
            // For now, return a static verse
            // In production, this would fetch from a verse of the day API
            let reference = BibleReference(book: .john, chapter: 3, verse: 16)
            let text = "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life."
            
            return Verse(
                reference: reference,
                text: text,
                number: 16
            )
        },
        getCrossReferences: { reference in
            // In production, this would fetch from a cross-reference API
            // For now, return empty array
            return []
        }
    )
    
    public static let testValue = Self(
        fetchPassage: { _ in
            Chapter(
                book: .genesis,
                number: 1,
                verses: [
                    Verse(
                        reference: BibleReference(book: .genesis, chapter: 1, verse: 1),
                        text: "In the beginning, God created the heavens and the earth.",
                        number: 1
                    )
                ],
                headings: []
            )
        },
        searchPassages: { _ in [] },
        fetchChapterInfo: { book, chapter in
            ChapterInfo(
                book: book,
                chapter: chapter,
                verseCount: 31,
                headings: [],
                hasPrevious: chapter > 1,
                hasNext: chapter < book.chapterCount
            )
        },
        getVerseOfTheDay: {
            Verse(
                reference: BibleReference(book: .john, chapter: 3, verse: 16),
                text: "For God so loved the world...",
                number: 16
            )
        },
        getCrossReferences: { _ in [] }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var bibleService: BibleService {
        get { self[BibleService.self] }
        set { self[BibleService.self] = newValue }
    }
}

// MARK: - Helper Functions
private func parseVersesFromText(_ text: String, book: Book, chapter: Int) -> [Verse] {
    // Simple verse parsing - in production this would be more sophisticated
    let lines = text.components(separatedBy: .newlines)
    var verses: [Verse] = []
    var currentVerse = 1
    
    for line in lines where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        // Look for verse numbers in brackets [1], [2], etc.
        if let match = line.firstMatch(of: /\[(\d+)\]/) {
            currentVerse = Int(match.1) ?? currentVerse
            let verseText = line.replacingOccurrences(of: match.0, with: "").trimmingCharacters(in: .whitespaces)
            
            verses.append(Verse(
                reference: BibleReference(book: book, chapter: chapter, verse: currentVerse),
                text: verseText,
                number: currentVerse
            ))
        } else if !line.isEmpty {
            // If no verse number found, append to the last verse
            if var lastVerse = verses.last {
                verses[verses.count - 1] = Verse(
                    id: lastVerse.id,
                    reference: lastVerse.reference,
                    text: lastVerse.text + " " + line,
                    number: lastVerse.number
                )
            } else {
                // Create first verse if none exist
                verses.append(Verse(
                    reference: BibleReference(book: book, chapter: chapter, verse: 1),
                    text: line,
                    number: 1
                ))
            }
        }
    }
    
    return verses
}

private func getVerseCount(for book: Book, chapter: Int) -> Int {
    // This would be populated with actual verse counts per chapter
    // For now, return a default
    return 31
}