import Foundation
import LeavnCore

// MARK: - Production Library Service Implementation

public actor ProductionLibraryService: LibraryServiceProtocol {
    
    // MARK: - Properties
    
    private let userService: UserServiceProtocol
    private let cacheService: CacheServiceProtocol
    private var isInitialized = false
    
    // Cache keys
    private enum CacheKeys {
        static let bookmarks = "library_bookmarks"
        static let readingPlans = "library_reading_plans"
        static let readingHistory = "library_reading_history"
        static let readingStats = "library_reading_stats"
    }
    
    // In-memory cache for performance
    private var bookmarksCache: [Bookmark] = []
    private var readingPlansCache: [ReadingPlan] = []
    private var readingHistoryCache: [ReadingHistory] = []
    private var notesCache: [Note] = []
    private var highlightsCache: [Highlight] = []
    
    // MARK: - Initialization
    
    public init(userService: UserServiceProtocol, cacheService: CacheServiceProtocol) {
        self.userService = userService
        self.cacheService = cacheService
    }
    
    public func initialize() async throws {
        // Load cached data
        bookmarksCache = await cacheService.get(CacheKeys.bookmarks, type: [Bookmark].self) ?? []
        readingPlansCache = await cacheService.get(CacheKeys.readingPlans, type: [ReadingPlan].self) ?? []
        readingHistoryCache = await cacheService.get(CacheKeys.readingHistory, type: [ReadingHistory].self) ?? []
        notesCache = await cacheService.get("library_notes", type: [Note].self) ?? []
        highlightsCache = await cacheService.get("library_highlights", type: [Highlight].self) ?? []
        
        // Create default reading plans if none exist
        if readingPlansCache.isEmpty {
            await createDefaultReadingPlans()
        }
        
        isInitialized = true
        print("📚 ProductionLibraryService initialized with \(bookmarksCache.count) bookmarks, \(readingPlansCache.count) plans")
    }
    
    // MARK: - Bookmark Management
    
    public func getBookmarks() async throws -> [Bookmark] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return bookmarksCache.sorted { $0.createdAt > $1.createdAt }
    }
    
    public func addBookmark(_ bookmark: Bookmark) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Check for duplicates
        if bookmarksCache.contains(where: { $0.verse.id == bookmark.verse.id }) {
            throw LibraryError.duplicateBookmark
        }
        
        bookmarksCache.append(bookmark)
        await saveBookmarks()
        
        // Add to reading history
        let historyEntry = ReadingHistory(
            book: bookmark.verse.bookName,
            chapter: bookmark.verse.chapter,
            startVerse: bookmark.verse.verse,
            endVerse: bookmark.verse.verse,
            translation: bookmark.verse.translation
        )
        try await addReadingEntry(historyEntry)
    }
    
    public func removeBookmark(_ id: String) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = bookmarksCache.firstIndex(where: { $0.id == id }) else {
            throw ServiceError.notFound
        }
        
        bookmarksCache.remove(at: index)
        await saveBookmarks()
    }
    
    public func updateBookmark(_ bookmark: Bookmark) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = bookmarksCache.firstIndex(where: { $0.id == bookmark.id }) else {
            throw ServiceError.notFound
        }
        
        let updatedBookmark = Bookmark(
            id: bookmark.id,
            verse: bookmark.verse,
            note: bookmark.note,
            tags: bookmark.tags,
            color: bookmark.color,
            createdAt: bookmark.createdAt,
            updatedAt: Date()
        )
        
        bookmarksCache[index] = updatedBookmark
        await saveBookmarks()
    }
    
    public func getBookmarksByTag(_ tag: String) async throws -> [Bookmark] {
        let bookmarks = try await getBookmarks()
        return bookmarks.filter { $0.tags.contains(tag) }
    }
    
    public func getAllTags() async throws -> [String] {
        let bookmarks = try await getBookmarks()
        let allTags = bookmarks.flatMap { $0.tags }
        return Array(Set(allTags)).sorted()
    }
    
    // MARK: - Reading Plan Management
    
    public func getReadingPlans() async throws -> [ReadingPlan] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return readingPlansCache.sorted { $0.name < $1.name }
    }
    
    public func addReadingPlan(_ plan: ReadingPlan) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        readingPlansCache.append(plan)
        await saveReadingPlans()
    }
    
    public func updateReadingPlan(_ plan: ReadingPlan) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = readingPlansCache.firstIndex(where: { $0.id == plan.id }) else {
            throw ServiceError.notFound
        }
        
        readingPlansCache[index] = plan
        await saveReadingPlans()
    }
    
    public func removeReadingPlan(_ id: String) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = readingPlansCache.firstIndex(where: { $0.id == id }) else {
            throw ServiceError.notFound
        }
        
        readingPlansCache.remove(at: index)
        await saveReadingPlans()
    }
    
    public func markReadingPlanDay(_ planId: String, dayNumber: Int, completed: Bool) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let planIndex = readingPlansCache.firstIndex(where: { $0.id == planId }) else {
            throw ServiceError.notFound
        }
        
        let plan = readingPlansCache[planIndex]
        
        guard let dayIndex = plan.days.firstIndex(where: { $0.dayNumber == dayNumber }) else {
            throw ServiceError.notFound
        }
        
        var updatedDay = plan.days[dayIndex]
        updatedDay = ReadingPlanDay(
            id: updatedDay.id,
            dayNumber: updatedDay.dayNumber,
            readings: updatedDay.readings,
            isCompleted: completed,
            completedAt: completed ? Date() : nil
        )
        
        var updatedDays = plan.days
        updatedDays[dayIndex] = updatedDay
        
        // Calculate new progress
        let completedDays = updatedDays.filter { $0.isCompleted }.count
        let progress = Double(completedDays) / Double(updatedDays.count)
        
        let updatedPlan = ReadingPlan(
            id: plan.id,
            name: plan.name,
            description: plan.description,
            duration: plan.duration,
            days: updatedDays,
            isActive: plan.isActive,
            startDate: plan.startDate,
            progress: progress
        )
        
        readingPlansCache[planIndex] = updatedPlan
        await saveReadingPlans()
        
        // Add to reading history if completed
        if completed {
            for reading in updatedDay.readings {
                let historyEntry = ReadingHistory(
                    book: reading.bookId,
                    chapter: reading.startChapter,
                    startVerse: reading.startVerse,
                    endVerse: reading.endVerse,
                    translation: "KJV" // Default - would get from user preferences
                )
                try await addReadingEntry(historyEntry)
            }
        }
    }
    
    public func getActiveReadingPlan() async throws -> ReadingPlan? {
        let plans = try await getReadingPlans()
        return plans.first { $0.isActive }
    }
    
    public func setActiveReadingPlan(_ planId: String) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Deactivate all plans
        for i in readingPlansCache.indices {
            if readingPlansCache[i].isActive {
                readingPlansCache[i] = ReadingPlan(
                    id: readingPlansCache[i].id,
                    name: readingPlansCache[i].name,
                    description: readingPlansCache[i].description,
                    duration: readingPlansCache[i].duration,
                    days: readingPlansCache[i].days,
                    isActive: false,
                    startDate: readingPlansCache[i].startDate,
                    progress: readingPlansCache[i].progress
                )
            }
        }
        
        // Activate the selected plan
        guard let index = readingPlansCache.firstIndex(where: { $0.id == planId }) else {
            throw ServiceError.notFound
        }
        
        readingPlansCache[index] = ReadingPlan(
            id: readingPlansCache[index].id,
            name: readingPlansCache[index].name,
            description: readingPlansCache[index].description,
            duration: readingPlansCache[index].duration,
            days: readingPlansCache[index].days,
            isActive: true,
            startDate: Date(),
            progress: readingPlansCache[index].progress
        )
        
        await saveReadingPlans()
    }
    
    // MARK: - Reading History Management
    
    public func getReadingHistory() async throws -> [ReadingHistory] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return readingHistoryCache.sorted { $0.timestamp > $1.timestamp }
    }
    
    public func addReadingEntry(_ entry: ReadingHistory) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        readingHistoryCache.append(entry)
        
        // Keep only recent history (last 1000 entries) for performance
        if readingHistoryCache.count > 1000 {
            readingHistoryCache = Array(readingHistoryCache.suffix(1000))
        }
        
        await saveReadingHistory()
    }
    
    public func getReadingStats() async throws -> ReadingStats {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        let history = readingHistoryCache
        let calendar = Calendar.current
        let now = Date()
        
        // Calculate total days read
        let uniqueDays = Set(history.map { calendar.startOfDay(for: $0.timestamp) })
        let totalDaysRead = uniqueDays.count
        
        // Calculate current streak
        let currentStreak = calculateCurrentStreak(history: history, calendar: calendar, now: now)
        
        // Calculate longest streak
        let longestStreak = calculateLongestStreak(history: history, calendar: calendar)
        
        // Calculate reading totals
        let totalVersesRead = history.reduce(0) { total, entry in
            let versesInEntry = (entry.endVerse ?? entry.startVerse ?? 1) - (entry.startVerse ?? 1) + 1
            return total + versesInEntry
        }
        
        let totalChaptersRead = history.count
        
        // Calculate average reading time
        let totalTime = history.compactMap { $0.duration }.reduce(0, +)
        let averageReadingTime = totalTime / Double(max(history.count, 1))
        
        // Find favorite books
        let bookFrequency = Dictionary(grouping: history, by: { $0.book })
            .mapValues { $0.count }
            .sorted { $0.value > $1.value }
        
        let favoriteBooks = Array(bookFrequency.prefix(5).map { $0.key })
        
        return ReadingStats(
            totalDaysRead: totalDaysRead,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            totalVersesRead: totalVersesRead,
            totalChaptersRead: totalChaptersRead,
            averageReadingTime: averageReadingTime,
            favoriteBooks: favoriteBooks
        )
    }
    
    public func getReadingHistoryForDateRange(_ startDate: Date, _ endDate: Date) async throws -> [ReadingHistory] {
        let history = try await getReadingHistory()
        return history.filter { $0.timestamp >= startDate && $0.timestamp <= endDate }
    }
    
    // MARK: - Private Methods
    
    private func saveBookmarks() async {
        await cacheService.set(CacheKeys.bookmarks, value: bookmarksCache, expirationDate: nil)
    }
    
    private func saveReadingPlans() async {
        await cacheService.set(CacheKeys.readingPlans, value: readingPlansCache, expirationDate: nil)
    }
    
    private func saveReadingHistory() async {
        await cacheService.set(CacheKeys.readingHistory, value: readingHistoryCache, expirationDate: nil)
    }
    
    private func createDefaultReadingPlans() async {
        let chronologicalPlan = createChronologicalReadingPlan()
        let newTestamentPlan = createNewTestamentReadingPlan()
        let psalmsProverbsPlan = createPsalmsProverbsReadingPlan()
        
        readingPlansCache = [chronologicalPlan, newTestamentPlan, psalmsProverbsPlan]
        await saveReadingPlans()
    }
    
    private func createChronologicalReadingPlan() -> ReadingPlan {
        var days: [ReadingPlanDay] = []
        
        // Simplified chronological reading plan (365 days)
        let bibleBooks = BibleBook.allCases
        let totalDays = 365
        
        // Distribute books across days more evenly
        for dayNumber in 1...totalDays {
            let bookIndex = (dayNumber - 1) % bibleBooks.count
            let book = bibleBooks[bookIndex]
            
            let reading = BibleReading(
                bookId: book.id,
                startChapter: 1,
                startVerse: nil,
                endChapter: min(3, book.chapterCount),
                endVerse: nil
            )
            
            days.append(ReadingPlanDay(
                dayNumber: dayNumber,
                readings: [reading]
            ))
        }
        
        return ReadingPlan(
            name: "Chronological Bible Reading",
            description: "Read through the entire Bible in chronological order over one year.",
            duration: 365,
            days: days
        )
    }
    
    private func createNewTestamentReadingPlan() -> ReadingPlan {
        let newTestamentBooks: [BibleBook] = [
            .matthew, .mark, .luke, .john, .acts,
            .romans, .firstCorinthians, .secondCorinthians,
            .galatians, .ephesians, .philippians, .colossians,
            .firstThessalonians, .secondThessalonians,
            .firstTimothy, .secondTimothy, .titus, .philemon,
            .hebrews, .james, .firstPeter, .secondPeter,
            .firstJohn, .secondJohn, .thirdJohn, .jude, .revelation
        ]
        
        var days: [ReadingPlanDay] = []
        let totalDays = 90 // 3 months
        
        for (index, book) in newTestamentBooks.enumerated() {
            let dayNumber = (index % totalDays) + 1
            let reading = BibleReading(
                bookId: book.id,
                startChapter: 1,
                startVerse: nil,
                endChapter: book.chapterCount,
                endVerse: nil
            )
            
            if let existingDayIndex = days.firstIndex(where: { $0.dayNumber == dayNumber }) {
                var existingDay = days[existingDayIndex]
                existingDay = ReadingPlanDay(
                    id: existingDay.id,
                    dayNumber: existingDay.dayNumber,
                    readings: existingDay.readings + [reading],
                    isCompleted: existingDay.isCompleted,
                    completedAt: existingDay.completedAt
                )
                days[existingDayIndex] = existingDay
            } else {
                days.append(ReadingPlanDay(
                    dayNumber: dayNumber,
                    readings: [reading]
                ))
            }
        }
        
        return ReadingPlan(
            name: "New Testament in 90 Days",
            description: "Read through the entire New Testament in 3 months.",
            duration: 90,
            days: days.sorted { $0.dayNumber < $1.dayNumber }
        )
    }
    
    private func createPsalmsProverbsReadingPlan() -> ReadingPlan {
        var days: [ReadingPlanDay] = []
        let totalDays = 31 // One month
        
        for dayNumber in 1...totalDays {
            let psalmsReading = BibleReading(
                bookId: BibleBook.psalms.id,
                startChapter: dayNumber,
                startVerse: nil,
                endChapter: dayNumber,
                endVerse: nil
            )
            
            let proverbsReading = BibleReading(
                bookId: BibleBook.proverbs.id,
                startChapter: dayNumber,
                startVerse: nil,
                endChapter: dayNumber,
                endVerse: nil
            )
            
            days.append(ReadingPlanDay(
                dayNumber: dayNumber,
                readings: [psalmsReading, proverbsReading]
            ))
        }
        
        return ReadingPlan(
            name: "Psalms & Proverbs",
            description: "Read one chapter of Psalms and one chapter of Proverbs each day for a month.",
            duration: 31,
            days: days
        )
    }
    
    private func calculateCurrentStreak(history: [ReadingHistory], calendar: Calendar, now: Date) -> Int {
        let daysSorted = history.map { calendar.startOfDay(for: $0.timestamp) }
            .sorted()
            .reversed()
        
        var streak = 0
        var currentDay = calendar.startOfDay(for: now)
        
        for day in daysSorted {
            if day == currentDay {
                streak += 1
                currentDay = calendar.date(byAdding: .day, value: -1, to: currentDay) ?? currentDay
            } else {
                break
            }
        }
        
        return streak
    }
    
    private func calculateLongestStreak(history: [ReadingHistory], calendar: Calendar) -> Int {
        let uniqueDays = Set(history.map { calendar.startOfDay(for: $0.timestamp) })
            .sorted()
        
        guard !uniqueDays.isEmpty else { return 0 }
        
        var longestStreak = 1
        var currentStreak = 1
        
        for i in 1..<uniqueDays.count {
            let previousDay = uniqueDays[i - 1]
            let currentDay = uniqueDays[i]
            
            if let nextDay = calendar.date(byAdding: .day, value: 1, to: previousDay),
               nextDay == currentDay {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return longestStreak
    }
    
    // MARK: - Notes Management
    
    public func getNotes() async throws -> [Note] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return notesCache.sorted { $0.createdAt > $1.createdAt }
    }
    
    public func addNote(_ note: Note) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        notesCache.append(note)
        await saveNotes()
    }
    
    public func updateNote(_ note: Note) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = notesCache.firstIndex(where: { $0.id == note.id }) else {
            throw ServiceError.notFound
        }
        
        notesCache[index] = Note(
            id: note.id,
            verse: note.verse,
            content: note.content,
            createdAt: note.createdAt,
            updatedAt: Date()
        )
        await saveNotes()
    }
    
    public func deleteNote(_ id: String) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = notesCache.firstIndex(where: { $0.id == id }) else {
            throw ServiceError.notFound
        }
        
        notesCache.remove(at: index)
        await saveNotes()
    }
    
    public func getNote(for verse: BibleVerse) async -> Note? {
        return notesCache.first { $0.verse.id == verse.id }
    }
    
    // MARK: - Highlights Management
    
    public func getHighlights() async throws -> [Highlight] {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        return highlightsCache.sorted { $0.createdAt > $1.createdAt }
    }
    
    public func addHighlight(_ highlight: Highlight) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Check for duplicate
        if highlightsCache.contains(where: { $0.verse.id == highlight.verse.id }) {
            throw LibraryError.duplicateHighlight
        }
        
        highlightsCache.append(highlight)
        await saveHighlights()
    }
    
    public func removeHighlight(_ id: String) async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard let index = highlightsCache.firstIndex(where: { $0.id == id }) else {
            throw ServiceError.notFound
        }
        
        highlightsCache.remove(at: index)
        await saveHighlights()
    }
    
    public func getHighlight(for verse: BibleVerse) async -> Highlight? {
        return highlightsCache.first { $0.verse.id == verse.id }
    }
    
    private func saveNotes() async {
        await cacheService.set("library_notes", value: notesCache, expirationDate: nil)
    }
    
    private func saveHighlights() async {
        await cacheService.set("library_highlights", value: highlightsCache, expirationDate: nil)
    }
}

// MARK: - Library Errors

public enum LibraryError: LocalizedError {
    case duplicateBookmark
    case duplicateHighlight
    case planNotFound
    case invalidDateRange
    
    public var errorDescription: String? {
        switch self {
        case .duplicateBookmark:
            return "This verse is already bookmarked"
        case .duplicateHighlight:
            return "This verse is already highlighted"
        case .planNotFound:
            return "Reading plan not found"
        case .invalidDateRange:
            return "Invalid date range specified"
        }
    }
}