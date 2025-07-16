import Foundation

// MARK: - Life Situations Data Provider
public final class LifeSituationsDataProvider {
    
    public static let shared = LifeSituationsDataProvider()
    
    private init() {}
    
    public func getAllSituations() -> [LifeSituation] {
        return emotionalSituations + 
               spiritualSituations + 
               relationalSituations + 
               financialSituations + 
               physicalSituations + 
               decisionMakingSituations +
               dailyLifeSituations
    }
    
    // MARK: - Emotional Life Situations
    private let emotionalSituations: [LifeSituation] = [
        LifeSituation(
            id: "anxiety-general",
            title: "Dealing with Anxiety",
            description: "When worry and fear overwhelm your heart and mind",
            category: .emotional,
            verses: [
                BibleReference(id: <#String#>, reference: "Philippians 4:6-7", preview: "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God."),
                BibleReference(id: <#String#>, reference: "1 Peter 5:7", preview: "Cast all your anxiety on him because he cares for you."),
                BibleReference(id: <#String#>, reference: "Matthew 6:25-26", preview: "Therefore I tell you, do not worry about your life, what you will eat or drink; or about your body, what you will wear."),
                BibleReference(id: <#String#>, reference: "Psalm 94:19", preview: "When anxiety was great within me, your consolation brought me joy."),
                BibleReference(id: <#String#>, reference: "Isaiah 41:10", preview: "So do not fear, for I am with you; do not be dismayed, for I am your God.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Peace from Anxiety",
                    content: "Heavenly Father, I come before You with a heart full of anxiety. Your Word tells me not to be anxious about anything, but to bring everything to You in prayer. I lay down my worries at Your feet. Fill me with Your peace that surpasses all understanding. Help me to trust in Your perfect plan and timing. Guard my heart and mind in Christ Jesus. Amen."
                )
            ],
            resources: [
                ResourceLink(title: "Understanding Biblical Anxiety", url: "https://example.com/anxiety"),
                ResourceLink(title: "Breathing Prayers for Calm", url: "https://example.com/prayers")
            ],
            iconName: "brain.head.profile",
            tags: ["anxiety", "worry", "fear", "peace", "trust"]
        ),
        
        LifeSituation(
            id: "depression-hopelessness",
            title: "Overcoming Depression",
            description: "Finding hope when darkness seems overwhelming",
            category: .emotional,
            verses: [
                BibleReference(id: <#String#>, reference: "Psalm 42:11", preview: "Why, my soul, are you downcast? Why so disturbed within me? Put your hope in God."),
                BibleReference(id: <#String#>, reference: "Psalm 34:17-18", preview: "The righteous cry out, and the Lord hears them; he delivers them from all their troubles."),
                BibleReference(id: <#String#>, reference: "Isaiah 61:3", preview: "To provide for those who grieve in Zion—to bestow on them a crown of beauty instead of ashes."),
                BibleReference(id: <#String#>, reference: "2 Corinthians 1:3-4", preview: "Praise be to the God and Father of our Lord Jesus Christ, the Father of compassion and the God of all comfort."),
                BibleReference(id: <#String#>, reference: "Jeremiah 29:11", preview: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Light in Darkness",
                    content: "Lord Jesus, You are the light of the world. In this season of darkness and depression, I need Your light to shine in my heart. Lift the heavy burden from my soul. Restore to me the joy of Your salvation. Help me to see hope where I see none, and give me the strength to take one more step forward. Surround me with Your love and the support of caring people. In Your name, Amen."
                )
            ],
            resources: [],
            iconName: "moon.stars",
            tags: ["depression", "sadness", "hope", "darkness", "healing"]
        ),
        
        LifeSituation(
            id: "anger-management",
            title: "Managing Anger",
            description: "Handling anger in a godly way",
            category: .emotional,
            verses: [
                BibleReference(id: <#String#>, reference: "Ephesians 4:26-27", preview: "In your anger do not sin: Do not let the sun go down while you are still angry."),
                BibleReference(id: <#String#>, reference: "James 1:19-20", preview: "Everyone should be quick to listen, slow to speak and slow to become angry."),
                BibleReference(id: <#String#>, reference: "Proverbs 15:1", preview: "A gentle answer turns away wrath, but a harsh word stirs up anger."),
                BibleReference(id: <#String#>, reference: "Colossians 3:8", preview: "But now you must also rid yourselves of all such things as these: anger, rage, malice."),
                BibleReference(id: <#String#>, reference: "Psalm 37:8", preview: "Refrain from anger and turn from wrath; do not fret—it leads only to evil.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Self-Control",
                    content: "Father God, I confess my struggle with anger. Grant me Your spirit of self-control. Help me to be slow to anger and quick to listen. Transform my heart so that I respond with love instead of wrath. Show me the root of my anger and heal any wounds that fuel it. Make me an instrument of Your peace. Through Jesus Christ, Amen."
                )
            ],
            resources: [],
            iconName: "flame",
            tags: ["anger", "self-control", "forgiveness", "peace", "patience"]
        )
    ]
    
    // MARK: - Spiritual Life Situations
    private let spiritualSituations: [LifeSituation] = [
        LifeSituation(
            id: "spiritual-dryness",
            title: "Spiritual Dryness",
            description: "When God feels distant and prayer seems empty",
            category: .spiritual,
            verses: [
                BibleReference(id: <#String#>, reference: "Psalm 63:1", preview: "You, God, are my God, earnestly I seek you; I thirst for you, my whole being longs for you."),
                BibleReference(id: <#String#>, reference: "Isaiah 55:1", preview: "Come, all you who are thirsty, come to the waters; and you who have no money, come, buy and eat!"),
                BibleReference(id: <#String#>, reference: "Psalm 42:1-2", preview: "As the deer pants for streams of water, so my soul pants for you, my God."),
                BibleReference(id: <#String#>, reference: "John 7:37-38", preview: "Let anyone who is thirsty come to me and drink."),
                BibleReference(id: <#String#>, reference: "Psalm 84:2", preview: "My soul yearns, even faints, for the courts of the Lord.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Spiritual Renewal",
                    content: "Living Water, I come to You in my spiritual dryness. My soul thirsts for You like a parched land. Revive my spirit, Lord. Restore the joy of intimate communion with You. Help me to persevere in prayer even when I don't feel Your presence. I trust that You are near even when You seem far. Pour out Your Spirit afresh upon me. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "drop",
            tags: ["spiritual", "dryness", "prayer", "renewal", "thirst"]
        ),
        
        LifeSituation(
            id: "doubt-faith",
            title: "Struggling with Doubt",
            description: "When questions shake your faith foundation",
            category: .spiritual,
            verses: [
                BibleReference(id: <#String#>, reference: "Mark 9:24", preview: "I do believe; help me overcome my unbelief!"),
                BibleReference(id: <#String#>, reference: "Jude 1:22", preview: "Be merciful to those who doubt."),
                BibleReference(id: <#String#>, reference: "Matthew 14:31", preview: "Immediately Jesus reached out his hand and caught him. 'You of little faith,' he said, 'why did you doubt?'"),
                BibleReference(id: <#String#>, reference: "John 20:27-29", preview: "Stop doubting and believe... blessed are those who have not seen and yet have believed."),
                BibleReference(id: <#String#>, reference: "Hebrews 11:1", preview: "Now faith is confidence in what we hope for and assurance about what we do not see.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Strengthened Faith",
                    content: "Lord, I believe; help my unbelief. Like Thomas, I sometimes need to see and touch before I can fully trust. Strengthen my faith where it is weak. Give me wisdom to understand what I can, and faith to trust what I cannot. Help me to hold onto You even in the midst of questions and doubts. You are bigger than my doubts. In Christ, Amen."
                )
            ],
            resources: [],
            iconName: "questionmark.circle",
            tags: ["doubt", "faith", "questions", "belief", "trust"]
        )
    ]
    
    // MARK: - Relational Life Situations
    private let relationalSituations: [LifeSituation] = [
        LifeSituation(
            id: "marriage-struggles",
            title: "Marriage Difficulties",
            description: "Navigating challenges in your marriage with God's wisdom",
            category: .relational,
            verses: [
                BibleReference(id: <#String#>, reference: "Ephesians 5:25", preview: "Husbands, love your wives, just as Christ loved the church and gave himself up for her."),
                BibleReference(id: <#String#>, reference: "1 Corinthians 13:4-7", preview: "Love is patient, love is kind... It always protects, always trusts, always hopes, always perseveres."),
                BibleReference(id: <#String#>, reference: "Ephesians 4:32", preview: "Be kind and compassionate to one another, forgiving each other, just as in Christ God forgave you."),
                BibleReference(id: <#String#>, reference: "1 Peter 3:7", preview: "Husbands, in the same way be considerate as you live with your wives."),
                BibleReference(id: <#String#>, reference: "Colossians 3:18-19", preview: "Wives, submit yourselves to your husbands... Husbands, love your wives and do not be harsh with them.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Marriage Restoration",
                    content: "Lord, we invite You into our marriage. Where there is hurt, bring healing. Where there is misunderstanding, bring clarity. Where love has grown cold, rekindle it with Your fire. Help us to see each other through Your eyes of love. Give us patience, kindness, and the humility to serve one another. Restore our marriage to honor You. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "heart.circle",
            tags: ["marriage", "relationship", "love", "conflict", "reconciliation"]
        ),
        
        LifeSituation(
            id: "parenting-challenges",
            title: "Parenting Struggles",
            description: "Raising children with godly wisdom and patience",
            category: .relational,
            verses: [
                BibleReference(id: <#String#>, reference: "Proverbs 22:6", preview: "Start children off on the way they should go, and even when they are old they will not turn from it."),
                BibleReference(id: <#String#>, reference: "Ephesians 6:4", preview: "Fathers, do not exasperate your children; instead, bring them up in the training and instruction of the Lord."),
                BibleReference(id: <#String#>, reference: "Psalm 127:3", preview: "Children are a heritage from the Lord, offspring a reward from him."),
                BibleReference(id: <#String#>, reference: "Colossians 3:21", preview: "Fathers, do not embitter your children, or they will become discouraged."),
                BibleReference(id: <#String#>, reference: "Deuteronomy 6:6-7", preview: "These commandments... Impress them on your children. Talk about them when you sit at home.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Parenting Wisdom",
                    content: "Heavenly Father, You have entrusted these precious children to my care. Grant me wisdom beyond my own to guide them in Your ways. Give me patience when I am frustrated, love when I am angry, and consistency when I am weary. Help me to see my children as You see them, and to nurture their unique gifts. Make me the parent You've called me to be. Through Christ, Amen."
                )
            ],
            resources: [],
            iconName: "figure.2.and.child.holdinghands",
            tags: ["parenting", "children", "family", "wisdom", "patience"]
        )
    ]
    
    // MARK: - Financial Life Situations
    private let financialSituations: [LifeSituation] = [
        LifeSituation(
            id: "financial-stress",
            title: "Financial Hardship",
            description: "Trusting God's provision in times of need",
            category: .financial,
            verses: [
                BibleReference(id: <#String#>, reference: "Philippians 4:19", preview: "And my God will meet all your needs according to the riches of his glory in Christ Jesus."),
                BibleReference(id: <#String#>, reference: "Matthew 6:31-33", preview: "So do not worry, saying, 'What shall we eat?'... But seek first his kingdom and his righteousness."),
                BibleReference(id: <#String#>, reference: "Psalm 37:25", preview: "I was young and now I am old, yet I have never seen the righteous forsaken or their children begging bread."),
                BibleReference(id: <#String#>, reference: "2 Corinthians 9:8", preview: "And God is able to bless you abundantly, so that in all things at all times, having all that you need."),
                BibleReference(id: <#String#>, reference: "Proverbs 3:9-10", preview: "Honor the Lord with your wealth, with the firstfruits of all your crops.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Financial Provision",
                    content: "Provider God, I bring my financial needs before You. You own the cattle on a thousand hills, and nothing is impossible for You. Help me to be a good steward of what You've given me. Show me wisdom in my spending and opportunities for provision. I trust You to meet my needs according to Your riches in glory. Thank You for Your faithfulness. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "dollarsign.circle",
            tags: ["finances", "money", "provision", "stewardship", "trust"]
        ),
        
        LifeSituation(
            id: "job-loss",
            title: "Job Loss or Career Change",
            description: "Finding hope and direction after employment changes",
            category: .financial,
            verses: [
                BibleReference(id: <#String#>, reference: "Jeremiah 29:11", preview: "For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you."),
                BibleReference(id: <#String#>, reference: "Isaiah 43:18-19", preview: "Forget the former things; do not dwell on the past. See, I am doing a new thing!"),
                BibleReference(id: <#String#>, reference: "Psalm 32:8", preview: "I will instruct you and teach you in the way you should go; I will counsel you with my loving eye on you."),
                BibleReference(id: <#String#>, reference: "Proverbs 16:9", preview: "In their hearts humans plan their course, but the Lord establishes their steps."),
                BibleReference(id: <#String#>, reference: "Romans 8:28", preview: "And we know that in all things God works for the good of those who love him.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Career Direction",
                    content: "Lord of all work, I trust You with my career and livelihood. Though this change is difficult, I believe You have a plan. Open doors that no one can shut, and close doors that need to be closed. Give me wisdom in my job search, favor with potential employers, and peace in the waiting. Use this season to draw me closer to You. Your will be done. Amen."
                )
            ],
            resources: [],
            iconName: "briefcase",
            tags: ["job", "career", "unemployment", "work", "provision"]
        )
    ]
    
    // MARK: - Physical Life Situations
    private let physicalSituations: [LifeSituation] = [
        LifeSituation(
            id: "illness-healing",
            title: "Facing Illness",
            description: "Seeking God's healing and strength in sickness",
            category: .physical,
            verses: [
                BibleReference(id: <#String#>, reference: "James 5:14-15", preview: "Is anyone among you sick? Let them call the elders of the church to pray over them."),
                BibleReference(id: <#String#>, reference: "Psalm 103:2-3", preview: "Praise the Lord, my soul, and forget not all his benefits—who forgives all your sins and heals all your diseases."),
                BibleReference(id: <#String#>, reference: "Isaiah 53:5", preview: "But he was pierced for our transgressions... and by his wounds we are healed."),
                BibleReference(id: <#String#>, reference: "3 John 1:2", preview: "Dear friend, I pray that you may enjoy good health and that all may go well with you."),
                BibleReference(id: <#String#>, reference: "Psalm 41:3", preview: "The Lord sustains them on their sickbed and restores them from their bed of illness.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Healing",
                    content: "Great Physician, I come to You for healing. You know every cell in my body and every concern in my heart. I ask for Your healing touch - whether through medical treatment, miraculous intervention, or the ultimate healing of heaven. Give me strength for each day, peace in uncertainty, and faith to trust Your perfect will. Surround me with Your presence. In the name of Jesus, the Healer, Amen."
                )
            ],
            resources: [],
            iconName: "heart.text.square",
            tags: ["healing", "illness", "health", "sickness", "faith"]
        ),
        
        LifeSituation(
            id: "chronic-pain",
            title: "Living with Chronic Pain",
            description: "Finding God's grace sufficient in ongoing suffering",
            category: .physical,
            verses: [
                BibleReference(id: <#String#>, reference: "2 Corinthians 12:9", preview: "My grace is sufficient for you, for my power is made perfect in weakness."),
                BibleReference(id: <#String#>, reference: "Romans 8:18", preview: "I consider that our present sufferings are not worth comparing with the glory that will be revealed in us."),
                BibleReference(id: <#String#>, reference: "2 Corinthians 4:16-17", preview: "Therefore we do not lose heart. Though outwardly we are wasting away, yet inwardly we are being renewed."),
                BibleReference(id: <#String#>, reference: "Psalm 34:19", preview: "The righteous person may have many troubles, but the Lord delivers him from them all."),
                BibleReference(id: <#String#>, reference: "Revelation 21:4", preview: "He will wipe every tear from their eyes. There will be no more death or mourning or crying or pain.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Endurance in Pain",
                    content: "Lord Jesus, You understand suffering and pain. In my chronic struggle, be my constant companion. When the pain is overwhelming, be my strength. When I want to give up, be my hope. Help me to find purpose in my pain and to encourage others who suffer. May Your grace be sufficient for me today. I look forward to the day when all pain will cease. Until then, sustain me. Amen."
                )
            ],
            resources: [],
            iconName: "bandage",
            tags: ["pain", "suffering", "chronic", "endurance", "grace"]
        )
    ]
    
    // MARK: - Decision Making Situations
    private let decisionMakingSituations: [LifeSituation] = [
        LifeSituation(
            id: "major-decision",
            title: "Making Major Decisions",
            description: "Seeking God's guidance for important life choices",
            category: .spiritual,
            verses: [
                BibleReference(id: <#String#>, reference: "James 1:5", preview: "If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault."),
                BibleReference(id: <#String#>, reference: "Proverbs 3:5-6", preview: "Trust in the Lord with all your heart and lean not on your own understanding."),
                BibleReference(id: <#String#>, reference: "Psalm 25:4-5", preview: "Show me your ways, Lord, teach me your paths. Guide me in your truth and teach me."),
                BibleReference(id: <#String#>, reference: "Isaiah 30:21", preview: "Whether you turn to the right or to the left, your ears will hear a voice behind you, saying, 'This is the way; walk in it.'"),
                BibleReference(id: <#String#>, reference: "Psalm 32:8", preview: "I will instruct you and teach you in the way you should go.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Prayer for Clear Direction",
                    content: "All-knowing God, I stand at a crossroads and need Your direction. You see the end from the beginning and know which path is best. Grant me wisdom beyond my understanding. Open and close doors according to Your will. Give me peace about the right decision and courage to follow through. I surrender my plans to You and trust Your guidance. Lead me, Lord. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "arrow.triangle.branch",
            tags: ["decisions", "guidance", "wisdom", "direction", "choices"]
        )
    ]
    
    // MARK: - Daily Life Situations
    private let dailyLifeSituations: [LifeSituation] = [
        LifeSituation(
            id: "starting-day",
            title: "Starting Your Day",
            description: "Beginning each morning with God's presence",
            category: .spiritual,
            verses: [
                BibleReference(id: <#String#>, reference: "Psalm 5:3", preview: "In the morning, Lord, you hear my voice; in the morning I lay my requests before you and wait expectantly."),
                BibleReference(id: <#String#>, reference: "Lamentations 3:22-23", preview: "His mercies... are new every morning; great is your faithfulness."),
                BibleReference(id: <#String#>, reference: "Psalm 143:8", preview: "Let the morning bring me word of your unfailing love, for I have put my trust in you."),
                BibleReference(id: <#String#>, reference: "Mark 1:35", preview: "Very early in the morning, while it was still dark, Jesus got up... and went off to a solitary place, where he prayed."),
                BibleReference(id: <#String#>, reference: "Psalm 90:14", preview: "Satisfy us in the morning with your unfailing love, that we may sing for joy and be glad all our days.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Morning Prayer",
                    content: "Good morning, Lord. Thank You for the gift of a new day. Your mercies are new this morning, and I'm grateful. Guide my steps today. Help me to walk in Your ways and reflect Your love to everyone I meet. Give me strength for today's challenges and wisdom for today's decisions. May this day bring glory to Your name. I commit all my plans to You. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "sunrise",
            tags: ["morning", "daily", "routine", "prayer", "devotion"]
        ),
        
        LifeSituation(
            id: "ending-day",
            title: "Ending Your Day",
            description: "Finding peace and rest in God's presence at night",
            category: .spiritual,
            verses: [
                BibleReference(id: <#String#>, reference: "Psalm 4:8", preview: "In peace I will lie down and sleep, for you alone, Lord, make me dwell in safety."),
                BibleReference(id: <#String#>, reference: "Psalm 63:6", preview: "On my bed I remember you; I think of you through the watches of the night."),
                BibleReference(id: <#String#>, reference: "Psalm 92:2", preview: "proclaiming your love in the morning and your faithfulness at night"),
                BibleReference(id: <#String#>, reference: "Psalm 139:11-12", preview: "Even the darkness will not be dark to you; the night will shine like the day."),
                BibleReference(id: <#String#>, reference: "Matthew 11:28", preview: "Come to me, all you who are weary and burdened, and I will give you rest.")
            ],
            prayers: [
                Prayer(
                    id: <#String#>, title: "Evening Prayer",
                    content: "Father, as this day comes to an end, I thank You for Your faithfulness. Forgive me for the ways I've fallen short today. Thank You for the blessings, both seen and unseen. As I prepare for rest, I release all my worries to You. Watch over my loved ones tonight. Grant me peaceful sleep and prepare me for tomorrow. I trust in Your protection through the night. In Jesus' name, Amen."
                )
            ],
            resources: [],
            iconName: "moon.stars",
            tags: ["evening", "night", "rest", "peace", "sleep"]
        )
    ]
}
