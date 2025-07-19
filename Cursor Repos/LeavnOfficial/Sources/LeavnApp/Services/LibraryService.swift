import Foundation
import Dependencies
import IdentifiedCollections
import CoreData

// MARK: - Library Service
@MainActor
public struct LibraryService: Sendable {
    // Bookmarks
    public var fetchBookmarks: @Sendable () async throws -> IdentifiedArrayOf<Bookmark>
    public var createBookmark: @Sendable (Bookmark) async throws -> Bookmark
    public var updateBookmark: @Sendable (Bookmark) async throws -> Bookmark
    public var deleteBookmark: @Sendable (BookmarkID) async throws -> Void
    public var fetchBookmarkFolders: @Sendable () async throws -> [BookmarkFolder]
    public var createBookmarkFolder: @Sendable (BookmarkFolder) async throws -> BookmarkFolder
    
    // Notes
    public var fetchNotes: @Sendable (NotesFilter?) async throws -> IdentifiedArrayOf<Note>
    public var fetchNote: @Sendable (NoteID) async throws -> Note
    public var createNote: @Sendable (Note) async throws -> Note
    public var updateNote: @Sendable (Note) async throws -> Note
    public var deleteNote: @Sendable (NoteID) async throws -> Void
    public var searchNotes: @Sendable (String) async throws -> IdentifiedArrayOf<Note>
    
    // Highlights
    public var fetchHighlights: @Sendable (HighlightFilter?) async throws -> IdentifiedArrayOf<Highlight>
    public var createHighlight: @Sendable (Highlight) async throws -> Highlight
    public var updateHighlight: @Sendable (Highlight) async throws -> Highlight
    public var deleteHighlight: @Sendable (HighlightID) async throws -> Void
    
    // Downloads
    public var fetchDownloads: @Sendable () async throws -> IdentifiedArrayOf<Download>
    public var downloadChapter: @Sendable (Book, Int) async throws -> Download
    public var downloadBook: @Sendable (Book) async throws -> Download
    public var deleteDownload: @Sendable (UUID) async throws -> Void
    public var getDownloadProgress: @Sendable () -> AsyncStream<DownloadProgress>
    
    // Reading Plans
    public var fetchReadingPlans: @Sendable () async throws -> IdentifiedArrayOf<ReadingPlan>
    public var fetchActiveReadingPlan: @Sendable () async throws -> ReadingPlan?
    public var startReadingPlan: @Sendable (ReadingPlanID) async throws -> ReadingPlan
    public var markDayComplete: @Sendable (ReadingPlanID, Int) async throws -> ReadingPlan
    public var pauseReadingPlan: @Sendable (ReadingPlanID) async throws -> ReadingPlan
    public var resumeReadingPlan: @Sendable (ReadingPlanID) async throws -> ReadingPlan
}

// MARK: - Filters
public struct NotesFilter: Equatable, Sendable {
    public var book: Book?
    public var tags: [String]
    public var searchText: String?
    public var sortBy: NotesSortOption
    
    public enum NotesSortOption: String, CaseIterable, Sendable {
        case newest = "Newest"
        case oldest = "Oldest"
        case alphabetical = "Alphabetical"
        case lastModified = "Last Modified"
    }
    
    public init(
        book: Book? = nil,
        tags: [String] = [],
        searchText: String? = nil,
        sortBy: NotesSortOption = .newest
    ) {
        self.book = book
        self.tags = tags
        self.searchText = searchText
        self.sortBy = sortBy
    }
}

public struct HighlightFilter: Equatable, Sendable {
    public var book: Book?
    public var color: HighlightColor?
    public var dateRange: DateInterval?
    
    public init(
        book: Book? = nil,
        color: HighlightColor? = nil,
        dateRange: DateInterval? = nil
    ) {
        self.book = book
        self.color = color
        self.dateRange = dateRange
    }
}

// MARK: - Download Progress
public struct DownloadProgress: Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let progress: Double
    public let totalSize: Int64
    public let downloadedSize: Int64
    public let status: DownloadStatus
    
    public enum DownloadStatus: Equatable, Sendable {
        case queued
        case downloading
        case paused
        case completed
        case failed(String)
    }
}

