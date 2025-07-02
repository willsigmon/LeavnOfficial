import SwiftUI
import AppKit

#if os(macOS)

// MARK: - macOS Main Bible View

@available(macOS 15.0, *)
public struct MacBibleView: View {
    @StateObject private var viewModel = MacBibleViewModel()
    @EnvironmentObject var container: DIContainer
    @Environment(\.openWindow) private var openWindow
    @State private var selectedSidebarItem: SidebarItem? = .bible
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView(
            columnVisibility: $viewModel.columnVisibility,
            sidebar: {
                MacSidebarView(selectedItem: $selectedSidebarItem)
                    .frame(minWidth: 200, idealWidth: 250)
                    .toolbar {
                        ToolbarItem(placement: .navigation) {
                            Button {
                                viewModel.toggleSidebar()
                            } label: {
                                Image(systemName: "sidebar.leading")
                            }
                            .help("Toggle Sidebar")
                        }
                    }
            },
            content: {
                MacContentView(selectedItem: selectedSidebarItem ?? .bible)
                    .frame(minWidth: 400, idealWidth: 600)
            },
            detail: {
                MacDetailView()
                    .frame(minWidth: 300, idealWidth: 400)
            }
        )
        .navigationSplitViewColumnWidth(
            sidebar: 200...300,
            content: 400...800,
            detail: 300...500
        )
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                MacToolbarView()
            }
        }
        .task {
            viewModel.container = container
            await viewModel.initialize()
        }
        .onAppear {
            setupWindowSettings()
        }
    }
    
    private func setupWindowSettings() {
        // Configure window for better Bible reading experience
        if let window = NSApp.keyWindow {
            window.title = "Leavn Bible"
            window.subtitle = "Study • Read • Reflect"
            window.titlebarAppearsTransparent = false
            window.titleVisibility = .visible
            
            // Set minimum window size
            window.minSize = NSSize(width: 900, height: 600)
            
            // Center window on first launch
            if !UserDefaults.standard.bool(forKey: "mac_window_positioned") {
                window.center()
                UserDefaults.standard.set(true, forKey: "mac_window_positioned")
            }
        }
    }
}

// MARK: - macOS Sidebar View

@available(macOS 15.0, *)
struct MacSidebarView: View {
    @Binding var selectedItem: SidebarItem?
    @StateObject private var viewModel = MacSidebarViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        List(selection: $selectedItem) {
            Section("Study") {
                ForEach(SidebarItem.studyItems, id: \.self) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                }
            }
            
            Section("Library") {
                ForEach(SidebarItem.libraryItems, id: \.self) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                        .badge(viewModel.getBadgeCount(for: item))
                }
            }
            
            Section("Tools") {
                ForEach(SidebarItem.toolItems, id: \.self) { item in
                    Label(item.title, systemImage: item.systemImage)
                        .tag(item)
                }
            }
            
            if !viewModel.recentBooks.isEmpty {
                Section("Recent") {
                    ForEach(viewModel.recentBooks, id: \.id) { book in
                        Button {
                            viewModel.openRecentBook(book)
                        } label: {
                            HStack {
                                Image(systemName: "book.closed")
                                    .foregroundColor(.secondary)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(book.name)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                    Text("Chapter \(book.lastChapter)")
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Bible Study")
        .task {
            viewModel.container = container
            await viewModel.loadSidebarData()
        }
    }
}

// MARK: - macOS Content View

@available(macOS 15.0, *)
struct MacContentView: View {
    let selectedItem: SidebarItem
    @StateObject private var viewModel = MacContentViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        Group {
            switch selectedItem {
            case .bible:
                MacBibleReaderView()
            case .search:
                MacSearchView()
            case .bookmarks:
                MacBookmarksView()
            case .readingPlans:
                MacReadingPlansView()
            case .history:
                MacReadingHistoryView()
            case .commentaries:
                MacCommentariesView()
            case .crossReferences:
                MacCrossReferencesView()
            case .settings:
                MacSettingsView()
            }
        }
        .task {
            viewModel.container = container
            await viewModel.loadContent(for: selectedItem)
        }
    }
}

// MARK: - macOS Detail View

@available(macOS 15.0, *)
struct MacDetailView: View {
    @StateObject private var viewModel = MacDetailViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack(spacing: 0) {
            if let selectedVerse = viewModel.selectedVerse {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Verse Header
                        MacVerseHeaderCard(verse: selectedVerse)
                        
                        // AI Insights
                        if !viewModel.aiInsights.isEmpty {
                            MacInsightsSection(insights: viewModel.aiInsights)
                        }
                        
                        // Cross References
                        if !viewModel.crossReferences.isEmpty {
                            MacCrossReferencesSection(references: viewModel.crossReferences)
                        }
                        
                        // Commentary
                        if let commentary = viewModel.commentary {
                            MacCommentarySection(commentary: commentary)
                        }
                        
                        // Notes
                        MacNotesSection(
                            verse: selectedVerse,
                            note: viewModel.userNote,
                            onNoteChanged: { note in
                                Task {
                                    await viewModel.saveNote(note, for: selectedVerse)
                                }
                            }
                        )
                    }
                    .padding()
                }
            } else {
                MacEmptyDetailView()
            }
        }
        .navigationTitle("Details")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if viewModel.selectedVerse != nil {
                    MacDetailToolbarView(verse: viewModel.selectedVerse!)
                }
            }
        }
        .task {
            viewModel.container = container
        }
    }
}

