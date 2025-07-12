import SwiftUI
import LeavnCore
import LeavnServices
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var dailyVerse: BibleVerse?
    @Published var isLoadingDailyVerse = false
    @Published var dailyVerseError: String?
    
    @Published var lifeSituationText = ""
    @Published var analyzedSituation: LifeSituation?
    @Published var isAnalyzingSituation = false
    @Published var situationError: String?
    
    @Published var suggestedVerses: [VerseRecommendation] = []
    @Published var emotionalJourney: [LifeSituation] = []
    
    private var bibleService: BibleServiceProtocol?
    private var lifeSituationsEngine: LifeSituationsEngineProtocol?
    private var cancellables = Set<AnyCancellable>()
    private var isInitialized = false
    
    init(
        bibleService: BibleServiceProtocol? = nil,
        lifeSituationsEngine: LifeSituationsEngineProtocol? = nil
    ) {
        // Don't access DIContainer in init - wait for explicit initialization
        if let bibleService = bibleService, let lifeSituationsEngine = lifeSituationsEngine {
            self.bibleService = bibleService
            self.lifeSituationsEngine = lifeSituationsEngine
            self.isInitialized = true
            loadDailyVerse()
            loadEmotionalJourney()
        }
    }
    
    func initializeServices() async {
        guard !isInitialized else { return }
        
        await DIContainer.shared.waitForInitialization()
        
        self.bibleService = DIContainer.shared.requireBibleService()
        self.lifeSituationsEngine = DIContainer.shared.requireLifeSituationsEngine()
        self.isInitialized = true
        
        loadDailyVerse()
        loadEmotionalJourney()
    }
    
    func loadDailyVerse() {
        guard let bibleService = bibleService else {
            dailyVerseError = "Bible service not initialized"
            return
        }
        
        isLoadingDailyVerse = true
        dailyVerseError = nil
        
        Task {
            do {
                // Get a verse based on day of year for variety
                let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
                let verses = [
                    ("John", 3, 16),
                    ("Philippians", 4, 13),
                    ("Jeremiah", 29, 11),
                    ("Proverbs", 3, 5),
                    ("Isaiah", 40, 31),
                    ("Romans", 8, 28),
                    ("Psalm", 23, 1),
                    ("Matthew", 6, 33),
                    ("1 Corinthians", 13, 4),
                    ("Ephesians", 2, 8)
                ]
                let verseIndex = (dayOfYear - 1) % verses.count
                let (book, chapter, verseNum) = verses[verseIndex]
                
                let verse = try await bibleService.getVerse(
                    book: book,
                    chapter: chapter,
                    verse: verseNum,
                    translation: .kjv
                )
                
                await MainActor.run {
                    self.dailyVerse = verse
                    self.isLoadingDailyVerse = false
                }
            } catch {
                await MainActor.run {
                    self.dailyVerseError = error.localizedDescription
                    self.isLoadingDailyVerse = false
                }
            }
        }
    }
    
    func analyzeSituation() {
        guard !lifeSituationText.isEmpty else { return }
        guard let lifeSituationsEngine = lifeSituationsEngine else {
            situationError = "Life situations service not initialized"
            return
        }
        
        isAnalyzingSituation = true
        situationError = nil
        
        Task {
            let analyzed = await lifeSituationsEngine.analyzeSituation(lifeSituationText)
            let verses = await lifeSituationsEngine.getVersesForMood(analyzed.detectedEmotions.first ?? .peace)
            
            await MainActor.run {
                self.analyzedSituation = analyzed
                self.suggestedVerses = verses.map { $0 }
                self.isAnalyzingSituation = false
                
                // Clear the text after successful analysis
                self.lifeSituationText = ""
                
                // Reload journey to include new entry
                self.loadEmotionalJourney()
            }
        }
    }
    
    func loadEmotionalJourney() {
        guard let lifeSituationsEngine = lifeSituationsEngine else { return }
        
        Task {
            emotionalJourney = await lifeSituationsEngine.getEmotionalJourney()
        }
    }
    
    func clearAnalysis() {
        analyzedSituation = nil
        suggestedVerses = []
        situationError = nil
    }
}

