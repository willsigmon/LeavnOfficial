import XCTest
@testable import LeavnCore
@testable import LeavnServices

/// Comprehensive tests for AI guardrails and content safety
final class AIGuardrailsTests: XCTestCase {
    
    // MARK: - Guardrails Validation Tests
    
    func testValidatesProperContent() {
        // Test that valid content passes
        let validResponses = [
            "God's love is eternal and unchanging.",
            "Jesus Christ is our Lord and Savior.",
            "The Holy Spirit guides us in all truth.",
            "Scripture teaches us to love one another."
        ]
        
        for response in validResponses {
            let result = AIGuardrails.validateResponse(response)
            XCTAssertTrue(result.isValid, "Valid response failed: \(response)")
        }
    }
    
    func testRejectsBlasphemousContent() {
        // Test that blasphemous content is rejected
        let blasphemousResponses = [
            "god is dead and we killed him",
            "jesus was just a regular person",
            "the bible is fake news",
            "scripture is wrong about this"
        ]
        
        for response in blasphemousResponses {
            let result = AIGuardrails.validateResponse(response)
            XCTAssertFalse(result.isValid, "Blasphemous response passed: \(response)")
            XCTAssertNotNil(result.failureReason)
        }
    }
    
    func testRejectsHereticalTheology() {
        // Test theological accuracy checks
        let hereticalResponses = [
            "You can earn your salvation through good works alone.",
            "All paths lead to the same god eventually.",
            "The Bible has many errors and contradictions."
        ]
        
        for response in hereticalResponses {
            let result = AIGuardrails.validateResponse(response)
            XCTAssertFalse(result.isValid, "Heretical response passed: \(response)")
        }
    }
    
    func testEnforcesReverentCapitalization() {
        // Test divine name capitalization
        let improperResponses = [
            "god loves you", // Should be "God"
            "jesus saves", // Should be "Jesus"
            "the holy spirit guides" // Should be "Holy Spirit"
        ]
        
        for response in improperResponses {
            let result = AIGuardrails.validateResponse(response)
            XCTAssertFalse(result.isValid, "Improper capitalization passed: \(response)")
        }
    }
    
    func testSystemPromptInclusion() {
        // Test that system prompt is properly formatted
        let userPrompt = "Tell me about salvation"
        let wrappedPrompt = AIGuardrails.wrapPrompt(userPrompt)
        
        XCTAssertTrue(wrappedPrompt.contains("BIBLICAL ACCURACY"))
        XCTAssertTrue(wrappedPrompt.contains("REVERENT TONE"))
        XCTAssertTrue(wrappedPrompt.contains(userPrompt))
    }
    
    // MARK: - Content Filter Tests
    
    func testContentFilterDetectsIssues() async {
        let filter = ContentFilterService()
        let context = FilterContext(contentType: .devotion)
        
        let problematicContent = "god is not real and jesus was just a myth"
        let result = await filter.filterContent(problematicContent, context: context)
        
        XCTAssertFalse(result.isApproved)
        XCTAssertTrue(result.severity >= .moderate)
        XCTAssertFalse(result.issues.isEmpty)
    }
    
    func testContentFilterApprovesGoodContent() async {
        let filter = ContentFilterService()
        let context = FilterContext(contentType: .explanation)
        
        let goodContent = "This verse teaches us about God's love and mercy. Jesus demonstrated this love through His sacrifice on the cross."
        let result = await filter.filterContent(goodContent, context: context)
        
        XCTAssertTrue(result.isApproved)
        XCTAssertEqual(result.severity, .none)
    }
    
    // MARK: - Fact Checker Tests
    
    func testFactCheckerValidatesClaims() async {
        let factChecker = BiblicalFactChecker()
        
        // Test accurate claim
        let accurateClaim = "The Gospel of John was written in the late first century"
        let result1 = await factChecker.checkClaim(accurateClaim)
        XCTAssertTrue(result1.verdict != .incorrect)
        
        // Test inaccurate claim
        let inaccurateClaim = "Moses wrote the book of Revelation"
        let result2 = await factChecker.checkClaim(inaccurateClaim)
        XCTAssertEqual(result2.verdict, .incorrect)
    }
    
    // MARK: - Safe AI Service Tests
    
