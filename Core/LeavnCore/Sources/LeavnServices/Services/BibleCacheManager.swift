import Foundation
import CoreData
import LeavnCore

// MARK: - Bible Cache Manager Protocol
public protocol BibleCacheManager {
    func getCachedVerse(reference: String, translation: String) async throws -> BibleVerse?
    func getCachedChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter?
    func cacheVerse(_ verse: BibleVerse) async throws
    func cacheChapter(_ chapter: BibleChapter) async throws
    func clearCache() async throws
    func getCacheSize() async throws -> Int64
}

// MARK: - Core Data Cache Manager Implementation
public final class CoreDataBibleCacheManager: BibleCacheManager {
    private let context: NSManagedObjectContext
    private let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    
    public init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public func getCachedVerse(reference: String, translation: String) async throws -> BibleVerse? {
        return try await context.perform {
            let request: NSFetchRequest<CachedVerse> = CachedVerse.fetchRequest()
            request.predicate = NSPredicate(
                format: "reference == %@ AND translation == %@",
                reference, translation
            )
            request.fetchLimit = 1
            
            guard let cachedVerse = try self.context.fetch(request).first else {
                return nil
            }
            
            // Update last accessed time
            cachedVerse.lastAccessed = Date()
            try self.context.save()
            
            return BibleVerse(
                id: cachedVerse.id ?? "",
                reference: cachedVerse.reference ?? "",
                text: cachedVerse.text ?? "",
                translation: cachedVerse.translation ?? "",
                book: cachedVerse.book ?? "",
                chapter: Int(cachedVerse.chapter),
                verse: Int(cachedVerse.verse)
            )
        }
    }
    
    public func getCachedChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter? {
        return try await context.perform {
            let request: NSFetchRequest<CachedChapter> = CachedChapter.fetchRequest()
            request.predicate = NSPredicate(
                format: "book == %@ AND chapter == %d AND translation == %@",
                book, chapter, translation
            )
            request.fetchLimit = 1
            
            guard let cachedChapter = try self.context.fetch(request).first else {
                return nil
            }
            
            // Update last accessed time
            cachedChapter.lastAccessed = Date()
            
            // Fetch associated verses
            let verseRequest: NSFetchRequest<CachedVerse> = CachedVerse.fetchRequest()
            verseRequest.predicate = NSPredicate(
                format: "book == %@ AND chapter == %d AND translation == %@",
                book, chapter, translation
            )
            verseRequest.sortDescriptors = [NSSortDescriptor(key: "verse", ascending: true)]
            
            let cachedVerses = try self.context.fetch(verseRequest)
            let verses = cachedVerses.map { cachedVerse in
                BibleVerse(
                    id: cachedVerse.id ?? "",
                    reference: cachedVerse.reference ?? "",
                    text: cachedVerse.text ?? "",
                    translation: cachedVerse.translation ?? "",
                    book: cachedVerse.book ?? "",
                    chapter: Int(cachedVerse.chapter),
                    verse: Int(cachedVerse.verse)
                )
            }
            
            try self.context.save()
            
            return BibleChapter(
                book: book,
                chapter: chapter,
                verses: verses,
                translation: translation
            )
        }
    }
    
    public func cacheVerse(_ verse: BibleVerse) async throws {
        try await context.perform {
            // Check if verse already exists
            let request: NSFetchRequest<CachedVerse> = CachedVerse.fetchRequest()
            request.predicate = NSPredicate(
                format: "reference == %@ AND translation == %@",
                verse.reference, verse.translation
            )
            
            let existingVerse = try self.context.fetch(request).first
            let cachedVerse = existingVerse ?? CachedVerse(context: self.context)
            
            cachedVerse.id = verse.id
            cachedVerse.reference = verse.reference
            cachedVerse.text = verse.text
            cachedVerse.translation = verse.translation
            cachedVerse.book = verse.book
            cachedVerse.chapter = Int32(verse.chapter)
            cachedVerse.verse = Int32(verse.verse)
            cachedVerse.lastAccessed = Date()
            cachedVerse.createdAt = existingVerse?.createdAt ?? Date()
            
            try self.context.save()
            
            // Check cache size and clean if necessary
            try await self.cleanCacheIfNeeded()
        }
    }
    
    public func cacheChapter(_ chapter: BibleChapter) async throws {
        try await context.perform {
            // Cache chapter metadata
            let chapterRequest: NSFetchRequest<CachedChapter> = CachedChapter.fetchRequest()
            chapterRequest.predicate = NSPredicate(
                format: "book == %@ AND chapter == %d AND translation == %@",
                chapter.book, chapter.chapter, chapter.translation
            )
            
            let existingChapter = try self.context.fetch(chapterRequest).first
            let cachedChapter = existingChapter ?? CachedChapter(context: self.context)
            
            cachedChapter.book = chapter.book
            cachedChapter.chapter = Int32(chapter.chapter)
            cachedChapter.translation = chapter.translation
            cachedChapter.lastAccessed = Date()
            cachedChapter.createdAt = existingChapter?.createdAt ?? Date()
            
            // Cache individual verses
            for verse in chapter.verses {
                try await self.cacheVerse(verse)
            }
            
            try self.context.save()
        }
    }
    
