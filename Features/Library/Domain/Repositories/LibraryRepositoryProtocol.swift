import Foundation

public protocol LibraryRepositoryProtocol {
    func fetchAllItems() async throws -> [LibraryItem]
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem]
    func fetchItem(withId id: UUID) async throws -> LibraryItem?
    func saveItem(_ item: LibraryItem) async throws
    func updateItem(_ item: LibraryItem) async throws
    func deleteItem(withId id: UUID) async throws
    func searchItems(query: String) async throws -> [LibraryItem]
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem]
}