// MARK: - Core Data Manager
private actor CoreDataManager {
    private let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "LeavnModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }
    
    func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            container.performBackgroundTask { context in
                do {
                    let result = try block(context)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - Dependency Implementation
extension LibraryService: DependencyKey {
    public static let liveValue: Self = {
        let coreDataManager = CoreDataManager()
        let downloadManager = DownloadManager()
        
        return Self(
            fetchBookmarks: {
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "BookmarkEntity")
                    let entities = try context.fetch(request)
                    
                    return IdentifiedArray(uniqueElements: entities.compactMap { entity in
                        guard let id = entity.value(forKey: "id") as? UUID,
                              let bookName = entity.value(forKey: "book") as? String,
                              let book = Book(rawValue: bookName),
                              let chapter = entity.value(forKey: "chapter") as? Int,
                              let createdAt = entity.value(forKey: "createdAt") as? Date else {
                            return nil
                        }
                        
                        let verse = entity.value(forKey: "verse") as? Int
                        let reference = BibleReference(book: book, chapter: chapter, verse: verse)
                        
                        return Bookmark(
                            id: BookmarkID(id),
                            reference: reference,
                            createdAt: createdAt,
                            title: entity.value(forKey: "title") as? String,
                            color: BookmarkColor(rawValue: entity.value(forKey: "color") as? String ?? "") ?? .default
                        )
                    })
                }
            },
            createBookmark: { bookmark in
                try await coreDataManager.performBackgroundTask { context in
                    let entity = NSEntityDescription.entity(forEntityName: "BookmarkEntity", in: context)!
                    let bookmarkEntity = NSManagedObject(entity: entity, insertInto: context)
                    
                    bookmarkEntity.setValue(bookmark.id.rawValue, forKey: "id")
                    bookmarkEntity.setValue(bookmark.reference.book.rawValue, forKey: "book")
                    bookmarkEntity.setValue(bookmark.reference.chapter.rawValue, forKey: "chapter")
                    bookmarkEntity.setValue(bookmark.reference.verse?.rawValue, forKey: "verse")
                    bookmarkEntity.setValue(bookmark.createdAt, forKey: "createdAt")
                    bookmarkEntity.setValue(bookmark.title, forKey: "title")
                    bookmarkEntity.setValue(bookmark.color.rawValue, forKey: "color")
                    
                    try context.save()
                    return bookmark
                }
            },
            updateBookmark: { bookmark in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "BookmarkEntity")
                    request.predicate = NSPredicate(format: "id == %@", bookmark.id.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    entity.setValue(bookmark.title, forKey: "title")
                    entity.setValue(bookmark.color.rawValue, forKey: "color")
                    
                    try context.save()
                    return bookmark
                }
            },
            deleteBookmark: { bookmarkId in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "BookmarkEntity")
                    request.predicate = NSPredicate(format: "id == %@", bookmarkId.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    context.delete(entity)
                    try context.save()
                }
            },
            fetchBookmarkFolders: {
                BookmarkFolder.defaultFolders
            },
            createBookmarkFolder: { folder in
                folder
            },
            fetchNotes: { filter in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
                    
                    if let book = filter?.book {
                        request.predicate = NSPredicate(format: "book == %@", book.rawValue)
                    }
                    
                    let entities = try context.fetch(request)
                    
                    return IdentifiedArray(uniqueElements: entities.compactMap { entity in
                        guard let id = entity.value(forKey: "id") as? UUID,
                              let bookName = entity.value(forKey: "book") as? String,
                              let book = Book(rawValue: bookName),
                              let chapter = entity.value(forKey: "chapter") as? Int,
                              let content = entity.value(forKey: "content") as? String,
                              let createdAt = entity.value(forKey: "createdAt") as? Date,
                              let updatedAt = entity.value(forKey: "updatedAt") as? Date else {
                            return nil
                        }
                        
                        let verse = entity.value(forKey: "verse") as? Int
                        let reference = BibleReference(book: book, chapter: chapter, verse: verse)
                        
                        return Note(
                            id: NoteID(id),
                            reference: reference,
                            title: entity.value(forKey: "title") as? String,
                            content: content,
                            createdAt: createdAt,
                            updatedAt: updatedAt,
                            tags: entity.value(forKey: "tags") as? [String] ?? []
                        )
                    })
                }
            },
            fetchNote: { noteId in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
                    request.predicate = NSPredicate(format: "id == %@", noteId.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first,
                          let id = entity.value(forKey: "id") as? UUID,
                          let bookName = entity.value(forKey: "book") as? String,
                          let book = Book(rawValue: bookName),
                          let chapter = entity.value(forKey: "chapter") as? Int,
                          let content = entity.value(forKey: "content") as? String,
                          let createdAt = entity.value(forKey: "createdAt") as? Date,
                          let updatedAt = entity.value(forKey: "updatedAt") as? Date else {
                        throw LibraryError.notFound
                    }
                    
                    let verse = entity.value(forKey: "verse") as? Int
                    let reference = BibleReference(book: book, chapter: chapter, verse: verse)
                    
                    return Note(
                        id: NoteID(id),
                        reference: reference,
                        title: entity.value(forKey: "title") as? String,
                        content: content,
                        createdAt: createdAt,
                        updatedAt: updatedAt,
                        tags: entity.value(forKey: "tags") as? [String] ?? []
                    )
                }
            },
            createNote: { note in
                try await coreDataManager.performBackgroundTask { context in
                    let entity = NSEntityDescription.entity(forEntityName: "NoteEntity", in: context)!
                    let noteEntity = NSManagedObject(entity: entity, insertInto: context)
                    
                    noteEntity.setValue(note.id.rawValue, forKey: "id")
                    noteEntity.setValue(note.reference.book.rawValue, forKey: "book")
                    noteEntity.setValue(note.reference.chapter.rawValue, forKey: "chapter")
                    noteEntity.setValue(note.reference.verse?.rawValue, forKey: "verse")
                    noteEntity.setValue(note.title, forKey: "title")
                    noteEntity.setValue(note.content, forKey: "content")
                    noteEntity.setValue(note.createdAt, forKey: "createdAt")
                    noteEntity.setValue(note.updatedAt, forKey: "updatedAt")
                    noteEntity.setValue(note.tags, forKey: "tags")
                    
                    try context.save()
                    return note
                }
            },
            updateNote: { note in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
                    request.predicate = NSPredicate(format: "id == %@", note.id.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    entity.setValue(note.title, forKey: "title")
                    entity.setValue(note.content, forKey: "content")
                    entity.setValue(Date(), forKey: "updatedAt")
                    entity.setValue(note.tags, forKey: "tags")
                    
                    try context.save()
                    return note
                }
            },
            deleteNote: { noteId in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
                    request.predicate = NSPredicate(format: "id == %@", noteId.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    context.delete(entity)
                    try context.save()
                }
            },
            searchNotes: { searchText in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "NoteEntity")
                    request.predicate = NSPredicate(
                        format: "content CONTAINS[cd] %@ OR title CONTAINS[cd] %@",
                        searchText, searchText
                    )
                    
                    let entities = try context.fetch(request)
                    
                    return IdentifiedArray(uniqueElements: entities.compactMap { entity in
                        guard let id = entity.value(forKey: "id") as? UUID,
                              let bookName = entity.value(forKey: "book") as? String,
                              let book = Book(rawValue: bookName),
                              let chapter = entity.value(forKey: "chapter") as? Int,
                              let content = entity.value(forKey: "content") as? String,
                              let createdAt = entity.value(forKey: "createdAt") as? Date,
                              let updatedAt = entity.value(forKey: "updatedAt") as? Date else {
                            return nil
                        }
                        
                        let verse = entity.value(forKey: "verse") as? Int
                        let reference = BibleReference(book: book, chapter: chapter, verse: verse)
                        
                        return Note(
                            id: NoteID(id),
                            reference: reference,
                            title: entity.value(forKey: "title") as? String,
                            content: content,
                            createdAt: createdAt,
                            updatedAt: updatedAt,
                            tags: entity.value(forKey: "tags") as? [String] ?? []
                        )
                    })
                }
            },
            fetchHighlights: { filter in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "HighlightEntity")
                    
                    var predicates: [NSPredicate] = []
                    
                    if let book = filter?.book {
                        predicates.append(NSPredicate(format: "book == %@", book.rawValue))
                    }
                    
                    if let color = filter?.color {
                        predicates.append(NSPredicate(format: "color == %@", color.rawValue))
                    }
                    
                    if !predicates.isEmpty {
                        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                    }
                    
                    let entities = try context.fetch(request)
                    
                    return IdentifiedArray(uniqueElements: entities.compactMap { entity in
                        guard let id = entity.value(forKey: "id") as? UUID,
                              let bookName = entity.value(forKey: "book") as? String,
                              let book = Book(rawValue: bookName),
                              let chapter = entity.value(forKey: "chapter") as? Int,
                              let text = entity.value(forKey: "text") as? String,
                              let colorString = entity.value(forKey: "color") as? String,
                              let color = HighlightColor(rawValue: colorString),
                              let createdAt = entity.value(forKey: "createdAt") as? Date else {
                            return nil
                        }
                        
                        let verse = entity.value(forKey: "verse") as? Int
                        let reference = BibleReference(book: book, chapter: chapter, verse: verse)
                        
                        return Highlight(
                            id: HighlightID(id),
                            reference: reference,
                            text: text,
                            color: color,
                            createdAt: createdAt
                        )
                    })
                }
            },
            createHighlight: { highlight in
                try await coreDataManager.performBackgroundTask { context in
                    let entity = NSEntityDescription.entity(forEntityName: "HighlightEntity", in: context)!
                    let highlightEntity = NSManagedObject(entity: entity, insertInto: context)
                    
                    highlightEntity.setValue(highlight.id.rawValue, forKey: "id")
                    highlightEntity.setValue(highlight.reference.book.rawValue, forKey: "book")
                    highlightEntity.setValue(highlight.reference.chapter.rawValue, forKey: "chapter")
                    highlightEntity.setValue(highlight.reference.verse?.rawValue, forKey: "verse")
                    highlightEntity.setValue(highlight.text, forKey: "text")
                    highlightEntity.setValue(highlight.color.rawValue, forKey: "color")
                    highlightEntity.setValue(highlight.createdAt, forKey: "createdAt")
                    
                    try context.save()
                    return highlight
                }
            },
            updateHighlight: { highlight in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "HighlightEntity")
                    request.predicate = NSPredicate(format: "id == %@", highlight.id.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    entity.setValue(highlight.color.rawValue, forKey: "color")
                    entity.setValue(Date(), forKey: "updatedAt")
                    
                    try context.save()
                    return highlight
                }
            },
            deleteHighlight: { highlightId in
                try await coreDataManager.performBackgroundTask { context in
                    let request = NSFetchRequest<NSManagedObject>(entityName: "HighlightEntity")
                    request.predicate = NSPredicate(format: "id == %@", highlightId.rawValue as CVarArg)
                    
                    guard let entity = try context.fetch(request).first else {
                        throw LibraryError.notFound
                    }
                    
                    context.delete(entity)
                    try context.save()
                }
            },
            fetchDownloads: {
                try await downloadManager.fetchDownloads()
            },
            downloadChapter: { book, chapter in
                try await downloadManager.downloadChapter(book: book, chapter: chapter)
            },
            downloadBook: { book in
                try await downloadManager.downloadBook(book: book)
            },
            deleteDownload: { id in
                try await downloadManager.deleteDownload(id: id)
            },
            getDownloadProgress: {
                downloadManager.progressStream
            },
            fetchReadingPlans: {
                // In production, this would fetch from server
                IdentifiedArray(uniqueElements: ReadingPlan.defaultPlans)
            },
            fetchActiveReadingPlan: {
                nil // Would fetch from Core Data
            },
            startReadingPlan: { planId in
                // Would save to Core Data and return updated plan
                ReadingPlan.defaultPlans.first { $0.id == planId } ?? ReadingPlan.defaultPlans[0]
            },
            markDayComplete: { planId, day in
                // Would update Core Data and return updated plan
                ReadingPlan.defaultPlans.first { $0.id == planId } ?? ReadingPlan.defaultPlans[0]
            },
            pauseReadingPlan: { planId in
                ReadingPlan.defaultPlans.first { $0.id == planId } ?? ReadingPlan.defaultPlans[0]
            },
            resumeReadingPlan: { planId in
                ReadingPlan.defaultPlans.first { $0.id == planId } ?? ReadingPlan.defaultPlans[0]
            }
        )
    }()
    
    public static let testValue = Self(
        fetchBookmarks: { [] },
        createBookmark: { $0 },
        updateBookmark: { $0 },
        deleteBookmark: { _ in },
        fetchBookmarkFolders: { BookmarkFolder.defaultFolders },
        createBookmarkFolder: { $0 },
        fetchNotes: { _ in [] },
        fetchNote: { _ in
            Note(
                reference: BibleReference(book: .genesis, chapter: 1, verse: 1),
                content: "Test note"
            )
        },
        createNote: { $0 },
        updateNote: { $0 },
        deleteNote: { _ in },
        searchNotes: { _ in [] },
        fetchHighlights: { _ in [] },
        createHighlight: { $0 },
        updateHighlight: { $0 },
        deleteHighlight: { _ in },
        fetchDownloads: { [] },
        downloadChapter: { _, _ in Download.sample },
        downloadBook: { _ in Download.sample },
        deleteDownload: { _ in },
        getDownloadProgress: {
            AsyncStream { _ in }
        },
        fetchReadingPlans: { [] },
        fetchActiveReadingPlan: { nil },
        startReadingPlan: { _ in ReadingPlan.defaultPlans[0] },
        markDayComplete: { _, _ in ReadingPlan.defaultPlans[0] },
        pauseReadingPlan: { _ in ReadingPlan.defaultPlans[0] },
        resumeReadingPlan: { _ in ReadingPlan.defaultPlans[0] }
    )
}