// MARK: - macOS Bible Reader View

@available(macOS 15.0, *)
struct MacBibleReaderView: View {
    @StateObject private var viewModel = MacBibleReaderViewModel()
    @EnvironmentObject var container: DIContainer
    @FocusState private var isTextFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Chapter Navigation
            MacChapterNavigationBar()
                .padding()
                .background(.regularMaterial)
            
            Divider()
            
            // Bible Text
            GeometryReader { geometry in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.verses, id: \.id) { verse in
                            MacVerseRow(
                                verse: verse,
                                isSelected: viewModel.selectedVerses.contains(verse.id),
                                isHighlighted: viewModel.highlightedVerses.contains(verse.id),
                                fontSize: viewModel.fontSize
                            ) {
                                viewModel.selectVerse(verse)
                            } onRightClick: { location in
                                viewModel.showContextMenu(for: verse, at: location)
                            }
                            .id(verse.id)
                        }
                    }
                    .padding()
                }
                .focused($isTextFocused)
                .scrollTargetBehavior(.viewAligned)
            }
        }
        .navigationTitle(viewModel.currentChapterTitle)
        .navigationSubtitle(viewModel.currentTranslation.name)
        .task {
            viewModel.container = container
            await viewModel.loadCurrentChapter()
        }
        .onAppear {
            isTextFocused = true
        }
        .contextMenu {
            if let selectedVerse = viewModel.contextMenuVerse {
                MacVerseContextMenu(verse: selectedVerse, viewModel: viewModel)
            }
        }
    }
}

// MARK: - macOS Verse Row

@available(macOS 15.0, *)
struct MacVerseRow: View {
    let verse: BibleVerse
    let isSelected: Bool
    let isHighlighted: Bool
    let fontSize: CGFloat
    let onSelect: () -> Void
    let onRightClick: (NSPoint) -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number
            Text("\(verse.verse)")
                .font(.system(size: fontSize * 0.8))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
                .opacity(isHovered ? 1.0 : 0.7)
            
            // Verse text
            Text(verse.text)
                .font(.system(size: fontSize))
                .lineSpacing(fontSize * 0.3)
                .textSelection(.enabled)
                .multilineTextAlignment(.leading)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(backgroundColorForVerse)
                .opacity(backgroundOpacity)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(borderColorForVerse, lineWidth: borderWidth)
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            onSelect()
        }
        .onRightClick { location in
            onRightClick(location)
        }
    }
    
    private var backgroundColorForVerse: Color {
        if isSelected {
            return .accentColor
        } else if isHighlighted {
            return .yellow
        } else if isHovered {
            return .secondary
        } else {
            return .clear
        }
    }
    
    private var borderColorForVerse: Color {
        if isSelected {
            return .accentColor
        } else if isHighlighted {
            return .yellow
        } else {
            return .clear
        }
    }
    
    private var backgroundOpacity: Double {
        if isSelected {
            return 0.15
        } else if isHighlighted {
            return 0.2
        } else if isHovered {
            return 0.1
        } else {
            return 0.0
        }
    }
    
    private var borderWidth: CGFloat {
        (isSelected || isHighlighted) ? 1 : 0
    }
}

// MARK: - macOS Chapter Navigation Bar

