import SwiftUI
import ComposableArchitecture

public struct CommunityView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    
    public init(store: StoreOf<CommunityReducer>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Community", selection: $store.selectedTab.sending(\.tabSelected)) {
                    ForEach(CommunityReducer.State.Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch store.selectedTab {
                case .prayerWall:
                    PrayerWallView(store: store.scope(state: \.prayerWall, action: \.prayerWall))
                case .groups:
                    GroupsView(store: store.scope(state: \.groups, action: \.groups))
                }
            }
            .navigationTitle("Community")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Prayer Wall View

struct PrayerWallView: View {
    @Bindable var store: StoreOf<PrayerWallReducer>
    
    var body: some View {
        VStack {
            if store.isLoading && store.prayers.isEmpty {
                ProgressView("Loading prayers...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // New prayer input
                        VStack(spacing: 12) {
                            Text("Share a Prayer Request")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            TextField("What's on your heart?", text: $store.newPrayerText.sending(\.newPrayerTextChanged), axis: .vertical)
                                .textFieldStyle(.roundedBorder)
                                .lineLimit(3...6)
                            
                            HStack {
                                Toggle("Post Anonymously", isOn: $store.isAnonymous.sending(\.anonymousToggled))
                                    .toggleStyle(.switch)
                                
                                Spacer()
                                
                                Button("Submit") {
                                    store.send(.submitPrayer)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(store.newPrayerText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Prayer requests
                        ForEach(store.prayers) { prayer in
                            PrayerCardView(
                                prayer: prayer,
                                onPray: { store.send(.prayForRequest(prayer.id)) },
                                onDelete: prayer.authorId == store.currentUserId ? {
                                    store.send(.deletePrayer(prayer.id))
                                } : nil
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    store.send(.loadPrayers)
                }
            }
            
            if let error = store.error {
                ErrorBanner(message: error)
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct PrayerCardView: View {
    let prayer: Prayer
    let onPray: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(prayer.authorName ?? "Anonymous")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(prayer.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let onDelete {
                    Menu {
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Text(prayer.text)
                .font(.body)
                .multilineTextAlignment(.leading)
            
            HStack {
                Button(action: onPray) {
                    HStack(spacing: 4) {
                        Image(systemName: prayer.hasPrayed ? "hands.clap.fill" : "hands.clap")
                        Text("\(prayer.prayerCount) \(prayer.prayerCount == 1 ? "prayer" : "prayers")")
                            .font(.caption)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(prayer.hasPrayed ? .blue : .secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Groups View

struct GroupsView: View {
    @Bindable var store: StoreOf<GroupsReducer>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search groups...", text: $store.searchQuery.sending(\.searchQueryChanged))
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                if store.isLoading {
                    ProgressView("Loading groups...")
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    // My Groups
                    if !store.myGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("My Groups")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(store.myGroups) { group in
                                GroupCardView(
                                    group: group,
                                    isMember: true,
                                    action: {
                                        store.send(.leaveGroup(group.id))
                                    }
                                )
                            }
                        }
                    }
                    
                    // Discover Groups
                    if !store.discoverGroups.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Discover Groups")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(store.discoverGroups.filter { group in
                                store.searchQuery.isEmpty ||
                                group.name.localizedCaseInsensitiveContains(store.searchQuery) ||
                                group.description.localizedCaseInsensitiveContains(store.searchQuery)
                            }) { group in
                                GroupCardView(
                                    group: group,
                                    isMember: false,
                                    action: {
                                        store.send(.joinGroup(group.id))
                                    }
                                )
                            }
                        }
                    }
                }
                
                if let error = store.error {
                    ErrorBanner(message: error)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

struct GroupCardView: View {
    let group: Group
    let isMember: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.name)
                    .font(.headline)
                
                Text(group.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.caption)
                    Text("\(group.memberCount) members")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: action) {
                Text(isMember ? "Leave" : "Join")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ErrorBanner: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.caption)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.red)
    }
}