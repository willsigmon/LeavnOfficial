import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// Import HapticManager if available
#if canImport(LeavnCore)
#else
// Minimal HapticManager implementation
@MainActor
final class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func impact(_ style: Int) {
        #if canImport(UIKit)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
}
#endif

// MARK: - Import necessary types
#if canImport(LifeSituationModels)
import LifeSituationModels
#endif

// MARK: - Temporary Type Definitions (remove when imports work)
public struct LifeSituation: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let category: LifeSituationCategory
    public let verses: [BibleReference]
    public let prayers: [Prayer]
    public let resources: [Resource]
    public let iconName: String
    public let tags: [String]
}

public enum LifeSituationCategory: String, CaseIterable {
    case emotional = "Emotional"
    case spiritual = "Spiritual"
    case relational = "Relational"
    case physical = "Physical"
    case financial = "Financial"
    case career = "Career"
    case family = "Family"
}

public struct BibleReference: Identifiable {
    public let id: String
    public let reference: String
    public let preview: String?
}

public struct Prayer: Identifiable {
    public let id: String
    public let title: String
    public let content: String
    public let author: String?
    public let tags: [String]
}

public struct Resource: Identifiable {
    public let id: String
    public let title: String
    public let description: String
    public let type: ResourceType
    public let url: URL?
    public let content: String?
}

public enum ResourceType: String {
    case article, video, podcast, book, meditation, exercise
}

public enum EmotionalState: String, CaseIterable {
    case anxious, peaceful, joyful, sad, grateful, overwhelmed, hopeful, lonely
    
    var displayName: String { rawValue.capitalized }
    var emoji: String {
        switch self {
        case .anxious: return "😰"
        case .peaceful: return "😌"
        case .joyful: return "😊"
        case .sad: return "😢"
        case .grateful: return "🙏"
        case .overwhelmed: return "😵"
        case .hopeful: return "🤗"
        case .lonely: return "😔"
        }
    }
    
    var relatedCategories: [LifeSituationCategory] {
        switch self {
        case .anxious, .overwhelmed:
            return [.emotional, .spiritual, .physical]
        case .peaceful, .grateful:
            return [.spiritual, .emotional]
        case .joyful, .hopeful:
            return [.spiritual, .emotional, .family]
        case .sad, .lonely:
            return [.emotional, .relational, .spiritual]
        }
    }
}

public struct LifeSituationsHomeSection: View {
    @StateObject private var viewModel = LifeSituationsHomeSectionViewModel()
    @State private var selectedSituation: LifeSituation?
    @State private var showingFullFeature = false
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Life Guidance")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Find verses for your current situation")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button {
                    showingFullFeature = true
                    HapticManager.shared.impact(0)
                } label: {
                    HStack(spacing: 4) {
                        Text("See all")
                            .font(.system(size: 14, weight: .medium))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Situation Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.featuredSituations) { situation in
                        LifeSituationCard(situation: situation) {
                            selectedSituation = situation
                            HapticManager.shared.impact(0)
                        }
                    }
                }
            }
            
            // Quick Emotion Check
            if viewModel.showEmotionCheck {
                emotionCheckCard
            }
        }
        .onAppear {
            viewModel.loadFeaturedSituations()
        }
        .sheet(item: $selectedSituation) { situation in
            NavigationView {
                LifeSituationDetailView(situation: situation)
            }
        }
        .sheet(isPresented: $showingFullFeature) {
            NavigationView {
                LifeSituationsView()
            }
        }
    }
    
    private var emotionCheckCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("How are you feeling?")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.quickEmotions, id: \.self) { emotion in
                    EmotionQuickButton(emotion: emotion) {
                        viewModel.selectEmotion(emotion)
                        HapticManager.shared.impact(0)
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Life Situation Card
struct LifeSituationCard: View {
    let situation: LifeSituation
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon and Category
                HStack {
                    Image(systemName: situation.iconName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(categoryColor)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(categoryColor.opacity(0.15))
                        )
                    
                    Spacer()
                    
                    Text(situation.category.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                }
                
                // Title
                Text(situation.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Verse Preview
                if let firstVerse = situation.verses.first {
                    HStack(spacing: 4) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text(firstVerse.reference)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
            .frame(width: 200, height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isPressed ? categoryColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.96 : 1)
        .onLongPressGesture(minimumDuration: 0.1, maximumDistance: .infinity) { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        } perform: {}
    }
    
    private var categoryColor: Color {
        switch situation.category {
        case .emotional: return .blue
        case .spiritual: return .purple
        case .relational: return .pink
        case .physical: return .green
        case .financial: return .orange
        case .career: return .indigo
        case .family: return .red
        }
    }
}

// MARK: - Emotion Quick Button
struct EmotionQuickButton: View {
    let emotion: EmotionalState
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(emotion.emoji)
                    .font(.system(size: 28))
                
                Text(emotion.displayName)
                    .font(.system(size: 10))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(UIColor.tertiarySystemBackground))
            )
        }
        .buttonStyle(ScaleDownButtonStyle())
    }
}

// MARK: - Life Situation Detail View
struct LifeSituationDetailView: View {
    let situation: LifeSituation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: situation.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(categoryColor)
                        .symbolRenderingMode(.hierarchical)
                    
                    Text(situation.title)
                        .font(.system(size: 28, weight: .bold))
                        .multilineTextAlignment(.center)
                    
