import Foundation
import LeavnCore
import SwiftUI

// TODO (Holistic IlluminateService Upgrades):
// [ ] Unify IlluminateInsight with AIInsight for model consistency
// [ ] Propagate errors instead of swallowing/printing (remove silent nil returns)
// [ ] Replace random cache eviction with LRU eviction
// [ ] Extract prompt templates for maintainability
// [ ] Add robust AI output parsing (prefer JSON)
// [ ] Add structured logging for AI/caching events
// [ ] Add unit/integration test hooks (suggest Swift Testing macros)
// [ ] Prepare for advanced theme analysis (future NLP)
// [ ] Add dependency injection for all services
// [ ] Improve UX hooks for error/loading/reporting

// Begin enacting these changes below...

// MARK: - Illuminate Service
// AI-powered biblical insights with visual effects

public actor IlluminateService {
    
    // MARK: - Types
    
    // Renamed local enum to avoid confusion with BibleModels.InsightType
    public enum LocalInsightType: String, CaseIterable {
        case historical = "historical"
        case theological = "theological"
        case practical = "practical"
        case cultural = "cultural"
        case linguistic = "linguistic"
        case devotional = "devotional"
        
        var icon: String {
            switch self {
            case .historical: return "clock.arrow.circlepath"
            case .theological: return "book.closed.fill"
            case .practical: return "lightbulb.fill"
            case .cultural: return "globe"
            case .linguistic: return "character.book.closed"
            case .devotional: return "heart.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .historical: return .brown
            case .theological: return .purple
            case .practical: return .orange
            case .cultural: return .blue
            case .linguistic: return .green
            case .devotional: return .pink
            }
        }
    }
    
    // Mapping VisualEffect to AIInsight if needed:
    public enum VisualEffect {
        case glow
        case sparkle
        case pulse
        case shimmer
        case ripple
    }
    
    // Using AIInsight from BibleModels.swift instead of IlluminateInsight
    // Assuming AIInsight has properties: id: String, type: InsightType, title: String, content: String, relatedVerses: [BibleVerse]
    // Since visualEffect is not part of AIInsight, define a helper to get visualEffect from LocalInsightType
    
    private func visualEffect(for type: LocalInsightType) -> VisualEffect {
        switch type {
        case .historical: return .shimmer
        case .theological: return .glow
        case .practical: return .pulse
        case .cultural: return .ripple
        case .linguistic: return .sparkle
        case .devotional: return .glow
        }
    }
    
    // VerseTheme is already defined in LeavnCore/LibraryTypes.swift
    
    // MARK: - Properties
    
    private let aiService: AIServiceProtocol
    
    // Cache dictionary holding AIInsights per verse key
    private var cachedInsights: [String: [AIInsight]] = [:]
    
    // To implement LRU cache eviction, maintain usage order:
    private var cacheUsageOrder: [String] = []
    
    private var maxCacheSize = 100
    
    // Theme mappings for verses
    private let themeDatabase: [String: [VerseTheme]] = [
        "faith": [.faith],
        "love": [.love],
        "endurance": [.strength],
        "wisdom": [.wisdom]
    ]
    
    // MARK: - Prompt Templates
    
    private struct Prompts {
        static func historical(verse: BibleVerse) -> String {
            """
            Provide historical context for \(verse.reference):
            "\(verse.text)"
            
            Focus on: When was this written? What was happening at the time? Who was the audience?
            Keep it concise (2-3 sentences).
            """
        }
        
        static func theological(verse: BibleVerse) -> String {
            """
            Explain the theological significance of \(verse.reference):
            "\(verse.text)"
            
            What does this teach us about God, humanity, or salvation?
            Keep it concise (2-3 sentences).
            """
        }
        
        static func practical(verse: BibleVerse) -> String {
            """
            How can we apply \(verse.reference) to modern life?
            "\(verse.text)"
            
            Provide a practical, actionable insight.
            Keep it concise (2-3 sentences).
            """
        }
        
        static func storyMode(chapterTexts: String, mode: StoryMode) -> String {
            switch mode {
            case .standard:
                return """
                Rewrite this Bible chapter in clear, modern English while maintaining its meaning:
                
                \(chapterTexts)
                
                Make it easy to understand for contemporary readers.
                """
            case .kids:
                return """
                Rewrite this Bible chapter for children ages 6-10:
                
                \(chapterTexts)
                
                Use simple words, short sentences, and make it engaging for kids.
                Include appropriate emoji where helpful.
                """
            case .novelization:
                return """
                Transform this Bible chapter into a narrative story format:
                
                \(chapterTexts)
                
                Add descriptive details, dialogue, and narrative flow while staying true to the biblical account.
                Make it read like a compelling story.
                """
            }
        }
    }
    
    // MARK: - Initialization
    
    public init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }
    
    /// Public initializer for testing with dependency injection
    public init(aiService: AIServiceProtocol, maxCacheSize: Int = 100) {
        self.aiService = aiService
        self.maxCacheSize = maxCacheSize
    }
    
    // MARK: - Public Methods
    
    public func illuminateVerse(_ verse: BibleVerse, context: [BibleVerse]? = nil) async throws -> [AIInsight] {
        let cacheKey = "\(verse.bookName)-\(verse.chapter)-\(verse.verse)"
        if let cached = cachedInsights[cacheKey] {
            // Update usage order for LRU cache
            updateCacheUsage(for: cacheKey)
            print("🗂 [Cache Hit] IlluminateService for key: \(cacheKey)")
            // Insert hook for structured logging here
            return cached
        } else {
            print("⚡️ [Cache Miss] IlluminateService for key: \(cacheKey)")
            // Insert hook for structured logging here
        }
        
        var insights: [AIInsight] = []
        
        // Generate insights using AI, propagate errors instead of swallowing
        
        // Historical Context
        let historicalPrompt = Prompts.historical(verse: verse)
        let historicalInsight = try await generateInsight(prompt: historicalPrompt, type: .historical, verse: verse)
        insights.append(historicalInsight)
        
        // Theological Significance
        let theologicalPrompt = Prompts.theological(verse: verse)
        let theologicalInsight = try await generateInsight(prompt: theologicalPrompt, type: .theological, verse: verse)
        insights.append(theologicalInsight)
        
        // Practical Application
        let practicalPrompt = Prompts.practical(verse: verse)
        let practicalInsight = try await generateInsight(prompt: practicalPrompt, type: .practical, verse: verse)
        insights.append(practicalInsight)
        
        // Cache the insights with LRU management
        cachedInsights[cacheKey] = insights
        updateCacheUsage(for: cacheKey)
        enforceCacheLimit()
        
        // Insert hook for analytics/event tracking here
        
        return insights
    }
    
    public func getThemesForVerse(_ verse: BibleVerse) async -> [VerseTheme] {
        // TODO: Future NLP-based advanced theme analysis here (placeholder)
        let text = verse.text.lowercased()
        var themes: [VerseTheme] = []
        
        for (keyword, themeList) in themeDatabase {
            if text.contains(keyword) {
                themes.append(contentsOf: themeList)
            }
        }
        
        // Add default themes based on book
        switch verse.bookName.lowercased() {
        case "psalms":
            themes.append(.faith)
        case "proverbs":
            themes.append(.wisdom)
        case let gospel where ["matthew", "mark", "luke", "john"].contains(gospel):
            themes.append(.faith)
        default:
            break
        }
        
        // Return up to 5 unique themes
        return Array(Set(themes).prefix(5))
    }
    
    public func generateStoryMode(
        for chapter: [BibleVerse],
        mode: StoryMode
    ) async throws -> String {
        guard let _ = chapter.first else {
            throw NSError(domain: "IlluminateService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No verses provided"])
        }
        
        let _ = AIContext(
            preferredStyle: mode.rawValue
        )
        
        print("🤖 [AI Request] Generating story mode (\(mode.rawValue))")
        // Insert hook for structured logging, analytics
        
        let response = try await aiService.generateContent(prompt: Prompts.storyMode(chapterTexts: chapter.map(\.text).joined(separator: " "), mode: mode))
        
        // TODO: Parse AI output robustly (e.g., JSON) and validate
        
        return response
    }
    
    // MARK: - Private Methods
    
    private func generateInsight(
        prompt: String,
        type localType: LocalInsightType,
        verse: BibleVerse
    ) async throws -> AIInsight {
        // Propagate errors on failure, no silent catches
        print("🤖 [AI Request] Generating \(localType.rawValue) insight")
        // Insert hook for structured logging, analytics
        
        // Map our LocalInsightType to AIContext style
        let style: String
        switch localType {
        case .historical: style = "historical"
        case .theological: style = "theological"
        case .practical: style = "practical"
        case .devotional: style = "devotional"
        case .cultural: style = "cultural"
        case .linguistic: style = "linguistic"
        }
        
        let context = AIContext(preferredStyle: style)
        let content = try await aiService.explainVerse(verse, context: context)
        
        // TODO: Future enhancement to extract and resolve Bible references from AI content.
        // let referencedVerseStrings = extractBibleReferences(from: content)
        
        // Map our LocalInsightType to InsightType (from LeavnCore)
        // Strictly only supported cases: historical, theological, practical, devotional
        // For unsupported types (cultural, linguistic), map to .historical or .practical as fallback
        // Alternatively, could throw error if strictness is desired
        let mappedType: InsightType
        switch localType {
        case .historical:
            mappedType = .historical
        case .theological:
            mappedType = .theological
        case .practical:
            mappedType = .practical
        case .devotional:
            mappedType = .devotional
        case .cultural:
            mappedType = .historical // fallback mapping for now
        case .linguistic:
            mappedType = .practical // fallback mapping for now
        }
        
        // TODO: Convert referencedVerseStrings ([String]) to [BibleVerse] cross-references,
        // for now provide empty array.
        
        // Note: AIInsight initializer expects 'relatedVerses' label, NOT 'relevantVerses'.
        let insight = AIInsight(
            id: UUID().uuidString,
            type: mappedType,
            title: mappedType.rawValue.capitalized + " Insight",
            content: content,
            relatedVerses: [] // TODO: Resolve from referencedVerseStrings to actual BibleVerse
        )
        
        return insight
    }
    
    private func extractBibleReferences(from text: String) -> [String] {
        // Simple regex to find Bible references like "John 3:16" or "1 Corinthians 13:4-7"
        let pattern = #"(\d?\s*\w+)\s+(\d+):(\d+)(?:-(\d+))?"#
        let regex = try? NSRegularExpression(pattern: pattern)
        
        let matches = regex?.matches(
            in: text,
            range: NSRange(text.startIndex..., in: text)
        ) ?? []
        
        return matches.compactMap { match in
            guard let range = Range(match.range, in: text) else { return nil }
            return String(text[range])
        }
    }
    
    // MARK: - LRU Cache Helpers
    
    private func updateCacheUsage(for key: String) {
        if let index = cacheUsageOrder.firstIndex(of: key) {
            cacheUsageOrder.remove(at: index)
        }
        cacheUsageOrder.append(key)
    }
    
    private func enforceCacheLimit() {
        while cachedInsights.count > maxCacheSize {
            if let oldestKey = cacheUsageOrder.first {
                cachedInsights.removeValue(forKey: oldestKey)
                cacheUsageOrder.removeFirst()
                print("🗑 [Cache Evict] Removed least recently used cache for key: \(oldestKey)")
                // Insert hook for structured logging here
            } else {
                break
            }
        }
    }
}

// MARK: - Story Mode Types

public enum StoryMode: String, CaseIterable {
    case standard = "standard"
    case kids = "kids"
    case novelization = "novelization"
    
    var displayName: String {
        switch self {
        case .standard: return "Standard"
        case .kids: return "Kids"
        case .novelization: return "Novelization"
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "doc.text"
        case .kids: return "face.smiling"
        case .novelization: return "book.pages"
        }
    }
    
    var description: String {
        switch self {
        case .standard: return "Modern, easy-to-understand language"
        case .kids: return "Simple words and fun for children"
        case .novelization: return "Narrative story format"
        }
    }
}