@available(macOS 15.0, *)
struct MacChapterNavigationBar: View {
    @StateObject private var viewModel = MacChapterNavigationViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        HStack(spacing: 16) {
            // Book Picker
            Picker("Book", selection: $viewModel.selectedBook) {
                ForEach(BibleBook.allCases, id: \.self) { book in
                    Text(book.name).tag(book)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 150)
            
            // Chapter Navigation
            HStack(spacing: 8) {
                Button {
                    viewModel.previousChapter()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .disabled(!viewModel.canGoPrevious)
                
                Picker("Chapter", selection: $viewModel.selectedChapter) {
                    ForEach(1...viewModel.selectedBook.chapterCount, id: \.self) { chapter in
                        Text("\(chapter)").tag(chapter)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 80)
                
                Button {
                    viewModel.nextChapter()
                } label: {
                    Image(systemName: "chevron.right")
                }
                .disabled(!viewModel.canGoNext)
            }
            
            Spacer()
            
            // Translation Picker
            Picker("Translation", selection: $viewModel.selectedTranslation) {
                ForEach(viewModel.availableTranslations, id: \.id) { translation in
                    Text(translation.abbreviation).tag(translation)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 100)
            
            // Reading Tools
            HStack(spacing: 8) {
                Button {
                    viewModel.toggleReadingMode()
                } label: {
                    Image(systemName: viewModel.isReadingMode ? "eye.slash" : "eye")
                }
                .help(viewModel.isReadingMode ? "Exit Reading Mode" : "Enter Reading Mode")
                
                Button {
                    viewModel.adjustFontSize(.increase)
                } label: {
                    Image(systemName: "textformat.size.larger")
                }
                .help("Increase Font Size")
                
                Button {
                    viewModel.adjustFontSize(.decrease)
                } label: {
                    Image(systemName: "textformat.size.smaller")
                }
                .help("Decrease Font Size")
            }
        }
    }
}

// MARK: - macOS Toolbar View

@available(macOS 15.0, *)
struct MacToolbarView: View {
    @StateObject private var viewModel = MacToolbarViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        HStack(spacing: 12) {
            // Search Field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search verses...", text: $viewModel.searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        Task {
                            await viewModel.performSearch()
                        }
                    }
                
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.clearSearch()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .frame(width: 200)
            
            Spacer()
            
            // Action Buttons
            Button {
                viewModel.showDailyVerse()
            } label: {
                Image(systemName: "sun.max")
            }
            .help("Daily Verse")
            
            Button {
                viewModel.showBookmarks()
            } label: {
                Image(systemName: "bookmark")
            }
            .help("Bookmarks")
            
            Button {
                viewModel.showReadingPlans()
            } label: {
                Image(systemName: "list.clipboard")
            }
            .help("Reading Plans")
        }
    }
}

// MARK: - Supporting Views

@available(macOS 15.0, *)
struct MacSearchView: View {
    var body: some View {
        Text("Search - macOS Implementation")
            .navigationTitle("Search")
    }
}

@available(macOS 15.0, *)
struct MacBookmarksView: View {
    var body: some View {
        Text("Bookmarks - macOS Implementation")
            .navigationTitle("Bookmarks")
    }
}

@available(macOS 15.0, *)
struct MacReadingPlansView: View {
    var body: some View {
        Text("Reading Plans - macOS Implementation")
            .navigationTitle("Reading Plans")
    }
}

@available(macOS 15.0, *)
struct MacReadingHistoryView: View {
    var body: some View {
        Text("Reading History - macOS Implementation")
            .navigationTitle("Reading History")
    }
}

@available(macOS 15.0, *)
struct MacCommentariesView: View {
    var body: some View {
        Text("Commentaries - macOS Implementation")
            .navigationTitle("Commentaries")
    }
}

@available(macOS 15.0, *)
struct MacCrossReferencesView: View {
    var body: some View {
        Text("Cross References - macOS Implementation")
            .navigationTitle("Cross References")
    }
}

@available(macOS 15.0, *)
struct MacSettingsView: View {
    var body: some View {
        Text("Settings - macOS Implementation")
            .navigationTitle("Settings")
    }
}

@available(macOS 15.0, *)
struct MacEmptyDetailView: View {
    var body: some View {
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

// MARK: - Detail Section Views

@available(macOS 15.0, *)
struct MacVerseHeaderCard: View {
    let verse: BibleVerse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(verse.reference)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Text(verse.translation)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.quaternary, in: Capsule())
            }
            
            Text(verse.text)
                .font(.body)
                .lineSpacing(6)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

@available(macOS 15.0, *)
struct MacInsightsSection: View {
    let insights: [AIInsight]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("AI Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            ForEach(insights, id: \.id) { insight in
                MacInsightCard(insight: insight)
            }
        }
    }
}

@available(macOS 15.0, *)
struct MacInsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
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
                .lineSpacing(2)
        }
        .padding(12)
        .background(insight.type.backgroundColor, in: RoundedRectangle(cornerRadius: 8))
    }
}

