import Foundation

public final class LibraryRepository: LibraryRepositoryProtocol {
    private let remoteDataSource: LibraryRemoteDataSourceProtocol
    private let localDataSource: LibraryLocalDataSourceProtocol
    
    public init(
        remoteDataSource: LibraryRemoteDataSourceProtocol,
        localDataSource: LibraryLocalDataSourceProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    public func fetchAllItems() async throws -> [LibraryItem] {
        do {
            // Try to fetch from remote first
            let remoteItems = try await remoteDataSource.fetchAllItems()
            // Cache locally
            for item in remoteItems {
                try await localDataSource.saveItem(item)
            }
            return remoteItems
        } catch {
            // Fallback to local cache if remote fails
            return try await localDataSource.fetchAllItems()
        }
    }
    
    public func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        do {
            let remoteItems = try await remoteDataSource.fetchItems(ofType: type)
            // Cache locally
            for item in remoteItems {
                try await localDataSource.saveItem(item)
            }
            return remoteItems
        } catch {
            return try await localDataSource.fetchItems(ofType: type)
        }
    }
    
    public func fetchItem(withId id: UUID) async throws -> LibraryItem? {
        do {
            if let remoteItem = try await remoteDataSource.fetchItem(withId: id) {
                try await localDataSource.saveItem(remoteItem)
                return remoteItem
            }
            return nil
        } catch {
            return try await localDataSource.fetchItem(withId: id)
        }
    }
    
    public func saveItem(_ item: LibraryItem) async throws {
        // Save locally first for immediate feedback
        try await localDataSource.saveItem(item)
        // Then sync to remote
        try await remoteDataSource.saveItem(item)
    }
    
    public func updateItem(_ item: LibraryItem) async throws {
        try await localDataSource.updateItem(item)
        try await remoteDataSource.updateItem(item)
    }
    
    public func deleteItem(withId id: UUID) async throws {
        try await localDataSource.deleteItem(withId: id)
        try await remoteDataSource.deleteItem(withId: id)
    }
    
    public func searchItems(query: String) async throws -> [LibraryItem] {
        do {
            return try await remoteDataSource.searchItems(query: query)
        } catch {
            return try await localDataSource.searchItems(query: query)
        }
    }
    
    public func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        do {
            return try await remoteDataSource.fetchItemsByTag(tag)
        } catch {
            return try await localDataSource.fetchItemsByTag(tag)
        }
    }
}