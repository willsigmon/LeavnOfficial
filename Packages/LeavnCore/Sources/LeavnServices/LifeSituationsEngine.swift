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
        .anxious: ["anxious", "nervous", "worried", "uneasy", "restless", "tense"],
        .depressed: ["depressed", "hopeless", "down", "worthless", "empty"],
        .angry: ["angry", "mad", "furious", "frustrated", "irritated", "annoyed"],
        .fearful: ["scared", "afraid", "terrified", "frightened", "fear"],
        .joyful: ["happy", "joyful", "excited", "blessed", "wonderful", "amazing"],
        .grateful: ["grateful", "thankful", "blessed", "appreciate"],
        .confused: ["confused", "lost", "unsure", "don't understand", "puzzled"],
        .hopeful: ["hopeful", "optimistic", "looking forward", "excited about"],
        .lonely: ["lonely", "alone", "isolated", "disconnected", "miss"],
        .overwhelmed: ["overwhelmed", "too much", "can't handle", "drowning"],
        .peaceful: ["peaceful", "calm", "serene", "relaxed", "tranquil"],
        .sad: ["sad", "unhappy", "crying", "tears", "heartbroken"],
        .stressed: ["stressed", "pressure", "deadline", "busy", "rushed"],
        .worried: ["worried", "concern", "anxious about", "nervous about"],
        .content: ["content", "satisfied", "good", "fine", "okay"],
        .uncertain: ["uncertain", "unsure", "don't know", "confused", "questioning"]
    ]
    
    // Biblical guidance for each emotional state
    private let emotionalGuidance: [EmotionalState: [(verse: String, reference: String)]] = [
        .anxious: [
            ("Cast all your anxiety on him because he cares for you.", "1 Peter 5:7"),
            ("Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.", "Philippians 4:6"),
            ("Therefore do not worry about tomorrow, for tomorrow will worry about itself.", "Matthew 6:34")
        ],
        .depressed: [
            ("The Lord is close to the brokenhearted and saves those who are crushed in spirit.", "Psalm 34:18"),
            ("He heals the brokenhearted and binds up their wounds.", "Psalm 147:3"),
            ("Why, my soul, are you downcast? Why so disturbed within me? Put your hope in God.", "Psalm 42:11")
        ],
        .angry: [
            ("In your anger do not sin: Do not let the sun go down while you are still angry.", "Ephesians 4:26"),
            ("A gentle answer turns away wrath, but a harsh word stirs up anger.", "Proverbs 15:1"),
            ("Be quick to listen, slow to speak and slow to become angry.", "James 1:19")
        ],
        .fearful: [
            ("For God has not given us a spirit of fear, but of power and of love and of a sound mind.", "2 Timothy 1:7"),
            ("When I am afraid, I put my trust in you.", "Psalm 56:3"),
            ("The Lord is my light and my salvation—whom shall I fear?", "Psalm 27:1")
        ],
        .joyful: [
            ("Rejoice in the Lord always. I will say it again: Rejoice!", "Philippians 4:4"),
            ("The joy of the Lord is your strength.", "Nehemiah 8:10"),
            ("This is the day that the Lord has made; let us rejoice and be glad in it.", "Psalm 118:24")
        ],
        .grateful: [
            ("Give thanks in all circumstances; for this is God's will for you in Christ Jesus.", "1 Thessalonians 5:18"),
            ("Enter his gates with thanksgiving and his courts with praise.", "Psalm 100:4"),
            ("Every good and perfect gift is from above.", "James 1:17")
        ],
        .confused: [
            ("Trust in the Lord with all your heart and lean not on your own understanding.", "Proverbs 3:5"),
            ("If any of you lacks wisdom, you should ask God, who gives generously to all.", "James 1:5"),
            ("For God is not a God of confusion but of peace.", "1 Corinthians 14:33")
        ],
        .hopeful: [
            ("For I know the plans I have for you, declares the Lord, plans to prosper you.", "Jeremiah 29:11"),
            ("May the God of hope fill you with all joy and peace as you trust in him.", "Romans 15:13"),
            ("But those who hope in the Lord will renew their strength.", "Isaiah 40:31")
        ],
        .lonely: [
            ("Never will I leave you; never will I forsake you.", "Hebrews 13:5"),
            ("The Lord himself goes before you and will be with you.", "Deuteronomy 31:8"),
            ("I am with you always, to the very end of the age.", "Matthew 28:20")
        ],
        .overwhelmed: [
            ("Come to me, all you who are weary and burdened, and I will give you rest.", "Matthew 11:28"),
            ("My grace is sufficient for you, for my power is made perfect in weakness.", "2 Corinthians 12:9"),
            ("Cast your cares on the Lord and he will sustain you.", "Psalm 55:22")
        ],
        .peaceful: [
            ("Peace I leave with you; my peace I give you.", "John 14:27"),
            ("You will keep in perfect peace those whose minds are steadfast.", "Isaiah 26:3"),
            ("Let the peace of Christ rule in your hearts.", "Colossians 3:15")
        ],
        .sad: [
            ("He will wipe every tear from their eyes.", "Revelation 21:4"),
            ("Weeping may stay for the night, but rejoicing comes in the morning.", "Psalm 30:5"),
            ("Blessed are those who mourn, for they will be comforted.", "Matthew 5:4")
        ],
        .stressed: [
            ("Be still, and know that I am God.", "Psalm 46:10"),
            ("My yoke is easy and my burden is light.", "Matthew 11:30"),
            ("Do not be anxious about anything.", "Philippians 4:6")
        ],
        .worried: [
            ("Therefore do not worry about tomorrow.", "Matthew 6:34"),
            ("Who of you by worrying can add a single hour to your life?", "Luke 12:25"),
            ("When anxiety was great within me, your consolation brought me joy.", "Psalm 94:19")
        ],
        .content: [
            ("I have learned to be content whatever the circumstances.", "Philippians 4:11"),
            ("Godliness with contentment is great gain.", "1 Timothy 6:6"),
            ("Keep your lives free from the love of money and be content.", "Hebrews 13:5")
        ],
        .uncertain: [
            ("We walk by faith, not by sight.", "2 Corinthians 5:7"),
            ("In their hearts humans plan their course, but the Lord establishes their steps.", "Proverbs 16:9"),
            ("Commit to the Lord whatever you do, and he will establish your plans.", "Proverbs 16:3")
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
        let dominantEmotion = detectedEmotions.first ?? .uncertain
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
            for emotion in [EmotionalState.sad, .anxious, .stressed] {
                detectedEmotions[emotion, default: 0] += 0.5
            }
        } else if sentimentScore > 0.3 {
            // Positive sentiment - boost positive emotions
            for emotion in [EmotionalState.joyful, .grateful, .peaceful] {
                detectedEmotions[emotion, default: 0] += 0.5
            }
        } else {
            // Neutral sentiment
            detectedEmotions[.content, default: 0] += 0.5
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
        case .anxious:
            return "I sense you're feeling anxious. Remember that God cares deeply about your worries. Take a moment to breathe and cast your anxieties on Him."
        case .depressed:
            return "I hear the heaviness in your heart. Know that God is especially close to you right now. You are not alone in this valley."
        case .angry:
            return "Anger is a valid emotion, but let's not let it control us. God understands your frustration and offers wisdom for handling it righteously."
        case .fearful:
            return "Fear can be overwhelming, but remember that perfect love casts out fear. God is with you and will give you courage."
        case .joyful:
            return "What a blessing to share in your joy! Let's celebrate and give thanks to God for His goodness in your life."
        case .grateful:
            return "A grateful heart is a magnet for miracles. Your thankfulness honors God and opens doors for more blessings."
        case .confused:
            return "When life doesn't make sense, God's wisdom is available. He will guide you through this uncertainty."
        case .hopeful:
            return "Hope is a powerful anchor for the soul. Keep trusting in God's promises - He is faithful!"
        case .lonely:
            return "Loneliness is painful, but you are never truly alone. God is with you always, and He understands your need for connection."
        case .overwhelmed:
            return "When life feels like too much, remember that God's grace is sufficient. He will help you carry these burdens."
        case .peaceful:
            return "What a gift to experience God's peace! Rest in this moment and let His tranquility guard your heart."
        case .sad:
            return "Your tears are precious to God. He sees your pain and promises that joy will come again."
        case .stressed:
            return "Stress can steal our peace, but God invites us to find rest in Him. Let's take this one step at a time."
        case .worried:
            return "Worrying won't add a single hour to your life, but prayer can change everything. Let's bring your concerns to God."
        case .content:
            return "Contentment is a beautiful fruit of the Spirit. Continue to rest in God's provision and faithfulness."
        case .uncertain:
            return "Uncertainty is part of the journey of faith. Trust that God is directing your steps, even when the path isn't clear."
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
            .anxious: [
                "Take a deep breath and repeat this verse when worries arise",
                "Write down your specific anxieties and give them to God in prayer",
                "Set aside worry time - limit it to 15 minutes, then focus on this promise"
            ],
            .grateful: [
                "Start a gratitude journal and write 3 things daily",
                "Share your gratitude with someone who needs encouragement",
                "Turn this thankfulness into worship through prayer or song"
            ],
            .sad: [
                "Allow yourself to grieve - God collects every tear",
                "Reach out to a trusted friend or counselor",
                "Remember that this season will pass - joy comes in the morning"
            ]
        ]
        
        let moodApplications = applications[mood] ?? ["Meditate on this verse throughout your day"]
        return moodApplications[min(verseIndex, moodApplications.count - 1)]
    }
    
    private func calculateCategoryRelevance(category: LifeCategory, mood: EmotionalState) -> Double {
        let relevanceMap: [LifeCategory: [EmotionalState: Double]] = [
            .relationships: [.lonely: 1.0, .angry: 0.9, .sad: 0.8],
            .work: [.stressed: 1.0, .overwhelmed: 0.9, .anxious: 0.8],
            .health: [.fearful: 1.0, .anxious: 0.9, .worried: 0.8],
            .family: [.grateful: 0.9, .angry: 0.8, .sad: 0.8]
        ]
        
        return relevanceMap[category]?[mood] ?? 0.7
    }
    
    private func getCategorySpecificApplication(category: LifeCategory, mood: EmotionalState) -> String {
        switch (category, mood) {
        case (.relationships, .lonely):
            return "Reach out to someone today - send a message or make a call"
        case (.work, .stressed):
            return "Take regular breaks and pray for wisdom in prioritizing tasks"
        case (.health, .anxious):
            return "Trust God with your health concerns while taking practical steps"
        default:
            return "Apply this verse specifically to your \(category.displayName.lowercased()) situation"
        }
    }
}

// MARK: - Extensions for UI Integration
