import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
// import LeavnCore - Module dependency issue, using direct imports instead

// MARK: - Verse Categories (local copy due to module dependencies)
enum VerseCategory: String, CaseIterable {
    case encouragement = "Encouragement"
    case wisdom = "Wisdom"
    case peace = "Peace"
    case faith = "Faith"
    case hope = "Hope"
    case love = "Love"
    case strength = "Strength"
    case guidance = "Guidance"
    case gratitude = "Gratitude"
    case forgiveness = "Forgiveness"
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .encouragement: return "heart.fill"
        case .wisdom: return "lightbulb.fill"
        case .peace: return "leaf.fill"
        case .faith: return "sparkles"
        case .hope: return "sun.max.fill"
        case .love: return "heart.circle.fill"
        case .strength: return "bolt.fill"
        case .guidance: return "location.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .forgiveness: return "arrow.triangle.2.circlepath"
        }
    }
}

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

// MARK: - ScrollOffsetPreferenceKey
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Selig/Ive-Inspired Home View
public struct HomeView: View {
    @State private var todaysDevotion: Devotion?
    @State private var showingDevotion = false
    @State private var isLoadingDevotion = false
    @State private var verseOfTheDay: BibleVerse?
    @State private var showAllStats = false
    @State private var selectedQuickAction: QuickAction?
    @State private var refreshID = UUID()
    @State private var selectedCategory: VerseCategory?
    @State private var isRefreshingVerse = false
    @State private var showingShareCard = false
    
    @AppStorage("readingStreak") private var readingStreak = 0
    @AppStorage("lastReadDate") private var lastReadDate = Date.distantPast
    @AppStorage("totalVersesRead") private var totalVersesRead = 0
    @AppStorage("totalReadingTime") private var totalReadingTime = 0
    @AppStorage("userName") private var userName = "Friend"
    
    @StateObject private var container = DIContainer.shared
    
    // Animation states
    @State private var cardAppearance: [Bool] = [false, false, false, false]
    @State private var headerScale: CGFloat = 1.0
    @State private var pullToRefreshOffset: CGFloat = 0
    
    enum QuickAction: String, CaseIterable {
        case continueReading = "Continue Reading"
        case search = "Search"
        case readingPlan = "Reading Plan"
        
        var icon: String {
            switch self {
            case .continueReading: return "book.fill"
            case .search: return "magnifyingglass"
            case .readingPlan: return "calendar"
            }
        }
        
        var color: Color {
            switch self {
            case .continueReading: return .blue
            case .search: return .purple
            case .readingPlan: return .green
            }
        }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Pull to refresh indicator
                    GeometryReader { geometry in
                        let offset = geometry.frame(in: .global).minY
                        
                        if offset > 60 {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .primary))
                                    .scaleEffect(0.8)
                                
