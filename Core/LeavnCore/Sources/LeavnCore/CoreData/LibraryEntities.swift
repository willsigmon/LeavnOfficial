import Foundation
import CoreData

// MARK: - Library Item Entity
@objc(LibraryItemEntity)
public class LibraryItemEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var type: String?
    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var reference: String?
    @NSManaged public var metadata: Data?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var collections: NSSet?
}

extension LibraryItemEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LibraryItemEntity> {
        return NSFetchRequest<LibraryItemEntity>(entityName: "LibraryItemEntity")
    }
    
    @objc(addCollectionsObject:)
    @NSManaged public func addToCollections(_ value: LibraryCollectionEntity)
    
    @objc(removeCollectionsObject:)
    @NSManaged public func removeFromCollections(_ value: LibraryCollectionEntity)
    
    @objc(addCollections:)
    @NSManaged public func addToCollections(_ values: NSSet)
    
    @objc(removeCollections:)
    @NSManaged public func removeFromCollections(_ values: NSSet)
}

// MARK: - Library Collection Entity
@objc(LibraryCollectionEntity)
public class LibraryCollectionEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var collectionDescription: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var items: NSSet?
}

extension LibraryCollectionEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<LibraryCollectionEntity> {
        return NSFetchRequest<LibraryCollectionEntity>(entityName: "LibraryCollectionEntity")
    }
    
    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: LibraryItemEntity)
    
    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: LibraryItemEntity)
    
    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)
    
    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)
}

// MARK: - Search History Entity
@objc(SearchHistoryEntity)
public class SearchHistoryEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var query: String?
    @NSManaged public var searchType: String?
    @NSManaged public var resultsCount: Int32
    @NSManaged public var timestamp: Date?
}

extension SearchHistoryEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SearchHistoryEntity> {
        return NSFetchRequest<SearchHistoryEntity>(entityName: "SearchHistoryEntity")
    }
}

// MARK: - Settings Change Entity
@objc(SettingsChangeEntity)
public class SettingsChangeEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var settingKey: String?
    @NSManaged public var oldValue: String?
    @NSManaged public var newValue: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var userId: String?
}

extension SettingsChangeEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsChangeEntity> {
        return NSFetchRequest<SettingsChangeEntity>(entityName: "SettingsChangeEntity")
    }
}

// MARK: - Settings Backup Entity
@objc(SettingsBackupEntity)
public class SettingsBackupEntity: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var settingsData: Data?
    @NSManaged public var version: String?
    @NSManaged public var createdAt: Date?
}

extension SettingsBackupEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsBackupEntity> {
        return NSFetchRequest<SettingsBackupEntity>(entityName: "SettingsBackupEntity")
    }
}