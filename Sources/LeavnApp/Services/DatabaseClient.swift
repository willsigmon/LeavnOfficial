import Dependencies
import CoreData
import Foundation

struct DatabaseClient {
    var saveBookmark: @Sendable (Bookmark) async throws -> Void
    var deleteBookmark: @Sendable (Bookmark.ID) async throws -> Void
    var loadBookmarks: @Sendable () async throws -> [Bookmark]
    
    var saveNote: @Sendable (Note) async throws -> Void
    var updateNote: @Sendable (Note) async throws -> Void
    var deleteNote: @Sendable (Note.ID) async throws -> Void
    var loadNotes: @Sendable () async throws -> [Note]
    
    var updateHighlight: @Sendable (String, HighlightColor) async throws -> Void
    var loadHighlights: @Sendable () async throws -> [String: HighlightColor]
    
    var cachePassage: @Sendable (Book, Int, String) async throws -> Void
    var getCachedPassage: @Sendable (Book, Int) async throws -> String?
    var clearCache: @Sendable () async throws -> Void
}

extension DatabaseClient: DependencyKey {
    static let liveValue = Self(
        saveBookmark: { bookmark in
            let context = PersistenceController.shared.container.viewContext
            
            let entity = BookmarkEntity(context: context)
            entity.id = bookmark.id
            entity.reference = bookmark.reference
            entity.book = bookmark.book.rawValue
            entity.chapter = Int16(bookmark.chapter)
            entity.verse = bookmark.verse.map { Int16($0) } ?? 0
            entity.createdAt = bookmark.createdAt
            entity.title = bookmark.title
            entity.color = bookmark.color.rawValue
            
            try context.save()
        },
        deleteBookmark: { id in
            let context = PersistenceController.shared.container.viewContext
            
            let request = BookmarkEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let bookmark = try context.fetch(request).first {
                context.delete(bookmark)
                try context.save()
            }
        },
        loadBookmarks: {
            let context = PersistenceController.shared.container.viewContext
            
            let request = BookmarkEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \BookmarkEntity.createdAt, ascending: false)]
            
            let entities = try context.fetch(request)
            
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let reference = entity.reference,
                      let bookRaw = entity.book,
                      let book = Book(rawValue: bookRaw),
                      let createdAt = entity.createdAt,
                      let colorRaw = entity.color,
                      let color = BookmarkColor(rawValue: colorRaw) else {
                    return nil
                }
                
                return Bookmark(
                    id: id,
                    reference: reference,
                    book: book,
                    chapter: Int(entity.chapter),
                    verse: entity.verse > 0 ? Int(entity.verse) : nil,
                    createdAt: createdAt,
                    title: entity.title,
                    color: color
                )
            }
        },
        saveNote: { note in
            let context = PersistenceController.shared.container.viewContext
            
            let entity = NoteEntity(context: context)
            entity.id = note.id
            entity.reference = note.reference
            entity.content = note.content
            entity.book = note.book.rawValue
            entity.chapter = Int16(note.chapter)
            entity.verse = note.verse.map { Int16($0) } ?? 0
            entity.createdAt = note.createdAt
            entity.updatedAt = note.updatedAt
            entity.tags = note.tags.joined(separator: ",")
            
            try context.save()
        },
        updateNote: { note in
            let context = PersistenceController.shared.container.viewContext
            
            let request = NoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", note.id as CVarArg)
            
            if let entity = try context.fetch(request).first {
                entity.content = note.content
                entity.updatedAt = note.updatedAt
                entity.tags = note.tags.joined(separator: ",")
                try context.save()
            }
        },
        deleteNote: { id in
            let context = PersistenceController.shared.container.viewContext
            
            let request = NoteEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
            
            if let note = try context.fetch(request).first {
                context.delete(note)
                try context.save()
            }
        },
        loadNotes: {
            let context = PersistenceController.shared.container.viewContext
            
            let request = NoteEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \NoteEntity.updatedAt, ascending: false)]
            
            let entities = try context.fetch(request)
            
            return entities.compactMap { entity in
                guard let id = entity.id,
                      let reference = entity.reference,
                      let content = entity.content,
                      let bookRaw = entity.book,
                      let book = Book(rawValue: bookRaw),
                      let createdAt = entity.createdAt,
                      let updatedAt = entity.updatedAt else {
                    return nil
                }
                
                let tags = entity.tags?.components(separatedBy: ",").filter { !$0.isEmpty } ?? []
                
                return Note(
                    id: id,
                    reference: reference,
                    content: content,
                    book: book,
                    chapter: Int(entity.chapter),
                    verse: entity.verse > 0 ? Int(entity.verse) : nil,
                    createdAt: createdAt,
                    updatedAt: updatedAt,
                    tags: tags
                )
            }
        },
        updateHighlight: { reference, color in
            let context = PersistenceController.shared.container.viewContext
            
            let request = HighlightEntity.fetchRequest()
            request.predicate = NSPredicate(format: "reference == %@", reference)
            
            if let existing = try context.fetch(request).first {
                if color == .none {
                    context.delete(existing)
                } else {
                    existing.color = color.rawValue
                    existing.updatedAt = Date()
                }
            } else if color != .none {
                let entity = HighlightEntity(context: context)
                entity.reference = reference
                entity.color = color.rawValue
                entity.createdAt = Date()
                entity.updatedAt = Date()
            }
            
            try context.save()
        },
        loadHighlights: {
            let context = PersistenceController.shared.container.viewContext
            
            let request = HighlightEntity.fetchRequest()
            let entities = try context.fetch(request)
            
            var highlights: [String: HighlightColor] = [:]
            
            for entity in entities {
                if let reference = entity.reference,
                   let colorRaw = entity.color,
                   let color = HighlightColor(rawValue: colorRaw) {
                    highlights[reference] = color
                }
            }
            
            return highlights
        },
        cachePassage: { book, chapter, text in
            let context = PersistenceController.shared.container.viewContext
            
            let request = CachedPassageEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "book == %@ AND chapter == %d",
                book.rawValue,
                chapter
            )
            
            if let existing = try context.fetch(request).first {
                existing.text = text
                existing.cachedAt = Date()
            } else {
                let entity = CachedPassageEntity(context: context)
                entity.book = book.rawValue
                entity.chapter = Int16(chapter)
                entity.text = text
                entity.cachedAt = Date()
            }
            
            try context.save()
        },
        getCachedPassage: { book, chapter in
            let context = PersistenceController.shared.container.viewContext
            
            let request = CachedPassageEntity.fetchRequest()
            request.predicate = NSPredicate(
                format: "book == %@ AND chapter == %d",
                book.rawValue,
                chapter
            )
            
            return try context.fetch(request).first?.text
        },
        clearCache: {
            let context = PersistenceController.shared.container.viewContext
            
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedPassageEntity")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            try context.execute(deleteRequest)
            try context.save()
        }
    )
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

// MARK: - Core Data Stack

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LeavnModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}