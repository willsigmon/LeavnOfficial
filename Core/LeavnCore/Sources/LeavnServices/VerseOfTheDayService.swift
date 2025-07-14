import Foundation
import Combine

// MARK: - Verse of the Day Service Protocol
public protocol VerseOfTheDayServiceProtocol {
    /// Get today's verse based on the current date
    func getTodaysVerse(translation: BibleTranslation) async throws -> BibleVerse
    
    /// Get verse for a specific date
    func getVerseForDate(_ date: Date, translation: BibleTranslation) async throws -> BibleVerse
    
    /// Get verses by category
    func getVersesByCategory(_ category: VerseCategory, limit: Int) async throws -> [BibleVerse]
    
    /// Cache the current verse for offline access
    func cacheVerse(_ verse: BibleVerse) async throws
    
    /// Get cached verse if available
    func getCachedVerse() async throws -> BibleVerse?
    
    /// Subscribe to daily verse updates
    var dailyVersePublisher: AnyPublisher<BibleVerse?, Never> { get }
}

// MARK: - Verse Categories
public enum VerseCategory: String, CaseIterable, Sendable {
    case encouragement = "Encouragement"
    case wisdom = "Wisdom"
    case peace = "Peace"
    case faith = "Faith"
    case hope = "Hope"
    case love = "Love"
    case strength = "Strength"
    case guidance = "Guidance"
    case gratitude = "Gratitude"
    case forgiveness = "Forgiveness"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .encouragement: return "heart.fill"
        case .wisdom: return "lightbulb.fill"
        case .peace: return "leaf.fill"
        case .faith: return "sparkles"
        case .hope: return "sun.max.fill"
        case .love: return "heart.circle.fill"
        case .strength: return "bolt.fill"
        case .guidance: return "location.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .forgiveness: return "arrow.triangle.2.circlepath"
        }
    }
}

// MARK: - Verse of the Day Service Implementation
public final class VerseOfTheDayService: VerseOfTheDayServiceProtocol {
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let dailyVerseSubject = CurrentValueSubject<BibleVerse?, Never>(nil)
    
    // Curated verse references organized by category
    private let versesByCategory: [VerseCategory: [String]] = [
        .encouragement: [
            "Joshua 1:9", "Isaiah 41:10", "Philippians 4:13", "Psalm 23:4",
            "2 Timothy 1:7", "Romans 8:28", "Deuteronomy 31:6", "Psalm 27:1"
        ],
        .wisdom: [
            "Proverbs 3:5-6", "James 1:5", "Proverbs 2:6", "Psalm 111:10",
            "Colossians 2:3", "Proverbs 16:9", "Ecclesiastes 7:12", "Job 12:12"
        ],
        .peace: [
            "John 14:27", "Philippians 4:7", "Isaiah 26:3", "Psalm 29:11",
            "Romans 15:13", "Colossians 3:15", "2 Thessalonians 3:16", "Psalm 119:165"
        ],
        .faith: [
            "Hebrews 11:1", "2 Corinthians 5:7", "Mark 11:22", "Romans 10:17",
            "Ephesians 2:8", "Galatians 2:20", "Matthew 17:20", "1 Peter 1:7"
        ],
        .hope: [
            "Romans 15:13", "Jeremiah 29:11", "Psalm 42:11", "Romans 5:5",
            "Hebrews 11:1", "Lamentations 3:21-23", "1 Peter 1:3", "Isaiah 40:31"
        ],
        .love: [
            "1 Corinthians 13:4-7", "John 3:16", "1 John 4:8", "Romans 8:38-39",
            "1 John 4:19", "John 15:13", "Song of Solomon 8:7", "Matthew 22:37-39"
        ],
        .strength: [
            "Isaiah 40:31", "Psalm 46:1", "2 Corinthians 12:9", "Nehemiah 8:10",
            "Ephesians 6:10", "Psalm 18:2", "Habakkuk 3:19", "1 Chronicles 16:11"
        ],
        .guidance: [
            "Psalm 32:8", "Proverbs 3:5-6", "Isaiah 30:21", "Psalm 119:105",
            "James 1:5", "Psalm 25:9", "Proverbs 16:9", "John 16:13"
        ],
        .gratitude: [
            "1 Thessalonians 5:18", "Psalm 100:4", "Colossians 3:17", "Psalm 107:1",
            "Ephesians 5:20", "Psalm 136:1", "1 Chronicles 16:34", "Philippians 4:6"
        ],
        .forgiveness: [
            "Ephesians 4:32", "Matthew 6:14-15", "Colossians 3:13", "1 John 1:9",
            "Luke 6:37", "Mark 11:25", "Matthew 18:21-22", "Psalm 103:12"
        ]
    ]
    
