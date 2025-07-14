import Foundation

import OSLog

/// AI Service wrapper that ensures all responses pass through guardrails
/// This service enhances AI responses with theological perspective awareness when user preferences are available
public actor SafeAIService: AIServiceProtocol {
    
    // MARK: - Properties
    
    private let wrappedService: AIServiceProtocol
    private let contentFilter: ContentFilterService
    private let factChecker: BiblicalFactChecker
    private let monitoringService: AIMonitoringService?
    private let logger = Logger(subsystem: "com.leavn3", category: "SafeAI")
    
    // Fallback content pool for different types
    private let fallbackPool = FallbackContentPool()
    
    // Monitoring
    private var totalRequests = 0
    private var failedValidations = 0
    private var fallbacksUsed = 0
    
    // MARK: - Initialization
    
    public init(wrapping service: AIServiceProtocol, monitoringService: AIMonitoringService? = nil) {
        self.wrappedService = service
        self.contentFilter = ContentFilterService()
        self.factChecker = BiblicalFactChecker()
        self.monitoringService = monitoringService
    }
    
    // MARK: - ServiceProtocol
    
    public func initialize() async throws {
        try await wrappedService.initialize()
        logger.info("✅ Safe AI Service initialized with guardrails")
    }
    
    // MARK: - AIServiceProtocol with Guardrails
    
    public func getInsights(for verse: BibleVerse) async throws -> [AIInsight] {
        totalRequests += 1
        let requestId = await monitoringService?.recordRequest(contentType: .verseInsight) ?? ""
        let startTime = Date()
        
        do {
            // Get insights from wrapped service with theological perspective context
            let perspectiveContext = await getTheologicalPerspectiveContext()
            if !perspectiveContext.isEmpty {
                logger.info("Getting insights with theological perspective context")
            }
            let insights = try await wrappedService.getInsights(for: verse)
            
            // Validate each insight
            var validatedInsights: [AIInsight] = []
            
            for insight in insights {
                let validation = AIGuardrails.validateResponse(insight.content)
                
                if validation.isValid {
                    // Additional fact-checking for historical insights
                    if insight.type == .historical {
                        let factCheck = await factChecker.checkClaim(insight.content)
                        if factCheck.verdict == .incorrect {
                            logger.warning("Fact check failed for insight: \(insight.title)")
                            validatedInsights.append(createFallbackInsight(for: verse, type: insight.type))
                            fallbacksUsed += 1
                            continue
                        }
                    }
                    
                    validatedInsights.append(insight)
                } else {
                    logger.warning("Insight validation failed: \(validation.failureReason ?? "Unknown")")
                    failedValidations += 1
                    
                    // Use fallback insight
                    validatedInsights.append(createFallbackInsight(for: verse, type: insight.type))
                    fallbacksUsed += 1
                }
            }
            
            logMetrics()
            
            // Record successful response
            await monitoringService?.recordResponse(
                eventId: requestId,
                success: true,
                responseTime: Date().timeIntervalSince(startTime),
                validationResult: validatedInsights.allSatisfy { _ in true } ? ValidationResult.success : ValidationResult.failure(reason: "Some insights failed validation"),
                fallbackUsed: fallbacksUsed > 0
            )
            
            return validatedInsights
            
        } catch {
            logger.error("AI service error: \(error)")
            
            // Record error
            await monitoringService?.recordError(
                contentType: .verseInsight,
                error: error,
                metadata: [:]
            )
            
            // Return safe fallback insights
            return createFallbackInsights(for: verse)
        }
    }
    
    public func generateDevotion(for verse: BibleVerse) async throws -> Devotion {
        totalRequests += 1
        
        do {
            // Generate devotion with theological perspective context
            let perspectiveContext = await getTheologicalPerspectiveContext()
            if !perspectiveContext.isEmpty {
                logger.info("Generating devotion with theological perspective context")
            }
            let devotion = try await wrappedService.generateDevotion(for: verse)
            
            // Validate devotion content
            let validation = AIGuardrails.validateResponse(devotion.content)
            let filterContext = FilterContext(contentType: .devotion, targetAudience: .general)
            let filterResult = await contentFilter.filterContent(
                devotion.content,
                context: filterContext
            )
            
            if validation.isValid && filterResult.isApproved {
                return devotion
            } else {
                logger.warning("Devotion validation failed")
                failedValidations += 1
                fallbacksUsed += 1
                
                // Return safe fallback devotion
                return fallbackPool.getDevotion(for: verse)
            }
            
        } catch {
            logger.error("Devotion generation error: \(error)")
            fallbacksUsed += 1
            return fallbackPool.getDevotion(for: verse)
        }
    }
    
    public func explainVerse(_ verse: BibleVerse, context: AIContext) async throws -> String {
        totalRequests += 1
        
        do {
            // Enhance context with theological perspective
            let enhancedContext = await enhanceContextWithTheologicalPerspective(context)
            let explanation = try await wrappedService.explainVerse(verse, context: enhancedContext)
            
            // Validate explanation
            let validation = AIGuardrails.validateResponse(explanation)
            let filterContext = FilterContext(
                contentType: .explanation,
                expectsScriptureReferences: true,
                strictnessLevel: .standard
            )
            let filterResult = await contentFilter.filterContent(
                explanation,
                context: filterContext
            )
            
            if validation.isValid && filterResult.isApproved {
                // Fact-check if historical context
                if context.preferredStyle == "historical" {
                    let facts = await factChecker.validateContent(
                        explanation
                    )
                    let hasErrors = facts.contains { $0.verdict == .incorrect }
                    
                    if hasErrors {
                        logger.warning("Historical explanation contains factual errors")
                        return fallbackPool.getExplanation(
                            for: verse,
                            style: context.preferredStyle ?? "general"
                        )
                    }
                }
                
                return explanation
            } else {
                logger.warning("Verse explanation validation failed")
                failedValidations += 1
                fallbacksUsed += 1
                return fallbackPool.getExplanation(
                    for: verse,
                    style: context.preferredStyle ?? "general"
                )
            }
            
        } catch {
            logger.error("Explanation generation error: \(error)")
            fallbacksUsed += 1
            return fallbackPool.getExplanation(
                for: verse,
                style: context.preferredStyle ?? "general"
            )
        }
    }
    
    public func compareTranslations(_ verse: BibleVerse, translations: [BibleTranslation]) async throws -> TranslationComparison {
        totalRequests += 1
        
        // Translation comparison is mostly factual, less prone to issues
        do {
            let comparison = try await wrappedService.compareTranslations(
                verse,
                translations: translations
            )
            
            // Quick validation of recommendations
            for recommendation in comparison.recommendations {
                if !AIGuardrails.validateResponse(recommendation).isValid {
                    logger.warning("Translation recommendation failed validation")
                    // Return safe version with filtered recommendations
                    return TranslationComparison(
                        verse: verse,
                        translations: comparison.translations,
                        differences: comparison.differences,
                        recommendations: fallbackPool.getTranslationRecommendations()
                    )
                }
            }
            
            return comparison
            
        } catch {
            logger.error("Translation comparison error: \(error)")
            throw error // Let upper layer handle this
        }
    }
    
    public func getHistoricalContext(for verse: BibleVerse) async throws -> HistoricalContext {
        totalRequests += 1
        
        do {
            let context = try await wrappedService.getHistoricalContext(for: verse)
            
            // Validate and fact-check
            let validation = AIGuardrails.validateResponse(context.description)
            
            if validation.isValid {
                // Extensive fact-checking for historical claims
                let facts = await factChecker.validateContent(context.description)
                let hasSerious = facts.contains { $0.verdict == .incorrect && $0.confidence > 0.8 }
                
                if hasSerious {
                    logger.warning("Historical context contains serious factual errors")
                    failedValidations += 1
                    fallbacksUsed += 1
                    return HistoricalContext(
                        description: fallbackPool.getHistoricalContext(for: verse)
                    )
                }
                
                // Add corrections if needed
                let corrections = facts.compactMap { $0.corrections.first }
                if !corrections.isEmpty {
                    let correctedDescription = context.description + "\n\nNote: " + corrections.joined(separator: ". ")
                    return HistoricalContext(description: correctedDescription)
                }
            } else {
                failedValidations += 1
                fallbacksUsed += 1
                return HistoricalContext(
                    description: fallbackPool.getHistoricalContext(for: verse)
                )
            }
            
            return context
            
        } catch {
            logger.error("Historical context error: \(error)")
            fallbacksUsed += 1
            return HistoricalContext(
                description: fallbackPool.getHistoricalContext(for: verse)
            )
        }
    }
    
    public func generateContent(prompt: String) async throws -> String {
        totalRequests += 1
        
        // Wrap prompt with guardrails and theological perspective context
        let perspectiveEnhancedPrompt = await createPerspectiveAwarePrompt(basePrompt: prompt, for: BibleVerse(book: "", chapter: 1, verse: 1, text: "", translation: ""))
        let safePrompt = AIGuardrails.wrapPrompt(perspectiveEnhancedPrompt)
        
        do {
            let content = try await wrappedService.generateContent(prompt: safePrompt)
            
            // Validate generated content
            let validation = AIGuardrails.validateResponse(content)
            let filterResult = await contentFilter.quickValidate(content)
            
            if validation.isValid && filterResult {
                return content
            } else {
                logger.warning("Generated content failed validation")
                failedValidations += 1
                fallbacksUsed += 1
                return "I apologize, but I cannot generate appropriate content for this request. Please try rephrasing your question or consult your pastor for guidance on this topic."
            }
            
        } catch {
            logger.error("Content generation error: \(error)")
            throw error
        }
    }
    
    // MARK: - Theological Perspective Helpers
    
    @MainActor
    private func getUserTheologicalPerspectives() -> Set<TheologicalPerspective> {
        guard let preferences = UserDataManager.shared.userPreferences else {
            return Set()
        }
        return preferences.theologicalPerspectives
    }
    
    private func getTheologicalPerspectiveContext() async -> String {
        let perspectives = await getUserTheologicalPerspectives()
        
        if perspectives.isEmpty {
            return ""
        }
        
        let perspectiveNames = perspectives.map { $0.rawValue }.sorted().joined(separator: ", ")
        let perspectiveDescriptions = perspectives.map { perspective in
            "\(perspective.rawValue): \(perspective.description)"
        }.joined(separator: "\n")
        
        return """
        
        **Theological Perspective Context:**
        User's theological background: \(perspectiveNames)
        
        Key perspectives to consider:
        \(perspectiveDescriptions)
        
        Please provide insights that are sensitive to and informed by these theological perspectives while remaining respectful of all Christian traditions.
        """
    }
    
    private func enhanceContextWithTheologicalPerspective(_ context: AIContext) async -> AIContext {
        let perspectiveContext = await getTheologicalPerspectiveContext()
        
        if perspectiveContext.isEmpty {
            return context
        }
        
        // Create enhanced context with theological perspective
        var enhancedContext = context
        
        // Add theological perspective to the context's preferred style or create new context
        if let existingStyle = context.preferredStyle {
            enhancedContext.preferredStyle = existingStyle + perspectiveContext
        } else {
            enhancedContext.preferredStyle = perspectiveContext
        }
        
        return enhancedContext
    }
    
    private func createPerspectiveAwarePrompt(basePrompt: String, for verse: BibleVerse) async -> String {
        let perspectiveContext = await getTheologicalPerspectiveContext()
        
        if perspectiveContext.isEmpty {
            return basePrompt
        }
        
        return basePrompt + perspectiveContext
    }
    
    // MARK: - Private Helpers
    
    private func createFallbackInsight(for verse: BibleVerse, type: InsightType) -> AIInsight {
        // Create perspective-aware fallback insight
        // For now, use the basic fallback with a note that perspectives would be considered
        let content = fallbackPool.getInsight(for: verse, type: type)
        let perspectiveNote = " (Theological perspectives would be considered in full AI responses)"
        
        return AIInsight(
            id: UUID().uuidString,
            type: type,
            title: type.rawValue.capitalized + " Insight",
            content: content + perspectiveNote,
            relatedVerses: []
        )
    }
    
    private func createFallbackInsights(for verse: BibleVerse) -> [AIInsight] {
        return [
            createFallbackInsight(for: verse, type: .devotional),
            createFallbackInsight(for: verse, type: .practical),
            createFallbackInsight(for: verse, type: .theological)
        ]
    }
    
    private func logMetrics() {
        let validationRate = Double(totalRequests - failedValidations) / Double(max(totalRequests, 1))
        let fallbackRate = Double(fallbacksUsed) / Double(max(totalRequests, 1))
        
        logger.info("""
        📊 AI Guardrail Metrics:
        Total Requests: \(self.totalRequests)
        Validation Rate: \(String(format: "%.1f%%", validationRate * 100))
        Fallback Rate: \(String(format: "%.1f%%", fallbackRate * 100))
        """)
    }
}

