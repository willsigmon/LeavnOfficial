import Foundation
import LeavnCore
import OSLog

/// Production AI Service for intelligent Bible insights
/// - Note: API key is required and must be provided securely during initialization.
///   Do not hardcode or bake the key into the app binary.
///   Consider providing the key from secure storage or environment configuration.
/// Production implementation of the `AIService` protocol that communicates with the OpenAI API
public actor ProductionAIService: AIServiceProtocol {
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.leavn3", category: "AI")
    private let cacheService: CacheServiceProtocol
    
    // API Configuration
    private let apiKey: String
    private let baseURL: URL
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let apiEndpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini" // Cost-effective model
    private let maxTokens = 500
    private let temperature = 0.7
    
    // Cache keys
    private let cachePrefix = "ai_cache"
    private let cacheDuration: TimeInterval = 86400 // 24 hours
    
    // Rate limiting
    private var requestCount = 0
    private let requestLimit = 100 // per day
    private var lastResetDate = Date()
    
    // MARK: - ServiceProtocol Conformance

    public func initialize() async throws {
        logger.info("🤖 Production AI Service initialized successfully.")
        // Health check could be added here in the future.
    }

    // MARK: - Initialization
    
    /// Creates a new instance of `ProductionAIService`
    /// - Parameters:
    ///   - apiKey: The OpenAI API key
    ///   - baseURL: Optional custom base URL (defaults to OpenAI's API)
    ///   - urlSession: Custom URLSession for testing (defaults to shared session)
    ///   - cacheService: The cache service to store AI results.
    public init(
        apiKey: String,
        baseURL: URL? = nil,
        urlSession: URLSession = .shared,
        cacheService: CacheServiceProtocol
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL ?? URL(string: "https://api.openai.com/v1")!
        self.urlSession = urlSession
        self.jsonDecoder = JSONDecoder()
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        self.cacheService = cacheService
    }
    

    
    // MARK: - AIServiceProtocol
    
    public func getInsights(for verse: BibleVerse) async throws -> [AIInsight] {
        let cacheKey = "\(cachePrefix)_insights_\(verse.bookId)_\(verse.chapter)_\(verse.verse)"
        
        // Check cache first
        if let cached: [AIInsight] = await cacheService.get(cacheKey, type: [AIInsight].self) {
            logger.debug("📦 Returning cached insights for \(verse.reference)")
            return cached
        }
        
        // Check rate limit
        guard await checkRateLimit() else {
            throw LeavnError.aiError(message: "Daily request limit exceeded")
        }
        
        // Generate insights
        let insights = try await generateInsights(for: verse)
        
        // Cache results
        let expirationDate = Date().addingTimeInterval(cacheDuration)
        await cacheService.set(cacheKey, value: insights, expirationDate: expirationDate)
        
        return insights
    }
    
    public func generateDevotion(for verse: BibleVerse) async throws -> Devotion {
        let cacheKey = "\(cachePrefix)_devotion_\(verse.bookId)_\(verse.chapter)_\(verse.verse)"
        
        // Check cache
        if let cached: Devotion = await cacheService.get(cacheKey, type: Devotion.self) {
            return cached
        }
        
        // Check rate limit
        guard await checkRateLimit() else {
            throw LeavnError.aiError(message: "Daily request limit exceeded")
        }
        
        // Generate devotion
        let prompt = """
        Create a short, meaningful devotion based on this Bible verse:
        "\(verse.text)" - \(verse.reference)
        
        Include:
        1. A devotional title
        2. Brief reflection (2-3 paragraphs)
        3. A short prayer
        4. A personal application thought
        
        Keep the tone warm, encouraging, and accessible.
        """
        
        let response = try await makeAIRequest(prompt: prompt)
        let devotion = try parseDevotionResponse(response, verse: verse)
        
        // Cache
        let expirationDate = Date().addingTimeInterval(cacheDuration)
        await cacheService.set(cacheKey, value: devotion, expirationDate: expirationDate)
        
        return devotion
    }
    
    public func explainVerse(_ verse: BibleVerse, context: AIContext) async throws -> String {
        let cacheKey = "\(cachePrefix)_explain_\(verse.bookId)_\(verse.chapter)_\(verse.verse)_\(context.preferredStyle ?? "general")"
        
        // Check cache
        if let cached: String = await cacheService.get(cacheKey, type: String.self) {
            return cached
        }
        
        // Check rate limit
        guard await checkRateLimit() else {
            throw LeavnError.aiError(message: "Daily request limit exceeded")
        }
        
        let contextPrompt: String
        switch context.preferredStyle?.lowercased() {
        case "historical":
            contextPrompt = "Explain the historical context and background of"
        case "theological":
            contextPrompt = "Explain the theological significance and meaning of"
        case "practical":
            contextPrompt = "Explain the practical application for modern life of"
        case "linguistic":
            contextPrompt = "Explain the original language and translation nuances of"
        default:
            contextPrompt = "Explain the meaning and significance of"
        }
        
        let prompt = """
        \(contextPrompt) this Bible verse:
        "\(verse.text)" - \(verse.reference)
        
        Keep the explanation clear, accurate, and accessible to a general audience.
        Maximum 3 paragraphs.
        """
        
        let response = try await makeAIRequest(prompt: prompt)
        let explanation = extractTextFromResponse(response)
        
        // Cache
        let expirationDate = Date().addingTimeInterval(cacheDuration)
        await cacheService.set(cacheKey, value: explanation, expirationDate: expirationDate)
        
        return explanation
    }
    
    public func compareTranslations(_ verse: BibleVerse, translations: [BibleTranslation]) async throws -> TranslationComparison {
        // For now, return a simple comparison
        // In production, this would analyze linguistic differences
        
        var translationTexts: [String: String] = [:]
        translationTexts[verse.translation] = verse.text
        
        return TranslationComparison(
            verse: verse,
            translations: translationTexts,
            differences: [
                "This translation emphasizes clarity and modern language",
                "Key theological terms are preserved from the original text"
            ],
            recommendations: [
                "For study: Use multiple translations to gain fuller understanding",
                "For memorization: Choose the translation that resonates most with you"
            ]
        )
    }
    
    public func getHistoricalContext(for verse: BibleVerse) async throws -> HistoricalContext {
        let cacheKey = "\(cachePrefix)_history_\(verse.bookId)_\(verse.chapter)"
        
        // Check cache
        if let cached: HistoricalContext = await cacheService.get(cacheKey, type: HistoricalContext.self) {
            return cached
        }
        
        // Check rate limit
        guard await checkRateLimit() else {
            throw LeavnError.aiError(message: "Daily request limit exceeded")
        }
        
        let prompt = """
        Provide brief historical context for \(verse.bookName) chapter \(verse.chapter):
        - Time period and date
        - Author and audience
        - Cultural and political background
        - Key historical events
        
        Keep it concise and factual.
        """
        
        let response = try await makeAIRequest(prompt: prompt)
        let description = extractTextFromResponse(response)
        
        let context = HistoricalContext(description: description)
        
        // Cache
        let expirationDate = Date().addingTimeInterval(cacheDuration)
        await cacheService.set(cacheKey, value: context, expirationDate: expirationDate)
        
        return context
    }
    
    // MARK: - Public New Method
    
    // MARK: - AIService Implementation
    
    public func generateContent(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            logger.critical("API Key is missing. AI Service cannot function.")
            throw AIError.missingAPIKey
        }
        
        // Check rate limit before proceeding
        guard await checkRateLimit() else {
            logger.warning("Daily AI request limit exceeded.")
            throw AIError.rateLimitExceeded
        }
        
        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": self.model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": self.maxTokens,
            "temperature": self.temperature
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            logger.debug("Sending AI request to endpoint: \(endpoint.absoluteString)")
            
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                logger.error("Invalid response from AI service: not an HTTPURLResponse.")
                throw AIError.invalidResponse
            }
            
            // Increment request count after a successful call
            await incrementRequestCount()
            
            switch httpResponse.statusCode {
            case 200...299:
                return try parseCompletionResponse(data: data)
            case 401:
                logger.error("AI request failed: Invalid API Key.")
                throw AIError.missingAPIKey
            case 429:
                logger.warning("AI request failed: Rate limit or quota exceeded.")
                throw AIError.rateLimitExceeded
            case 500...599:
                logger.error("AI service server error: \(httpResponse.statusCode)")
                throw AIError.serverError(httpResponse.statusCode)
            default:
                logger.error("AI request failed with status code: \(httpResponse.statusCode)")
                throw AIError.requestFailed(NSError(domain: "AIError", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Unhandled API error"]))
            }
        } catch {
            logger.error("An error occurred during the AI request: \(error.localizedDescription)")
            throw handleAPIError(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func parseCompletionResponse(data: Data) throws -> String {
        struct CompletionResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }
        
        do {
            let response = try jsonDecoder.decode(CompletionResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                logger.error("Failed to parse AI response: 'content' field missing.")
                throw AIError.invalidResponse
            }
            return content
        } catch let decodingError as DecodingError {
            logger.error("JSON decoding failed: \(decodingError)")
            throw AIError.decodingError(decodingError)
        }
    }
    
    private func handleAPIError(_ error: Error) -> AIError {
        if let aiError = error as? AIError {
            return aiError
        }
        
        if let urlError = error as? URLError {
            return .requestFailed(urlError)
        }
        
        return .requestFailed(error)
    }

    // MARK: - Rate Limiting
    
    private func checkRateLimit() async -> Bool {
        await resetDailyLimitIfNeeded()
        return requestCount < requestLimit
    }
    
    private func incrementRequestCount() async {
        requestCount += 1
        logger.debug("📊 AI requests today: \(self.requestCount)/\(self.requestLimit)")
    }
    
    private func resetDailyLimitIfNeeded() async {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastResetDate) {
            requestCount = 0
            lastResetDate = Date()
            logger.info("🔄 Reset daily AI request limit")
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func makeAIRequest(prompt: String) async throws -> Data {
        let endpoint = baseURL.appendingPathComponent("chat/completions")
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": maxTokens,
            "temperature": temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LeavnError.aiError(message: "Invalid response")
        }
        
        guard httpResponse.statusCode == 200 else {
            throw LeavnError.aiError(message: "API request failed with status: \(httpResponse.statusCode)")
        }
        
        await incrementRequestCount()
        return data
    }
    
    private func extractTextFromResponse(_ data: Data) -> String {
        do {
            let response = try jsonDecoder.decode(AIResponse.self, from: data)
            return response.choices.first?.message.content ?? "No response generated"
        } catch {
            logger.error("Failed to decode AI response: \(error)")
            return "Error processing AI response"
        }
    }
    
    private func generateInsights(for verse: BibleVerse) async throws -> [AIInsight] {
        let prompt = """
        Provide 3-4 spiritual insights for \(verse.reference): "\(verse.text)"
        
        For each insight, provide:
        1. A clear, practical spiritual lesson
        2. How it applies to daily Christian life
        3. A brief supporting thought or cross-reference
        
        Keep each insight concise but meaningful.
        """
        
        let response = try await makeAIRequest(prompt: prompt)
        let content = extractTextFromResponse(response)
        
        // Parse the response into insights
        // For now, create a simple parsing that splits by numbers or new lines
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        var insights: [AIInsight] = []
        var currentInsight = ""
        
        for line in lines {
            if line.hasPrefix("1.") || line.hasPrefix("2.") || line.hasPrefix("3.") || line.hasPrefix("4.") {
                if !currentInsight.isEmpty {
                    let insightTitle = currentInsight.components(separatedBy: ".").first?.trimmingCharacters(in: .whitespaces) ?? "Insight"
                    let insightContent = currentInsight.components(separatedBy: ".").dropFirst().joined(separator: ".").trimmingCharacters(in: .whitespaces)
                    
                    insights.append(AIInsight(
                        id: UUID().uuidString,
                        type: .devotional,
                        title: insightTitle,
                        content: insightContent,
                        relatedVerses: [verse]
                    ))
                }
                currentInsight = String(line.dropFirst(2)).trimmingCharacters(in: .whitespaces)
            } else {
                currentInsight += " " + line
            }
        }
        
        // Add the last insight
        if !currentInsight.isEmpty {
            let insightTitle = currentInsight.components(separatedBy: ".").first?.trimmingCharacters(in: .whitespaces) ?? "Insight"
            let insightContent = currentInsight.components(separatedBy: ".").dropFirst().joined(separator: ".").trimmingCharacters(in: .whitespaces)
            
            insights.append(AIInsight(
                id: UUID().uuidString,
                type: .devotional,
                title: insightTitle,
                content: insightContent,
                relatedVerses: [verse]
            ))
        }
        
        return insights.isEmpty ? [AIInsight(
            id: UUID().uuidString,
            type: .devotional,
            title: "Insight",
            content: content,
            relatedVerses: [verse]
        )] : insights
    }
    
    private func parseDevotionResponse(_ data: Data, verse: BibleVerse) throws -> Devotion {
        let content = extractTextFromResponse(data)
        
        // Simple parsing - in production you might want more sophisticated parsing
        let lines = content.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        let title = lines.first ?? "Daily Devotion"
        let body = lines.dropFirst().joined(separator: "\n\n")
        
        return Devotion(
            id: UUID().uuidString,
            title: title,
            verse: verse,
            content: body.isEmpty ? content : body,
            prayer: "",
            reflection: "",
            date: Date(),
            author: "AI-Generated",
            scriptureReference: verse.reference,
            scriptureText: verse.text
        )
    }
}

// MARK: - Response Models

private struct AIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}
