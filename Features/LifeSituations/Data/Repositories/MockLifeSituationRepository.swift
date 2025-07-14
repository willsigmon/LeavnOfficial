import Foundation

public final class MockLifeSituationRepository: LifeSituationRepository {
    
    private var viewedSituations: Set<String> = []
    private var favoriteSituations: Set<String> = []
    
    public init() {}
    
    public func getLifeSituations() async throws -> [LifeSituation] {
        // Return mock life situations
        return MockLifeSituationData.allSituations
    }
    
    public func getLifeSituation(by id: String) async throws -> LifeSituation? {
        return MockLifeSituationData.allSituations.first { $0.id == id }
    }
    
    public func searchLifeSituations(query: String) async throws -> [LifeSituation] {
        let lowercasedQuery = query.lowercased()
        return MockLifeSituationData.allSituations.filter { situation in
            situation.title.lowercased().contains(lowercasedQuery) ||
            situation.description.lowercased().contains(lowercasedQuery) ||
            situation.tags.contains { $0.lowercased().contains(lowercasedQuery) }
        }
    }
    
    public func getRecentlyViewed() async throws -> [LifeSituation] {
        return MockLifeSituationData.allSituations.filter { viewedSituations.contains($0.id) }
    }
    
    public func markAsViewed(_ situation: LifeSituation) async throws {
        viewedSituations.insert(situation.id)
    }
    
    public func getFavorites() async throws -> [LifeSituation] {
        return MockLifeSituationData.allSituations.filter { favoriteSituations.contains($0.id) }
    }
    
    public func toggleFavorite(_ situation: LifeSituation) async throws {
        if favoriteSituations.contains(situation.id) {
            favoriteSituations.remove(situation.id)
        } else {
            favoriteSituations.insert(situation.id)
        }
    }
}

// MARK: - Mock Data
private struct MockLifeSituationData {
    static let allSituations: [LifeSituation] = [
        // Anxiety & Worry
        LifeSituation(
            id: "anxiety-work",
            title: "Feeling Anxious About Work",
            description: "When work pressures and deadlines overwhelm you, find peace in God's promises",
            category: .emotional,
            verses: [
                BibleReference(reference: "Philippians 4:6-7", preview: "Do not be anxious about anything, but in everything by prayer..."),
                BibleReference(reference: "Matthew 6:34", preview: "Therefore do not worry about tomorrow..."),
                BibleReference(reference: "1 Peter 5:7", preview: "Cast all your anxiety on him because he cares for you")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Peace at Work",
                    content: "Lord, I bring my work anxieties before You. Help me to trust in Your provision and find peace in Your presence. Grant me wisdom to handle my responsibilities and faith to release my worries to You. Amen."
                )
            ],
            resources: [],
            iconName: "briefcase.circle.fill",
            tags: ["anxiety", "work", "stress", "peace", "worry"]
        ),
        
