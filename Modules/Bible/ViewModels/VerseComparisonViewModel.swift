import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import Combine

/// ViewModel for AI-powered verse comparison across translations
@MainActor
public final class VerseComparisonViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public private(set) var translations: [VerseTranslation] = []
    @Published public private(set) var aiInsights: [AIInsight] = []
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    // MARK: - Dependencies
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private let supportedTranslations = ["ESV", "NIV", "NASB", "KJV", "MSG", "NLT"]
    
    // MARK: - Initialization
    public init(
        bibleService: BibleServiceProtocol? = nil,
        cacheService: CacheServiceProtocol? = nil,
        analyticsService: AnalyticsServiceProtocol? = nil
    ) {
        let container = DIContainer.shared
        self.bibleService = bibleService ?? container.requireBibleService()
        self.cacheService = cacheService ?? container.requireCacheService()
        self.analyticsService = analyticsService ?? container.resolve(AnalyticsServiceProtocol.self)
    }
    
    // MARK: - Public Methods
    
    public func loadComparisons(for verse: BibleVerse) async {
        isLoading = true
        error = nil
        
        // Initialize translations with loading state
        translations = supportedTranslations.compactMap { abbrev in
            guard abbrev != verse.translation else { return nil }
            return VerseTranslation(
                abbreviation: abbrev,
                name: translationName(for: abbrev),
                text: nil,
                isLoading: true,
                differenceHighlight: 0.0
            )
        }
        
        // Load translations concurrently
        await withTaskGroup(of: Void.self) { group in
            for index in translations.indices {
                group.addTask { [weak self] in
                    await self?.loadTranslation(at: index, for: verse)
                }
            }
            
            // Load AI insights
            group.addTask { [weak self] in
                await self?.loadAIInsights(for: verse)
            }
        }
        
        // Track the comparison view
        await analyticsService?.track(event: AnalyticsEvent(
            name: "verse_comparison_viewed",
            parameters: [
                "verse_id": verse.id,
                "book": verse.bookName,
                "chapter": "\(verse.chapter)",
                "verse": "\(verse.verse)",
                "translation": verse.translation
            ]
        ))
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    
    private func loadTranslation(at index: Int, for verse: BibleVerse) async {
        guard index < translations.count else { return }
        
        let translation = translations[index]
        
        do {
            guard let translationId = BibleTranslation.defaultTranslations.first(where: { $0.abbreviation == translation.abbreviation }) else {
                throw NSError(domain: "VerseComparisonError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Translation not found"])
            }
            
            let chapter = try await bibleService.getChapter(
                book: verse.bookId,
                chapter: verse.chapter,
                translation: translationId
            )
            
            if let translatedVerse = chapter.verses.first(where: { $0.verse == verse.verse }) {
                await MainActor.run {
                    self.translations[index] = VerseTranslation(
                        abbreviation: translation.abbreviation,
                        name: translation.name,
                        text: translatedVerse.text,
                        isLoading: false,
                        differenceHighlight: self.calculateDifference(
                            original: verse.text,
                            comparison: translatedVerse.text
                        )
                    )
                }
            }
        } catch {
            await MainActor.run {
                self.translations[index] = VerseTranslation(
                    abbreviation: translation.abbreviation,
                    name: translation.name,
                    text: "Translation unavailable",
                    isLoading: false,
                    differenceHighlight: 0.0
                )
            }
        }
    }
    
    private func loadAIInsights(for verse: BibleVerse) async {
        guard let aiService = container?.aiService else { return }
        
        do {
            let insights = try await aiService.generateInsights(for: verse)
            await MainActor.run {
                self.aiInsights = insights
            }
        } catch {
            // Fallback to sample insights if AI service fails
            await MainActor.run {
                self.aiInsights = mockInsights
            }
            
            // Track insight generation
            await analyticsService?.track(event: AnalyticsEvent(
                name: "ai_insights_generated",
                parameters: ["verse_id": verse.id, "insight_count": mockInsights.count]
            ))
        } catch {
            print("Failed to load AI insights: \(error)")
            // Don't show error to user for non-critical features
        }
    }
    
    // Historical context is now loaded as part of AI insights
    // This method is kept for backward compatibility
    private func loadHistoricalContext(for verse: BibleVerse) async {
        // No-op - historical context is now part of AI insights
    }
    
    private func calculateDifference(original: String, comparison: String) -> Double {
        // Simple difference calculation based on word overlap
        // In a production app, this would use more sophisticated NLP
        let originalWords = Set(original.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let comparisonWords = Set(comparison.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        let commonWords = originalWords.intersection(comparisonWords)
        let totalUniqueWords = originalWords.union(comparisonWords)
        
        return 1.0 - (Double(commonWords.count) / Double(totalUniqueWords.count))
    }
    
    private func translationName(for abbreviation: String) -> String {
        BibleTranslation.all.first { $0.abbreviation == abbreviation }?.name ?? abbreviation
    }
    
    private func generateSampleInsights(for verse: BibleVerse) -> [AIInsight] {
        // Sample insights for demonstration
        [
            AIInsight(
                type: .theological,
                title: "Central Theme",
                content: "This verse captures the essence of God's sacrificial love and the path to eternal life through faith."
            ),
            AIInsight(
                type: .historical,
                title: "Cultural Context",
                content: "The concept of 'giving' one's son would have resonated deeply with ancient audiences familiar with sacrificial practices."
            ),
            AIInsight(
                type: .practical,
                title: "Application",
                content: "This verse emphasizes the universality of God's love ('the world') and the simplicity of the faith response required."
            )
        ]
    }
}

// MARK: - Supporting Models

public struct VerseTranslation: Identifiable {
    public let id = UUID()
    public let abbreviation: String
    public let name: String
    public let text: String?
    public let isLoading: Bool
    public let differenceHighlight: Double
}

public struct HistoricalContext {
    public let description: String
    public let timeframe: String?
    public let culturalNotes: [String]
    
    public init(description: String, timeframe: String? = nil, culturalNotes: [String] = []) {
        self.description = description
        self.timeframe = timeframe
        self.culturalNotes = culturalNotes
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension VerseComparisonViewModel {
    static func preview() -> VerseComparisonViewModel {
        let viewModel = VerseComparisonViewModel()
        viewModel.translations = [
            VerseTranslation(
                abbreviation: "ESV",
                name: "English Standard Version",
                text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                isLoading: false,
                differenceHighlight: 0.2
            ),
            VerseTranslation(
                abbreviation: "MSG",
                name: "The Message",
                text: "This is how much God loved the world: He gave his Son, his one and only Son. And this is why: so that no one need be destroyed; by believing in him, anyone can have a whole and lasting life.",
                isLoading: false,
                differenceHighlight: 0.8
            )
        ]
        
        viewModel.aiInsights = [
            AIInsight(
                type: .theological,
                title: "Divine Love",
                content: "The Greek word 'agape' used here represents unconditional, sacrificial love."
            ),
            AIInsight(
                type: .practical,
                title: "Universal Scope",
                content: "The word 'world' (kosmos) emphasizes God's love extends to all humanity."
            )
        ]
        
        return viewModel
    }
}
#endif