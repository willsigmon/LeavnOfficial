import SwiftUI
import ComposableArchitecture

struct ActivityFeedPreview: View {
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(store.recentActivities.prefix(5)) { activity in
                    ActivityCard(activity: activity)
                        .onTapGesture {
                            store.send(.selectActivity(activity))
                        }
                }
                
                // View All Card
                ViewAllCard(title: "View All Activity") {
                    store.send(.navigateToActivityFeed)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // User Avatar
                Circle()
                    .fill(Color.leavnPrimary.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(activity.userName.prefix(1))
                            .font(.caption.bold())
                            .foregroundColor(.leavnPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activity.userName)
                        .font(.caption.bold())
                        .lineLimit(1)
                    
                    Text(activity.timestamp, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: activity.type.icon)
                    .font(.caption)
                    .foregroundColor(activity.type.color)
            }
            
            Text(activity.content)
                .font(.callout)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if let metadata = activity.metadata {
                HStack {
                    Image(systemName: metadata.icon)
                        .font(.caption2)
                    Text(metadata.text)
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(width: 280)
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
    }
}

struct ActivityFeedView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @State private var selectedFilter: ActivityFilter = .all
    
    enum ActivityFilter: String, CaseIterable {
        case all = "All"
        case prayers = "Prayers"
        case groups = "Groups"
        case discussions = "Discussions"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ActivityFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding()
            }
            
            if store.isLoadingActivities {
                LoadingView(message: "Loading activities...")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredActivities) { activity in
                            ActivityRow(activity: activity) {
                                store.send(.selectActivity(activity))
                            }
                        }
                    }
                    .padding()
                }
                .refreshable {
                    store.send(.refreshActivityFeed)
                }
            }
        }
        .navigationTitle("Activity Feed")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var filteredActivities: [Activity] {
        switch selectedFilter {
        case .all:
            return store.activities
        case .prayers:
            return store.activities.filter { $0.type == .prayer }
        case .groups:
            return store.activities.filter { $0.type == .groupJoined || $0.type == .groupPost }
        case .discussions:
            return store.activities.filter { $0.type == .discussion }
        }
    }
}

struct ActivityRow: View {
    let activity: Activity
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                // User Avatar
                Circle()
                    .fill(Color.leavnPrimary.opacity(0.2))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(activity.userName.prefix(1))
                            .font(.headline)
                            .foregroundColor(.leavnPrimary)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(activity.userName)
                            .font(.headline)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(activity.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: activity.type.icon)
                            .font(.caption)
                            .foregroundColor(activity.type.color)
                        
                        Text(activity.type.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(activity.content)
                        .font(.body)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                    
                    if let metadata = activity.metadata {
                        HStack {
                            Image(systemName: metadata.icon)
                                .font(.caption)
                            Text(metadata.text)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.callout)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

// Mock Activity model
struct Activity: Identifiable {
    let id = UUID()
    let userName: String
    let timestamp: Date
    let type: ActivityType
    let content: String
    let metadata: ActivityMetadata?
    
    enum ActivityType {
        case prayer
        case groupJoined
        case groupPost
        case discussion
        case verseShared
        
        var icon: String {
            switch self {
            case .prayer: return "hands.sparkles"
            case .groupJoined: return "person.badge.plus"
            case .groupPost: return "bubble.left"
            case .discussion: return "bubble.left.and.bubble.right"
            case .verseShared: return "book"
            }
        }
        
        var color: Color {
            switch self {
            case .prayer: return .blue
            case .groupJoined: return .green
            case .groupPost: return .purple
            case .discussion: return .orange
            case .verseShared: return .leavnPrimary
            }
        }
        
        var description: String {
            switch self {
            case .prayer: return "shared a prayer"
            case .groupJoined: return "joined a group"
            case .groupPost: return "posted in group"
            case .discussion: return "started a discussion"
            case .verseShared: return "shared a verse"
            }
        }
    }
}

struct ActivityMetadata {
    let icon: String
    let text: String
}