        // Grief & Loss
        LifeSituation(
            id: "grief-loss",
            title: "Dealing with Grief and Loss",
            description: "Finding comfort in God's presence during times of mourning and sorrow",
            category: .emotional,
            verses: [
                BibleReference(reference: "Psalm 34:18", preview: "The Lord is close to the brokenhearted..."),
                BibleReference(reference: "Matthew 5:4", preview: "Blessed are those who mourn, for they will be comforted"),
                BibleReference(reference: "Revelation 21:4", preview: "He will wipe every tear from their eyes...")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Comfort in Grief",
                    content: "Heavenly Father, my heart is heavy with loss. Wrap me in Your comforting arms and help me feel Your presence. Give me strength to face each day and hope for the future. Thank You for the promise of eternal life. Amen."
                )
            ],
            resources: [],
            iconName: "heart.circle.fill",
            tags: ["grief", "loss", "mourning", "comfort", "death"]
        ),
        
        // Joy & Gratitude
        LifeSituation(
            id: "joy-gratitude",
            title: "Celebrating Joy and Blessings",
            description: "Expressing gratitude and rejoicing in God's goodness",
            category: .spiritual,
            verses: [
                BibleReference(reference: "Psalm 118:24", preview: "This is the day the Lord has made; let us rejoice..."),
                BibleReference(reference: "1 Thessalonians 5:16-18", preview: "Rejoice always, pray continually, give thanks..."),
                BibleReference(reference: "Philippians 4:4", preview: "Rejoice in the Lord always. I will say it again: Rejoice!")
            ],
            prayers: [
                Prayer(
                    title: "Prayer of Thanksgiving",
                    content: "Lord, my heart overflows with gratitude for Your blessings. Thank You for Your faithfulness, love, and provision. Help me to always maintain a grateful heart and share Your joy with others. Amen."
                )
            ],
            resources: [],
            iconName: "star.circle.fill",
            tags: ["joy", "gratitude", "thankfulness", "blessing", "celebration"]
        ),
        
        // Relationship Struggles
        LifeSituation(
            id: "relationship-conflict",
            title: "Navigating Relationship Conflicts",
            description: "Seeking wisdom and reconciliation in difficult relationships",
            category: .relational,
            verses: [
                BibleReference(reference: "Ephesians 4:32", preview: "Be kind and compassionate to one another, forgiving..."),
                BibleReference(reference: "Matthew 18:15", preview: "If your brother or sister sins, go and point out their fault..."),
                BibleReference(reference: "Colossians 3:13", preview: "Bear with each other and forgive one another...")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Relationship Healing",
                    content: "Lord, I need Your wisdom in this relationship. Soften our hearts, help us communicate with love, and guide us toward reconciliation. Give us the humility to forgive and the courage to seek forgiveness. Amen."
                )
            ],
            resources: [],
            iconName: "person.2.circle.fill",
            tags: ["relationships", "conflict", "forgiveness", "reconciliation", "communication"]
        ),
        
        // Financial Stress
        LifeSituation(
            id: "financial-worry",
            title: "Financial Worries and Provision",
            description: "Trusting God's provision during financial difficulties",
            category: .financial,
            verses: [
                BibleReference(reference: "Philippians 4:19", preview: "And my God will meet all your needs according to..."),
                BibleReference(reference: "Matthew 6:26", preview: "Look at the birds of the air; they do not sow or reap..."),
                BibleReference(reference: "Proverbs 3:5-6", preview: "Trust in the Lord with all your heart...")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Financial Peace",
                    content: "Father, I surrender my financial worries to You. Help me to be a good steward of what You've given me and trust in Your provision. Give me wisdom in financial decisions and peace in uncertainty. Amen."
                )
            ],
            resources: [],
            iconName: "dollarsign.circle.fill",
            tags: ["finances", "money", "provision", "worry", "trust"]
        ),
        
        // Health Concerns
        LifeSituation(
            id: "health-concerns",
            title: "Facing Health Challenges",
            description: "Finding strength and hope during illness or health concerns",
            category: .physical,
            verses: [
                BibleReference(reference: "Psalm 103:2-3", preview: "Praise the Lord, my soul... who heals all your diseases"),
                BibleReference(reference: "Isaiah 41:10", preview: "So do not fear, for I am with you; do not be dismayed..."),
                BibleReference(reference: "James 5:15", preview: "And the prayer offered in faith will make the sick person well")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Healing",
                    content: "Great Physician, I come to You in my time of need. Grant healing to my body, peace to my mind, and strength to my spirit. Help me trust in Your perfect will and find comfort in Your presence. Amen."
                )
            ],
            resources: [],
            iconName: "heart.text.square.fill",
            tags: ["health", "healing", "illness", "strength", "faith"]
        ),
        
        // Loneliness
        LifeSituation(
            id: "feeling-lonely",
            title: "Overcoming Loneliness",
            description: "Finding companionship in God's presence and community",
            category: .emotional,
            verses: [
                BibleReference(reference: "Deuteronomy 31:6", preview: "The Lord your God goes with you; he will never leave..."),
                BibleReference(reference: "Psalm 68:6", preview: "God sets the lonely in families..."),
                BibleReference(reference: "Matthew 28:20", preview: "And surely I am with you always, to the very end of the age")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Companionship",
                    content: "Lord, in my loneliness, remind me that You are always with me. Fill the empty spaces in my heart with Your love. Lead me to meaningful connections and help me be a friend to others who feel alone. Amen."
                )
            ],
            resources: [],
            iconName: "person.circle.fill",
            tags: ["loneliness", "alone", "companionship", "community", "presence"]
        ),
        
        // Purpose & Direction
        LifeSituation(
            id: "seeking-purpose",
            title: "Seeking Purpose and Direction",
            description: "Discovering God's plan and purpose for your life",
            category: .spiritual,
            verses: [
                BibleReference(reference: "Jeremiah 29:11", preview: "For I know the plans I have for you..."),
                BibleReference(reference: "Proverbs 16:9", preview: "In their hearts humans plan their course, but the Lord..."),
                BibleReference(reference: "Romans 8:28", preview: "And we know that in all things God works for the good...")
            ],
            prayers: [
                Prayer(
                    title: "Prayer for Direction",
                    content: "Lord, I seek Your will for my life. Open my eyes to see the path You have for me. Give me courage to follow where You lead and patience to wait for Your timing. Help me trust that Your plans are perfect. Amen."
                )
            ],
            resources: [],
            iconName: "map.circle.fill",
            tags: ["purpose", "direction", "calling", "guidance", "plans"]
        )
    ]
}