@available(macOS 15.0, *)
struct MacCrossReferencesSection: View {
    let references: [BibleVerse]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cross References")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(references, id: \.id) { reference in
                    MacCrossReferenceCard(verse: reference)
                }
            }
        }
    }
}

@available(macOS 15.0, *)
struct MacCrossReferenceCard: View {
    let verse: BibleVerse
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(verse.reference)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            
            Text(verse.text)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(3)
        }
        .padding(8)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
    }
}

@available(macOS 15.0, *)
struct MacCommentarySection: View {
    let commentary: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Commentary")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(commentary)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

@available(macOS 15.0, *)
struct MacNotesSection: View {
    let verse: BibleVerse
    let note: String
    let onNoteChanged: (String) -> Void
    
    @State private var editingNote = ""
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button {
                    if isEditing {
                        onNoteChanged(editingNote)
                        isEditing = false
                    } else {
                        editingNote = note
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                        .font(.caption)
                }
            }
            
            if isEditing {
                TextEditor(text: $editingNote)
                    .font(.caption)
                    .frame(height: 100)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            } else {
                if note.isEmpty {
                    Text("No notes yet. Click Edit to add notes.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    Text(note)
                        .font(.caption)
                        .lineSpacing(2)
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

@available(macOS 15.0, *)
struct MacVerseContextMenu: View {
    let verse: BibleVerse
    let viewModel: MacBibleReaderViewModel
    
    var body: some View {
        Group {
            Button("Copy Verse") {
                viewModel.copyVerse(verse)
            }
            
            Button("Bookmark") {
                Task {
                    await viewModel.bookmarkVerse(verse)
                }
            }
            
            Button("Highlight") {
                viewModel.toggleHighlight(verse)
            }
            
            Divider()
            
            Button("Share") {
                viewModel.shareVerse(verse)
            }
            
            Button("Add Note") {
                viewModel.addNote(to: verse)
            }
        }
    }
}

@available(macOS 15.0, *)
struct MacDetailToolbarView: View {
    let verse: BibleVerse
    
    var body: some View {
        HStack {
            Button {
                // Copy verse
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .help("Copy Verse")
            
            Button {
                // Bookmark verse
            } label: {
                Image(systemName: "bookmark")
            }
            .help("Bookmark Verse")
            
            Button {
                // Share verse
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .help("Share Verse")
        }
    }
}

// MARK: - Supporting Types

public enum SidebarItem: String, CaseIterable, Hashable {
    case bible = "Bible"
    case search = "Search"
    case bookmarks = "Bookmarks"
    case readingPlans = "Reading Plans"
    case history = "History"
    case commentaries = "Commentaries"
    case crossReferences = "Cross References"
    case settings = "Settings"
    
    var title: String {
        return rawValue
    }
    
    var systemImage: String {
        switch self {
        case .bible:
            return "book.closed"
        case .search:
            return "magnifyingglass"
        case .bookmarks:
            return "bookmark"
        case .readingPlans:
            return "list.clipboard"
        case .history:
            return "clock"
        case .commentaries:
            return "quote.bubble"
        case .crossReferences:
            return "link"
        case .settings:
            return "gearshape"
        }
    }
    
    static let studyItems: [SidebarItem] = [.bible, .search]
    static let libraryItems: [SidebarItem] = [.bookmarks, .readingPlans, .history]
    static let toolItems: [SidebarItem] = [.commentaries, .crossReferences, .settings]
}

public struct RecentBook {
    public let id = UUID()
    public let name: String
    public let lastChapter: Int
    public let lastAccessDate: Date
    
    public init(name: String, lastChapter: Int, lastAccessDate: Date = Date()) {
        self.name = name
        self.lastChapter = lastChapter
        self.lastAccessDate = lastAccessDate
    }
}

public enum FontSizeAdjustment {
    case increase
    case decrease
}

// MARK: - Extensions

extension View {
    func onRightClick(perform action: @escaping (NSPoint) -> Void) -> some View {
        self.background(
            RightClickView(action: action)
        )
    }
}

struct RightClickView: NSViewRepresentable {
    let action: (NSPoint) -> Void
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let rightClickGesture = NSClickGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.rightClicked(_:)))
        rightClickGesture.buttonMask = [.rightMouse]
        view.addGestureRecognizer(rightClickGesture)
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(action: action)
    }
    
    class Coordinator: NSObject {
        let action: (NSPoint) -> Void
        
        init(action: @escaping (NSPoint) -> Void) {
            self.action = action
        }
        
        @objc func rightClicked(_ gesture: NSClickGestureRecognizer) {
            let location = gesture.location(in: gesture.view)
            action(location)
        }
    }
}

#endif