    // Daily verse selection algorithm - ensures variety and theological balance
    private let dailyVerseSequence: [String] = [
        // A curated sequence that cycles through different themes
        "Psalm 23:1", "John 3:16", "Philippians 4:13", "Proverbs 3:5-6",
        "Isaiah 40:31", "Romans 8:28", "Psalm 91:1", "Matthew 6:33",
        "Jeremiah 29:11", "2 Corinthians 5:7", "Psalm 46:10", "Joshua 1:9",
        "1 Corinthians 13:4", "Galatians 5:22-23", "Ephesians 2:8-9", "Psalm 119:105",
        "Matthew 11:28", "John 14:6", "Romans 12:2", "Psalm 27:1",
        "Isaiah 41:10", "Hebrews 11:1", "1 Peter 5:7", "Psalm 139:14",
        "John 15:5", "2 Timothy 1:7", "Psalm 37:4", "Matthew 5:16",
        "Romans 8:38-39", "Philippians 4:6-7"
    ]
    
    public init(bibleService: BibleServiceProtocol, cacheService: CacheServiceProtocol) {
        self.bibleService = bibleService
        self.cacheService = cacheService
        
        // Load cached verse on init
        Task {
            if let cachedVerse = try? await getCachedVerse() {
                await MainActor.run {
                    dailyVerseSubject.send(cachedVerse)
                }
            }
        }
    }
    
    public func getTodaysVerse(translation: BibleTranslation) async throws -> BibleVerse {
        // Check cache first
        if let cached = try? await getCachedVerse(),
           Calendar.current.isDateInToday(cached.cachedDate ?? Date()) {
            return cached
        }
        
        // Generate verse for today
        let verse = try await getVerseForDate(Date(), translation: translation)
        
        // Cache it
        try? await cacheVerse(verse)
        
        // Update publisher
        await MainActor.run {
            dailyVerseSubject.send(verse)
        }
        
        return verse
    }
    
    public func getVerseForDate(_ date: Date, translation: BibleTranslation) async throws -> BibleVerse {
        // Use day of year to select from our sequence
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = (dayOfYear - 1) % dailyVerseSequence.count
        let reference = dailyVerseSequence[index]
        
        // Fetch the verse
        let verse = try await bibleService.getVerse(reference: reference, translation: translation.abbreviation)
        
        // Add metadata for caching
        var verseWithDate = verse
        verseWithDate.cachedDate = date
        
        return verseWithDate
    }
    
    public func getVersesByCategory(_ category: VerseCategory, limit: Int) async throws -> [BibleVerse] {
        guard let references = versesByCategory[category] else {
            return []
        }
        
        // Randomly select verses from the category
        let selectedRefs = references.shuffled().prefix(limit)
        
        var verses: [BibleVerse] = []
        for reference in selectedRefs {
            if let verse = try? await bibleService.getVerse(reference: reference, translation: "ESV") {
                verses.append(verse)
            }
        }
        
        return verses
    }
    
    public func cacheVerse(_ verse: BibleVerse) async throws {
        let key = "verse_of_the_day_\(Calendar.current.component(.year, from: Date()))_\(Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0)"
        try await cacheService.store(verse, forKey: key)
    }
    
    public func getCachedVerse() async throws -> BibleVerse? {
        let key = "verse_of_the_day_\(Calendar.current.component(.year, from: Date()))_\(Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0)"
        return try await cacheService.retrieve(BibleVerse.self, forKey: key)
    }
    
    public var dailyVersePublisher: AnyPublisher<BibleVerse?, Never> {
        dailyVerseSubject.eraseToAnyPublisher()
    }
}

// MARK: - Widget Support
public extension VerseOfTheDayService {
    /// Create a widget-friendly verse format
    func createWidgetVerse(from verse: BibleVerse) -> WidgetVerse {
        WidgetVerse(
            text: verse.text,
            reference: verse.reference,
            translation: verse.translation,
            date: Date()
        )
    }
}

// MARK: - Widget Verse Model
public struct WidgetVerse: Codable {
    public let text: String
    public let reference: String
    public let translation: String
    public let date: Date
    
    public init(text: String, reference: String, translation: String, date: Date) {
        self.text = text
        self.reference = reference
        self.translation = translation
        self.date = date
    }
}

// MARK: - BibleVerse Extension for Caching
private extension BibleVerse {
    var cachedDate: Date? {
        get { nil } // This would be stored in cache metadata
        set { } // This would be stored in cache metadata
    }
}

// MARK: - Cache Service Protocol
public protocol CacheServiceProtocol {
    func store<T: Codable>(_ object: T, forKey key: String) async throws
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
    func clear() async throws
}

// MARK: - Simple In-Memory Cache Implementation
public final class InMemoryCacheService: CacheServiceProtocol {
    private var cache: [String: Data] = [:]
    private let queue = DispatchQueue(label: "com.leavn.cache", attributes: .concurrent)
    
    public init() {}
    
    public func store<T: Codable>(_ object: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(object)
        queue.async(flags: .barrier) {
            self.cache[key] = data
        }
    }
    
    public func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        return queue.sync {
            guard let data = cache[key] else { return nil }
            return try? JSONDecoder().decode(type, from: data)
        }
    }
    
    public func remove(forKey key: String) async throws {
        queue.async(flags: .barrier) {
            self.cache.removeValue(forKey: key)
        }
    }
    
    public func clear() async throws {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}