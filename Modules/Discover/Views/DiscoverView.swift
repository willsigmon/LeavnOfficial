import SwiftUI

public struct DiscoverView: View {
    @State private var selectedCategory = 0
    @State private var showingDevotion = false
    @State private var selectedDevotion: LeavnBible.Devotion?
    @State private var showingLifeSituations = false
    @State private var showingBiblicalAtlas = false
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Study Tools Section
                    studyToolsSection
                    
                    // Featured Section
                    featuredSection
                    
                    // Categories
                    categoryPicker
                    
                    // Content based on category
                    switch selectedCategory {
                    case 0:
                        devotionsSection
                    case 1:
                        readingPlansSection
                    case 2:
                        topicsSection
                    default:
                        devotionsSection
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(item: $selectedDevotion) { devotion in
            NavigationView {
                DevotionReaderView(devotion: devotion)
            }
            .onAppear {
                HapticManager.shared.impact(.medium)
            }
        }
        .fullScreenCover(isPresented: $showingLifeSituations) {
            LifeSituationsView()
        }
        .fullScreenCover(isPresented: $showingBiblicalAtlas) {
            BiblicalAtlasView()
        }
    }
    
    // MARK: - Sections
    
    private var studyToolsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Study Tools")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            HStack(spacing: 16) {
                // Life Situations Card
                Button(action: { 
                    HapticManager.shared.impact(.medium)
                    showingLifeSituations = true 
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeavnTheme.Colors.accent, LeavnTheme.Colors.accentLight],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Life Guidance")
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.primary)
                        
                        Text("Get biblical wisdom for your emotions")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LeavnTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
                
                // Biblical Atlas Card
                Button(action: { 
                    HapticManager.shared.impact(.medium)
                    showingBiblicalAtlas = true 
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [LeavnTheme.Colors.info, LeavnTheme.Colors.info.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Biblical Atlas")
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.primary)
                        
                        Text("Explore ancient lands and routes")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(LeavnTheme.Colors.info.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Featured")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    FeaturedCard(
                        title: "Peace in Trials",
                        subtitle: "Finding God's comfort in difficult times",
                        gradient: LeavnTheme.Colors.primaryGradient,
                        icon: "heart.fill"
                    )
                    
                    FeaturedCard(
                        title: "Daily Wisdom",
                        subtitle: "Proverbs for everyday life",
                        gradient: LinearGradient(
                            colors: [LeavnTheme.Colors.warning, LeavnTheme.Colors.warning.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        icon: "lightbulb.fill"
                    )
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CategoryChip(title: "Devotions", isSelected: selectedCategory == 0) {
                    HapticManager.shared.impact(.light)
                    selectedCategory = 0
                }
                
                CategoryChip(title: "Reading Plans", isSelected: selectedCategory == 1) {
                    HapticManager.shared.impact(.light)
                    selectedCategory = 1
                }
                
                CategoryChip(title: "Topics", isSelected: selectedCategory == 2) {
                    HapticManager.shared.impact(.light)
                    selectedCategory = 2
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var devotionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Popular Devotions")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ForEach(sampleDevotions) { devotion in
                    DevotionCard(devotion: devotion) {
                        HapticManager.shared.impact(.medium)
                        selectedDevotion = devotion
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
    
    private var readingPlansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reading Plans")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            VStack(spacing: 12) {
                ReadingPlanCard(
                    title: "Bible in a Year",
                    description: "Read through the entire Bible in 365 days",
                    progress: 0.45,
                    duration: "365 days"
                )
                
                ReadingPlanCard(
                    title: "Gospels in 30 Days",
                    description: "Journey through Matthew, Mark, Luke, and John",
                    progress: 0.0,
                    duration: "30 days"
                )
                
                ReadingPlanCard(
                    title: "Psalms & Proverbs",
                    description: "Daily wisdom and worship",
                    progress: 0.2,
                    duration: "60 days"
                )
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var topicsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Browse by Topic")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                TopicCard(title: "Faith", icon: "flame.fill", color: LeavnTheme.Colors.error)
                TopicCard(title: "Love", icon: "heart.fill", color: LeavnTheme.Colors.accent)
                TopicCard(title: "Hope", icon: "sun.max.fill", color: LeavnTheme.Colors.warning)
                TopicCard(title: "Prayer", icon: "hands.sparkles.fill", color: LeavnTheme.Colors.info)
                TopicCard(title: "Wisdom", icon: "lightbulb.fill", color: LeavnTheme.Colors.success)
                TopicCard(title: "Peace", icon: "leaf.fill", color: LeavnTheme.Colors.success)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Supporting Views

struct FeaturedCard: View {
    let title: String
    let subtitle: String
    let gradient: LinearGradient
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
            
            Spacer()
            
            Text(title)
                .font(LeavnTheme.Typography.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(2)
        }
        .frame(width: 250, height: 150)
        .padding()
        .background(gradient)
        .cornerRadius(20)
    }
}

struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(LeavnTheme.Typography.body)
                .fontWeight(isSelected ? .semibold : .medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    isSelected ? LeavnTheme.Colors.accent : Color(.secondarySystemBackground)
                )
                .cornerRadius(20)
        }
    }
}

struct DevotionCard: View {
    let devotion: LeavnBible.Devotion
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(devotion.title)
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Text(devotion.author)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("\(devotion.readingTime) min read")
                            .font(LeavnTheme.Typography.caption)
                    }
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct ReadingPlanCard: View {
    let title: String
    let description: String
    let progress: Double
    let duration: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(LeavnTheme.Typography.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(description)
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer()
                
                if progress > 0 {
                    CircularProgressView(progress: progress)
                        .frame(width: 50, height: 50)
                }
            }
            
            HStack {
                Image(systemName: "calendar")
                    .font(.system(size: 14))
                Text(duration)
                    .font(LeavnTheme.Typography.body)
                
                Spacer()
                
                if progress > 0 {
                    Text("\(Int(progress * 100))% Complete")
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(LeavnTheme.Colors.accent)
                } else {
                    Text("Start Plan")
                        .font(LeavnTheme.Typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
            }
            .foregroundColor(.secondary)
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
}

struct TopicCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(title)
                .font(LeavnTheme.Typography.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(2)
                .minimumScaleFactor(0.9)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(LeavnTheme.Colors.accent, lineWidth: 4)
                .rotationEffect(.degrees(-90))
            
            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - Sample Data
extension DiscoverView {
    var sampleDevotions: [LeavnBible.Devotion] {
        [
            LeavnBible.Devotion(
                id: "1",
                title: "Morning Mercies",
                author: "Sarah Chen",
                content: "His mercies are new every morning...",
                preview: "Start your day with God's promises",
                scripture: "Lamentations 3:22-23",
                date: Date(),
                readingTime: 5
            ),
            LeavnBible.Devotion(
                id: "2",
                title: "Strength in Weakness",
                author: "Michael Torres",
                content: "When I am weak, then I am strong...",
                preview: "Finding God's power in our limitations",
                scripture: "2 Corinthians 12:9-10",
                date: Date(),
                readingTime: 7
            ),
            LeavnBible.Devotion(
                id: "3",
                title: "Walking by Faith",
                author: "Grace Johnson",
                content: "We walk by faith, not by sight...",
                preview: "Trusting God when the path is unclear",
                scripture: "2 Corinthians 5:7",
                date: Date(),
                readingTime: 6
            )
        ]
    }
}

#Preview {
    DiscoverView()
}