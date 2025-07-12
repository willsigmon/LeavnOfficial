import Foundation

public protocol SaveLibraryItemUseCaseProtocol {
    func execute(item: LibraryItem) async throws
}

public struct SaveLibraryItemUseCase: SaveLibraryItemUseCaseProtocol {
    private let repository: LibraryRepositoryProtocol
    
    public init(repository: LibraryRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(item: LibraryItem) async throws {
        try await repository.saveItem(item)
    }
}