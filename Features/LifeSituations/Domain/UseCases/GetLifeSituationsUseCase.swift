import Foundation

public struct GetLifeSituationsUseCase: UseCase {
    public typealias Input = GetLifeSituationsInput
    public typealias Output = [LifeSituation]
    
    private let repository: LifeSituationRepository
    
    public init(repository: LifeSituationRepository) {
        self.repository = repository
    }
    
    public func execute(_ input: GetLifeSituationsInput) async throws -> [LifeSituation] {
        let situations = try await repository.getLifeSituations()
        
        // Filter by category if specified
        var filtered = situations
        if let category = input.category {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Filter by search query if specified
        if let query = input.searchQuery?.lowercased(), !query.isEmpty {
            filtered = filtered.filter { situation in
                situation.title.lowercased().contains(query) ||
                situation.description.lowercased().contains(query) ||
                situation.tags.contains { $0.lowercased().contains(query) }
            }
        }
        
        // Sort by relevance or title
        filtered.sort { lhs, rhs in
            switch input.sortBy {
            case .relevance:
                // For now, just sort by title
                return lhs.title < rhs.title
            case .title:
                return lhs.title < rhs.title
            case .recent:
                // For now, just sort by title
                return lhs.title < rhs.title
            }
        }
        
        return filtered
    }
}

public struct GetLifeSituationsInput {
    public let category: LifeSituationCategory?
    public let searchQuery: String?
    public let sortBy: SortOption
    
    public init(
        category: LifeSituationCategory? = nil,
        searchQuery: String? = nil,
        sortBy: SortOption = .relevance
    ) {
        self.category = category
        self.searchQuery = searchQuery
        self.sortBy = sortBy
    }
    
    public enum SortOption {
        case relevance
        case title
        case recent
    }
}