// MARK: - Dependency Values
extension DependencyValues {
    public var libraryService: LibraryService {
        get { self[LibraryService.self] }
        set { self[LibraryService.self] = newValue }
    }
}

// MARK: - Library Errors
enum LibraryError: LocalizedError {
    case notFound
    case invalidData
    case syncFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notFound:
            return "The requested item was not found"
        case .invalidData:
            return "Invalid data format"
        case .syncFailed(let reason):
            return "Sync failed: \(reason)"
        }
    }
}

// MARK: - Download Manager
private actor DownloadManager {
    private var activeDownloads: [UUID: URLSessionDownloadTask] = [:]
    private let progressSubject = PassthroughSubject<DownloadProgress, Never>()
    
    var progressStream: AsyncStream<DownloadProgress> {
        AsyncStream { continuation in
            let cancellable = progressSubject.sink { progress in
                continuation.yield(progress)
            }
            
            continuation.onTermination = { _ in
                _ = cancellable
            }
        }
    }
    
    func fetchDownloads() async throws -> IdentifiedArrayOf<Download> {
        // Would fetch from Core Data
        return []
    }
    
    func downloadChapter(book: Book, chapter: Int) async throws -> Download {
        @Dependency(\.bibleService) var bibleService
        
        let reference = BibleReference(book: book, chapter: chapter)
        let chapterData = try await bibleService.fetchPassage(reference)
        
        // Save to disk and create Download record
        let download = Download(
            id: UUID(),
            title: "\(book.name) \(chapter)",
            type: .chapter,
            book: book,
            chapters: [chapter],
            sizeInBytes: estimateChapterSize(book: book.name, chapter: chapter)
            downloadedAt: Date()
        )
        
        return download
    }
    
    func downloadBook(book: Book) async throws -> Download {
        let download = Download(
            id: UUID(),
            title: book.name,
            type: .book,
            book: book,
            chapters: Array(1...book.chapterCount),
            sizeInBytes: estimateBookSize(book: book)
            downloadedAt: Date()
        )
        
        return download
    }
    
    func deleteDownload(id: UUID) async throws {
        // Would delete from disk and Core Data
    }
    
    // MARK: - Helper Functions
    private func estimateChapterSize(book: String, chapter: Int) -> Int64 {
        // Estimate based on average chapter sizes
        // Old Testament chapters average ~3KB, New Testament ~2KB
        let baseSize: Int64 = book < "Matthew" ? 3072 : 2048
        
        // Some chapters are notably longer
        let longChapters: [(String, Int)] = [
            ("Psalms", 119), // Longest chapter
            ("Genesis", 24),
            ("Numbers", 7),
            ("1 Chronicles", 6)
        ]
        
        let multiplier: Int64 = longChapters.contains { $0.0 == book && $0.1 == chapter } ? 3 : 1
        return baseSize * multiplier
    }
    
    private func estimateBookSize(book: Book) -> Int64 {
        // Estimate total book size based on chapter count
        let avgChapterSize: Int64 = book.rawValue < "Matthew" ? 3072 : 2048
        return Int64(book.chapterCount) * avgChapterSize
    }
}

// MARK: - Reading Plan Extensions
extension ReadingPlan {
    static let defaultPlans: [ReadingPlan] = [
        ReadingPlan(
            name: "Bible in a Year",
            description: "Read through the entire Bible in one year",
            duration: .year,
            category: .wholeBible,
            days: []
        ),
        ReadingPlan(
            name: "New Testament in 90 Days",
            description: "Read through the New Testament in 90 days",
            duration: .days(90),
            category: .newTestament,
            days: []
        ),
        ReadingPlan(
            name: "Psalms in 30 Days",
            description: "Read through the book of Psalms in one month",
            duration: .days(30),
            category: .psalms,
            days: []
        )
    ]
}