import Foundation
import CoreData

// MARK: - Core Data Stack
public final class CoreDataStack {
    public let persistentContainer: NSPersistentContainer
    public let viewContext: NSManagedObjectContext
    
    public init(modelName: String, inMemory: Bool = false) {
        persistentContainer = NSPersistentContainer(name: modelName)
        
        if inMemory {
            persistentContainer.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        persistentContainer.loadPersistentStores { _, error in
            if error != nil {
                fatalError("Core Data failed to load: \\(error)")
            }
        }
        
        viewContext = persistentContainer.viewContext
        viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public func save() async throws {
        guard viewContext.hasChanges else { return }
        
        try await viewContext.perform {
            try self.viewContext.save()
        }
    }
    
    public func performBackgroundTask<T>(_ block: @escaping (NSManagedObjectContext) async throws -> T) async throws -> T {
        try await persistentContainer.performBackgroundTask { context in
            try await block(context)
        }
    }
}

// MARK: - Core Data Repository Protocol
public protocol CoreDataRepository {
    associatedtype Entity: NSManagedObject
    
    var coreDataStack: CoreDataStack { get }
    
    func create() -> Entity
    func fetch(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) async throws -> [Entity]
    func fetchFirst(predicate: NSPredicate?) async throws -> Entity?
    func delete(_ entity: Entity) async throws
    func deleteAll() async throws
    func save() async throws
}

// MARK: - Base Core Data Repository
open class BaseCoreDataRepository<Entity: NSManagedObject>: CoreDataRepository {
    public let coreDataStack: CoreDataStack
    
    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }
    
    public func create() -> Entity {
        Entity(context: coreDataStack.viewContext)
    }
    
    public func fetch(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [Entity] {
        guard let request = Entity.fetchRequest() as? NSFetchRequest<Entity> else {
            throw NSError(domain: "CoreDataStack", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to cast fetch request"])
        }
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        return try await coreDataStack.viewContext.perform {
            try self.coreDataStack.viewContext.fetch(request)
        }
    }
    
    public func fetchFirst(predicate: NSPredicate? = nil) async throws -> Entity? {
        guard let request = Entity.fetchRequest() as? NSFetchRequest<Entity> else {
            throw NSError(domain: "CoreDataStack", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to cast fetch request"])
        }
        request.predicate = predicate
        request.fetchLimit = 1
        
        return try await coreDataStack.viewContext.perform {
            try self.coreDataStack.viewContext.fetch(request).first
        }
    }
    
    public func delete(_ entity: Entity) async throws {
        await coreDataStack.viewContext.perform {
            self.coreDataStack.viewContext.delete(entity)
        }
        try await save()
    }
    
    public func deleteAll() async throws {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Entity.self))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        
        try await coreDataStack.performBackgroundTask { context in
            try context.execute(deleteRequest)
            try context.save()
        }
    }
    
    public func save() async throws {
        try await coreDataStack.save()
    }
}

// MARK: - Managed Object Extensions
public extension NSManagedObject {
    static var entityName: String {
        String(describing: self)
    }
}
