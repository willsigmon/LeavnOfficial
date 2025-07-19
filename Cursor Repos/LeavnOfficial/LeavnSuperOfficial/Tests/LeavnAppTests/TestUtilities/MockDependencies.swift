import Foundation
import Dependencies
import IdentifiedCollections
@testable import LeavnApp

// MARK: - Mock Bible Service
extension BibleService {
    static let mock = Self(
        fetchPassage: { reference in
            Chapter(
                book: reference.book,
                number: reference.chapter.rawValue,
                verses: mockVerses(for: reference),
                headings: []
            )
        },
        searchPassages: { query in
            IdentifiedArrayOf<SearchResult>([
                SearchResult(
                    id: UUID(),
                    reference: BibleReference(book: .john, chapter: 3, verse: 16),
                    text: "For God so loved the world...",
                    context: "John 3:16-17"
                ),
                SearchResult(
                    id: UUID(),
                    reference: BibleReference(book: .romans, chapter: 8, verse: 28),
                    text: "And we know that in all things...",
                    context: "Romans 8:28-29"
                )
            ])
        },
        fetchChapterInfo: { book, chapter in
            ChapterInfo(
                book: book,
                chapter: chapter,
                verseCount: mockVerseCount(for: book, chapter: chapter),
                headings: [],
                hasPrevious: chapter > 1,
                hasNext: chapter < book.chapterCount
            )
        },
        getVerseOfTheDay: {
            Verse(
                reference: BibleReference(book: .john, chapter: 3, verse: 16),
                text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                number: 16
            )
        },
        getCrossReferences: { reference in
            [
                BibleReference(book: .matthew, chapter: 5, verse: 17),
                BibleReference(book: .luke, chapter: 10, verse: 27)
            ]
        }
    )
    
    private static func mockVerses(for reference: BibleReference) -> [Verse] {
        let versesData = [
            "In the beginning, God created the heavens and the earth.",
            "And the earth was without form, and void; and darkness was upon the face of the deep.",
            "And God said, Let there be light: and there was light.",
            "And God saw the light, that it was good: and God divided the light from the darkness.",
            "And God called the light Day, and the darkness he called Night."
        ]
        
        return versesData.enumerated().map { index, text in
            Verse(
                reference: BibleReference(
                    book: reference.book,
                    chapter: reference.chapter.rawValue,
                    verse: index + 1
                ),
                text: text,
                number: index + 1
            )
        }
    }
    
    private static func mockVerseCount(for book: Book, chapter: Int) -> Int {
        // Return realistic verse counts for testing
        switch book {
        case .genesis where chapter == 1: return 31
        case .john where chapter == 3: return 36
        case .psalms where chapter == 23: return 6
        default: return 25
        }
    }
}

// MARK: - Mock ESV Client
extension ESVClient {
    static let mock = Self(
        getPassage: { book, chapter, verse in
            ESVResponse(
                query: "\(book.name) \(chapter)",
                text: mockPassageText(book: book, chapter: chapter, verse: verse),
                verseNumbers: true
            )
        },
        search: { query in
            [
                SearchResult(
                    id: UUID(),
                    reference: BibleReference(book: .john, chapter: 3, verse: 16),
                    text: "For God so loved the world...",
                    context: "John 3:16-17"
                )
            ]
        }
    )
    
    private static func mockPassageText(book: Book, chapter: Int, verse: Int?) -> String {
        if let verse = verse {
            return "[\(verse)] This is verse \(verse) of \(book.name) chapter \(chapter)."
        } else {
            return """
            [1] In the beginning, God created the heavens and the earth.
            [2] And the earth was without form, and void; and darkness was upon the face of the deep.
            [3] And God said, Let there be light: and there was light.
            """
        }
    }
}

// MARK: - Mock Database Client
extension DatabaseClient {
    static let mock = Self(
        save: { _ in },
        fetch: { _ in [] },
        delete: { _ in },
        update: { _, _ in }
    )
}

// MARK: - Mock Community Service
extension CommunityService {
    static let mock = Self(
        fetchGroups: {
            [
                Group(
                    id: UUID(),
                    name: "Bible Study Group",
                    description: "Weekly Bible study",
                    memberCount: 25,
                    imageURL: nil,
                    isPrivate: false,
                    createdAt: Date()
                ),
                Group(
                    id: UUID(),
                    name: "Prayer Warriors",
                    description: "Daily prayer group",
                    memberCount: 150,
                    imageURL: nil,
                    isPrivate: false,
                    createdAt: Date()
                )
            ]
        },
        fetchPrayers: {
            [
                Prayer(
                    id: UUID(),
                    userId: UUID(),
                    userName: "John Doe",
                    content: "Please pray for healing",
                    prayerCount: 42,
                    isPraying: false,
                    createdAt: Date()
                ),
                Prayer(
                    id: UUID(),
                    userId: UUID(),
                    userName: "Jane Smith",
                    content: "Thankful for God's blessings",
                    prayerCount: 78,
                    isPraying: true,
                    createdAt: Date()
                )
            ]
        },
        fetchActivityFeed: {
            [
                ActivityItem(
                    id: UUID(),
                    type: .prayer,
                    userId: UUID(),
                    userName: "Mike Johnson",
                    content: "Started a new reading plan",
                    timestamp: Date()
                ),
                ActivityItem(
                    id: UUID(),
                    type: .highlight,
                    userId: UUID(),
                    userName: "Sarah Lee",
                    content: "Highlighted John 3:16",
                    timestamp: Date()
                )
            ]
        },
        joinGroup: { _ in },
        leaveGroup: { _ in },
        createPrayer: { _ in
            Prayer(
                id: UUID(),
                userId: UUID(),
                userName: "Test User",
                content: "Test prayer",
                prayerCount: 0,
                isPraying: false,
                createdAt: Date()
            )
        },
        togglePraying: { _ in }
    )
}

