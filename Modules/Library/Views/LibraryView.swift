import SwiftUI
import LeavnCore
import DesignSystem
import LibraryModels

public struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var selectedCategory: LibraryModels.LibraryCategory = .bookmarks
    @State private var showAddCollection = false
    @State private var selectedItem: LibraryModels.LibraryItem?
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackground()
            
            VStack(spacing: 0) {
                // Header
                libraryHeader
                
                // Content
                if viewModel.isLoading {
                    Spacer()
                    VibrantLoadingView(message: "Loading your library...")
                    Spacer()
                } else if viewModel.isEmpty(for: selectedCategory) {
                    emptyState
                } else {
                    libraryContent
                }
            }
            
            // Floating add button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingActionButton(icon: "plus") {
                        showAddCollection = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(isPresented: $showAddCollection) {
            AddCollectionView()
        }
        .sheet(item: $selectedItem) { item in
            LibraryItemDetailView(item: item)
        }
        .task {
            await viewModel.loadLibrary()
        }
    }
    
    private var libraryHeader: some View {
        VStack(spacing: 16) {
            // Title
            HStack {
                Text("Library")
                    .font(LeavnTheme.Typography.displayMedium)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [LeavnTheme.Colors.accentLight, LeavnTheme.Colors.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                Spacer()
                
                // Stats
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(viewModel.totalItems)")
                        .font(LeavnTheme.Typography.titleMedium)
                        .foregroundColor(.primary)
                    Text("Items")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Category tabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(LibraryModels.LibraryCategory.allCases, id: \.self) { category in
                        CategoryTab(
                            category: category,
                            isSelected: selectedCategory == category,
                            count: viewModel.itemCount(for: category)
                        ) {
                            withAnimation(LeavnTheme.Motion.smoothSpring) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 16)
        .background(.ultraThinMaterial)
    }
    
    private var emptyState: some View {
        PlayfulEmptyState(
            icon: iconForCategory(selectedCategory),
            title: "No \(selectedCategory.title) Yet",
            message: messageForCategory(selectedCategory),
            buttonTitle: "Add First Item",
            action: { showAddCollection = true }
        )
    }
    
    private var libraryContent: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], spacing: 16) {
                ForEach(Array(viewModel.items(for: selectedCategory).enumerated()), id: \.element.id) { index, item in
                    LibraryItemCard(
                        item: item,
                        delay: LeavnTheme.Motion.staggerDelay(index: index)
                    ) {
                        selectedItem = item
                    }
                }
            }
            .padding(20)
            .padding(.bottom, 100)
        }
    }
    
    private func iconForCategory(_ category: LibraryModels.LibraryCategory) -> String {
        switch category {
        case .bookmarks: return "bookmark.circle"
        case .highlights: return "highlighter"
        case .notes: return "note.text"
        case .readingPlans: return "calendar.circle"
        case .favorites: return "heart.circle"
        case .collections: return "folder.circle"
        }
    }
    
    private func messageForCategory(_ category: LibraryModels.LibraryCategory) -> String {
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

// MARK: - Category Tab
struct CategoryTab: View {
    let category: LibraryModels.LibraryCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    private var categoryColor: Color {
        switch category {
        case .bookmarks: return LeavnTheme.Colors.info
        case .highlights: return LeavnTheme.Colors.warning
        case .notes: return LeavnTheme.Colors.success
        case .readingPlans: return LeavnTheme.Colors.accent
        case .favorites: return LeavnTheme.Colors.error
        case .collections: return LeavnTheme.Colors.accent
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(category.title)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if count > 0 {
                    Text("\(count)")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.2) : categoryColor.opacity(0.2))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(isSelected ? categoryColor : Color(UIColor.tertiarySystemBackground))
            )
            .shadow(
                color: isSelected ? categoryColor.opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
    }
}

// MARK: - Library Item Card
struct LibraryItemCard: View {
    let item: LibraryModels.LibraryItem
    let delay: Double
    let action: () -> Void
    
    @State private var appear = false
    @State private var isPressed = false
    
    private var itemColor: Color {
        LeavnTheme.Colors.categoryColors[item.colorIndex % LeavnTheme.Colors.categoryColors.count]
    }
    
    var body: some View {
        Button(action: {
            withAnimation(LeavnTheme.Motion.quickBounce) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(itemColor.opacity(0.2))
                        .frame(height: 100)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 32))
                        .foregroundColor(itemColor)
                }
                
                // Title
                Text(item.title)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Metadata
                HStack {
                    Text(item.date, style: .date)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if item.itemCount > 1 {
                        Text("\(item.itemCount) items")
                            .font(LeavnTheme.Typography.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.secondarySystemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(itemColor.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1)
            .shadow(
                color: LeavnTheme.Shadows.soft.color,
                radius: isPressed ? 2 : LeavnTheme.Shadows.soft.radius,
                x: 0,
                y: isPressed ? 1 : LeavnTheme.Shadows.soft.y
            )
            .opacity(appear ? 1 : 0)
            .scaleEffect(appear ? 1 : 0.8)
            .animation(
                LeavnTheme.Motion.smoothSpring.delay(delay),
                value: appear
            )
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            appear = true
        }
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
                LeavnTheme.Colors.darkBackground.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Name input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Collection Name")
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.secondary)
                        
                        TextField("Enter name", text: $collectionName)
                            .textFieldStyle(.plain)
                            .font(LeavnTheme.Typography.body)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(UIColor.secondarySystemBackground))
                            )
                    }
                    
                    // Icon selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Choose Icon")
                            .font(LeavnTheme.Typography.headline)
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
                            .font(LeavnTheme.Typography.headline)
                            .foregroundColor(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 12) {
                            ForEach(0..<LeavnTheme.Colors.categoryColors.count, id: \.self) { index in
                                ColorOption(
                                    color: LeavnTheme.Colors.categoryColors[index],
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
                        .fill(isSelected ? LeavnTheme.Colors.accent : Color(UIColor.tertiarySystemBackground))
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
                .animation(LeavnTheme.Motion.quickBounce, value: isSelected)
        }
    }
}

// MARK: - Library Item Detail View
struct LibraryItemDetailView: View {
    let item: LibraryModels.LibraryItem
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(item.verses) { verse in
                            VerseCard(
                                verseNumber: verse.number,
                                text: verse.text,
                                reference: verse.reference,
                                isHighlighted: true
                            ) {
                                // Handle verse tap
                            }
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
