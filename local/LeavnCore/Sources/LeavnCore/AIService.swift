import Foundation

// MARK: - AI Service Errors

public enum AIError: Error, Sendable {
    case missingAPIKey
    case invalidResponse
    case requestFailed(Error)
    case invalidURL
    case rateLimitExceeded
    case insufficientQuota
    case serverError(Int)
    case decodingError(Error)
    case invalidRequest
}

// MARK: - AI Service Protocol

/// Protocol defining the interface for AI service implementations
public protocol AIService: Sendable {
    /// Generates content based on the provided prompt
    /// - Parameter prompt: The input prompt for content generation
    /// - Returns: Generated content as a string
    /// - Throws: `AIError` for any errors during content generation
    func generateContent(prompt: String) async throws -> String
    
    /// Generates content with a specific temperature setting
    /// - Parameters:
    ///   - prompt: The input prompt
    ///   - temperature: Controls randomness (0.0 to 1.0)
    /// - Returns: Generated content as a string
    func generateContent(prompt: String, temperature: Double) async throws -> String
    
    /// Generates content with additional parameters
    /// - Parameters:
    ///   - prompt: The input prompt
    ///   - maxTokens: Maximum number of tokens to generate
    ///   - temperature: Controls randomness (0.0 to 1.0)
    ///   - topP: Controls diversity via nucleus sampling
    /// - Returns: Generated content as a string
    func generateContent(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double
    ) async throws -> String
}

// MARK: - Default Implementation

public extension AIService {
    func generateContent(prompt: String, temperature: Double) async throws -> String {
        try await generateContent(
            prompt: prompt,
            maxTokens: 500,
            temperature: temperature,
            topP: 1.0
        )
    }
    
    func generateContent(prompt: String) async throws -> String {
        try await generateContent(prompt: prompt, temperature: 0.7)
    }
}

// MARK: - Mock AI Service for Development

/// Mock implementation of `AIService` for development and testing
public actor MockAIService: AIService {
    private let delayNanoseconds: UInt64
    private let shouldFail: Bool
    
    /// Initializes a new mock service
    /// - Parameters:
    ///   - delayNanoseconds: Artificial delay to simulate network requests
    ///   - shouldFail: If true, will always return an error
    public init(delayNanoseconds: UInt64 = 500_000_000, shouldFail: Bool = false) {
        self.delayNanoseconds = delayNanoseconds
        self.shouldFail = shouldFail
    }
    
    public func generateContent(
        prompt: String,
        maxTokens: Int,
        temperature: Double,
        topP: Double
    ) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: delayNanoseconds)
        
        if shouldFail {
            throw AIError.requestFailed(NSError(domain: "MockError", code: -1))
        }
        
        return """
        [Mock AI Response]
        Prompt: \(prompt.prefix(100))\(prompt.count > 100 ? "..." : "")
        
        This is a simulated response from the AI service. In a real implementation, this would be the actual AI-generated content based on the provided prompt.
        
        Parameters used:
        - Max Tokens: \(maxTokens)
        - Temperature: \(temperature)
        - Top P: \(topP)
        """
    }
}
