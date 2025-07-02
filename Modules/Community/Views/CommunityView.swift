import SwiftUI
import DesignSystem

public struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var selectedTab = 0
    @State private var showCreatePost = false
    @State private var showNotificationCenter = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                // Header
                communityHeader
                
                // Content tabs
                TabView(selection: $selectedTab) {
                    feedView
                        .tag(0)
                    
                    groupsView
                        .tag(1)
                    
                    challengesView
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            
            // Floating create button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "square.and.pencil") {
                        showCreatePost = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView()
        }
        .sheet(isPresented: $showNotificationCenter) {
            NotificationCenterView()
        }
    }
    
    private var communityHeader: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Community")
                    .font(LeavnTheme.Typography.displayMedium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LeavnTheme.Colors.accentLight, LeavnTheme.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                
                // Notifications
                Button(action: { showNotificationCenter = true }) {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.primary)
                        
                        if viewModel.unreadNotifications > 0 {
                            Circle()
                                .fill(LeavnTheme.Colors.error)
                                .frame(width: 10, height: 10)
                                .offset(x: 3, y: -3)
                        }
                    }
                }
                .padding(8)
                .background(
                    Circle()
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Tabs
            HStack(spacing: 0) {
                CommunityTab(title: "Feed", isSelected: selectedTab == 0) {
                    withAnimation { selectedTab = 0 }
                }
                
                CommunityTab(title: "Groups", isSelected: selectedTab == 1) {
                    withAnimation { selectedTab = 1 }
                }
                
                CommunityTab(title: "Challenges", isSelected: selectedTab == 2) {
                    withAnimation { selectedTab = 2 }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
    
    private var feedView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Welcome card
                WelcomeCard()
                    .padding(.horizontal, 20)
                
                // Posts
                ForEach(0..<5) { index in
                    PostCard(index: index)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var groupsView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Featured groups
                VStack(alignment: .leading, spacing: 16) {
                    Text("Featured Groups")
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<3) { index in
                                GroupCard(index: index)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Your groups
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Groups")
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    ForEach(0..<3) { index in
                        GroupRow(index: index)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var challengesView: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Active challenge
                ActiveChallengeCard()
                    .padding(.horizontal, 20)
                
                // Available challenges
                VStack(alignment: .leading, spacing: 16) {
                    Text("Join a Challenge")
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                    
                    ForEach(0..<3) { index in
                        ChallengeCard(index: index)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.vertical, 20)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Community Tab
struct CommunityTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(isSelected ? LeavnTheme.Colors.accent : .secondary)
                
                Rectangle()
                    .fill(isSelected ? LeavnTheme.Colors.accent : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Welcome Card
struct WelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Welcome to Community!")
                .font(LeavnTheme.Typography.titleMedium)
                .foregroundColor(.primary)
            
            Text("Share your insights, join discussions, and grow together in faith.")
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary)
            
            HStack {
                Label("\(234) Members", systemImage: "person.2.fill")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(LeavnTheme.Colors.info)
                
                Spacer()
                
                Label("\(12) Online", systemImage: "circle.fill")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(LeavnTheme.Colors.success)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(LeavnTheme.Colors.primaryGradient.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(LeavnTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Post Card
struct PostCard: View {
    let index: Int
    @State private var isLiked = false
    @State private var appear = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Author info
            HStack {
                Circle()
                    .fill(LeavnTheme.Colors.categoryColors[index % LeavnTheme.Colors.categoryColors.count])
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("JD")
                            .font(LeavnTheme.Typography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("John Doe")
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text("2 hours ago")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.secondary)
                }
            }
            
            // Content
            Text("Just finished reading Psalms 23 and it really spoke to my heart today. " +
                 "The Lord truly is my shepherd! 🙏")
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.primary)
            
            // Verse reference
            if index % 2 == 0 {
                HStack {
                    Image(systemName: "book.fill")
                        .font(.system(size: 14))
                        .foregroundColor(LeavnTheme.Colors.accent)
                    
                    Text("Psalm 23:1-6")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(LeavnTheme.Colors.accent.opacity(0.1))
                )
            }
            
            // Actions
            HStack(spacing: 24) {
                Button(action: {
                    withAnimation(LeavnTheme.Motion.quickBounce) {
                        isLiked.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? LeavnTheme.Colors.error : .secondary)
                        Text("\(isLiked ? 13 : 12)")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.secondary)
                        Text("5")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: {}) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            LeavnTheme.Motion.smoothSpring.delay(Double(index) * 0.1),
            value: appear
        )
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Group Card
struct GroupCard: View {
    let index: Int
    
    private var groupColor: Color {
        LeavnTheme.Colors.categoryColors[index % LeavnTheme.Colors.categoryColors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(groupColor.opacity(0.2))
                    .frame(height: 100)
                
                Image(systemName: "person.3.fill")
                    .font(.system(size: 32))
                    .foregroundColor(groupColor)
            }
            
            Text("Bible Study Group \(index + 1)")
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.primary)
            
            Text("\(20 + index * 5) members")
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
            
            Button(action: {}) {
                Text("Join")
                    .font(LeavnTheme.Typography.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(groupColor)
                    )
            }
        }
        .frame(width: 160)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Group Row
struct GroupRow: View {
    let index: Int
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(LeavnTheme.Colors.categoryColors[index % LeavnTheme.Colors.categoryColors.count])
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "person.3.fill")
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Study Group \(index + 1)")
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text("Last active 2h ago")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Active Challenge Card
struct ActiveChallengeCard: View {
    @State private var progress: Double = 0.65
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("30 Day Prayer Challenge")
                        .font(LeavnTheme.Typography.titleMedium)
                        .foregroundColor(.primary)
                    
                    Text("Day 19 of 30")
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color(UIColor.tertiarySystemFill), lineWidth: 8)
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LeavnTheme.Colors.primaryGradient,
                            style: StrokeStyle(lineWidth: 8, lineCap: .round)
                        )
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(LeavnTheme.Typography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            
            Text("Keep up the great work! You're on a 19 day streak 🔥")
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.primary)
            
            Button(action: {}) {
                Text("Continue Challenge")
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LeavnTheme.Colors.primaryGradient)
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(LeavnTheme.Colors.success.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(LeavnTheme.Colors.success.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let index: Int
    
    private var challengeColor: Color {
        [LeavnTheme.Colors.info, LeavnTheme.Colors.success, LeavnTheme.Colors.warning][index % 3]
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(challengeColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: ["book.pages", "calendar", "star.fill"][index % 3])
                    .font(.system(size: 24))
                    .foregroundColor(challengeColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(["Read the Gospels", "30 Day Prayer", "Memory Verses"][index % 3])
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text("\(45 + index * 20) participants")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemBackground))
        )
    }
}

// MARK: - Create Post View
struct CreatePostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var postText = ""
    @State private var selectedVerse: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                LeavnTheme.Colors.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Post input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Share your thoughts")
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $postText)
                            .font(LeavnTheme.Typography.body)
                            .padding(12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                            .frame(minHeight: 150)
                    }
                    
                    // Add verse button
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "book.fill")
                            Text("Add Bible Verse")
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                        }
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(LeavnTheme.Colors.accent)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(LeavnTheme.Colors.accent.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(LeavnTheme.Colors.accent.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        // Create post
                        dismiss()
                    }
                    .disabled(postText.isEmpty)
                }
            }
        }
    }
}
