import Foundation

public protocol ManageRecentSearchesUseCaseProtocol {
    func getRecentSearches() async throws -> [String]
    func clearRecentSearches() async throws
}

public struct ManageRecentSearchesUseCase: ManageRecentSearchesUseCaseProtocol {
    private let repository: SearchRepositoryProtocol
    
    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getRecentSearches() async throws -> [String] {
        try await repository.getRecentSearches()
    }
    
    public func clearRecentSearches() async throws {
        try await repository.clearRecentSearches()
    }
}