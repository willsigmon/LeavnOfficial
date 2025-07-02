import SwiftUI
import RealityKit

#if os(visionOS)

// MARK: - VisionOS Bible Study Scene

@available(visionOS 2.0, *)
public struct VisionBibleStudyView: View {
    @StateObject private var viewModel = VisionBibleStudyViewModel()
    @EnvironmentObject var container: DIContainer
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar for navigation
            VisionSidebarView()
                .frame(minWidth: 300)
        } content: {
            // Main content area
            VisionMainContentView()
                .frame(minWidth: 400)
        } detail: {
            // Detail view for verses/studies
            VisionDetailView()
                .frame(minWidth: 500)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomOrnament) {
                HStack(spacing: 20) {
                    // Immersive Space Toggle
                    Button {
                        Task {
                            await toggleImmersiveSpace()
                        }
                    } label: {
                        Label(
                            viewModel.isImmersiveSpaceOpen ? "Exit Study Space" : "Enter Study Space",
                            systemImage: viewModel.isImmersiveSpaceOpen ? "xmark.circle" : "globe.americas"
                        )
                    }
                    .controlSize(.large)
                    
                    // Reading Mode
                    Button {
                        viewModel.toggleReadingMode()
                    } label: {
                        Label("Reading Mode", systemImage: "book.pages")
                    }
                    .controlSize(.large)
                    
                    // Spatial Controls
                    Button {
                        viewModel.toggleSpatialControls()
                    } label: {
                        Label("Spatial Controls", systemImage: "hand.tap")
                    }
                    .controlSize(.large)
                }
            }
        }
        .task {
            viewModel.container = container
            await viewModel.initialize()
        }
        .onChange(of: viewModel.selectedEnvironment) { oldValue, newValue in
            Task {
                await updateImmersiveEnvironment(newValue)
            }
        }
    }
    
    private func toggleImmersiveSpace() async {
        if viewModel.isImmersiveSpaceOpen {
            await dismissImmersiveSpace()
            viewModel.isImmersiveSpaceOpen = false
        } else {
            switch await openImmersiveSpace(id: "BibleStudySpace") {
            case .opened:
                viewModel.isImmersiveSpaceOpen = true
            case .error, .userCancelled:
                break
            @unknown default:
                break
            }
        }
    }
    
    private func updateImmersiveEnvironment(_ environment: StudyEnvironment) async {
        // Update the immersive space environment
        // This would communicate with the RealityKit scene
    }
}

// MARK: - Vision Sidebar View

@available(visionOS 2.0, *)
struct VisionSidebarView: View {
    @StateObject private var viewModel = VisionSidebarViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        List {
            Section("Library") {
                NavigationLink("Bible Books") {
                    VisionBibleBooksView()
                }
                
                NavigationLink("Bookmarks") {
                    VisionBookmarksView()
                }
                
                NavigationLink("Reading Plans") {
                    VisionReadingPlansView()
                }
                
                NavigationLink("Reading History") {
                    VisionReadingHistoryView()
                }
            }
            
            Section("Study Tools") {
                NavigationLink("Search") {
                    VisionSearchView()
                }
                
                NavigationLink("Commentaries") {
                    VisionCommentariesView()
                }
                
                NavigationLink("Cross References") {
                    VisionCrossReferencesView()
                }
            }
            
            Section("Environments") {
                ForEach(StudyEnvironment.allCases, id: \.self) { environment in
                    Button {
                        viewModel.selectEnvironment(environment)
                    } label: {
                        HStack {
                            Image(systemName: environment.systemImage)
                                .foregroundColor(environment.color)
                            Text(environment.displayName)
                            Spacer()
                            if viewModel.selectedEnvironment == environment {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("Bible Study")
        .task {
            viewModel.container = container
        }
    }
}

// MARK: - Vision Main Content View

@available(visionOS 2.0, *)
struct VisionMainContentView: View {
    @StateObject private var viewModel = VisionMainContentViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack(spacing: 0) {
            // Chapter Navigation
            VisionChapterNavigationView()
                .padding()
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            
            // Bible Text with Spatial Scrolling
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(viewModel.verses, id: \.id) { verse in
                        VisionVerseCard(
                            verse: verse,
                            isHighlighted: viewModel.highlightedVerses.contains(verse.id)
                        ) {
                            viewModel.toggleHighlight(verse)
                        }
                        .id(verse.id)
                    }
                }
                .padding()
            }
            .scrollTargetBehavior(.viewAligned)
        }
        .navigationTitle(viewModel.currentChapterTitle)
        .task {
            viewModel.container = container
            await viewModel.loadCurrentChapter()
        }
    }
}

// MARK: - Vision Detail View

@available(visionOS 2.0, *)
struct VisionDetailView: View {
    @StateObject private var viewModel = VisionDetailViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let selectedVerse = viewModel.selectedVerse {
                // Verse Details
                VisionVerseDetailCard(verse: selectedVerse)
                
                // AI Insights (if available)
                if !viewModel.insights.isEmpty {
                    VisionInsightsSection(insights: viewModel.insights)
                }
                
                // Cross References
                if !viewModel.crossReferences.isEmpty {
                    VisionCrossReferencesSection(references: viewModel.crossReferences)
                }
                
                // Commentary
                if let commentary = viewModel.commentary {
                    VisionCommentarySection(commentary: commentary)
                }
            } else {
                // Empty state
                VStack {
                    Image(systemName: "book.closed")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a verse to view details")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding()
        .task {
            viewModel.container = container
        }
    }
}

// MARK: - Vision Verse Card

@available(visionOS 2.0, *)
struct VisionVerseCard: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    let onTap: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number
            Text("\(verse.verse)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
            
            // Verse text
            Text(verse.text)
                .font(.body)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHighlighted ? .blue.opacity(0.1) : .clear)
                .stroke(
                    isHighlighted ? .blue : (isHovered ? .secondary.opacity(0.3) : .clear),
                    lineWidth: isHighlighted ? 2 : 1
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onTap()
        }
        .hoverEffect(.lift)
    }
}

// MARK: - Vision Chapter Navigation

@available(visionOS 2.0, *)
struct VisionChapterNavigationView: View {
    @StateObject private var viewModel = VisionChapterNavigationViewModel()
    
