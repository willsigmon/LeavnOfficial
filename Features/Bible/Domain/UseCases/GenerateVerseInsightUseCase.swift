import Foundation

public protocol GenerateVerseInsightUseCaseProtocol {
    func execute(for verse: BibleVerse, type: VerseInsight.InsightType) async throws -> VerseInsight
    func getCachedInsights(for verseId: String) async throws -> [VerseInsight]
}

public struct GenerateVerseInsightUseCase: GenerateVerseInsightUseCaseProtocol {
    private let insightRepository: BibleInsightRepositoryProtocol
    
    public init(insightRepository: BibleInsightRepositoryProtocol) {
        self.insightRepository = insightRepository
    }
    
    public func execute(for verse: BibleVerse, type: VerseInsight.InsightType) async throws -> VerseInsight {
        // First check if we have a cached insight
        let existingInsights = try await insightRepository.fetchInsights(for: verse.id)
        if let existingInsight = existingInsights.first(where: { $0.type == type }) {
            return existingInsight
        }
        
        // Generate new insight
        let insight = try await insightRepository.generateInsight(for: verse, type: type)
        
        // Save for future use
        try await insightRepository.saveInsight(insight)
        
        return insight
    }
    
    public func getCachedInsights(for verseId: String) async throws -> [VerseInsight] {
        try await insightRepository.fetchInsights(for: verseId)
    }
}