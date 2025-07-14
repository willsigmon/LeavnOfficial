import Foundation

// MARK: - Safe AI Service (with Biblical Guardrails)
public final class SafeAIService: AIServiceProtocol {
    private let bibleService: BibleServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // Biblical content templates
    private let insightTemplates = [
        "This verse reminds us of God's {attribute} and calls us to {action}.",
        "In this passage, we see {theme} demonstrated through {example}.",
        "The context of this scripture teaches us about {lesson}.",
        "This text reveals {truth} about our relationship with God.",
        "Here we learn about {concept} and how it applies to our daily lives."
    ]
    
    private let attributes = ["love", "mercy", "grace", "faithfulness", "sovereignty", "wisdom", "justice"]
    private let actions = ["trust Him", "love others", "seek His will", "practice forgiveness", "walk in faith", "remain steadfast"]
    private let themes = ["redemption", "covenant", "faith", "obedience", "God's provision", "divine purpose"]
    
    public init(bibleService: BibleServiceProtocol, analyticsService: AnalyticsServiceProtocol) {
        self.bibleService = bibleService
        self.analyticsService = analyticsService
    }
    
    public func generateInsight(for verse: BibleVerse) async throws -> String {
        // Track the request
        analyticsService.track(event: "ai_insight_requested", properties: [
            "verse": verse.reference,
            "translation": verse.translation
        ])
        
        // Generate a safe, theologically sound insight
        let template = insightTemplates.randomElement() ?? insightTemplates[0]
        var insight = template
        
        // Replace placeholders with appropriate content
        insight = insight.replacingOccurrences(of: "{attribute}", with: attributes.randomElement() ?? "love")
        insight = insight.replacingOccurrences(of: "{action}", with: actions.randomElement() ?? "trust Him")
        insight = insight.replacingOccurrences(of: "{theme}", with: themes.randomElement() ?? "faith")
        
        // Add contextual elements based on the book
        if verse.book.contains("Psalm") {
            insight = "This psalm \(insight.lowercased())"
        } else if ["Matthew", "Mark", "Luke", "John"].contains(verse.book) {
            insight = "In this Gospel passage, \(insight.lowercased())"
        } else if verse.book.contains("Corinthians") || verse.book.contains("Timothy") {
            insight = "Paul's letter here \(insight.lowercased())"
        }
        
        return insight
    }
    
    public func generateSummary(for chapter: BibleChapter) async throws -> String {
        // Track the request
        analyticsService.track(event: "ai_summary_requested", properties: [
            "book": chapter.book,
            "chapter": chapter.chapter,
            "translation": chapter.translation
        ])
        
        // Generate a safe chapter summary
        let verseCount = chapter.verses.count
        let keyThemes = identifyKeyThemes(in: chapter)
        
        var summary = "Chapter \(chapter.chapter) of \(chapter.book) contains \(verseCount) verses. "
        
        // Add book-specific context
        if let bookContext = getBookContext(chapter.book) {
            summary += bookContext + " "
        }
        
        // Add thematic summary
        if !keyThemes.isEmpty {
            summary += "Key themes include \(keyThemes.joined(separator: ", ")). "
        }
        
        summary += "This chapter invites us to reflect on God's word and apply these truths to our lives."
        
        return summary
    }
    
    public func answerQuestion(_ question: String, context: [BibleVerse]) async throws -> String {
        // Track the request
        analyticsService.track(event: "ai_question_asked", properties: [
            "question_length": question.count,
            "context_verses": context.count
        ])
        
        // Provide safe, biblically-grounded answers
        let questionLower = question.lowercased()
        
        // Check for common question patterns
        if questionLower.contains("who") {
            return generateWhoAnswer(question: question, context: context)
        } else if questionLower.contains("what") {
            return generateWhatAnswer(question: question, context: context)
        } else if questionLower.contains("why") {
            return generateWhyAnswer(question: question, context: context)
        } else if questionLower.contains("how") {
            return generateHowAnswer(question: question, context: context)
        } else {
            return generateGeneralAnswer(question: question, context: context)
        }
    }
    
    // MARK: - Private Helpers
    
