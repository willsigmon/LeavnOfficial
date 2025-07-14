import Foundation

public final class MockGetLifeSituationsUseCase: GetLifeSituationsUseCase {
    private let repository: LifeSituationRepository
    
    public init() {
        self.repository = MockLifeSituationRepository()
    }
    
    public func execute(_ input: GetLifeSituationsInput) async throws -> [LifeSituation] {
        return try await repository.getLifeSituations()
    }
}