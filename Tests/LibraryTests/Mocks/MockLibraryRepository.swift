import Foundation
@testable import LeavnOfficial

final class MockLibraryRepository: LibraryRepositoryProtocol {
    var fetchAllItemsCalled = false
    var fetchItemsOfTypeCalled = false
    var saveItemCalled = false
    var updateItemCalled = false
    var deleteItemCalled = false
    var searchItemsCalled = false
    
    var itemsToReturn: [LibraryItem] = []
    var errorToThrow: Error?
    var lastSavedItem: LibraryItem?
    var lastUpdatedItem: LibraryItem?
    var lastDeletedId: UUID?
    var lastSearchQuery: String?
    
    func fetchAllItems() async throws -> [LibraryItem] {
        fetchAllItemsCalled = true
        if let error = errorToThrow { throw error }
        return itemsToReturn
    }
    
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        fetchItemsOfTypeCalled = true
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.type == type }
    }
    
    func fetchItem(withId id: UUID) async throws -> LibraryItem? {
        if let error = errorToThrow { throw error }
        return itemsToReturn.first { $0.id == id }
    }
    
    func saveItem(_ item: LibraryItem) async throws {
        saveItemCalled = true
        lastSavedItem = item
        if let error = errorToThrow { throw error }
        itemsToReturn.append(item)
    }
    
    func updateItem(_ item: LibraryItem) async throws {
        updateItemCalled = true
        lastUpdatedItem = item
        if let error = errorToThrow { throw error }
    }
    
    func deleteItem(withId id: UUID) async throws {
        deleteItemCalled = true
        lastDeletedId = id
        if let error = errorToThrow { throw error }
        itemsToReturn.removeAll { $0.id == id }
    }
    
    func searchItems(query: String) async throws -> [LibraryItem] {
        searchItemsCalled = true
        lastSearchQuery = query
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { 
            $0.title.localizedCaseInsensitiveContains(query) 
        }
    }
    
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.tags.contains(tag) }
    }
}