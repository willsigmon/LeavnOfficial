import Foundation

public protocol GetLibraryItemsUseCaseProtocol {
    func execute() async throws -> [LibraryItem]
    func execute(ofType type: LibraryItemType) async throws -> [LibraryItem]
}

public struct GetLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol {
    private let repository: LibraryRepositoryProtocol
    
    public init(repository: LibraryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> [LibraryItem] {
        try await repository.fetchAllItems()
    }
    
    public func execute(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        try await repository.fetchItems(ofType: type)
    }
}