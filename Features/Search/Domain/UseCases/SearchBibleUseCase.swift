import Foundation

public protocol SearchBibleUseCaseProtocol {
    func execute(query: SearchQuery) async throws -> [SearchResult]
}

public struct SearchBibleUseCase: SearchBibleUseCaseProtocol {
    private let repository: SearchRepositoryProtocol
    
    public init(repository: SearchRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute(query: SearchQuery) async throws -> [SearchResult] {
        // Validate query
        let trimmedText = query.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return []
        }
        
        // Add to recent searches
        try await repository.addRecentSearch(trimmedText)
        
        // Perform search
        let validatedQuery = SearchQuery(
            text: trimmedText,
            filter: query.filter,
            translation: query.translation
        )
        
        return try await repository.search(query: validatedQuery)
    }
}