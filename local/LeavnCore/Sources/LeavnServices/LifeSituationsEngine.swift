import Foundation
import LeavnCore
import NaturalLanguage
import SwiftUI

// MARK: - Life Situations Engine
// This is the crown jewel - emotional intelligence for biblical guidance

public actor LifeSituationsEngine: LifeSituationsEngineProtocol {
    
    // MARK: - Properties
    
    private let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass, .tokenType])
    private var emotionHistory: [LifeSituation] = []
    private let maxHistorySize = 100
    private let bibleService: BibleServiceProtocol
    private let cacheService: CacheServiceProtocol
    private var isInitialized = false
    
    // Emotion keyword mappings
    private let emotionKeywords: [EmotionalState: [String]] = [
        .joy: [
            "happy",
            "joyful",
            "excited",
            "blessed",
            "wonderful",
            "amazing",
            "grateful",
            "thankful",
            "blessed",
            "appreciate",
            "content",
            "satisfied",
            "good",
            "fine",
            "okay",
            "hopeful",
            "optimistic",
            "looking forward",
            "excited about"
        ],
        .peace: [
            "peaceful",
            "calm",
            "serene",
            "relaxed",
            "tranquil"
        ],
        .struggle: [
            "anxious",
            "nervous",
            "worried",
            "uneasy",
            "restless",
            "tense",
            "depressed",
            "hopeless",
            "down",
            "worthless",
            "empty",
            "angry",
            "mad",
            "furious",
            "frustrated",
            "irritated",
            "annoyed",
            "scared",
            "afraid",
            "terrified",
            "frightened",
            "fear",
            "lonely",
            "alone",
            "isolated",
            "disconnected",
            "miss",
            "overwhelmed",
            "too much",
            "can't handle",
            "drowning",
            "sad",
            "unhappy",
            "crying",
            "tears",
            "heartbroken",
            "stressed",
            "pressure",
            "deadline",
            "busy",
            "rushed",
            "worried",
            "concern",
            "anxious about",
            "nervous about",
            "uncertain",
            "unsure",
            "don't know",
            "confused",
            "questioning",
            "confused",
            "lost",
            "unsure",
            "don't understand",
            "puzzled"
        ],
        .growth: [
            "growing",
            "learning",
            "developing",
            "changing"
        ],
        .worship: [
            "worship",
            "praise",
            "pray",
            "thankful",
            "blessed"
        ]
    ]
    
    // Biblical guidance for each emotional state
    private let emotionalGuidance: [EmotionalState: [(verse: String, reference: String)]] = [
        .joy: [
            ("Rejoice in the Lord always. I will say it again: Rejoice!", "Philippians 4:4"),
            ("The joy of the Lord is your strength.", "Nehemiah 8:10"),
            ("This is the day that the Lord has made; let us rejoice and be glad in it.", "Psalm 118:24"),
            ("Give thanks in all circumstances; for this is God's will for you in Christ Jesus.", "1 Thessalonians 5:18"),
            ("Enter his gates with thanksgiving and his courts with praise.", "Psalm 100:4"),
            ("Every good and perfect gift is from above.", "James 1:17"),
            ("I have learned to be content whatever the circumstances.", "Philippians 4:11"),
            ("Godliness with contentment is great gain.", "1 Timothy 6:6"),
            ("Keep your lives free from the love of money and be content.", "Hebrews 13:5"),
            ("For I know the plans I have for you, declares the Lord, plans to prosper you.", "Jeremiah 29:11"),
            ("May the God of hope fill you with all joy and peace as you trust in him.", "Romans 15:13"),
            ("But those who hope in the Lord will renew their strength.", "Isaiah 40:31")
        ],
        .peace: [
            ("Peace I leave with you; my peace I give you.", "John 14:27"),
            ("You will keep in perfect peace those whose minds are steadfast.", "Isaiah 26:3"),
            ("Let the peace of Christ rule in your hearts.", "Colossians 3:15")
        ],
        .struggle: [
            ("Cast all your anxiety on him because he cares for you.", "1 Peter 5:7"),
            ("Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.", "Philippians 4:6"),
            ("Therefore do not worry about tomorrow, for tomorrow will worry about itself.", "Matthew 6:34"),
            ("The Lord is close to the brokenhearted and saves those who are crushed in spirit.", "Psalm 34:18"),
            ("He heals the brokenhearted and binds up their wounds.", "Psalm 147:3"),
            ("Why, my soul, are you downcast? Why so disturbed within me? Put your hope in God.", "Psalm 42:11"),
            ("In your anger do not sin: Do not let the sun go down while you are still angry.", "Ephesians 4:26"),
            ("A gentle answer turns away wrath, but a harsh word stirs up anger.", "Proverbs 15:1"),
            ("Be quick to listen, slow to speak and slow to become angry.", "James 1:19"),
            ("For God has not given us a spirit of fear, but of power and of love and of a sound mind.", "2 Timothy 1:7"),
            ("When I am afraid, I put my trust in you.", "Psalm 56:3"),
            ("The Lord is my light and my salvation—whom shall I fear?", "Psalm 27:1"),
            ("Never will I leave you; never will I forsake you.", "Hebrews 13:5"),
            ("The Lord himself goes before you and will be with you.", "Deuteronomy 31:8"),
            ("I am with you always, to the very end of the age.", "Matthew 28:20"),
            ("Come to me, all you who are weary and burdened, and I will give you rest.", "Matthew 11:28"),
            ("My grace is sufficient for you, for my power is made perfect in weakness.", "2 Corinthians 12:9"),
            ("Cast your cares on the Lord and he will sustain you.", "Psalm 55:22"),
            ("He will wipe every tear from their eyes.", "Revelation 21:4"),
            ("Weeping may stay for the night, but rejoicing comes in the morning.", "Psalm 30:5"),
            ("Blessed are those who mourn, for they will be comforted.", "Matthew 5:4"),
            ("Be still, and know that I am God.", "Psalm 46:10"),
            ("My yoke is easy and my burden is light.", "Matthew 11:30"),
            ("Do not be anxious about anything.", "Philippians 4:6"),
            ("Therefore do not worry about tomorrow.", "Matthew 6:34"),
            ("Who of you by worrying can add a single hour to your life?", "Luke 12:25"),
            ("When anxiety was great within me, your consolation brought me joy.", "Psalm 94:19"),
            ("We walk by faith, not by sight.", "2 Corinthians 5:7"),
            ("In their hearts humans plan their course, but the Lord establishes their steps.", "Proverbs 16:9"),
            ("Commit to the Lord whatever you do, and he will establish your plans.", "Proverbs 16:3"),
            ("Trust in the Lord with all your heart and lean not on your own understanding.", "Proverbs 3:5"),
            ("If any of you lacks wisdom, you should ask God, who gives generously to all.", "James 1:5"),
            ("For God is not a God of confusion but of peace.", "1 Corinthians 14:33")
        ],
        .growth: [
            ("But grow in the grace and knowledge of our Lord and Savior Jesus Christ.", "2 Peter 3:18"),
            ("And we all... are being transformed into his image with ever-increasing glory.", "2 Corinthians 3:18")
        ],
        .worship: [
            ("Worship the Lord with gladness; come before him with joyful songs.", "Psalm 100:2"),
            ("Exalt the Lord our God and worship at his footstool; he is holy.", "Psalm 99:5")
        ]
    ]
    
    // MARK: - Public Methods
    
    public init(bibleService: BibleServiceProtocol, cacheService: CacheServiceProtocol) {
        self.bibleService = bibleService
        self.cacheService = cacheService
    }
    
    public func initialize() async throws {
        isInitialized = true
        print("🧠 LifeSituationsEngine initialized")
    }
    
    public func analyzeSituation(_ text: String) async -> LifeSituation {
        // Detect emotions from text
        let detectedEmotions = detectEmotions(from: text)
        let dominantEmotion = detectedEmotions.first ?? .struggle
        let confidence = calculateConfidence(for: detectedEmotions, in: text)
        
        // Get suggested verses
        let suggestedVerses = getVersesForEmotion(dominantEmotion)
        
        // Create guidance prompt
        let guidancePrompt = createGuidancePrompt(for: dominantEmotion, with: text)
        
        // Create life situation
        let situation = LifeSituation(
            text: text,
            detectedEmotions: detectedEmotions,
            dominantEmotion: dominantEmotion,
            confidence: confidence,
            timestamp: Date(),
            suggestedVerses: suggestedVerses,
            guidancePrompt: guidancePrompt
        )
        
        // Add to history
        addToHistory(situation)
        
        return situation
    }
    
    public func getEmotionalJourney() -> [LifeSituation] {
        return emotionHistory
    }
    
    public func getMostCommonEmotions(days: Int = 30) -> [(EmotionalState, Int)] {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        let recentSituations = emotionHistory.filter { $0.timestamp > cutoffDate }
        
        var emotionCounts: [EmotionalState: Int] = [:]
        for situation in recentSituations {
            emotionCounts[situation.dominantEmotion, default: 0] += 1
        }
        
        return emotionCounts.sorted { $0.value > $1.value }
    }
    
    public func getVersesForMood(_ mood: EmotionalState) async -> [VerseRecommendation] {
        let verses = emotionalGuidance[mood] ?? []
        return verses.enumerated().map { index, verseData in
            let bookName = self.parseBookFromReference(verseData.1)
            let bookId = BibleBook(from: bookName)?.id ?? ""
            let verse = BibleVerse(
                bookName: bookName,
                bookId: bookId,
                chapter: self.parseChapterFromReference(verseData.1),
                verse: self.parseVerseFromReference(verseData.1),
                text: verseData.0,
                translation: "N/A"
            )
            
            return VerseRecommendation(
                verse: verse,
                relevanceScore: 1.0 - (Double(index) * 0.1),
                reason: "This verse directly addresses feelings of being \(mood.displayName.lowercased())",
                application: getApplicationForMood(mood, verseIndex: index),
                category: nil,
                mood: mood
            )
        }
    }
    
    public func getVersesForCategory(_ category: LifeCategory, mood: EmotionalState) async -> [VerseRecommendation] {
        // Get base verses for mood
        var recommendations = await getVersesForMood(mood)
        
        // Adjust relevance based on category
        recommendations = recommendations.map { rec in
            _ = rec
            let categoryRelevance = calculateCategoryRelevance(category: category, mood: mood)
            let newScore = rec.relevanceScore * categoryRelevance
            
            return VerseRecommendation(
                verse: rec.verse,
                relevanceScore: newScore,
                reason: "This verse speaks to \(mood.displayName.lowercased()) feelings in the context of \(category.displayName.lowercased())",
                application: getCategorySpecificApplication(category: category, mood: mood),
                category: category,
                mood: mood
            )
        }
        
        return recommendations.sorted { $0.relevanceScore > $1.relevanceScore }
    }
    
    // MARK: - Private Methods
    
    private func detectEmotions(from text: String) -> [EmotionalState] {
        var detectedEmotions: [EmotionalState: Double] = [:]
        let lowercasedText = text.lowercased()
        
        // Check for emotion keywords
        for (emotion, keywords) in emotionKeywords {
            for keyword in keywords {
                if lowercasedText.contains(keyword) {
                    detectedEmotions[emotion, default: 0] += 1.0
                }
            }
        }
        
        // Use sentiment analysis with NLTagger
        tagger.string = text
        let range = text.startIndex..<text.endIndex
        
        var sentimentScore: Double = 0.0
        tagger.enumerateTags(in: range, unit: .paragraph, scheme: .sentimentScore) { tag, _ in
            if let tag = tag,
               let score = Double(tag.rawValue) {
                sentimentScore = score
            }
            return true
        }
        
        // Interpret sentiment score (-1 to 1, where negative is negative sentiment)
        if sentimentScore < -0.3 {
            // Negative sentiment - boost negative emotions
            for emotion in [EmotionalState.struggle] {
                detectedEmotions[emotion, default: 0] += (abs(sentimentScore) * 0.5)
            }
        } else if sentimentScore > 0.3 {
            // Positive sentiment - boost positive emotions
            for emotion in [EmotionalState.joy, .peace, .worship] {
                detectedEmotions[emotion, default: 0] += 0.5
            }
        } else {
            // Neutral sentiment
            detectedEmotions[.peace, default: 0] += 0.5
        }
        
        // Sort by score and return top emotions
        let sortedEmotions = detectedEmotions.sorted { $0.value > $1.value }
        return sortedEmotions.prefix(3).map { $0.key }
    }
    
    private func calculateConfidence(for emotions: [EmotionalState], in text: String) -> Double {
        // Simple confidence calculation based on keyword matches
        var totalMatches = 0
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        
        for emotion in emotions {
            let keywords = emotionKeywords[emotion] ?? []
            for keyword in keywords {
                if words.contains(keyword) {
                    totalMatches += 1
                }
            }
        }
        
        // Calculate confidence (0-1)
        let confidence = min(Double(totalMatches) / 3.0, 1.0)
        return confidence
    }
    
    private func getVersesForEmotion(_ emotion: EmotionalState) -> [BibleVerse] {
        let guidanceVerses = emotionalGuidance[emotion] ?? []
        
        return guidanceVerses.map { guidance in
            let components = guidance.reference.components(separatedBy: " ")
            let _ = components.first ?? "Unknown"
            let chapterVerse = components.last?.components(separatedBy: ":") ?? ["1", "1"]
            let _ = Int(chapterVerse.first ?? "1") ?? 1
            let _ = Int(chapterVerse.last ?? "1") ?? 1
            
            let bookName = self.parseBookFromReference(guidance.reference)
            let bookId = BibleBook(from: bookName)?.id ?? ""
            return BibleVerse(
                bookName: bookName,
                bookId: bookId,
                chapter: self.parseChapterFromReference(guidance.reference),
                verse: self.parseVerseFromReference(guidance.reference),
                text: guidance.verse,
                translation: "N/A"
            )
        }
    }
    
    private func createGuidancePrompt(for emotion: EmotionalState, with text: String) -> String {
        switch emotion {
        case .joy:
            return "What a blessing to share in your joy! Let's celebrate and give thanks to God for His goodness in your life."
        case .peace:
            return "What a gift to experience God's peace! Rest in this moment and let His tranquility guard your heart."
        case .struggle:
            return "When life feels like too much, remember that God's grace is sufficient. He will help you carry these burdens."
        case .growth:
            return "Growth is a natural part of the journey. Keep learning and trusting in God's plan for your life."
        case .worship:
            return "Worship the Lord with gladness; come before him with joyful songs. Exalt the Lord our God and worship at his footstool; he is holy."
        }
    }
    
    private func addToHistory(_ situation: LifeSituation) {
        emotionHistory.append(situation)
        
        // Keep history size manageable
        if emotionHistory.count > maxHistorySize {
            emotionHistory.removeFirst()
        }
    }
    
    // Helper parsing methods
    private func parseBookFromReference(_ reference: String) -> String {
        let parts = reference.split(separator: " ")
        if parts.count >= 2 {
            return parts.dropLast().joined(separator: " ")
        }
        return "Unknown"
    }
    
    private func parseChapterFromReference(_ reference: String) -> Int {
        let parts = reference.split(separator: " ")
        if let chapterVerse = parts.last?.split(separator: ":"),
           let chapter = Int(chapterVerse.first ?? "") {
            return chapter
        }
        return 1
    }
    
    private func parseVerseFromReference(_ reference: String) -> Int {
        let parts = reference.split(separator: " ")
        if let chapterVerse = parts.last?.split(separator: ":"),
           chapterVerse.count > 1,
           let verse = Int(chapterVerse[1]) {
            return verse
        }
        return 1
    }
    
    private func parseBookIdFromReference(_ reference: String) -> String {
        let parts = reference.split(separator: " ")
        let bookName = parts.dropLast().joined(separator: " ")
        
        // Simple mapping of common book names to IDs
        let bookMappings: [String: String] = [
            "Genesis": "gen",
            "Exodus": "exo",
            "Leviticus": "lev",
            "Numbers": "num",
            "Deuteronomy": "deu",
            "Joshua": "jos",
            "Judges": "jdg",
            "Ruth": "rut",
            "1 Samuel": "1sa",
            "2 Samuel": "2sa",
            "1 Kings": "1ki",
            "2 Kings": "2ki",
            "1 Chronicles": "1ch",
            "2 Chronicles": "2ch",
            "Ezra": "ezr",
            "Nehemiah": "neh",
            "Esther": "est",
            "Job": "job",
            "Psalm": "psa",
            "Psalms": "psa",
            "Proverbs": "pro",
            "Ecclesiastes": "ecc",
            "Song of Solomon": "sng",
            "Isaiah": "isa",
            "Jeremiah": "jer",
            "Lamentations": "lam",
            "Ezekiel": "ezk",
            "Daniel": "dan",
            "Hosea": "hos",
            "Joel": "jol",
            "Amos": "amo",
            "Obadiah": "oba",
            "Jonah": "jon",
            "Micah": "mic",
            "Nahum": "nam",
            "Habakkuk": "hab",
            "Zephaniah": "zep",
            "Haggai": "hag",
            "Zechariah": "zec",
            "Malachi": "mal",
            "Matthew": "mat",
            "Mark": "mrk",
            "Luke": "luk",
            "John": "jhn",
            "Acts": "act",
            "Romans": "rom",
            "1 Corinthians": "1co",
            "2 Corinthians": "2co",
            "Galatians": "gal",
            "Ephesians": "eph",
            "Philippians": "php",
            "Colossians": "col",
            "1 Thessalonians": "1th",
            "2 Thessalonians": "2th",
            "1 Timothy": "1ti",
            "2 Timothy": "2ti",
            "Titus": "tit",
            "Philemon": "phm",
            "Hebrews": "heb",
            "James": "jas",
            "1 Peter": "1pe",
            "2 Peter": "2pe",
            "1 John": "1jn",
            "2 John": "2jn",
            "3 John": "3jn",
            "Jude": "jud",
            "Revelation": "rev"
        ]
        
        // Try to find a matching book name (case insensitive)
        for (name, id) in bookMappings {
            if name.compare(bookName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame {
                return id
            }
        }
        
        // If no exact match, try a partial match (e.g., "1 Peter" matches "1 Peter 5:7")
        for (name, id) in bookMappings {
            if bookName.localizedCaseInsensitiveContains(name) || name.localizedCaseInsensitiveContains(bookName) {
                return id
            }
        }
        
        return "unknown"
    }
    
    private func getApplicationForMood(_ mood: EmotionalState, verseIndex: Int) -> String {
        let applications: [EmotionalState: [String]] = [
            .joy: [
                "Rejoice in the Lord always. I will say it again: Rejoice!",
                "The joy of the Lord is your strength.",
                "This is the day that the Lord has made; let us rejoice and be glad in it."
            ],
            .peace: [
                "Peace I leave with you; my peace I give you.",
                "You will keep in perfect peace those whose minds are steadfast.",
                "Let the peace of Christ rule in your hearts."
            ],
            .struggle: [
                "Practice deep breathing and prayer",
                "Reach out to a friend or mentor",
                "Journal your thoughts and God's promises",
                "Allow yourself to grieve - God collects every tear",
                "Reach out to a trusted friend or counselor",
                "Remember that this season will pass - joy comes in the morning",
                "In your anger do not sin: Do not let the sun go down while you are still angry.",
                "A gentle answer turns away wrath, but a harsh word stirs up anger.",
                "Be quick to listen, slow to speak and slow to become angry.",
                "For God has not given us a spirit of fear, but of power and of love and of a sound mind.",
                "When I am afraid, I put my trust in you.",
                "The Lord is my light and my salvation—whom shall I fear?",
                "Never will I leave you; never will I forsake you.",
                "The Lord himself goes before you and will be with you.",
                "I am with you always, to the very end of the age.",
                "Come to me, all you who are weary and burdened, and I will give you rest.",
                "My grace is sufficient for you, for my power is made perfect in weakness.",
                "Cast your cares on the Lord and he will sustain you.",
                "He will wipe every tear from their eyes.",
                "Weeping may stay for the night, but rejoicing comes in the morning.",
                "Blessed are those who mourn, for they will be comforted.",
                "Be still, and know that I am God.",
                "My yoke is easy and my burden is light.",
                "Do not be anxious about anything.",
                "Therefore do not worry about tomorrow.",
                "Who of you by worrying can add a single hour to your life?",
                "When anxiety was great within me, your consolation brought me joy.",
                "We walk by faith, not by sight.",
                "In their hearts humans plan their course, but the Lord establishes their steps.",
                "Commit to the Lord whatever you do, and he will establish your plans.",
                "Trust in the Lord with all your heart and lean not on your own understanding.",
                "If any of you lacks wisdom, you should ask God, who gives generously to all.",
                "For God is not a God of confusion but of peace."
            ],
            .growth: [
                "But grow in the grace and knowledge of our Lord and Savior Jesus Christ.",
                "And we all... are being transformed into his image with ever-increasing glory."
            ],
            .worship: [
                "Worship the Lord with gladness; come before him with joyful songs.",
                "Exalt the Lord our God and worship at his footstool; he is holy."
            ]
        ]
        
        let moodApplications = applications[mood] ?? ["Meditate on this verse throughout your day"]
        return moodApplications[min(verseIndex, moodApplications.count - 1)]
    }
    
    private func calculateCategoryRelevance(category: LifeCategory, mood: EmotionalState) -> Double {
        let relevanceMap: [LifeCategory: [EmotionalState: Double]] = [
            .relationships: [.joy: 0.6, .struggle: 0.4],
            .growth: [.growth: 1.0, .struggle: 0.8],
            .challenges: [.struggle: 1.0],
            .purpose: [.growth: 0.9, .worship: 0.8],
            .spiritual: [.worship: 1.0, .peace: 0.9]
        ]
        
        return relevanceMap[category]?[mood] ?? 0.7
    }
    
    private func getCategorySpecificApplication(category: LifeCategory, mood: EmotionalState) -> String {
        switch (category, mood) {
        case (.relationships, .struggle):
            return "Reach out to someone today - send a message or make a call"
        case (.growth, .struggle):
            return "Take regular breaks and pray for wisdom in prioritizing tasks"
        case (.challenges, .struggle):
            return "Trust God with your concerns while taking practical steps"
        default:
            return "Apply this verse specifically to your \(category.displayName.lowercased()) situation"
        }
    }
}

// MARK: - Extensions for UI Integration