    func testSafeAIServiceUseFallbacks() async throws {
        // Create a mock AI service that returns inappropriate content
        let mockAI = MockInappropriateAIService()
        let safeAI = SafeAIService(wrapping: mockAI)
        
        // Initialize
        try await safeAI.initialize()
        
        // Test verse explanation
        let verse = BibleVerse(
            id: "GEN.1.1",
            bookId: "GEN",
            bookName: "Genesis",
            chapter: 1,
            verse: 1,
            text: "In the beginning God created the heaven and the earth.",
            translation: "KJV"
        )
        
        let explanation = try await safeAI.explainVerse(verse, context: AIContext())
        
        // Should use fallback content
        XCTAssertFalse(explanation.contains("fake"))
        XCTAssertTrue(explanation.contains("passage"))
    }
    
    // MARK: - Monitoring Service Tests
    
    func testMonitoringTracksMetrics() async {
        let monitoring = AIMonitoringService()
        
        // Record some events
        let eventId1 = await monitoring.recordRequest(contentType: .devotion)
        await monitoring.recordResponse(
            eventId: eventId1,
            success: true,
            responseTime: 1.5,
            validationResult: .success,
            fallbackUsed: false
        )
        
        let eventId2 = await monitoring.recordRequest(contentType: .explanation)
        await monitoring.recordResponse(
            eventId: eventId2,
            success: true,
            responseTime: 2.0,
            validationResult: .failure(reason: "Inappropriate content"),
            fallbackUsed: true
        )
        
        // Check metrics
        let metrics = await monitoring.getMetrics()
        XCTAssertEqual(metrics.totalRequests, 2)
        XCTAssertEqual(metrics.successfulResponses, 2)
        XCTAssertEqual(metrics.validationFailures, 1)
        XCTAssertEqual(metrics.fallbacksUsed, 1)
        XCTAssertTrue(metrics.averageResponseTime > 0)
    }
    
    func testMonitoringGeneratesHealthReport() async {
        let monitoring = AIMonitoringService()
        
        // Add some data
        _ = await monitoring.recordRequest(contentType: .devotion)
        
        let report = await monitoring.generateHealthReport()
        XCTAssertTrue(report.contains("AI Service Health Report"))
        XCTAssertTrue(report.contains("Performance Metrics"))
    }
    
    // MARK: - Fallback Content Tests
    
    func testFallbackContentIsAppropriate() {
        let fallbackTypes: [ContentType] = [.devotion, .explanation, .verseInsight, .historicalContext]
        
        for type in fallbackTypes {
            let fallback = AIGuardrails.getFallbackResponse(for: type)
            
            // Verify fallback content is appropriate
            let validation = AIGuardrails.validateResponse(fallback)
            XCTAssertTrue(validation.isValid, "Fallback content failed validation for type: \(type)")
            
            // Check it contains relevant content
            XCTAssertFalse(fallback.isEmpty)
            XCTAssertTrue(fallback.contains("God") || fallback.contains("Lord") || fallback.contains("Scripture"))
        }
    }
}

// MARK: - Mock Services

/// Mock AI service that returns inappropriate content for testing
actor MockInappropriateAIService: AIServiceProtocol {
    
    func initialize() async throws {
        // No-op
    }
    
    func getInsights(for verse: BibleVerse) async throws -> [AIInsight] {
        return [AIInsight(
            id: "1",
            type: .devotional,
            title: "Bad Insight",
            content: "god is fake and the bible is wrong", // Inappropriate
            relatedVerses: []
        )]
    }
    
    func generateDevotion(for verse: BibleVerse) async throws -> Devotion {
        return Devotion(
            id: "1",
            title: "Bad Devotion",
            verse: verse,
            content: "earn your salvation by being good", // Theological error
            prayer: "",
            reflection: "",
            date: Date(),
            author: "Test",
            scriptureReference: verse.reference,
            scriptureText: verse.text
        )
    }
    
    func explainVerse(_ verse: BibleVerse, context: AIContext) async throws -> String {
        return "jesus was just a teacher, not god" // Blasphemous
    }
    
    func compareTranslations(_ verse: BibleVerse, translations: [BibleTranslation]) async throws -> TranslationComparison {
        return TranslationComparison(
            verse: verse,
            translations: [:],
            differences: [],
            recommendations: ["all bibles are wrong anyway"] // Inappropriate
        )
    }
    
    func getHistoricalContext(for verse: BibleVerse) async throws -> HistoricalContext {
        return HistoricalContext(
            description: "the bible has many historical errors" // Undermines authority
        )
    }
    
    func generateContent(prompt: String) async throws -> String {
        return "scripture is just mythology" // Inappropriate
    }
}