    private func identifyKeyThemes(in chapter: BibleChapter) -> [String] {
        var themes: Set<String> = []
        
        let text = chapter.verses.map { $0.text }.joined(separator: " ").lowercased()
        
        // Check for common biblical themes
        let themeKeywords = [
            ("love", ["love", "loved", "loving"]),
            ("faith", ["faith", "believe", "trust"]),
            ("salvation", ["save", "saved", "salvation", "redeem"]),
            ("prayer", ["pray", "prayer", "praying"]),
            ("forgiveness", ["forgive", "forgiven", "forgiveness"]),
            ("wisdom", ["wisdom", "wise", "understanding"]),
            ("righteousness", ["righteous", "righteousness", "holy"])
        ]
        
        for (theme, keywords) in themeKeywords {
            if keywords.contains(where: { text.contains($0) }) {
                themes.insert(theme)
            }
        }
        
        return Array(themes).prefix(3).map { $0 }
    }
    
    private func getBookContext(_ book: String) -> String? {
        let bookContexts = [
            "Genesis": "This foundational book reveals God's creation and the beginning of His covenant relationship with humanity.",
            "Exodus": "This book of deliverance shows God's power in freeing His people and establishing His law.",
            "Psalms": "This collection of prayers and songs expresses the full range of human emotion in relationship with God.",
            "Proverbs": "This wisdom literature provides practical guidance for righteous living.",
            "Isaiah": "This prophetic book reveals both God's judgment and His promise of redemption.",
            "Matthew": "This Gospel presents Jesus as the promised Messiah and King.",
            "John": "This Gospel emphasizes Jesus as the Word made flesh and the Son of God.",
            "Romans": "Paul's letter explains the gospel of grace and justification by faith.",
            "Revelation": "This prophetic book reveals God's ultimate victory and the hope of eternity."
        ]
        
        return bookContexts[book]
    }
    
    private func generateWhoAnswer(question: String, context: [BibleVerse]) -> String {
        if !context.isEmpty {
            return "Based on these verses, this refers to individuals or groups mentioned in Scripture. The passage helps us understand their role in God's plan and what we can learn from their example."
        }
        return "To answer questions about biblical figures, it's important to study the full context of Scripture. Consider reading the surrounding passages to better understand the people and their significance in God's story."
    }
    
    private func generateWhatAnswer(question: String, context: [BibleVerse]) -> String {
        if !context.isEmpty {
            let references = context.map { $0.reference }.joined(separator: ", ")
            return "Looking at \(references), we see important biblical concepts being explained. These verses help us understand God's truth and how it applies to our lives today."
        }
        return "Biblical 'what' questions often explore definitions, meanings, and theological concepts. I encourage you to study these topics in their full biblical context for deeper understanding."
    }
    
    private func generateWhyAnswer(question: String, context: [BibleVerse]) -> String {
        if !context.isEmpty {
            return "The 'why' behind biblical events and commands reveals God's character and purposes. These verses show us that God's ways are higher than our ways, and His plans are always for our good and His glory."
        }
        return "Understanding the 'why' in Scripture requires studying God's character, His covenant relationships, and the broader narrative of redemption. Prayer and meditation on God's word can bring clarity to these deeper questions."
    }
    
    private func generateHowAnswer(question: String, context: [BibleVerse]) -> String {
        if !context.isEmpty {
            return "These verses provide practical guidance for living out our faith. The 'how' of Christian living is empowered by the Holy Spirit and grounded in God's word. Apply these truths with prayer and in community with other believers."
        }
        return "Questions about 'how' to live according to Scripture are best answered through careful study of God's commands, the example of Jesus, and the teaching of the apostles. Seek wisdom from mature believers and pastoral guidance as well."
    }
    
    private func generateGeneralAnswer(question: String, context: [BibleVerse]) -> String {
        if !context.isEmpty {
            return "These scripture passages provide insight into your question. Remember that the Bible is God's revelation to us, and understanding comes through prayerful study, the illumination of the Holy Spirit, and often in community with other believers."
        }
        return "For deeper understanding of biblical questions, I recommend studying the relevant passages in context, consulting trusted commentaries, and discussing with pastors or Bible study groups. God's word is living and active, speaking to us in our specific situations."
    }
}