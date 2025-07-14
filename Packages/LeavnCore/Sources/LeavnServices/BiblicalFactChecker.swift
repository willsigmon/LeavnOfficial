import Foundation

/// Biblical fact-checking service that validates historical and theological claims
public actor BiblicalFactChecker {
    
    // MARK: - Types
    
    public struct FactCheckResult: Sendable {
        public let claim: String
        public let verdict: Verdict
        public let confidence: Double // 0.0 to 1.0
        public let evidence: [Evidence]
        public let corrections: [String]
        
        public enum Verdict: Sendable {
            case verified
            case plausible
            case disputed
            case incorrect
            case unverifiable
        }
        
        public struct Evidence: Sendable {
            public let source: String
            public let description: String
            public let reliability: Reliability
            
            public enum Reliability: Sendable {
                case primary // Biblical text
                case scholarly // Academic consensus
                case archaeological // Physical evidence
                case traditional // Church tradition
                case speculative // Reasonable inference
            }
        }
    }
    
    // MARK: - Properties
    
    // Core biblical facts database
    private let biblicalFacts = BiblicalFactsDatabase()
    
    // Pattern matchers for common claims
    private let claimPatterns: [(pattern: String, factType: FactType)] = [
        (#"written\s+(in|around|circa)\s+(\d+)\s*(bc|ad|bce|ce)"#, .dating),
        (#"(authored|written)\s+by\s+(\w+)"#, .authorship),
        (#"(\w+)\s+was\s+(king|prophet|apostle|disciple)"#, .person),
        (#"(\w+)\s+means?\s+"#, .linguistic),
        (#"located\s+(in|at|near)\s+(\w+)"#, .geographical)
    ]
    
    // MARK: - Public Methods
    
    /// Fact-check a claim about biblical content
    public func checkClaim(_ claim: String) async -> FactCheckResult {
        _ = claim.lowercased()
        
        // Identify claim type
        let claimType = identifyClaimType(claim)
        
        // Check against known facts
        switch claimType {
        case .dating:
            return await checkDatingClaim(claim)
        case .authorship:
            return await checkAuthorshipClaim(claim)
        case .person:
            return await checkPersonClaim(claim)
        case .linguistic:
            return await checkLinguisticClaim(claim)
        case .geographical:
            return await checkGeographicalClaim(claim)
        case .theological:
            return await checkTheologicalClaim(claim)
        case .general:
            return await checkGeneralClaim(claim)
        }
    }
    
    /// Validate multiple facts in a piece of content
    public func validateContent(_ content: String) async -> [FactCheckResult] {
        let claims = extractClaims(from: content)
        var results: [FactCheckResult] = []
        
        for claim in claims {
            let result = await checkClaim(claim)
            results.append(result)
        }
        
        return results
    }
    
    // MARK: - Claim Type Identification
    
    private enum FactType {
        case dating
        case authorship
        case person
        case linguistic
        case geographical
        case theological
        case general
    }
    
    private func identifyClaimType(_ claim: String) -> FactType {
        _ = claim.lowercased()
        
        for (pattern, type) in claimPatterns {
            if let _ = claim.range(of: pattern, options: .regularExpression) {
                return type
            }
        }
        
        // Check for theological claims
        if claim.contains("salvation") || claim.contains("trinity") || 
           claim.contains("resurrection") || claim.contains("messiah") {
            return .theological
        }
        
        return .general
    }
    
    // MARK: - Specific Fact Checkers
    
    private func checkDatingClaim(_ claim: String) async -> FactCheckResult {
        // Extract book and date from claim
        let datePattern = #"(\w+)\s+.*written.*\s+(\d+)\s*(bc|ad|bce|ce)"#
        guard claim.range(of: datePattern, options: [.regularExpression, .caseInsensitive]) != nil else {
            return FactCheckResult(
                claim: claim,
                verdict: .unverifiable,
                confidence: 0.0,
                evidence: [],
                corrections: ["Unable to parse dating claim"]
            )
        }
        
        // Check against known biblical book dates
        _ = biblicalFacts.bookDatingInfo
        
        // Simplified check - in production would parse and compare dates
        let evidence = [
            FactCheckResult.Evidence(
                source: "Biblical Scholarship",
                description: "Based on linguistic analysis and historical context",
                reliability: .scholarly
            )
        ]
        
        return FactCheckResult(
            claim: claim,
            verdict: .plausible,
            confidence: 0.75,
            evidence: evidence,
            corrections: []
        )
    }
    
    private func checkAuthorshipClaim(_ claim: String) async -> FactCheckResult {
        let authorshipInfo = biblicalFacts.authorshipInfo
        
        // Extract book and author
        _ = #"(\w+)\s+.*written by\s+(\w+)"#
        
        var verdict: FactCheckResult.Verdict = .plausible
        var corrections: [String] = []
        
        // Check if claim matches traditional authorship
        for (book, info) in authorshipInfo {
            if claim.lowercased().contains(book.lowercased()) {
                if info.isDisputed {
                    verdict = .disputed
                    corrections.append("Authorship of \(book) is debated among scholars")
                } else if claim.lowercased().contains(info.traditionalAuthor.lowercased()) {
                    verdict = .verified
                } else {
                    verdict = .incorrect
                    corrections.append("\(book) is traditionally attributed to \(info.traditionalAuthor)")
                }
                break
            }
        }
        
        return FactCheckResult(
            claim: claim,
            verdict: verdict,
            confidence: verdict == .verified ? 0.9 : 0.6,
            evidence: [
                FactCheckResult.Evidence(
                    source: "Traditional Attribution",
                    description: "Based on church tradition and internal evidence",
                    reliability: .traditional
                )
            ],
            corrections: corrections
        )
    }
    
    private func checkPersonClaim(_ claim: String) async -> FactCheckResult {
        let biblicalPersons = biblicalFacts.biblicalPersons
        
        var verdict: FactCheckResult.Verdict = .unverifiable
        var evidence: [FactCheckResult.Evidence] = []
        
        for (person, info) in biblicalPersons {
            if claim.lowercased().contains(person.lowercased()) {
                // Check if the claim about their role is accurate
                if claim.lowercased().contains(info.role.lowercased()) {
                    verdict = .verified
                    evidence.append(FactCheckResult.Evidence(
                        source: "Biblical Text",
                        description: info.references.joined(separator: ", "),
                        reliability: .primary
                    ))
                } else {
                    verdict = .incorrect
                }
                break
            }
        }
        
        return FactCheckResult(
            claim: claim,
            verdict: verdict,
            confidence: verdict == .verified ? 0.95 : 0.3,
            evidence: evidence,
            corrections: verdict == .incorrect ? ["Check biblical references for accurate information"] : []
        )
    }
    
    private func checkLinguisticClaim(_ claim: String) async -> FactCheckResult {
        // Check Hebrew/Greek word meanings
        let linguisticData = biblicalFacts.linguisticInfo
        
        var verdict: FactCheckResult.Verdict = .plausible
        var evidence: [FactCheckResult.Evidence] = []
        
        for (word, info) in linguisticData {
            if claim.lowercased().contains(word.lowercased()) {
                if claim.lowercased().contains(info.meaning.lowercased()) {
                    verdict = .verified
                    evidence.append(FactCheckResult.Evidence(
                        source: "Lexical Analysis",
                        description: "Based on \(info.language) lexicons",
                        reliability: .scholarly
                    ))
                }
                break
            }
        }
        
        return FactCheckResult(
            claim: claim,
            verdict: verdict,
            confidence: 0.8,
            evidence: evidence,
            corrections: []
        )
    }
    
    private func checkGeographicalClaim(_ claim: String) async -> FactCheckResult {
        let geographicalData = biblicalFacts.geographicalInfo
        
        var verdict: FactCheckResult.Verdict = .plausible
        var evidence: [FactCheckResult.Evidence] = []
        
        for (location, info) in geographicalData {
            if claim.lowercased().contains(location.lowercased()) {
                verdict = info.archaeologicalEvidence ? .verified : .plausible
                evidence.append(FactCheckResult.Evidence(
                    source: info.archaeologicalEvidence ? "Archaeological Evidence" : "Historical Records",
                    description: info.modernLocation ?? "Ancient Near East",
                    reliability: info.archaeologicalEvidence ? .archaeological : .scholarly
                ))
                break
            }
        }
        
        return FactCheckResult(
            claim: claim,
            verdict: verdict,
            confidence: verdict == .verified ? 0.9 : 0.7,
            evidence: evidence,
            corrections: []
        )
    }
    
    private func checkTheologicalClaim(_ claim: String) async -> FactCheckResult {
        let orthodoxDoctrine = biblicalFacts.orthodoxDoctrine
        
        var verdict: FactCheckResult.Verdict = .plausible
        var corrections: [String] = []
        
        // Check against core doctrines
        for (doctrine, _) in orthodoxDoctrine {
            if claim.lowercased().contains(doctrine.lowercased()) {
                // Simplified check - in production would do deeper analysis
                verdict = .verified
                break
            }
        }
        
        // Check for heretical statements
        let heresies = [
            "jesus was created", "god is not trinity", "salvation by works alone",
            "bible contains errors", "all religions lead to god"
        ]
        
        for heresy in heresies {
            if claim.lowercased().contains(heresy) {
                verdict = .incorrect
                corrections.append("This contradicts orthodox Christian doctrine")
                break
            }
        }
        
        return FactCheckResult(
            claim: claim,
            verdict: verdict,
            confidence: verdict == .verified ? 0.85 : 0.4,
            evidence: [
                FactCheckResult.Evidence(
                    source: "Orthodox Christian Doctrine",
                    description: "Based on historic creeds and biblical teaching",
                    reliability: .traditional
                )
            ],
            corrections: corrections
        )
    }
    
    private func checkGeneralClaim(_ claim: String) async -> FactCheckResult {
        // For general claims, return cautious result
        return FactCheckResult(
            claim: claim,
            verdict: .unverifiable,
            confidence: 0.5,
            evidence: [],
            corrections: ["Unable to verify this specific claim"]
        )
    }
    
    // MARK: - Claim Extraction
    
    private func extractClaims(from content: String) -> [String] {
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Filter for sentences that appear to make factual claims
        return sentences.filter { sentence in
            let lowercased = sentence.lowercased()
            return lowercased.contains("was") || lowercased.contains("were") ||
                   lowercased.contains("is") || lowercased.contains("are") ||
                   lowercased.contains("written") || lowercased.contains("means") ||
                   lowercased.contains("located") || lowercased.contains("happened")
        }
    }
}

// MARK: - Biblical Facts Database

/// Simplified biblical facts database
/// In production, this would connect to a comprehensive database
private struct BiblicalFactsDatabase {
    
    let bookDatingInfo: [String: (earliestDate: String, latestDate: String, consensus: String)] = [
        "Genesis": ("-1400", "-400", "Mosaic authorship traditionally, compiled later"),
        "Matthew": ("70", "90", "Post-temple destruction"),
        "John": ("90", "110", "Late first century"),
        "Romans": ("55", "58", "During Paul's third missionary journey"),
        "Revelation": ("81", "96", "During Domitian's reign")
    ]
    
    let authorshipInfo: [String: (traditionalAuthor: String, isDisputed: Bool)] = [
        "Genesis": ("Moses", true),
        "Psalms": ("David and others", false),
        "Proverbs": ("Solomon and others", false),
        "Isaiah": ("Isaiah", true),
        "Matthew": ("Matthew", true),
        "John": ("John the Apostle", true),
        "Romans": ("Paul", false),
        "Hebrews": ("Unknown", true)
    ]
    
    let biblicalPersons: [String: (role: String, period: String, references: [String])] = [
        "David": ("King", "1000 BC", ["1 Samuel 16", "2 Samuel", "1 Kings 1-2"]),
        "Moses": ("Prophet", "1400 BC", ["Exodus", "Leviticus", "Numbers", "Deuteronomy"]),
        "Paul": ("Apostle", "1st century AD", ["Acts 9", "Romans-Philemon"]),
        "Peter": ("Apostle", "1st century AD", ["Gospels", "Acts", "1-2 Peter"]),
        "Abraham": ("Patriarch", "2000 BC", ["Genesis 12-25"])
    ]
    
    let linguisticInfo: [String: (language: String, meaning: String)] = [
        "Yahweh": ("Hebrew", "I AM, the personal name of God"),
        "Messiah": ("Hebrew", "Anointed One"),
        "Christ": ("Greek", "Anointed One (Greek equivalent of Messiah)"),
        "Gospel": ("Greek", "Good News"),
        "Shalom": ("Hebrew", "Peace, wholeness, completeness"),
        "Agape": ("Greek", "Unconditional love")
    ]
    
    let geographicalInfo: [String: (modernLocation: String?, archaeologicalEvidence: Bool)] = [
        "Jerusalem": ("Jerusalem, Israel", true),
        "Babylon": ("Near Baghdad, Iraq", true),
        "Nineveh": ("Near Mosul, Iraq", true),
        "Ephesus": ("Near Selçuk, Turkey", true),
        "Nazareth": ("Nazareth, Israel", true),
        "Jericho": ("Near modern Jericho", true)
    ]
    
    let orthodoxDoctrine: [String: String] = [
        "Trinity": "One God in three persons: Father, Son, and Holy Spirit",
        "Incarnation": "Jesus Christ is fully God and fully human",
        "Salvation": "By grace through faith, not by works",
        "Resurrection": "Jesus physically rose from the dead",
        "Scripture": "The Bible is the inspired Word of God",
        "Second Coming": "Jesus will return to judge the living and the dead"
    ]
}