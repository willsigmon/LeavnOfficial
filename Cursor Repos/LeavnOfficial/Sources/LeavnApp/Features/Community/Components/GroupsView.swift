import SwiftUI
import ComposableArchitecture

struct GroupsPreview: View {
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // My Groups
            if !store.myGroups.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(store.myGroups.prefix(3)) { group in
                            MyGroupCard(group: group) {
                                store.send(.selectGroup(group))
                            }
                        }
                        
                        if store.myGroups.count > 3 {
                            ViewAllCard(title: "View All") {
                                store.send(.navigateToGroups)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                JoinGroupPrompt {
                    store.send(.navigateToGroups)
                }
            }
        }
    }
}

struct MyGroupCard: View {
    let group: Group
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    GroupAvatar(group: group, size: 40)
                    
                    Spacer()
                    
                    if group.hasUnreadMessages {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 8, height: 8)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text("\(group.memberCount) members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Recent Activity
                if let recentActivity = group.recentActivity {
                    Text(recentActivity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .frame(width: 180, height: 140)
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct JoinGroupPrompt: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "person.3.fill")
                    .font(.largeTitle)
                    .foregroundColor(.leavnPrimary)
                
                Text("Join a Group")
                    .font(.headline)
                
                Text("Connect with others in Bible study groups")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.leavnPrimary.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

struct GroupAvatar: View {
    let group: Group
    let size: CGFloat
    
    var body: some View {
        if let imageURL = group.imageURL {
            AsyncImage(url: imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(group.color)
                
                Text(group.initials)
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: size, height: size)
        }
    }
}

struct EnhancedGroupsView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @State private var selectedCategory: GroupCategory = .all
    @State private var searchQuery = ""
    @State private var showingCreateGroup = false
    
    enum GroupCategory: String, CaseIterable {
        case all = "All"
        case myGroups = "My Groups"
        case discover = "Discover"
        case local = "Local"
        case topical = "Topical"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .myGroups: return "person.2.fill"
            case .discover: return "sparkles"
            case .local: return "location.fill"
            case .topical: return "tag.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search groups...", text: $searchQuery)
                    .textFieldStyle(.plain)
                
                if !searchQuery.isEmpty {
                    Button(action: { searchQuery = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(GroupCategory.allCases, id: \.self) { category in
                        CategoryTab(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            count: countForCategory(category)
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Content
            ScrollView {
                if selectedCategory == .myGroups && store.myGroups.isEmpty {
                    EmptyStateView(
                        icon: "person.3",
                        title: "No Groups Yet",
                        message: "Join a group to start connecting with others",
                        buttonTitle: "Discover Groups",
                        action: {
                            selectedCategory = .discover
                        }
                    )
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredGroups) { group in
                            GroupListItem(
                                group: group,
                                isMember: store.myGroups.contains { $0.id == group.id }
                            ) {
                                store.send(.selectGroup(group))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Groups")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreateGroup = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateGroup) {
            CreateGroupView(store: store)
        }
    }
    
    private func countForCategory(_ category: GroupCategory) -> Int {
        switch category {
        case .all:
            return store.allGroups.count
        case .myGroups:
            return store.myGroups.count
        case .discover:
            return store.discoverGroups.count
        case .local:
            return store.localGroups.count
        case .topical:
            return store.topicalGroups.count
        }
    }
    
    private var filteredGroups: [Group] {
        var groups: [Group]
        
        switch selectedCategory {
        case .all:
            groups = store.allGroups
        case .myGroups:
            groups = store.myGroups
        case .discover:
            groups = store.discoverGroups
        case .local:
            groups = store.localGroups
        case .topical:
            groups = store.topicalGroups
        }
        
        if !searchQuery.isEmpty {
            groups = groups.filter { group in
                group.name.localizedCaseInsensitiveContains(searchQuery) ||
                group.description.localizedCaseInsensitiveContains(searchQuery) ||
                group.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            }
        }
        
        return groups
    }
}

struct GroupListItem: View {
    let group: Group
    let isMember: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Avatar
                GroupAvatar(group: group, size: 60)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(group.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if group.isPrivate {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if group.isVerified {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Text(group.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(group.memberCount)", systemImage: "person.2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if let meetingSchedule = group.meetingSchedule {
                            Label(meetingSchedule, systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        if group.hasUnreadMessages && isMember {
                            Label("New", systemImage: "bubble.left.fill")
                                .font(.caption.bold())
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
                
                // Action Button
                if isMember {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.tertiaryLabel)
                } else {
                    Button("Join") {
                        // Join action
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct GroupDetailView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    @State private var selectedTab: GroupTab = .feed
    
    enum GroupTab: String, CaseIterable {
        case feed = "Feed"
        case members = "Members"
        case about = "About"
        case events = "Events"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            GroupHeaderView(group: group, store: store)
            
            // Tabs
            Picker("Tab", selection: $selectedTab) {
                ForEach(GroupTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                GroupFeedView(group: group, store: store)
                    .tag(GroupTab.feed)
                
                GroupMembersView(group: group, store: store)
                    .tag(GroupTab.members)
                
                GroupAboutView(group: group, store: store)
                    .tag(GroupTab.about)
                
                GroupEventsView(group: group, store: store)
                    .tag(GroupTab.events)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    if store.isGroupMember(group) {
                        Button(action: { /* Notifications */ }) {
                            Label("Notifications", systemImage: "bell")
                        }
                        
                        Button(action: { /* Share */ }) {
                            Label("Share Group", systemImage: "square.and.arrow.up")
                        }
                        
                        Divider()
                        
                        Button(role: .destructive, action: { /* Leave */ }) {
                            Label("Leave Group", systemImage: "person.badge.minus")
                        }
                    } else {
                        Button(action: { /* Share */ }) {
                            Label("Share Group", systemImage: "square.and.arrow.up")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
}

struct GroupHeaderView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // Avatar
            GroupAvatar(group: group, size: 80)
            
            // Stats
            HStack(spacing: 32) {
                VStack(spacing: 4) {
                    Text("\(group.memberCount)")
                        .font(.headline)
                    Text("Members")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let postCount = group.postCount {
                    VStack(spacing: 4) {
                        Text("\(postCount)")
                            .font(.headline)
                        Text("Posts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                if let foundedDate = group.foundedDate {
                    VStack(spacing: 4) {
                        Text(foundedDate, format: .dateTime.year())
                            .font(.headline)
                        Text("Founded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Join/Leave Button
            if !store.isGroupMember(group) {
                Button(group.isPrivate ? "Request to Join" : "Join Group") {
                    store.send(.joinGroup(group.id))
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
        .background(Color.leavnSecondaryBackground)
    }
}

struct CreateGroupView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @Environment(\.dismiss) var dismiss
    @State private var groupName = ""
    @State private var groupDescription = ""
    @State private var isPrivate = false
    @State private var selectedCategory: GroupCategory = .general
    
    enum GroupCategory: String, CaseIterable {
        case general = "General"
        case bibleStudy = "Bible Study"
        case prayer = "Prayer"
        case youth = "Youth"
        case womens = "Women's"
        case mens = "Men's"
        case couples = "Couples"
        case parents = "Parents"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Group Details") {
                    TextField("Group Name", text: $groupName)
                    
                    TextField("Description", text: $groupDescription, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(GroupCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section("Privacy") {
                    Toggle(isOn: $isPrivate) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Private Group")
                            Text("Members must be approved to join")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Text("By creating a group, you agree to moderate content and foster a welcoming community.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Create Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createGroup()
                    }
                    .fontWeight(.semibold)
                    .disabled(groupName.isEmpty || groupDescription.isEmpty)
                }
            }
        }
    }
    
    private func createGroup() {
        let newGroup = CreateGroupRequest(
            name: groupName,
            description: groupDescription,
            category: selectedCategory.rawValue,
            isPrivate: isPrivate
        )
        store.send(.createGroup(newGroup))
        dismiss()
    }
}

// Mock models
struct CreateGroupRequest {
    let name: String
    let description: String
    let category: String
    let isPrivate: Bool
}

struct GroupFeedView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        Text("Group Feed")
    }
}

struct GroupMembersView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        Text("Group Members")
    }
}

struct GroupAboutView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        Text("About Group")
    }
}

struct GroupEventsView: View {
    let group: Group
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        Text("Group Events")
    }
}

// Group extensions
extension Group {
    var initials: String {
        name.split(separator: " ")
            .compactMap { $0.first }
            .map { String($0) }
            .joined()
            .uppercased()
    }
    
    var color: Color {
        // Generate color based on name
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .red]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
    
    var hasUnreadMessages: Bool { false } // Mock
    var recentActivity: String? { nil } // Mock
    var imageURL: URL? { nil } // Mock
    var isPrivate: Bool { false } // Mock
    var isVerified: Bool { false } // Mock
    var meetingSchedule: String? { nil } // Mock
    var postCount: Int? { nil } // Mock
    var foundedDate: Date? { nil } // Mock
    var tags: [String] { [] } // Mock
}

extension CommunityReducer {
    var localGroups: [Group] { [] } // Mock
    var topicalGroups: [Group] { [] } // Mock
    var allGroups: [Group] { myGroups + discoverGroups } // Mock
    
    func isGroupMember(_ group: Group) -> Bool {
        myGroups.contains { $0.id == group.id }
    }
}