import SwiftUI

// MARK: - Temporary Type Definitions (until proper module imports are fixed)
enum EmotionalState: String, CaseIterable {
    case anxious, peaceful, joyful, sad, grateful, overwhelmed, hopeful, angry, fearful, lonely, confused, content
    
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
        case .angry: return "😠"
        case .fearful: return "😨"
        case .lonely: return "😔"
        case .confused: return "😕"
        case .content: return "😊"
        }
    }
    var color: String {
        switch self {
        case .anxious: return "#FF6B6B"
        case .peaceful: return "#4ECDC4"
        case .joyful: return "#FFE66D"
        case .sad: return "#95A5A6"
        case .grateful: return "#A8E6CF"
        case .overwhelmed: return "#FF8B94"
        case .hopeful: return "#B4A7D6"
        case .angry: return "#D32F2F"
        case .fearful: return "#7986CB"
        case .lonely: return "#90A4AE"
        case .confused: return "#FFAB91"
        case .content: return "#81C784"
        }
    }
}

enum LifeCategory: String, CaseIterable {
    case relationships, work, health, faith, family, finances, guidance, purpose
    
    var displayName: String {
        switch self {
        case .relationships: return "Relationships"
        case .work: return "Work & Career"
        case .health: return "Health & Wellness"
        case .faith: return "Faith & Spirituality"
        case .family: return "Family"
        case .finances: return "Finances"
        case .guidance: return "Guidance"
        case .purpose: return "Purpose & Calling"
        }
    }
    
    var icon: String {
        switch self {
        case .relationships: return "person.2.fill"
        case .work: return "briefcase.fill"
        case .health: return "heart.fill"
        case .faith: return "sparkles"
        case .family: return "house.fill"
        case .finances: return "dollarsign.circle.fill"
        case .guidance: return "lightbulb.fill"
        case .purpose: return "target"
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// Mock Life Situations Engine for UI
private class MockLifeSituationsEngine: ObservableObject {
    func analyzeText(_ text: String) -> (dominantEmotion: EmotionalState, confidence: Double) {
        return (.peaceful, 0.8)
    }
    
    func getVerses(for emotion: EmotionalState) -> [String]? {
        return ["Philippians 4:13", "Psalm 23:1", "John 3:16"]
    }
    
    func getGuidance(for emotion: EmotionalState, category: LifeCategory) -> String? {
        return "God's word provides comfort and guidance for your \(emotion.displayName.lowercased()) feelings in \(category.displayName.lowercased())."
    }
    
    func logEmotionalJourney(emotion: EmotionalState, category: LifeCategory, note: String) {
        // Mock implementation
    }
}

public struct LifeSituationsView: View {
    @StateObject private var situationsEngine = MockLifeSituationsEngine()
    @State private var userInput = ""
    @State private var currentEmotion: EmotionalState?
    @State private var showingGuidance = false
    @State private var selectedCategory: LifeCategory = .guidance
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection
                    
                    // Emotion Detection Input
                    emotionInputSection
                    
                    // Current Emotional State
                    if let emotion = currentEmotion {
                        currentEmotionCard(emotion)
                    }
                    
                    // Life Categories
                    lifeCategoriesSection
                    
                    // Biblical Guidance
                    if showingGuidance, let emotion = currentEmotion {
                        guidanceSection(for: emotion)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Life Guidance")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolRenderingMode(.hierarchical)
            
            Text("How are you feeling today?")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Share what's on your heart and receive biblical guidance")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 20)
    }
    
    private var emotionInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Share your thoughts")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            TextEditor(text: $userInput)
                .font(.system(size: 17))
                .padding(12)
                .frame(minHeight: 120)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 20)
            
            Button(action: analyzeEmotion) {
                HStack {
                    Text("Get Guidance")
                    Image(systemName: "arrow.right.circle.fill")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(12)
            }
            .disabled(userInput.isEmpty)
            .padding(.horizontal, 20)
        }
    }
    
    private func currentEmotionCard(_ emotion: EmotionalState) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(emotion.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("You seem to be feeling")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text(emotion.rawValue.capitalized)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(hex: emotion.color).opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(hex: emotion.color).opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
    }
    
    private var lifeCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Life Areas")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(LifeCategory.allCases, id: \.self) { category in
                        LifeCategoryChip(
                            title: category.displayName,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                            if currentEmotion != nil {
                                showingGuidance = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func guidanceSection(for emotion: EmotionalState) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Biblical Guidance")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            // Scripture verses
            if let verses = situationsEngine.getVerses(for: emotion) {
                ForEach(verses, id: \.self) { verse in
                    LifeSituationVerseCard(reference: verse)
                        .padding(.horizontal, 20)
                }
            }
            
            // Personalized guidance
            if let guidance = situationsEngine.getGuidance(for: emotion, category: selectedCategory) {
                GuidanceCard(guidance: guidance)
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private func analyzeEmotion() {
        let analysis = $situationsEngine.analyzeText(userInput)
        currentEmotion = analysis.dominantEmotion
        showingGuidance = true
        
        // Log the analysis
        $situationsEngine.logEmotionalJourney(
            emotion: analysis.dominantEmotion,
            category: selectedCategory,
            note: userInput
        )
    }
}

// MARK: - Supporting Views

struct LifeCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.indigo : Color(.secondarySystemBackground))
            )
        }
    }
}

struct LifeSituationVerseCard: View {
    let reference: String
    @State private var showingShareCard = false
    @State private var verse: BibleVerse?
    
    var body: some View {
        HStack {
            Image(systemName: "book.fill")
                .font(.system(size: 20))
                .foregroundColor(Color.indigo)
            
            Text(reference)
                .font(.system(size: 17))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Share Button
            Button(action: {
                // Create a mock verse for sharing
                // In production, this would fetch the actual verse
                verse = createMockVerse(from: reference)
                showingShareCard = true
            }) {
                Image(systemName: "square.and.arrow.up")
                    .foregroundColor(Color.indigo)
            }
            
            // Read Button
            Button(action: {}) {
                Image(systemName: "arrow.right.circle")
                    .foregroundColor(Color.indigo)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .sheet(isPresented: $showingShareCard) {
            if let verse = verse {
                ShareableVerseCardView(verse: verse)
            }
        }
    }
    
    private func createMockVerse(from reference: String) -> BibleVerse {
        // In production, this would fetch the actual verse
        // For now, create a mock verse
        BibleVerse(
            id: UUID().uuidString,
            reference: reference,
            text: "The Lord is my strength and my shield; my heart trusts in him, and he helps me.",
            book: reference.components(separatedBy: " ").first ?? "Psalms",
            chapter: 28,
            verse: 7,
            translation: "NIV"
        )
    }
}

struct GuidanceCard: View {
    let guidance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(Color.orange)
                Text("Personalized Guidance")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            Text(guidance)
                .font(.system(size: 17))
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

#Preview {
    LifeSituationsView()
}
