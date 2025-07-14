import Foundation

// MARK: - FilterResult (file-global for visibility)
public struct FilterResult: Sendable {
    public let isApproved: Bool
    public let issues: [ContentIssue]
    public let suggestions: [String]
    public let severity: Severity
    
    public enum Severity: Int, Comparable, Sendable {
        case none = 0
        case minor = 1
        case moderate = 2
        case severe = 3
        
        public static func < (lhs: Severity, rhs: Severity) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

// MARK: - ContentIssue (file-global for visibility)
public struct ContentIssue: Sendable {
    public let type: IssueType
    public let description: String
    public let location: String?
    public let severity: FilterResult.Severity
    public enum IssueType: Sendable {
        case theological
        case factual
        case reverence
        case inappropriate
        case scriptureAccuracy
        case denominational
    }
}

/// Advanced content filtering service for AI-generated biblical content
public actor ContentFilterService {
    
    // MARK: - Properties
    
    private let scriptureValidator: ScriptureValidator
    private let theologicalChecker: TheologicalChecker
    private let reverenceAnalyzer: ReverenceAnalyzer
    
    // MARK: - Initialization
    
    public init() {
        self.scriptureValidator = ScriptureValidator()
        self.theologicalChecker = TheologicalChecker()
        self.reverenceAnalyzer = ReverenceAnalyzer()
    }
    
    // MARK: - Public Methods
    
    /// Comprehensive content filtering
    public func filterContent(_ content: String, context: FilterContext) async -> FilterResult {
        var issues: [ContentIssue] = []
        var suggestions: [String] = []
        
        // 1. Check for inappropriate content
        let inappropriateCheck = checkInappropriateContent(content)
        issues.append(contentsOf: inappropriateCheck.issues)
        
        // 2. Validate theological accuracy
        let theologicalCheck = theologicalChecker.validate(content, context: context)
        issues.append(contentsOf: theologicalCheck.issues)
        suggestions.append(contentsOf: theologicalCheck.suggestions)
        
        // 3. Check reverence and tone
        let reverenceCheck = reverenceAnalyzer.analyze(content)
        issues.append(contentsOf: reverenceCheck.issues)
        
        // 4. Validate scripture references
        if context.expectsScriptureReferences {
            let scriptureCheck = scriptureValidator.validate(content)
            issues.append(contentsOf: scriptureCheck.issues)
        }
        
        // Determine overall severity
        let maxSeverity = issues.map(\.severity).max() ?? .none
        let isApproved = maxSeverity < .moderate
        
        return FilterResult(
            isApproved: isApproved,
            issues: issues,
            suggestions: suggestions,
            severity: maxSeverity
        )
    }
    
    /// Quick validation for real-time checks
    public func quickValidate(_ content: String) async -> Bool {
        let lowercased = content.lowercased()
        
        // Quick checks for obvious issues
        for keyword in AIGuardrails.prohibitedKeywords {
            if lowercased.contains(keyword) {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Private Methods
    
    private func checkInappropriateContent(_ content: String) -> (issues: [ContentIssue], severity: FilterResult.Severity) {
        var issues: [ContentIssue] = []
        let lowercased = content.lowercased()
        
        // Extended inappropriate content patterns
        let inappropriatePatterns = [
            // Blasphemy
            (pattern: "god is (dead|fake|not real)", severity: FilterResult.Severity.severe),
            (pattern: "jesus (was just|wasn't|never)", severity: FilterResult.Severity.severe),
            (pattern: "bible is (fake|false|wrong|mythology)", severity: FilterResult.Severity.severe),
            
            // False doctrine
            (pattern: "(earn|work for) (your )?(salvation|heaven)", severity: FilterResult.Severity.moderate),
            (pattern: "all (religions|paths) (lead to|are)", severity: FilterResult.Severity.moderate),
            
            // Disrespect
            (pattern: "(stupid|foolish|primitive) (christian|faith|belief)", severity: FilterResult.Severity.moderate),
            (pattern: "mythology|fairy tale|fiction", severity: FilterResult.Severity.minor)
        ]
        
        for (pattern, severity) in inappropriatePatterns {
            if let _ = lowercased.range(of: pattern, options: .regularExpression) {
                issues.append(ContentIssue(
                    type: .inappropriate,
                    description: "Content contains inappropriate language or concepts",
                    location: pattern,
                    severity: severity
                ))
            }
        }
        
        let maxSeverity = issues.map(\.severity).max() ?? .none
        return (issues, maxSeverity)
    }
}

// MARK: - Supporting Components

/// Validates scripture references and quotations
public struct ScriptureValidator {
    
    func validate(_ content: String) -> (issues: [ContentIssue], suggestions: [String]) {
        var issues: [ContentIssue] = []
        var suggestions: [String] = []
        
        // Find all scripture references
        let referencePattern = #"(\d?\s*)?([A-Za-z]+)\s+(\d+):(\d+)(?:-(\d+))?"#
        let regex = try? NSRegularExpression(pattern: referencePattern)
        
        let matches = regex?.matches(
            in: content,
            range: NSRange(content.startIndex..., in: content)
        ) ?? []
        
        for match in matches {
            if let range = Range(match.range, in: content) {
                let reference = String(content[range])
                
                // Validate book name
                if !isValidBookName(reference) {
                    issues.append(ContentIssue(
                        type: .scriptureAccuracy,
                        description: "Invalid or misspelled book name",
                        location: reference,
                        severity: .minor
                    ))
                    suggestions.append("Check spelling of biblical book names")
                }
            }
        }
        
        return (issues, suggestions)
    }
    
    private func isValidBookName(_ reference: String) -> Bool {
        let validBooks = [
            "Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy",
            "Joshua", "Judges", "Ruth", "1 Samuel", "2 Samuel",
            "1 Kings", "2 Kings", "1 Chronicles", "2 Chronicles",
            "Ezra", "Nehemiah", "Esther", "Job", "Psalms", "Proverbs",
            "Ecclesiastes", "Song of Solomon", "Isaiah", "Jeremiah",
            "Lamentations", "Ezekiel", "Daniel", "Hosea", "Joel",
            "Amos", "Obadiah", "Jonah", "Micah", "Nahum", "Habakkuk",
            "Zephaniah", "Haggai", "Zechariah", "Malachi",
            "Matthew", "Mark", "Luke", "John", "Acts", "Romans",
            "1 Corinthians", "2 Corinthians", "Galatians", "Ephesians",
            "Philippians", "Colossians", "1 Thessalonians", "2 Thessalonians",
            "1 Timothy", "2 Timothy", "Titus", "Philemon", "Hebrews",
            "James", "1 Peter", "2 Peter", "1 John", "2 John", "3 John",
            "Jude", "Revelation"
        ]
        
        return validBooks.contains { book in
            reference.lowercased().contains(book.lowercased())
        }
    }
}

/// Checks theological accuracy
public struct TheologicalChecker {
    
    func validate(_ content: String, context: FilterContext) -> (issues: [ContentIssue], suggestions: [String]) {
        var issues: [ContentIssue] = []
        var suggestions: [String] = []
        let lowercased = content.lowercased()
        
        // Core doctrine checks
        let doctrineViolations = [
            // Trinity
            (check: lowercased.contains("jesus is not god") || lowercased.contains("jesus isn't god"),
             issue: "Denies deity of Christ", severity: FilterResult.Severity.severe),
            
            // Salvation
            (check: lowercased.contains("saved by works") || lowercased.contains("earn salvation"),
             issue: "Promotes works-based salvation", severity: FilterResult.Severity.moderate),
            
            // Scripture
            (check: lowercased.contains("bible has errors") || lowercased.contains("scripture is wrong"),
             issue: "Undermines biblical authority", severity: FilterResult.Severity.moderate),
            
            // Universalism
            (check: lowercased.contains("everyone goes to heaven") || lowercased.contains("all are saved"),
             issue: "Promotes universalism", severity: FilterResult.Severity.moderate)
        ]
        
        for (check, issue, severity) in doctrineViolations {
            if check {
                issues.append(ContentIssue(
                    type: .theological,
                    description: issue,
                    location: nil,
                    severity: severity
                ))
                suggestions.append("Ensure content aligns with orthodox Christian doctrine")
            }
        }
        
        return (issues, suggestions)
    }
}

/// Analyzes reverence and tone
public struct ReverenceAnalyzer {
    
    func analyze(_ content: String) -> (issues: [ContentIssue], suggestions: [String]) {
        var issues: [ContentIssue] = []
        var suggestions: [String] = []
        
        // Check divine name capitalization
        let divineNames = [
            "god", "lord", "jesus", "christ", "holy spirit", 
            "father", "son", "savior", "messiah", "yahweh"
        ]
        
        let words = content.split(separator: " ").map(String.init)
        
        for (index, word) in words.enumerated() {
            let cleanWord = word.trimmingCharacters(in: .punctuationCharacters)
            let lowercased = cleanWord.lowercased()
            
            if divineNames.contains(lowercased) {
                // Check context - some uses don't require capitalization
                let previousWord = index > 0 ? words[index - 1].lowercased() : ""
                let contextualUse = ["a", "the", "false", "other"].contains(previousWord)
                
                if !contextualUse && !cleanWord.first!.isUppercase {
                    issues.append(ContentIssue(
                        type: .reverence,
                        description: "Divine name '\(cleanWord)' should be capitalized",
                        location: cleanWord,
                        severity: .minor
                    ))
                }
            }
        }
        
        // Check for casual or flippant tone
        let casualPhrases = [
            "god's like", "jesus was like", "basically god", "sort of like heaven"
        ]
        
        let lowercased = content.lowercased()
        for phrase in casualPhrases {
            if lowercased.contains(phrase) {
                issues.append(ContentIssue(
                    type: .reverence,
                    description: "Tone is too casual for sacred content",
                    location: phrase,
                    severity: .minor
                ))
                suggestions.append("Use more reverent language when discussing sacred topics")
            }
        }
        
        return (issues, suggestions)
    }
}

// MARK: - Filter Context

public struct FilterContext {
    public let contentType: ContentType
    public let expectsScriptureReferences: Bool
    public let targetAudience: TargetAudience
    public let strictnessLevel: StrictnessLevel
    
    public enum TargetAudience {
        case general
        case children
        case scholarly
        case devotional
    }
    
    public enum StrictnessLevel {
        case relaxed
        case standard
        case strict
    }
    
    public init(
        contentType: ContentType,
        expectsScriptureReferences: Bool = false,
        targetAudience: TargetAudience = .general,
        strictnessLevel: StrictnessLevel = .standard
    ) {
        self.contentType = contentType
        self.expectsScriptureReferences = expectsScriptureReferences
        self.targetAudience = targetAudience
        self.strictnessLevel = strictnessLevel
    }
}