                                Text("Refreshing...")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .offset(y: -30)
                            .opacity(Double(min(max(offset - 60, 0), 40)) / 40)
                        }
                    }
                    .frame(height: 0)
                    
                    // Main content
                    VStack(spacing: 24) {
                        // Refined header
                        refinedHeader
                            .scaleEffect(headerScale)
                            .animation(.interactiveSpring(), value: headerScale)
                        
                        // Daily content cards
                        VStack(spacing: 16) {
                            // Verse of the day (hero card)
                            verseOfTheDayCard
                                .opacity(cardAppearance[0] ? 1 : 0)
                                .offset(y: cardAppearance[0] ? 0 : 20)
                            
                            // Daily devotion
                            dailyDevotionCard
                                .opacity(cardAppearance[1] ? 1 : 0)
                                .offset(y: cardAppearance[1] ? 0 : 20)
                        }
                        
                        // Stats section (minimal)
                        minimalStatsSection
                            .opacity(cardAppearance[2] ? 1 : 0)
                            .offset(y: cardAppearance[2] ? 0 : 20)
                        
                        // Life Situations section
                        LifeSituationsHomeSection()
                            .opacity(cardAppearance[3] ? 1 : 0)
                            .offset(y: cardAppearance[3] ? 0 : 20)
                        
                        // Quick actions (refined grid)
                        quickActionsGrid
                            .opacity(cardAppearance[3] ? 1 : 0)
                            .offset(y: cardAppearance[3] ? 0 : 20)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
                .background(GeometryReader { geometry in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geometry.frame(in: .named("scroll")).minY
                    )
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                pullToRefreshOffset = value
                
                // Pull to refresh
                if value > 120 {
                    triggerRefresh()
                }
                
                // Scale header on overscroll
                let scale = 1.0 + (max(value, 0) / 500)
                headerScale = min(scale, 1.1)
            }
            .background(Color(UIColor.systemBackground))
            .navigationBarHidden(true)
            .onAppear {
                animateCardAppearance()
                loadDailyContent()
                updateReadingStreak()
            }
            .id(refreshID)
        }
        .sheet(isPresented: $showingDevotion) {
            if let devotion = todaysDevotion {
                NavigationView {
                    DevotionReaderView(
                        devotionTitle: devotion.title,
                        devotionContent: devotion.content
                    )
                }
            }
        }
        .sheet(isPresented: $showingShareCard) {
            if let verse = verseOfTheDay {
                ShareableVerseCardView(verse: verse)
            }
        }
    }
    
    // MARK: - Refined Header (Selig/Ive Style)
    private var refinedHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Personalized greeting
            Text(getPersonalizedGreeting())
                .font(.system(size: 32, weight: .bold, design: .default))
                .foregroundColor(.primary)
            
            // Date and streak info
            HStack(spacing: 16) {
                Text(Date().formatted(.dateTime.weekday(.wide).month(.wide).day()))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                
                if readingStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.orange)
                        
                        Text("\(readingStreak) day streak")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.orange.opacity(0.15))
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
    
    // MARK: - Verse of the Day Card (Hero Style)
    private var verseOfTheDayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with category selector
            HStack {
                Label("Verse of the Day", systemImage: "quote.opening")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Spacer()
                
                // Category menu
                Menu {
                    ForEach(VerseCategory.allCases, id: \.self) { category in
                        Button {
                            selectedCategory = category
                            loadVerseByCategory(category)
                        } label: {
                            Label(category.displayName, systemImage: category.icon)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                }
                
                Button {
                    shareVerse()
                    HapticManager.shared.impact(0)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(UIColor.tertiarySystemBackground))
                        )
                }
            }
            
            if let verse = verseOfTheDay {
                // Verse text with beautiful typography
                Text(verse.text)
                    .font(.system(size: 20, weight: .regular, design: .serif))
                    .foregroundColor(.primary)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Reference with category indicator
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verse.reference)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let category = selectedCategory {
                            HStack(spacing: 4) {
                                Image(systemName: category.icon)
                                    .font(.system(size: 11))
                                Text(category.displayName)
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Read more button
                    Button {
                        openVerseInContext()
                        HapticManager.shared.impact(0)
                    } label: {
                        HStack(spacing: 4) {
                            Text("Read in context")
                                .font(.system(size: 14, weight: .medium))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                    }
                }
            } else {
                // Loading state
                VStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .frame(height: 20)
                        .shimmer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(UIColor.tertiarySystemBackground))
                        .frame(height: 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .overlay(
                            GeometryReader { geometry in
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(UIColor.tertiarySystemBackground))
                                    .frame(width: geometry.size.width * 0.7)
                            }
                        )
                        .shimmer()
                }
            }
        }
        .padding(20)
        .background(
            ZStack {
                // Base gradient
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.05),
                                Color.purple.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Subtle pattern overlay
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(UIColor.separator).opacity(0.5),
                            Color(UIColor.separator).opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.5
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
        .scaleEffect(isRefreshingVerse ? 0.95 : 1.0)
        .rotation3DEffect(
            .degrees(isRefreshingVerse ? 5 : 0),
            axis: (x: 1, y: 0, z: 0)
        )
        .onTapGesture {
            refreshVerse()
        }
    }
    
    // MARK: - Daily Devotion Card (Refined)
    private var dailyDevotionCard: some View {
        Button {
            if todaysDevotion != nil {
                showingDevotion = true
                HapticManager.shared.impact(0)
            } else if !isLoadingDevotion {
                loadDailyContent()
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.green)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Devotion")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    if let devotion = todaysDevotion {
                        Text(devotion.title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Text(devotion.preview)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else if isLoadingDevotion {
                        HStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                                .scaleEffect(0.7)
                            
                            Text("Loading devotion...")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Tap to load devotion")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.tertiaryLabel)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
        }
        .buttonStyle(ScaleDownButtonStyle())
    }
    
    // MARK: - Minimal Stats Section (Apollo Style)
    private var minimalStatsSection: some View {
        HStack(spacing: 12) {
            // Today's reading time
            MinimalStatCard(
                icon: "clock",
                value: formatReadingTime(minutesToday()),
                label: "Today",
                color: .blue
            )
            
            // Total verses
            MinimalStatCard(
                icon: "text.book.closed",
                value: "\(totalVersesRead)",
                label: "Verses Read",
                color: .purple
            )
            
            // Week average
            MinimalStatCard(
                icon: "chart.line.uptrend.xyaxis",
                value: "\(weeklyAverage())m",
                label: "Daily Avg",
                color: .green
            )
        }
    }
    
    // MARK: - Quick Actions Grid (Refined)
    private var quickActionsGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                ForEach(QuickAction.allCases, id: \.self) { action in
                    QuickActionCard(action: action) {
                        handleQuickAction(action)
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func getPersonalizedGreeting() -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 0..<12:
            timeGreeting = "Good morning"
        case 12..<17:
            timeGreeting = "Good afternoon"
        default:
            timeGreeting = "Good evening"
        }
        
        return userName.isEmpty ? timeGreeting : "\(timeGreeting), \(userName)"
    }
    
    private func animateCardAppearance() {
        for index in 0..<cardAppearance.count {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                cardAppearance[index] = true
            }
        }
    }
    
    private func triggerRefresh() {
        guard pullToRefreshOffset > 120 else { return }
        
        HapticManager.shared.impact(1)
        
        withAnimation {
            refreshID = UUID()
        }
        
        loadDailyContent()
    }
    
    private func shareVerse() {
        guard let verse = verseOfTheDay else { return }
        showingShareCard = true
    }
    
    private func openVerseInContext() {
        // Navigate to Bible view with verse
    }
    
    private func handleQuickAction(_ action: QuickAction) {
        HapticManager.shared.impact(0)
        
        switch action {
        case .continueReading:
            // Navigate to last read position
            break
        case .search:
            // Navigate to search
            break
        case .readingPlan:
            // Navigate to reading plans
            break
        }
    }
    
    private func formatReadingTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }
    
    private func minutesToday() -> Int {
        // Calculate from stored data
        let calendar = Calendar.current
        if calendar.isDateInToday(lastReadDate) {
            return min(totalReadingTime, 180) // Cap at 3 hours for display
        }
        return 0
    }
    
    private func weeklyAverage() -> Int {
        // Calculate 7-day average
        return max(totalReadingTime / 7, 1)
    }
    
    private func loadDailyContent() {
        isLoadingDevotion = true
        
        Task {
            do {
                guard let verseOfTheDayService = container.verseOfTheDayService else {
                    await MainActor.run {
                        self.isLoadingDevotion = false
                    }
                    return
                }
                
                let translation = BibleTranslation(
                    id: "ESV",
                    name: "English Standard Version",
                    abbreviation: "ESV",
                    language: "English"
                )
                
                let dailyVerse = try await verseOfTheDayService.getTodaysVerse(translation: translation)
                
                let devotion = Devotion(
                    id: "daily-\(Date().formatted(.iso8601.year().month().day()))",
                    title: "Reflecting on \(dailyVerse.book)",
                    author: "Daily Devotional",
                    content: generateDevotionalContent(for: dailyVerse),
                    preview: "Today's verse from \(dailyVerse.book) reminds us of God's faithfulness...",
                    scripture: "\(dailyVerse.book) \(dailyVerse.chapter):\(dailyVerse.verse)",
                    date: Date()
                )
                
                await MainActor.run {
                    withAnimation {
                        self.todaysDevotion = devotion
                        self.verseOfTheDay = dailyVerse
                        self.isLoadingDevotion = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingDevotion = false
                }
            }
        }
    }
    
    private func generateDevotionalContent(for verse: BibleVerse) -> String {
        """
        Today's verse from \(verse.book) \(verse.chapter):\(verse.verse) offers profound wisdom for our daily walk.
        
        "\(verse.text)"
        
        Take a moment to reflect on these words. How do they speak to your current circumstances? What is God revealing to you through this passage?
        
        Prayer: Lord, help us to understand and apply Your word in our lives. May this scripture guide our thoughts and actions today. Amen.
        """
    }
    
    private func updateReadingStreak() {
        let calendar = Calendar.current
        if !calendar.isDateInToday(lastReadDate) {
            if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()),
               calendar.isDate(lastReadDate, inSameDayAs: yesterday) {
                // Streak continues
            } else {
                // Streak broken
                readingStreak = 0
            }
        }
    }
    
    private func loadVerseByCategory(_ category: VerseCategory) {
        Task {
            do {
                // For now, just reload the daily verse
                // In a full implementation, we'd convert between the local and service enums
                await loadDailyContent()
            } catch {
                print("Failed to load verse by category: \(error)")
            }
        }
    }
    
    private func refreshVerse() {
        guard !isRefreshingVerse else { return }
        
        HapticManager.shared.impact(1)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            isRefreshingVerse = true
        }
        
        Task {
            await loadDailyContent()
            
            await MainActor.run {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isRefreshingVerse = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct MinimalStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
            }
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

struct QuickActionCard: View {
    let action: HomeView.QuickAction
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(action.color.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: action.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(action.color)
                }
                
                // Title
                Text(action.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isPressed ? action.color : Color.clear, lineWidth: 2)
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
}

// MARK: - Shimmer Modifier
struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.1),
                        Color.white.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(25))
                .offset(x: phase * 200 - 100)
                .animation(
                    .linear(duration: 1.5).repeatForever(autoreverses: false),
                    value: phase
                )
            )
            .onAppear {
                phase = 1
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

#Preview {
    HomeView()
}