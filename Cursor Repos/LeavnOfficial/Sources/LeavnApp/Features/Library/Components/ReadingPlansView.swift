import SwiftUI
import ComposableArchitecture

struct ReadingPlansPreview: View {
    @Bindable var store: StoreOf<LibraryReducer>
    
    var body: some View {
        VStack(spacing: 16) {
            if store.activeReadingPlans.isEmpty {
                EmptyReadingPlanCard {
                    store.send(.navigateToReadingPlans)
                }
            } else {
                ForEach(store.activeReadingPlans.prefix(2)) { plan in
                    ActiveReadingPlanCard(plan: plan) {
                        store.send(.selectReadingPlan(plan))
                    }
                }
                
                if store.activeReadingPlans.count > 2 {
                    Button(action: { store.send(.navigateToReadingPlans) }) {
                        HStack {
                            Text("View All Plans")
                                .font(.callout.bold())
                            Image(systemName: "arrow.right")
                                .font(.caption)
                        }
                        .foregroundColor(.leavnPrimary)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct EmptyReadingPlanCard: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.largeTitle)
                    .foregroundColor(.leavnPrimary)
                
                VStack(spacing: 4) {
                    Text("Start a Reading Plan")
                        .font(.headline)
                    Text("Stay consistent with daily Bible reading")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.leavnPrimary.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct ActiveReadingPlanCard: View {
    let plan: ReadingPlan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(plan.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("\(plan.duration) days • \(plan.category)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Progress Circle
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                            .frame(width: 50, height: 50)
                        
                        Circle()
                            .trim(from: 0, to: plan.progress)
                            .stroke(Color.leavnPrimary, lineWidth: 4)
                            .frame(width: 50, height: 50)
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(plan.progress * 100))%")
                            .font(.caption.bold())
                    }
                }
                
                // Today's Reading
                if let todayReading = plan.todayReading {
                    HStack {
                        Image(systemName: "book.fill")
                            .font(.caption)
                            .foregroundColor(.leavnPrimary)
                        
                        Text("Today: \(todayReading)")
                            .font(.callout)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if plan.isCompletedToday {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Stats
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("\(plan.currentStreak) days")
                                .font(.caption.bold())
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("\(plan.daysRemaining) days")
                            .font(.caption.bold())
                    }
                }
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct ReadingPlansView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @State private var selectedCategory: PlanCategory = .all
    @State private var showingCreatePlan = false
    
    enum PlanCategory: String, CaseIterable {
        case all = "All"
        case active = "Active"
        case completed = "Completed"
        case bookmarked = "Saved"
        
        var icon: String {
            switch self {
            case .all: return "square.grid.2x2"
            case .active: return "play.circle"
            case .completed: return "checkmark.circle"
            case .bookmarked: return "bookmark"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(PlanCategory.allCases, id: \.self) { category in
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
                .padding()
            }
            
            // Content
            ScrollView {
                LazyVStack(spacing: 16) {
                    if filteredPlans.isEmpty {
                        EmptyStateView(
                            icon: "calendar",
                            title: emptyStateTitle,
                            message: emptyStateMessage,
                            buttonTitle: "Browse Plans",
                            action: {
                                showingCreatePlan = true
                            }
                        )
                        .padding(.top, 60)
                    } else {
                        ForEach(filteredPlans) { plan in
                            ReadingPlanRow(plan: plan) {
                                store.send(.selectReadingPlan(plan))
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Reading Plans")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingCreatePlan = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreatePlan) {
            BrowseReadingPlansView(store: store)
        }
    }
    
    private var filteredPlans: [ReadingPlan] {
        switch selectedCategory {
        case .all:
            return store.allReadingPlans
        case .active:
            return store.activeReadingPlans
        case .completed:
            return store.completedReadingPlans
        case .bookmarked:
            return store.bookmarkedReadingPlans
        }
    }
    
    private func countForCategory(_ category: PlanCategory) -> Int {
        switch category {
        case .all:
            return store.allReadingPlans.count
        case .active:
            return store.activeReadingPlans.count
        case .completed:
            return store.completedReadingPlans.count
        case .bookmarked:
            return store.bookmarkedReadingPlans.count
        }
    }
    
    private var emptyStateTitle: String {
        switch selectedCategory {
        case .all:
            return "No Reading Plans"
        case .active:
            return "No Active Plans"
        case .completed:
            return "No Completed Plans"
        case .bookmarked:
            return "No Saved Plans"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedCategory {
        case .all:
            return "Start your Bible reading journey"
        case .active:
            return "Browse and start a new reading plan"
        case .completed:
            return "Complete a reading plan to see it here"
        case .bookmarked:
            return "Save plans for later"
        }
    }
}

struct CategoryTab: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.body)
                    Text(title)
                        .font(.callout.bold())
                }
                .foregroundColor(isSelected ? .leavnPrimary : .secondary)
                
                if count > 0 {
                    Text("\(count)")
                        .font(.caption.bold())
                        .foregroundColor(isSelected ? .white : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.3))
                        .cornerRadius(10)
                }
                
                // Selection Indicator
                Rectangle()
                    .fill(Color.leavnPrimary)
                    .frame(height: 2)
                    .opacity(isSelected ? 1 : 0)
            }
        }
    }
}

struct ReadingPlanRow: View {
    let plan: ReadingPlan
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: plan.icon)
                    .font(.title2)
                    .foregroundColor(.leavnPrimary)
                    .frame(width: 50, height: 50)
                    .background(Color.leavnPrimary.opacity(0.1))
                    .cornerRadius(12)
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(plan.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 12) {
                        Label("\(plan.duration) days", systemImage: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if plan.isActive {
                            Label("\(Int(plan.progress * 100))% complete", systemImage: "chart.bar.fill")
                                .font(.caption)
                                .foregroundColor(.leavnPrimary)
                        }
                    }
                }
                
                Spacer()
                
                // Status Indicator
                if plan.isActive {
                    VStack {
                        if plan.isCompletedToday {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                        
                        if plan.currentStreak > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .font(.caption2)
                                Text("\(plan.currentStreak)")
                                    .font(.caption2.bold())
                            }
                            .foregroundColor(.orange)
                        }
                    }
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.tertiaryLabel)
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

struct BrowseReadingPlansView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @Environment(\.dismiss) var dismiss
    @State private var searchQuery = ""
    @State private var selectedDuration: Duration = .all
    @State private var selectedTheme: Theme = .all
    
    enum Duration: String, CaseIterable {
        case all = "All"
        case week = "7 Days"
        case month = "30 Days"
        case quarter = "90 Days"
        case year = "365 Days"
    }
    
    enum Theme: String, CaseIterable {
        case all = "All Themes"
        case wholeBible = "Whole Bible"
        case newTestament = "New Testament"
        case oldTestament = "Old Testament"
        case topical = "Topical"
        case devotional = "Devotional"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search reading plans...", text: $searchQuery)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Menu {
                            ForEach(Duration.allCases, id: \.self) { duration in
                                Button(action: { selectedDuration = duration }) {
                                    HStack {
                                        Text(duration.rawValue)
                                        if selectedDuration == duration {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedDuration.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.callout)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                        
                        Menu {
                            ForEach(Theme.allCases, id: \.self) { theme in
                                Button(action: { selectedTheme = theme }) {
                                    HStack {
                                        Text(theme.rawValue)
                                        if selectedTheme == theme {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedTheme.rawValue)
                                Image(systemName: "chevron.down")
                            }
                            .font(.callout)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Plans List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(store.availableReadingPlans) { plan in
                            AvailableReadingPlanCard(plan: plan) {
                                store.send(.startReadingPlan(plan))
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Browse Plans")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AvailableReadingPlanCard: View {
    let plan: ReadingPlan
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Image(systemName: plan.icon)
                    .font(.largeTitle)
                    .foregroundColor(.leavnPrimary)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.headline)
                    Text(plan.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Description
            Text(plan.description)
                .font(.callout)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            // Details
            HStack(spacing: 20) {
                Label("\(plan.duration) days", systemImage: "calendar")
                    .font(.caption)
                
                Label("\(plan.dailyReadingTime) min/day", systemImage: "clock")
                    .font(.caption)
                
                if plan.difficulty != nil {
                    Label(plan.difficulty!, systemImage: "chart.bar")
                        .font(.caption)
                }
            }
            .foregroundColor(.secondary)
            
            // Action Button
            Button(action: onStart) {
                Text("Start Plan")
                    .font(.callout.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.leavnPrimary)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
    }
}