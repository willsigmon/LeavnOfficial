import Foundation

public protocol GetDailyVerseUseCaseProtocol {
    func execute() async throws -> BibleVerse
}

public struct GetDailyVerseUseCase: GetDailyVerseUseCaseProtocol {
    private let repository: BibleRepositoryProtocol
    
    public init(repository: BibleRepositoryProtocol) {
        self.repository = repository
    }
    
    public func execute() async throws -> BibleVerse {
        try await repository.fetchDailyVerse()
    }
}