import Foundation
import LeavnCore
import OSLog

private let logger = Logger(subsystem: "com.leavn3", category: "AIService")

// MARK: - Mock AI Service

public actor MockAIService: AIServiceProtocol {
    private let error = LeavnError.aiError(message: "MockAIService was called. This should not happen in a production environment. Check DIContainer configuration.")

    public func initialize() async throws {
        logger.warning("🤖 Mock AI Service initialized. This service will fail on all method calls as per fail-fast design.")
    }

    public func getInsights(for verse: BibleVerse) async throws -> [AIInsight] {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }

    public func generateDevotion(for verse: BibleVerse) async throws -> Devotion {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }

    public func explainVerse(_ verse: BibleVerse, context: AIContext) async throws -> String {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }

    public func compareTranslations(_ verse: BibleVerse, translations: [BibleTranslation]) async throws -> TranslationComparison {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }

    public func getHistoricalContext(for verse: BibleVerse) async throws -> HistoricalContext {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }

    public func generateContent(prompt: String) async throws -> String {
        logger.error("\(self.error.localizedDescription)")
        throw error
    }
}