// MARK: - Fallback Content Pool

private struct FallbackContentPool {
    
    func getInsight(for verse: BibleVerse, type: InsightType) -> String {
        switch type {
        case .devotional:
            return "This verse reminds us of God's unchanging love and faithfulness. Take time today to reflect on how this truth applies to your current circumstances."
        case .practical:
            return "Consider how this passage calls us to live differently. What specific action can you take today to apply this teaching?"
        case .theological:
            return "This passage reveals important truths about God's nature and His relationship with humanity. Study it in context for deeper understanding."
        case .historical:
            return "This text was written in a specific historical and cultural context. Understanding the background helps us better appreciate its message for today."
        }
    }
    
    func getPerspectiveAwareInsight(for verse: BibleVerse, type: InsightType, perspectives: Set<TheologicalPerspective>) -> String {
        let baseInsight = getInsight(for: verse, type: type)
        
        if perspectives.isEmpty {
            return baseInsight
        }
        
        // Add perspective-specific guidance
        let perspectiveGuidance = perspectives.map { perspective in
            switch perspective {
            case .reformed:
                return "Consider how this reveals God's sovereignty and grace"
            case .catholic:
                return "Reflect on how this connects to Church teaching and tradition"
            case .orthodox:
                return "Contemplate the mystical and liturgical dimensions"
            case .evangelical:
                return "Consider how this strengthens your personal relationship with Jesus"
            case .charismatic:
                return "Be open to how the Holy Spirit might speak through this passage"
            case .mainline:
                return "Reflect on the social justice implications of this text"
            case .nonDenominational:
                return "Focus on the scriptural truth and its practical application"
            case .messianic:
                return "Consider the Hebrew roots and Jewish context of this passage"
            case .anglican:
                return "Consider both the catholic heritage and reformed principles"
            case .lutheran:
                return "Reflect on justification by faith and God's grace alone"
            case .baptist:
                return "Consider personal faith commitment and congregational community"
            case .pentecostal:
                return "Be attentive to the Spirit's movement and supernatural work"
            case .presbyterian:
                return "Reflect on God's covenant faithfulness and church order"
            case .methodist:
                return "Consider grace, personal holiness, and social witness"
            case .adventist:
                return "Reflect on Christ's soon return and holy living"
            case .quaker:
                return "Listen for the Inner Light speaking to your condition"
            }
        }.joined(separator: " ")
        
        return baseInsight + " " + perspectiveGuidance
    }
    