    var body: some View {
        HStack(spacing: 16) {
            // Book selector
            Menu {
                ForEach(BibleBook.allCases, id: \.self) { book in
                    Button(book.name) {
                        viewModel.selectBook(book)
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedBook.name)
                        .font(.headline)
                    Image(systemName: "chevron.down")
                        .font(.caption)
                }
            }
            .controlSize(.large)
            
            // Chapter navigation
            HStack(spacing: 8) {
                Button {
                    viewModel.previousChapter()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.canGoPrevious)
                
                Text("Chapter \(viewModel.selectedChapter)")
                    .font(.headline)
                    .frame(minWidth: 100)
                
                Button {
                    viewModel.nextChapter()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.canGoNext)
            }
            .controlSize(.large)
            
            Spacer()
            
            // Translation selector
            Menu {
                ForEach(BibleTranslation.defaultTranslations, id: \.id) { translation in
                    Button(translation.abbreviation) {
                        viewModel.selectTranslation(translation)
                    }
                }
            } label: {
                Text(viewModel.selectedTranslation.abbreviation)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

// MARK: - Study Environment Enum

public enum StudyEnvironment: String, CaseIterable {
    case sanctuary = "Sanctuary"
    case nature = "Nature"
    case library = "Library"
    case desert = "Desert"
    case mountain = "Mountain"
    case lakeside = "Lakeside"
    
    var displayName: String {
        return rawValue
    }
    
    var systemImage: String {
        switch self {
        case .sanctuary:
            return "building.columns"
        case .nature:
            return "leaf"
        case .library:
            return "books.vertical"
        case .desert:
            return "sun.max"
        case .mountain:
            return "mountain.2"
        case .lakeside:
            return "water.waves"
        }
    }
    
    var color: Color {
        switch self {
        case .sanctuary:
            return .brown
        case .nature:
            return .green
        case .library:
            return .blue
        case .desert:
            return .orange
        case .mountain:
            return .gray
        case .lakeside:
            return .cyan
        }
    }
}

// MARK: - Supporting Views

@available(visionOS 2.0, *)
struct VisionBibleBooksView: View {
    var body: some View {
        Text("Bible Books - VisionOS Implementation")
            .navigationTitle("Bible Books")
    }
}

@available(visionOS 2.0, *)
struct VisionBookmarksView: View {
    var body: some View {
        Text("Bookmarks - VisionOS Implementation")
            .navigationTitle("Bookmarks")
    }
}

@available(visionOS 2.0, *)
struct VisionReadingPlansView: View {
    var body: some View {
        Text("Reading Plans - VisionOS Implementation")
            .navigationTitle("Reading Plans")
    }
}

@available(visionOS 2.0, *)
struct VisionReadingHistoryView: View {
    var body: some View {
        Text("Reading History - VisionOS Implementation")
            .navigationTitle("Reading History")
    }
}

@available(visionOS 2.0, *)
struct VisionSearchView: View {
    var body: some View {
        Text("Search - VisionOS Implementation")
            .navigationTitle("Search")
    }
}

@available(visionOS 2.0, *)
struct VisionCommentariesView: View {
    var body: some View {
        Text("Commentaries - VisionOS Implementation")
            .navigationTitle("Commentaries")
    }
}

@available(visionOS 2.0, *)
struct VisionCrossReferencesView: View {
    var body: some View {
        Text("Cross References - VisionOS Implementation")
            .navigationTitle("Cross References")
    }
}

// MARK: - Detail Section Views

@available(visionOS 2.0, *)
struct VisionVerseDetailCard: View {
    let verse: BibleVerse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verse.reference)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(verse.translation)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            
            Text(verse.text)
                .font(.body)
                .lineSpacing(6)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

@available(visionOS 2.0, *)
struct VisionInsightsSection: View {
    let insights: [AIInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("AI Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(insights, id: \.id) { insight in
                VisionInsightCard(insight: insight)
            }
        }
    }
}

@available(visionOS 2.0, *)
struct VisionInsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: insight.type.iconName)
                    .foregroundColor(insight.type.color)
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(insight.content)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(insight.type.backgroundColor, in: RoundedRectangle(cornerRadius: 8))
    }
}

@available(visionOS 2.0, *)
struct VisionCrossReferencesSection: View {
    let references: [BibleVerse]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Cross References")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(references, id: \.id) { reference in
                    VisionCrossReferenceCard(verse: reference)
                }
            }
        }
    }
}

@available(visionOS 2.0, *)
struct VisionCrossReferenceCard: View {
    let verse: BibleVerse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.medium)
            
            Text(verse.text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

@available(visionOS 2.0, *)
struct VisionCommentarySection: View {
    let commentary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Commentary")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(commentary)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

#endif