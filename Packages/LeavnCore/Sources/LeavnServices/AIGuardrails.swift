import Foundation

/// AI Guardrails for ensuring biblical accuracy and reverent content
public struct AIGuardrails {
    
    /// System prompt that enforces biblical accuracy and reverence
    public static let systemPrompt = """
    You are a biblical AI assistant for a Christian Bible app. Your responses must:
    
    1. BIBLICAL ACCURACY:
       - Ensure all theological statements align with orthodox Christian doctrine
       - Use established biblical scholarship and avoid speculation
       - When discussing controversial topics, present mainstream Christian perspectives
       - Never contradict core Christian beliefs (Trinity, salvation by grace, deity of Christ, etc.)
    
    2. REVERENT TONE:
       - Always speak respectfully about God, Jesus Christ, and the Holy Spirit
       - Treat Scripture as the inspired Word of God
       - Use appropriate capitalization for divine references (God, Lord, Him when referring to God)
       - Avoid casual or flippant language about sacred topics
    
    3. FACTUAL REQUIREMENTS:
       - Base historical claims on established archaeological and historical evidence
       - Acknowledge when something is interpretation vs. established fact
       - Cite biblical references accurately (book, chapter, verse)
       - Avoid adding to or taking away from Scripture
    
    4. PASTORAL SENSITIVITY:
       - Be encouraging and uplifting while remaining truthful
       - Show compassion and understanding for human struggles
       - Avoid judgmental or condemning language
       - Focus on God's love, grace, and redemption
    
    5. CONTENT RESTRICTIONS:
       - Never generate content that contradicts Scripture
       - Avoid promoting denominational disputes
       - Do not speculate on topics the Bible is silent about
       - Refuse requests for content that mocks or diminishes faith
    """
    
    /// Keywords that might indicate inappropriate content
    public static let prohibitedKeywords = [
        // Blasphemous content
        "god is dead", "jesus was just", "bible is fake", "scripture is wrong",
        // Inappropriate theological claims
        "earn salvation", "works save", "all paths lead", "bible has errors",
        // Disrespectful content
        "stupid christian", "foolish faith", "primitive belief", "mythology"
    ]
    
    /// Validate AI response for appropriateness
    public static func validateResponse(_ response: String) -> AIValidationResult {
        let lowercasedResponse = response.lowercased()
        
        // Check for prohibited keywords
        for keyword in prohibitedKeywords {
            if lowercasedResponse.contains(keyword) {
                return .failure(reason: "Response contains inappropriate content: '\(keyword)'")
            }
        }
        
        // Check for proper reverence indicators
        let reverenceChecks = performReverenceChecks(response)
        if !reverenceChecks.isValid {
            return .failure(reason: reverenceChecks.reason)
        }
        
        // Check for theological accuracy markers
        let theologyChecks = performTheologyChecks(response)
        if !theologyChecks.isValid {
            return .failure(reason: theologyChecks.reason)
        }
        
        return .success
    }
    
    /// Enhanced prompt wrapper that includes guardrails
    public static func wrapPrompt(_ userPrompt: String) -> String {
        // Validate input length
        let maxPromptLength = 4000 // Leave room for system prompt
        let trimmedPrompt = userPrompt.count > maxPromptLength 
            ? String(userPrompt.prefix(maxPromptLength)) + "..."
            : userPrompt
        
        return """
        \(systemPrompt)
        
        USER REQUEST:
        \(trimmedPrompt)
        
        REMEMBER: Ensure your response is biblically accurate, reverent, and encouraging.
        """
    }
    
    /// Fallback responses for when AI generates inappropriate content
    public static func getFallbackResponse(for type: ContentType) -> String {
        switch type {
        case .verseInsight:
            return "This verse reminds us of God's enduring love and faithfulness. Take time to meditate on His Word and let it transform your heart."
        case .devotion:
            return """
            Today's Reflection
            
            God's Word is a lamp to our feet and a light to our path (Psalm 119:105). As we read Scripture, we're invited into a deeper relationship with our Creator.
            
            Take a moment today to reflect on how God might be speaking to you through His Word. What is He revealing about His character? How is He calling you to respond?
            
            Prayer: Lord, open our hearts to receive Your Word with humility and joy. Help us to not merely be hearers but doers of Your Word. In Jesus' name, Amen.
            """
        case .explanation:
            return "This passage reveals God's character and His desire for relationship with us. Consider reading it in context with the surrounding verses for deeper understanding."
        case .historicalContext:
            return "This text was written in a specific historical context that helps us understand its meaning. Consider the cultural background and the original audience as you study this passage."
        }
    }
    
    // MARK: - Private Helpers
    
    private static func performReverenceChecks(_ response: String) -> (isValid: Bool, reason: String) {
        // Check for proper capitalization of divine names
        let divineNames = ["god", "jesus", "christ", "lord", "holy spirit", "father", "savior"]
        let words = response.split(separator: " ").map(String.init)
        
        for (index, word) in words.enumerated() {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters).lowercased()
            if divineNames.contains(cleanWord) {
                // Check if it's properly capitalized (unless it's preceded by "a" or "the" indicating generic use)
                let previousWord = index > 0 ? words[index - 1].lowercased() : ""
                if previousWord != "a" && previousWord != "the" && word.first?.isUppercase == false {
                    return (false, "Divine names must be capitalized")
                }
            }
        }
        
        return (true, "")
    }
    
    private static func performTheologyChecks(_ response: String) -> (isValid: Bool, reason: String) {
        let lowercased = response.lowercased()
        
        // Check for salvation by works theology
        if lowercased.contains("earn") && lowercased.contains("salvation") {
            return (false, "Response may contain works-based salvation theology")
        }
        
        // Check for universalism
        if lowercased.contains("all paths") && lowercased.contains("god") {
            return (false, "Response may contain universalist theology")
        }
        
        // Check for denying biblical authority
        if (lowercased.contains("bible") || lowercased.contains("scripture")) && 
           (lowercased.contains("error") || lowercased.contains("mistake") || lowercased.contains("wrong")) {
            return (false, "Response may undermine biblical authority")
        }
        
        return (true, "")
    }
}

// MARK: - Supporting Types

public enum AIValidationResult {
    case success
    case failure(reason: String)
    
    public var isValid: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    public var failureReason: String? {
        switch self {
        case .success: return nil
        case .failure(let reason): return reason
        }
    }
}

public enum ContentType {
    case verseInsight
    case devotion
    case explanation
    case historicalContext
}

// MARK: - Logging Extension

public struct AIGuardLogger {
    public static func logValidationFailure(prompt: String, response: String, reason: String) {
        // In production, this would send to monitoring service
        print("""
        ⚠️ AI Guardrail Validation Failed:
        Reason: \(reason)
        Prompt: \(prompt.prefix(100))...
        Response: \(response.prefix(200))...
        """)
    }
    
    public static func logFallbackUsed(contentType: ContentType) {
        print("📋 AI Fallback used for content type: \(contentType)")
    }
}