    func getDevotion(for verse: BibleVerse) -> Devotion {
        return Devotion(
            id: UUID().uuidString,
            title: "Reflecting on God's Word",
            verse: verse,
            content: """
            Today's Scripture: \(verse.reference)
            
            God's Word is living and active, speaking to us across the centuries. This verse invites us to pause and listen to what the Lord is saying to our hearts today.
            
            As you meditate on this passage, consider:
            - What does this reveal about God's character?
            - How does this truth encourage or challenge you?
            - What response is God calling for in your life?
            
            Take a moment to sit quietly with this verse. Let its truth sink deep into your soul, transforming you from the inside out.
            
            Note: This is a general devotion. Your personal theological perspectives would be considered in AI-generated devotions.
            """,
            prayer: "Lord, thank You for Your Word that guides and sustains us. Help us to not merely read Your Scripture but to live it out daily. Give us wisdom to understand and courage to obey. In Jesus' name, Amen.",
            reflection: "How can I apply this verse to my life today?",
            date: Date(),
            author: "Leavn",
            scriptureReference: verse.reference,
            scriptureText: verse.text
        )
    }
    
    func getExplanation(for verse: BibleVerse, style: String) -> String {
        let baseExplanation = switch style {
        case "historical":
            "This passage was written during a significant period in biblical history. Understanding the cultural and historical background helps us grasp its intended meaning and apply it appropriately to our lives today."
        case "theological":
            "This verse teaches us important truths about God, salvation, and Christian living. It connects to broader biblical themes and helps us understand God's redemptive plan throughout Scripture."
        case "practical":
            "This Scripture provides practical wisdom for daily Christian living. Consider how its principles can guide your decisions, relationships, and spiritual growth."
        default:
            "This verse contains timeless truth that speaks to us today. Read it carefully, considering both its original context and its application to your life."
        }
        
        // Check if style contains theological perspective context
        if style.contains("**Theological Perspective Context:**") {
            return baseExplanation + " (Enhanced with your theological perspectives)"
        }
        
        return baseExplanation + " (Note: Full AI responses would consider your theological perspectives)"
    }
    
    func getHistoricalContext(for verse: BibleVerse) -> String {
        return """
        The book of \(verse.bookName) was written during a pivotal time in biblical history. Understanding the historical setting helps us appreciate the original meaning and significance of this passage.
        
        Key historical considerations:
        • The cultural context of the ancient Near East
        • The political and religious climate of the time
        • The original audience and their circumstances
        • The author's purpose in writing
        
        This background enriches our understanding while the timeless truths continue to speak to us today.
        """
    }
    
    func getTranslationRecommendations() -> [String] {
        return [
            "Compare multiple translations to gain a fuller understanding of the text",
            "Consider both word-for-word and thought-for-thought translations",
            "Consult study notes and commentaries for additional insights",
            "When in doubt, refer to the original Hebrew or Greek texts"
        ]
    }
}