// MARK: - Mock Audio Service
extension AudioService {
    static let mock = Self(
        playChapter: { _, _ in },
        pause: { },
        resume: { },
        stop: { },
        seekToVerse: { _ in },
        setPlaybackRate: { _ in },
        downloadChapter: { _, _ in },
        deleteDownload: { _, _ in },
        isDownloaded: { _, _ in false },
        currentPlaybackState: {
            AudioPlaybackState(
                isPlaying: false,
                currentBook: nil,
                currentChapter: nil,
                currentVerse: nil,
                playbackRate: 1.0,
                duration: 0,
                currentTime: 0
            )
        }
    )
}

// MARK: - Mock Settings Service
extension SettingsService {
    static let mock = Self(
        getSettings: {
            Settings(
                theme: .system,
                fontSize: .medium,
                fontFamily: .default,
                lineSpacing: .normal,
                readingMode: .continuous,
                translation: .esv,
                showVerseNumbers: true,
                showRedLetters: true,
                highlightColors: Settings.defaultHighlightColors,
                notifications: NotificationSettings(),
                audioSettings: AudioSettings()
            )
        },
        updateSettings: { _ in },
        resetSettings: { }
    )
}

// MARK: - Mock User Defaults Client
extension UserDefaultsClient {
    static let mock = Self(
        boolForKey: { _ in false },
        dataForKey: { _ in nil },
        doubleForKey: { _ in 0.0 },
        integerForKey: { _ in 0 },
        stringForKey: { _ in nil },
        setBool: { _, _ in },
        setData: { _, _ in },
        setDouble: { _, _ in },
        setInteger: { _, _ in },
        setString: { _, _ in },
        remove: { _ in },
        isFirstLaunch: false,
        hasCompletedOnboarding: false,
        lastSelectedBook: nil,
        lastSelectedChapter: nil
    )
}

// MARK: - Fixture Data
struct TestFixtures {
    static let sampleBooks: [Book] = [.genesis, .matthew, .john, .psalms, .revelation]
    
    static let sampleVerse = Verse(
        reference: BibleReference(book: .john, chapter: 3, verse: 16),
        text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
        number: 16
    )
    
    static let sampleChapter = Chapter(
        book: .genesis,
        number: 1,
        verses: [
            Verse(
                reference: BibleReference(book: .genesis, chapter: 1, verse: 1),
                text: "In the beginning, God created the heavens and the earth.",
                number: 1
            ),
            Verse(
                reference: BibleReference(book: .genesis, chapter: 1, verse: 2),
                text: "And the earth was without form, and void; and darkness was upon the face of the deep.",
                number: 2
            )
        ],
        headings: [
            ChapterHeading(text: "The Creation", startVerse: 1)
        ]
    )
    
    static let sampleUser = User(
        id: UUID(),
        name: "Test User",
        email: "test@example.com",
        avatarURL: nil,
        joinedDate: Date(),
        preferredTranslation: .esv,
        readingStreak: 7,
        totalReadingTime: 3600,
        chaptersRead: 42,
        isSubscribed: true
    )
    
    static let sampleHighlight = Highlight(
        id: UUID(),
        reference: BibleReference(book: .john, chapter: 3, verse: 16),
        text: "For God so loved the world",
        color: .yellow,
        note: "Beautiful verse about God's love",
        createdAt: Date(),
        modifiedAt: Date()
    )
    
    static let sampleBookmark = Bookmark(
        id: UUID(),
        reference: BibleReference(book: .psalms, chapter: 23),
        title: "The Lord is my shepherd",
        createdAt: Date()
    )
    
    static let sampleNote = Note(
        id: UUID(),
        reference: BibleReference(book: .romans, chapter: 8, verse: 28),
        content: "All things work together for good",
        createdAt: Date(),
        modifiedAt: Date()
    )
    
    static let sampleReadingPlan = ReadingPlan(
        id: UUID(),
        name: "Bible in a Year",
        description: "Read through the entire Bible in 365 days",
        duration: 365,
        currentDay: 42,
        isActive: true,
        startDate: Date().addingTimeInterval(-42 * 24 * 60 * 60),
        readings: []
    )
}