                    Text(situation.description)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                // Bible Verses
                VStack(alignment: .leading, spacing: 16) {
                    Text("Scripture Guidance")
                        .font(.system(size: 20, weight: .semibold))
                    
                    ForEach(situation.verses) { verse in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text(verse.reference)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Button {
                                    // Open in Bible reader
                                } label: {
                                    Image(systemName: "arrow.right.circle")
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            if let preview = verse.preview {
                                Text(preview)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                    }
                }
                
                // Prayers
                if !situation.prayers.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Prayers")
                            .font(.system(size: 20, weight: .semibold))
                        
                        ForEach(situation.prayers) { prayer in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(prayer.title)
                                    .font(.system(size: 16, weight: .medium))
                                
                                Text(prayer.content)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(4)
                                
                                if let author = prayer.author {
                                    Text("— \(author)")
                                        .font(.system(size: 12))
                                        .foregroundColor(.tertiary)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(categoryColor.opacity(0.08))
                            )
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Life Guidance")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private var categoryColor: Color {
        switch situation.category {
        case .emotional: return .blue
        case .spiritual: return .purple
        case .relational: return .pink
        case .physical: return .green
        case .financial: return .orange
        case .career: return .indigo
        case .family: return .red
        }
    }
}

// MARK: - View Model
@MainActor
class LifeSituationsHomeSectionViewModel: ObservableObject {
    @Published var featuredSituations: [LifeSituation] = []
    @Published var showEmotionCheck = true
    
    let quickEmotions: [EmotionalState] = [
        .anxious,
        .peaceful,
        .joyful,
        .sad,
        .grateful,
        .overwhelmed,
        .hopeful,
        .lonely
    ]
    
    func loadFeaturedSituations() {
        // Use mock data for now
        self.featuredSituations = Array(MockLifeSituationData.allSituations.prefix(4))
    }
    
    func selectEmotion(_ emotion: EmotionalState) {
        let filtered = MockLifeSituationData.allSituations.filter { situation in
            emotion.relatedCategories.contains(situation.category)
        }
        
        self.featuredSituations = Array(filtered.prefix(4))
        withAnimation {
            self.showEmotionCheck = false
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
                BibleReference(id: "1", reference: "Philippians 4:6-7", preview: "Do not be anxious about anything, but in everything by prayer..."),
                BibleReference(id: "2", reference: "Matthew 6:34", preview: "Therefore do not worry about tomorrow..."),
                BibleReference(id: "3", reference: "1 Peter 5:7", preview: "Cast all your anxiety on him because he cares for you")
            ],
            prayers: [
                Prayer(
                    id: "1",
                    title: "Prayer for Peace at Work",
                    content: "Lord, I bring my work anxieties before You. Help me to trust in Your provision and find peace in Your presence. Grant me wisdom to handle my responsibilities and faith to release my worries to You. Amen.",
                    author: nil,
                    tags: []
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
                BibleReference(id: "4", reference: "Psalm 34:18", preview: "The Lord is close to the brokenhearted..."),
                BibleReference(id: "5", reference: "Matthew 5:4", preview: "Blessed are those who mourn, for they will be comforted"),
                BibleReference(id: "6", reference: "Revelation 21:4", preview: "He will wipe every tear from their eyes...")
            ],
            prayers: [
                Prayer(
                    id: "2",
                    title: "Prayer for Comfort in Grief",
                    content: "Heavenly Father, my heart is heavy with loss. Wrap me in Your comforting arms and help me feel Your presence. Give me strength to face each day and hope for the future. Thank You for the promise of eternal life. Amen.",
                    author: nil,
                    tags: []
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
                BibleReference(id: "7", reference: "Psalm 118:24", preview: "This is the day the Lord has made; let us rejoice..."),
                BibleReference(id: "8", reference: "1 Thessalonians 5:16-18", preview: "Rejoice always, pray continually, give thanks..."),
                BibleReference(id: "9", reference: "Philippians 4:4", preview: "Rejoice in the Lord always. I will say it again: Rejoice!")
            ],
            prayers: [
                Prayer(
                    id: "3",
                    title: "Prayer of Thanksgiving",
                    content: "Lord, my heart overflows with gratitude for Your blessings. Thank You for Your faithfulness, love, and provision. Help me to always maintain a grateful heart and share Your joy with others. Amen.",
                    author: nil,
                    tags: []
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
                BibleReference(id: "10", reference: "Ephesians 4:32", preview: "Be kind and compassionate to one another, forgiving..."),
                BibleReference(id: "11", reference: "Matthew 18:15", preview: "If your brother or sister sins, go and point out their fault..."),
                BibleReference(id: "12", reference: "Colossians 3:13", preview: "Bear with each other and forgive one another...")
            ],
            prayers: [
                Prayer(
                    id: "4",
                    title: "Prayer for Relationship Healing",
                    content: "Lord, I need Your wisdom in this relationship. Soften our hearts, help us communicate with love, and guide us toward reconciliation. Give us the humility to forgive and the courage to seek forgiveness. Amen.",
                    author: nil,
                    tags: []
                )
            ],
            resources: [],
            iconName: "person.2.circle.fill",
            tags: ["relationships", "conflict", "forgiveness", "reconciliation", "communication"]
        )
    ]
}

// MARK: - Scale Down Button Style
struct ScaleDownButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}