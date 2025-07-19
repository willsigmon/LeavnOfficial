import SwiftUI
import ComposableArchitecture

struct PrayerWallPreview: View {
    @Bindable var store: StoreOf<CommunityReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            // Quick Prayer Submit
            QuickPrayerCard {
                store.send(.showCreatePrayer)
            }
            
            // Recent Prayers
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.recentPrayers.prefix(3)) { prayer in
                        PrayerPreviewCard(prayer: prayer) {
                            store.send(.selectPrayer(prayer))
                        }
                    }
                    
                    ViewAllCard(title: "View Prayer Wall") {
                        store.send(.navigateToPrayerWall)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct QuickPrayerCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundColor(.leavnPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Share a Prayer Request")
                        .font(.headline)
                    Text("Let the community pray with you")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
            .padding()
            .background(Color.leavnPrimary.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}

struct PrayerPreviewCard: View {
    let prayer: Prayer
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if prayer.isAnonymous {
                        Image(systemName: "person.fill.questionmark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Anonymous")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                    } else {
                        Circle()
                            .fill(Color.leavnPrimary.opacity(0.2))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Text(prayer.authorName?.prefix(1) ?? "?")
                                    .font(.caption.bold())
                                    .foregroundColor(.leavnPrimary)
                            )
                        Text(prayer.authorName ?? "Unknown")
                            .font(.caption.bold())
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    Text(prayer.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Text(prayer.text)
                    .font(.callout)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: prayer.hasPrayed ? "hands.clap.fill" : "hands.clap")
                            .font(.caption)
                        Text("\(prayer.prayerCount)")
                            .font(.caption)
                    }
                    .foregroundColor(prayer.hasPrayed ? .leavnPrimary : .secondary)
                    
                    Spacer()
                    
                    if prayer.isAnswered {
                        Label("Answered", systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .frame(width: 280)
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct EnhancedPrayerWallView: View {
    @Bindable var store: StoreOf<CommunityReducer>
    @State private var selectedFilter: PrayerFilter = .all
    @State private var showingFilters = false
    
    enum PrayerFilter: String, CaseIterable {
        case all = "All"
        case myPrayers = "My Prayers"
        case praying = "Praying For"
        case answered = "Answered"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filters
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PrayerFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button(action: { showingFilters.toggle() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                            Text("More")
                        }
                        .font(.callout)
                    }
                }
                .padding()
            }
            
            if store.isLoadingPrayers {
                LoadingView(message: "Loading prayers...")
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPrayers) { prayer in
                            EnhancedPrayerCard(
                                prayer: prayer,
                                onPray: { store.send(.prayForRequest(prayer.id)) },
                                onSelect: { store.send(.selectPrayer(prayer)) }
                            )
                        }
                    }
                    .padding()
                }
                .refreshable {
                    store.send(.refreshPrayerWall)
                }
            }
        }
        .navigationTitle("Prayer Wall")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { store.send(.showCreatePrayer) }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            PrayerFiltersView()
        }
    }
    
    private var filteredPrayers: [Prayer] {
        switch selectedFilter {
        case .all:
            return store.prayers
        case .myPrayers:
            return store.prayers.filter { $0.authorId == store.currentUserId }
        case .praying:
            return store.prayers.filter { $0.hasPrayed }
        case .answered:
            return store.prayers.filter { $0.isAnswered }
        }
    }
}

struct EnhancedPrayerCard: View {
    let prayer: Prayer
    let onPray: () -> Void
    let onSelect: () -> Void
    @State private var showingActions = false
    
    var body: some View {
        CardView(style: .elevated) {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .top) {
                    // Author Info
                    HStack(spacing: 12) {
                        if prayer.isAnonymous {
                            Image(systemName: "person.fill.questionmark")
                                .font(.title3)
                                .foregroundColor(.secondary)
                                .frame(width: 40, height: 40)
                                .background(Color.gray.opacity(0.2))
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.leavnPrimary.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(prayer.authorName?.prefix(1) ?? "?")
                                        .font(.headline)
                                        .foregroundColor(.leavnPrimary)
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(prayer.isAnonymous ? "Anonymous" : prayer.authorName ?? "Unknown")
                                .font(.headline)
                            Text(prayer.createdAt, style: .relative)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Menu
                    Menu {
                        Button(action: { /* Share */ }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        if prayer.authorId == store.currentUserId {
                            Divider()
                            
                            Button(action: { /* Edit */ }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: { /* Delete */ }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                    }
                }
                
                // Content
                Text(prayer.text)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tags
                if !prayer.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(prayer.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.leavnPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.leavnPrimary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
                
                // Actions
                HStack {
                    // Pray Button
                    Button(action: onPray) {
                        HStack(spacing: 6) {
                            Image(systemName: prayer.hasPrayed ? "hands.clap.fill" : "hands.clap")
                                .font(.body)
                            Text(prayer.hasPrayed ? "Prayed" : "Pray")
                                .font(.callout.bold())
                            if prayer.prayerCount > 0 {
                                Text("(\(prayer.prayerCount))")
                                    .font(.callout)
                            }
                        }
                        .foregroundColor(prayer.hasPrayed ? .leavnPrimary : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(prayer.hasPrayed ? Color.leavnPrimary.opacity(0.1) : Color.gray.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    Spacer()
                    
                    // Status
                    if prayer.isAnswered {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Answered")
                        }
                        .font(.caption.bold())
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .onTapGesture {
            onSelect()
        }
    }
}

struct PrayerFiltersView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Time Period") {
                    ForEach(["Today", "This Week", "This Month", "All Time"], id: \.self) { period in
                        HStack {
                            Text(period)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.leavnPrimary)
                                .opacity(period == "All Time" ? 1 : 0)
                        }
                    }
                }
                
                Section("Categories") {
                    ForEach(["Health", "Family", "Work", "Spiritual", "Other"], id: \.self) { category in
                        HStack {
                            Text(category)
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.leavnPrimary)
                                .opacity(0)
                        }
                    }
                }
                
                Section {
                    Toggle("Only show prayers needing prayer", isOn: .constant(false))
                    Toggle("Hide anonymous prayers", isOn: .constant(false))
                }
            }
            .navigationTitle("Filter Prayers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") {
                        // Reset filters
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ViewAllCard: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.leavnPrimary)
                
                Text(title)
                    .font(.callout.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 120, height: 120)
            .background(Color.leavnPrimary.opacity(0.1))
            .cornerRadius(12)
        }
    }
}