    public func clearCache() async throws {
        try await context.perform {
            let verseRequest: NSFetchRequest<NSFetchRequestResult> = CachedVerse.fetchRequest()
            let deleteVerseRequest = NSBatchDeleteRequest(fetchRequest: verseRequest)
            try self.context.execute(deleteVerseRequest)
            
            let chapterRequest: NSFetchRequest<NSFetchRequestResult> = CachedChapter.fetchRequest()
            let deleteChapterRequest = NSBatchDeleteRequest(fetchRequest: chapterRequest)
            try self.context.execute(deleteChapterRequest)
            
            try self.context.save()
        }
    }
    
    public func getCacheSize() async throws -> Int64 {
        return try await context.perform {
            let verseRequest: NSFetchRequest<CachedVerse> = CachedVerse.fetchRequest()
            let verses = try self.context.fetch(verseRequest)
            
            let totalSize = verses.reduce(0) { size, verse in
                let textSize = verse.text?.data(using: .utf8)?.count ?? 0
                return size + Int64(textSize)
            }
            
            return totalSize
        }
    }
    
    private func cleanCacheIfNeeded() async throws {
        let currentSize = try await getCacheSize()
        
        if currentSize > maxCacheSize {
            try await context.perform {
                // Remove oldest accessed verses
                let request: NSFetchRequest<CachedVerse> = CachedVerse.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "lastAccessed", ascending: true)]
                request.fetchLimit = 100 // Remove 100 oldest entries
                
                let oldestVerses = try self.context.fetch(request)
                for verse in oldestVerses {
                    self.context.delete(verse)
                }
                
                try self.context.save()
            }
        }
    }
}

// MARK: - Core Data Entities
@objc(CachedVerse)
public class CachedVerse: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var reference: String?
    @NSManaged public var text: String?
    @NSManaged public var translation: String?
    @NSManaged public var book: String?
    @NSManaged public var chapter: Int32
    @NSManaged public var verse: Int32
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var createdAt: Date?
}

extension CachedVerse {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedVerse> {
        return NSFetchRequest<CachedVerse>(entityName: "CachedVerse")
    }
}

@objc(CachedChapter)
public class CachedChapter: NSManagedObject {
    @NSManaged public var book: String?
    @NSManaged public var chapter: Int32
    @NSManaged public var translation: String?
    @NSManaged public var lastAccessed: Date?
    @NSManaged public var createdAt: Date?
}

extension CachedChapter {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedChapter> {
        return NSFetchRequest<CachedChapter>(entityName: "CachedChapter")
    }
}

// MARK: - In-Memory Cache Manager (for testing)
public final class InMemoryBibleCacheManager: BibleCacheManager {
    private var verseCache: [String: BibleVerse] = [:]
    private var chapterCache: [String: BibleChapter] = [:]
    private let queue = DispatchQueue(label: "bible.cache", attributes: .concurrent)
    
    public init() {}
    
    public func getCachedVerse(reference: String, translation: String) async throws -> BibleVerse? {
        return await withCheckedContinuation { continuation in
            queue.async {
                let key = "\(reference)-\(translation)"
                continuation.resume(returning: self.verseCache[key])
            }
        }
    }
    
    public func getCachedChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter? {
        return await withCheckedContinuation { continuation in
            queue.async {
                let key = "\(book)-\(chapter)-\(translation)"
                continuation.resume(returning: self.chapterCache[key])
            }
        }
    }
    
    public func cacheVerse(_ verse: BibleVerse) async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                let key = "\(verse.reference)-\(verse.translation)"
                self.verseCache[key] = verse
                continuation.resume()
            }
        }
    }
    
    public func cacheChapter(_ chapter: BibleChapter) async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                let key = "\(chapter.book)-\(chapter.chapter)-\(chapter.translation)"
                self.chapterCache[key] = chapter
                
                // Also cache individual verses
                for verse in chapter.verses {
                    let verseKey = "\(verse.reference)-\(verse.translation)"
                    self.verseCache[verseKey] = verse
                }
                
                continuation.resume()
            }
        }
    }
    
    public func clearCache() async throws {
        await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.verseCache.removeAll()
                self.chapterCache.removeAll()
                continuation.resume()
            }
        }
    }
    
    public func getCacheSize() async throws -> Int64 {
        return await withCheckedContinuation { continuation in
            queue.async {
                let verseSize = self.verseCache.values.reduce(0) { size, verse in
                    size + Int64(verse.text.data(using: .utf8)?.count ?? 0)
                }
                continuation.resume(returning: verseSize)
            }
        }
    }
}