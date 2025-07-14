import SwiftUI
import UIKit

// Import base components
// Note: Adjust import path based on your project structure
// import BaseComponents
// import ErrorHandling

// MARK: - Library Category
enum LibraryCategory: String, CaseIterable {
    case bookmarks = "bookmarks"
    case highlights = "highlights"
    case notes = "notes"
    case readingPlans = "readingPlans"
    case favorites = "favorites"
    case collections = "collections"
    
    var title: String {
        switch self {
        case .bookmarks: return "Bookmarks"
        case .highlights: return "Highlights"
        case .notes: return "Notes"
        case .readingPlans: return "Reading Plans"
        case .favorites: return "Favorites"
        case .collections: return "Collections"
        }
    }
    
    var icon: String {
        switch self {
        case .bookmarks: return "bookmark.fill"
        case .highlights: return "highlighter"
        case .notes: return "note.text"
        case .readingPlans: return "calendar"
        case .favorites: return "heart.fill"
        case .collections: return "folder.fill"
        }
    }
}

// MARK: - Library Item Protocol
protocol LibraryItemProtocol: Identifiable {
    var id: String { get }
    var title: String { get }
    var date: Date { get }
    var icon: String { get }
    var colorIndex: Int { get }
    var itemCount: Int { get }
    var verses: [LibraryVerse] { get }
}

// MARK: - Library Verse
struct LibraryVerse: Identifiable {
    let id = UUID()
    let number: Int
    let reference: String
    let text: String
}

// MARK: - Library Item Wrapper
struct LibraryItemWrapper: LibraryItemProtocol {
    let id: String
    let title: String
    let date: Date
    let icon: String
    let colorIndex: Int
    let itemCount: Int
    let verses: [LibraryVerse]
    
    init(bookmark: BookmarkItem) {
        self.id = bookmark.id
        self.title = bookmark.reference
        self.date = bookmark.dateAdded
        self.icon = "bookmark.fill"
        self.colorIndex = 0
        self.itemCount = 1
        self.verses = [LibraryVerse(number: 1, reference: bookmark.reference, text: "Bookmarked verse")]
    }
    
    init(highlight: HighlightItem) {
        self.id = highlight.id
        self.title = highlight.reference
        self.date = highlight.dateAdded
        self.icon = "highlighter"
        self.colorIndex = 1
        self.itemCount = 1
        self.verses = [LibraryVerse(number: 1, reference: highlight.reference, text: highlight.text)]
    }
    
    init(note: NoteItem) {
        self.id = note.id
        self.title = note.reference
        self.date = note.dateAdded
        self.icon = "note.text"
        self.colorIndex = 2
        self.itemCount = 1
        self.verses = [LibraryVerse(number: 1, reference: note.reference, text: note.content)]
    }
    
    init(plan: ReadingPlan) {
        self.id = plan.id
        self.title = plan.name
        self.date = Date()
        self.icon = "calendar"
        self.colorIndex = 3
        self.itemCount = plan.daysRemaining
        self.verses = [LibraryVerse(number: 1, reference: plan.name, text: "\(Int(plan.progress * 100))% Complete")]
    }
}

public struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var selectedCategory: LibraryCategory = .bookmarks
    @State private var showAddCollection = false
    @State private var selectedItem: LibraryItemWrapper?
    @State private var searchText = ""
    @State private var sortOption: SortOption = .recent
    @State private var showingSortOptions = false
    @State private var selectedItems: Set<String> = []
    @State private var isSelectionMode = false
    @State private var scrollOffset: CGFloat = 0
    
    // Animation states
    @State private var headerScale: CGFloat = 1.0
    @State private var refreshing = false
    
    enum SortOption: String, CaseIterable {
        case recent = "Recent"
        case alphabetical = "A-Z"
        case mostUsed = "Most Used"
        
        var icon: String {
            switch self {
            case .recent: return "clock.arrow.circlepath"
            case .alphabetical: return "textformat"
            case .mostUsed: return "star.fill"
            }
        }
    }
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Premium background with subtle gradient
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Elegant header
                    libraryHeader
                    
                    // Content with beautiful transitions
                    if viewModel.isLoading {
                        loadingState
                    } else if isEmpty(for: selectedCategory) {
                        emptyState
                    } else {
                        libraryContent
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showAddCollection) {
            AddCollectionView()
        }
        .sheet(item: $selectedItem) { item in
            LibraryItemDetailView(item: item)
        }
        .onAppear {
            viewModel.loadLibraryData()
        }
    }
    
    // MARK: - Header with Premium Design
    private var libraryHeader: some View {
        VStack(spacing: 0) {
            // Top section with title and stats
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Library")
                            .font(.system(size: 34, weight: .bold, design: .default))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Your personal study collection")
                            .font(.system(size: 17, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Elegant stats badge
                    VStack(spacing: 2) {
                        Text("\(totalItems)")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("items")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Premium category selector
                categorySelector
            }
            .padding(.bottom, 24)
            .background(.ultraThinMaterial)
        }
    }
    
    // MARK: - Elegant Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(LibraryCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory == category,
                        count: itemCount(for: category)
                    ) {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            selectedCategory = category
                            // HapticManager.shared.buttonTap()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Loading State
    private var loadingState: some View {
        BaseLoadingView(message: "Loading your library...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Empty State with Elegance
    private var emptyState: some View {
        BaseEmptyStateView(
            title: "No \(selectedCategory.title) Yet",
            message: messageForCategory(selectedCategory),
            icon: iconForCategory(selectedCategory),
            actionTitle: "Start Reading",
            action: startReadingAction
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Premium Library Content
    private var libraryContent: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 20
            ) {
                ForEach(Array(items(for: selectedCategory).enumerated()), id: \.element.id) { index, item in
                    PremiumLibraryCard(
                        item: item,
                        delay: Double(index) * 0.1
                    ) {
                        selectedItem = item
                        // HapticManager.shared.buttonTap()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Helper Functions
    private var totalItems: Int {
        viewModel.bookmarks.count + viewModel.highlights.count + viewModel.notes.count + viewModel.readingPlans.count
    }
    
    private func isEmpty(for category: LibraryCategory) -> Bool {
        items(for: category).isEmpty
    }
    
    private func itemCount(for category: LibraryCategory) -> Int {
        items(for: category).count
    }
    
    private func items(for category: LibraryCategory) -> [LibraryItemWrapper] {
        switch category {
        case .bookmarks:
            return viewModel.bookmarks.map { LibraryItemWrapper(bookmark: $0) }
        case .highlights:
            return viewModel.highlights.map { LibraryItemWrapper(highlight: $0) }
        case .notes:
            return viewModel.notes.map { LibraryItemWrapper(note: $0) }
        case .readingPlans:
            return viewModel.readingPlans.map { LibraryItemWrapper(plan: $0) }
        case .favorites:
            return [] // Not implemented in current ViewModel
        case .collections:
            return [] // Not implemented in current ViewModel
        }
    }
    
    private func iconForCategory(_ category: LibraryCategory) -> String {
        switch category {
        case .bookmarks: return "bookmark.circle"
        case .highlights: return "highlighter"
        case .notes: return "note.text"
        case .readingPlans: return "calendar.circle"
        case .favorites: return "heart.circle"
        case .collections: return "folder.circle"
        }
    }
    
    private func messageForCategory(_ category: LibraryCategory) -> String {
        switch category {
        case .bookmarks: return "Bookmark verses to continue reading later"
        case .highlights: return "Highlight important passages as you read"
        case .notes: return "Add personal notes and insights to verses"
        case .readingPlans: return "Track your Bible reading journey"
        case .favorites: return "Save your favorite verses to access them quickly"
        case .collections: return "Create custom collections to organize your study"
        }
    }
}

// MARK: - Premium Category Chip
struct CategoryChip: View {
    let category: LibraryCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    private var categoryColor: Color {
        switch category {
        case .bookmarks: return .blue
        case .highlights: return .orange
        case .notes: return .green
        case .readingPlans: return .purple
        case .favorites: return .red
        case .collections: return .indigo
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Category icon
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : categoryColor)
                
                // Category title
                Text(category.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Count badge
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? categoryColor : .white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? .white.opacity(0.9) : categoryColor)
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? categoryColor : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(isSelected ? .clear : Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Premium Library Card
struct PremiumLibraryCard: View {
    let item: LibraryItemWrapper
    let delay: Double
    let action: () -> Void
    
    @State private var appear = false
    
    private var itemColor: Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .indigo]
        return colors[item.colorIndex % colors.count]
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                // Beautiful header with icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [itemColor.opacity(0.15), itemColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 100)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 32, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [itemColor, itemColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Content section
                VStack(alignment: .leading, spacing: 12) {
                    Text(item.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Text(item.date, style: .date)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if item.itemCount > 1 {
                            HStack(spacing: 4) {
                                Image(systemName: "doc.on.doc")
                                    .font(.system(size: 10, weight: .medium))
                                Text("\(item.itemCount)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(itemColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(itemColor.opacity(0.1))
                            )
                        }
                    }
                }
                .padding(16)
            }
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 0.5)
                    )
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PremiumCardButtonStyle())
        .opacity(appear ? 1 : 0)
        .scaleEffect(appear ? 1 : 0.9)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8).delay(delay),
            value: appear
        )
        .onAppear {
            appear = true
        }
    }
}

// MARK: - Premium Button Styles
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct PremiumCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}


// MARK: - Add Collection View
struct AddCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    @State private var selectedColor = 0
    @State private var selectedIcon = "folder.fill"
    
    let icons = ["folder.fill", "star.fill", "heart.fill", "bookmark.fill", "flag.fill", "tag.fill"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Collection Name")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter name", text: $collectionName)
                            .textFieldStyle(.plain)
                            .font(.body)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                    }
                    
                    // Icon selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Icon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                            ForEach(icons, id: \.self) { icon in
                                IconOption(
                                    icon: icon,
                                    isSelected: selectedIcon == icon
                                ) {
                                    selectedIcon = icon
                                }
                            }
                        }
                    }
                    
                    // Color selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Color")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                            ForEach(0..<6, id: \.self) { index in
                                ColorOption(
                                    color: [Color.blue, Color.green, Color.orange, Color.purple, Color.red, Color.pink][index],
                                    isSelected: selectedColor == index
                                ) {
                                    selectedColor = index
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("New Collection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        // Create collection
                        dismiss()
                    }
                    .disabled(collectionName.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func messageForCategory(_ category: LibraryCategory) -> String {
        switch category {
        case .bookmarks: return "Start bookmarking verses to save them for later"
        case .highlights: return "Highlight important verses while reading"
        case .notes: return "Add your thoughts and reflections to verses"
        case .readingPlans: return "Create reading plans to guide your Bible study"
        case .favorites: return "Mark verses as favorites for quick access"
        case .collections: return "Organize your verses into custom collections"
        }
    }
    
    private func startReadingAction() {
        // TODO: Navigate to Bible reading view
        print("Start reading action")
    }
}

// MARK: - Icon Option
struct IconOption: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? Color.blue : Color(UIColor.tertiarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.clear : Color(UIColor.separator), lineWidth: 0.5)
                )
        }
    }
}

// MARK: - Color Option
struct ColorOption: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 50, height: 50)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: isSelected ? 3 : 0)
                )
                .scaleEffect(isSelected ? 1.1 : 1)
                .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
    }
}

// MARK: - Library Item Detail View
struct LibraryItemDetailView: View {
    let item: LibraryItemWrapper
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(UIColor.systemBackground),
                        Color(UIColor.systemBackground).opacity(0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(item.verses) { verse in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("\(verse.number)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Capsule())
                                    
                                    Spacer()
                                    
                                    Text(verse.reference)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Text(verse.text)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .lineLimit(nil)
                            }
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(item.title)
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

#Preview {
    LibraryView()
}