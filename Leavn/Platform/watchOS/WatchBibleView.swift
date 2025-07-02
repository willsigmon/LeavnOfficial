import SwiftUI
import WidgetKit
import ClockKit

#if os(watchOS)

// MARK: - WatchOS Main App View

@available(watchOS 11.0, *)
public struct WatchBibleView: View {
    @StateObject private var viewModel = WatchBibleViewModel()
    @EnvironmentObject var container: DIContainer
    @Environment(\.scenePhase) private var scenePhase
    
    public init() {}
    
    public var body: some View {
        NavigationStack {
            TabView {
                // Daily Verse Tab
                WatchDailyVerseView()
                    .tag(0)
                
                // Quick Read Tab
                WatchQuickReadView()
                    .tag(1)
                
                // Bookmarks Tab
                WatchBookmarksView()
                    .tag(2)
                
                // Settings Tab
                WatchSettingsView()
                    .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .automatic))
        }
        .task {
            viewModel.container = container
            await viewModel.initialize()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                Task {
                    await viewModel.refreshContent()
                }
            }
        }
    }
}

// MARK: - Watch Daily Verse View

@available(watchOS 11.0, *)
struct WatchDailyVerseView: View {
    @StateObject private var viewModel = WatchDailyVerseViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack(spacing: 8) {
            if viewModel.isLoading {
                ProgressView("Loading verse...")
                    .font(.caption)
            } else if let verse = viewModel.dailyVerse {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Reference
                        HStack {
                            Text(verse.reference)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)
                            
                            Spacer()
                            
                            Text(verse.translation)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        // Verse text
                        Text(verse.text)
                            .font(.footnote)
                            .lineSpacing(2)
                            .multilineTextAlignment(.leading)
                        
                        // Actions
                        HStack {
                            Button {
                                viewModel.bookmarkVerse()
                            } label: {
                                Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                            }
                            .foregroundColor(viewModel.isBookmarked ? .yellow : .secondary)
                            
                            Spacer()
                            
                            Button {
                                viewModel.shareVerse()
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button {
                                Task {
                                    await viewModel.getNewVerse()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                            }
                            .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 4)
                }
            } else {
                VStack {
                    Image(systemName: "book.closed")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No verse available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Daily Verse")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.container = container
            await viewModel.loadDailyVerse()
        }
    }
}

// MARK: - Watch Quick Read View

@available(watchOS 11.0, *)
struct WatchQuickReadView: View {
    @StateObject private var viewModel = WatchQuickReadViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack(spacing: 8) {
            // Quick access buttons
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                WatchQuickAccessButton(
                    title: "Psalms",
                    systemImage: "music.note",
                    color: .blue
                ) {
                    viewModel.openBook(.psalms)
                }
                
                WatchQuickAccessButton(
                    title: "Proverbs",
                    systemImage: "lightbulb",
                    color: .orange
                ) {
                    viewModel.openBook(.proverbs)
                }
                
                WatchQuickAccessButton(
                    title: "Matthew",
                    systemImage: "person",
                    color: .green
                ) {
                    viewModel.openBook(.matthew)
                }
                
                WatchQuickAccessButton(
                    title: "John",
                    systemImage: "heart",
                    color: .red
                ) {
                    viewModel.openBook(.john)
                }
            }
            
            // Continue reading
            if let lastRead = viewModel.lastReadChapter {
                Divider()
                
                Button {
                    viewModel.continueReading(lastRead)
                } label: {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Continue")
                            Spacer()
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        
                        HStack {
                            Text(lastRead.reference)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                }
                .buttonStyle(.bordered)
            }
        }
        .navigationTitle("Quick Read")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.container = container
            await viewModel.loadLastRead()
        }
    }
}

// MARK: - Watch Quick Access Button

@available(watchOS 11.0, *)
struct WatchQuickAccessButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(.bordered)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Watch Bookmarks View

@available(watchOS 11.0, *)
struct WatchBookmarksView: View {
    @StateObject private var viewModel = WatchBookmarksViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        VStack {
            if viewModel.bookmarks.isEmpty {
                VStack {
                    Image(systemName: "bookmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No bookmarks yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                List {
                    ForEach(viewModel.bookmarks.prefix(10), id: \.id) { bookmark in
                        NavigationLink {
                            WatchVerseDetailView(verse: bookmark.verse)
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(bookmark.verse.reference)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.accentColor)
                                
                                Text(bookmark.verse.text)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            await viewModel.deleteBookmarks(at: indexSet)
                        }
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.container = container
            await viewModel.loadBookmarks()
        }
    }
}

// MARK: - Watch Verse Detail View

@available(watchOS 11.0, *)
struct WatchVerseDetailView: View {
    let verse: BibleVerse
    @StateObject private var viewModel = WatchVerseDetailViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Reference
                Text(verse.reference)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                
                // Verse text
                Text(verse.text)
                    .font(.footnote)
                    .lineSpacing(3)
                
                // Translation
                HStack {
                    Spacer()
                    Text(verse.translation)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // Actions
                HStack(spacing: 16) {
                    Button {
                        Task {
                            await viewModel.bookmarkVerse(verse)
                        }
                    } label: {
                        Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                    }
                    .foregroundColor(viewModel.isBookmarked ? .yellow : .secondary)
                    
                    Button {
                        viewModel.shareVerse(verse)
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .foregroundColor(.secondary)
                    
                    Button {
                        viewModel.readAloud(verse)
                    } label: {
                        Image(systemName: viewModel.isReading ? "speaker.wave.3.fill" : "speaker.wave.2")
                    }
                    .foregroundColor(viewModel.isReading ? .blue : .secondary)
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("Verse")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.container = container
            await viewModel.checkBookmarkStatus(verse)
        }
    }
}

// MARK: - Watch Settings View

@available(watchOS 11.0, *)
struct WatchSettingsView: View {
    @StateObject private var viewModel = WatchSettingsViewModel()
    @EnvironmentObject var container: DIContainer
    
    var body: some View {
        List {
            Section {
                Picker("Translation", selection: $viewModel.selectedTranslation) {
                    ForEach(viewModel.availableTranslations, id: \.id) { translation in
                        Text(translation.abbreviation)
                            .tag(translation)
                    }
                }
                
                Stepper("Font Size: \(Int(viewModel.fontSize))", value: $viewModel.fontSize, in: 12...20, step: 1)
                
                Toggle("Daily Notifications", isOn: $viewModel.dailyNotificationsEnabled)
            } header: {
                Text("Reading")
            }
            
            Section {
                Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedbackEnabled)
                
                Toggle("Auto-Read Aloud", isOn: $viewModel.autoReadAloudEnabled)
                
                Picker("Complication Update", selection: $viewModel.complicationUpdateFrequency) {
                    Text("Hourly").tag(ComplicationUpdateFrequency.hourly)
                    Text("Daily").tag(ComplicationUpdateFrequency.daily)
                    Text("Weekly").tag(ComplicationUpdateFrequency.weekly)
                }
            } header: {
                Text("Watch")
            }
            
            Section {
                Button("Sync Now") {
                    Task {
                        await viewModel.syncData()
                    }
                }
                .disabled(viewModel.isSyncing)
                
                if viewModel.isSyncing {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Syncing...")
                            .font(.caption)
                    }
                }
            } header: {
                Text("Data")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.container = container
            await viewModel.loadSettings()
        }
        .onChange(of: viewModel.selectedTranslation) { oldValue, newValue in
            Task {
                await viewModel.saveSettings()
            }
        }
        .onChange(of: viewModel.fontSize) { oldValue, newValue in
            Task {
                await viewModel.saveSettings()
            }
        }
    }
}

// MARK: - Watch Complications Provider

@available(watchOS 11.0, *)
public class WatchComplicationProvider: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Data Source
    
    public func complicationDescriptors() async -> [CLKComplicationDescriptor] {
        return [
            CLKComplicationDescriptor(
                identifier: "daily_verse",
                displayName: "Daily Verse",
                supportedFamilies: [
                    .modularSmall,
                    .modularLarge,
                    .utilitarianSmall,
                    .utilitarianSmallFlat,
                    .utilitarianLarge,
                    .circularSmall,
                    .extraLarge,
                    .graphicCorner,
                    .graphicBezel,
                    .graphicCircular,
                    .graphicRectangular
                ]
            )
        ]
    }
    
    public func currentTimelineEntry(for complication: CLKComplication) async -> CLKComplicationTimelineEntry? {
        return createTimelineEntry(for: complication, date: Date())
    }
    
    public func timelineEntries(for complication: CLKComplication, after date: Date, limit: Int) async -> [CLKComplicationTimelineEntry] {
        var entries: [CLKComplicationTimelineEntry] = []
        let calendar = Calendar.current
        
        for i in 0..<limit {
            if let entryDate = calendar.date(byAdding: .hour, value: i, to: date),
               let entry = createTimelineEntry(for: complication, date: entryDate) {
                entries.append(entry)
            }
        }
        
        return entries
    }
    
    // MARK: - Template Creation
    
    private func createTimelineEntry(for complication: CLKComplication, date: Date) -> CLKComplicationTimelineEntry? {
        let verse = getDailyVerse(for: date)
        
        let template: CLKComplicationTemplate
        
        switch complication.family {
        case .modularSmall:
            template = createModularSmallTemplate(verse: verse)
        case .modularLarge:
            template = createModularLargeTemplate(verse: verse)
        case .utilitarianSmall, .utilitarianSmallFlat:
            template = createUtilitarianSmallTemplate(verse: verse)
        case .utilitarianLarge:
            template = createUtilitarianLargeTemplate(verse: verse)
        case .circularSmall:
            template = createCircularSmallTemplate(verse: verse)
        case .extraLarge:
            template = createExtraLargeTemplate(verse: verse)
        case .graphicCorner:
            template = createGraphicCornerTemplate(verse: verse)
        case .graphicBezel:
            template = createGraphicBezelTemplate(verse: verse)
        case .graphicCircular:
            template = createGraphicCircularTemplate(verse: verse)
        case .graphicRectangular:
            template = createGraphicRectangularTemplate(verse: verse)
        default:
            return nil
        }
        
        return CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
    }
    
    private func createModularSmallTemplate(verse: DailyVerse) -> CLKComplicationTemplateModularSmallSimpleText {
        let template = CLKComplicationTemplateModularSmallSimpleText()
        template.textProvider = CLKSimpleTextProvider(text: verse.reference)
        return template
    }
    
    private func createModularLargeTemplate(verse: DailyVerse) -> CLKComplicationTemplateModularLargeStandardBody {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: "Daily Verse")
        template.body1TextProvider = CLKSimpleTextProvider(text: verse.reference)
        template.body2TextProvider = CLKSimpleTextProvider(text: String(verse.text.prefix(50)) + "...")
        return template
    }
    
    private func createUtilitarianSmallTemplate(verse: DailyVerse) -> CLKComplicationTemplateUtilitarianSmallSquare {
        let template = CLKComplicationTemplateUtilitarianSmallSquare()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "book.closed")!)
        return template
    }
    
    private func createUtilitarianLargeTemplate(verse: DailyVerse) -> CLKComplicationTemplateUtilitarianLargeFlat {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = CLKSimpleTextProvider(text: "\(verse.reference) - \(String(verse.text.prefix(30)))...")
        return template
    }
    
    private func createCircularSmallTemplate(verse: DailyVerse) -> CLKComplicationTemplateCircularSmallSimpleImage {
        let template = CLKComplicationTemplateCircularSmallSimpleImage()
        template.imageProvider = CLKImageProvider(onePieceImage: UIImage(systemName: "book.closed")!)
        return template
    }
    
    private func createExtraLargeTemplate(verse: DailyVerse) -> CLKComplicationTemplateExtraLargeSimpleText {
        let template = CLKComplicationTemplateExtraLargeSimpleText()
        template.textProvider = CLKSimpleTextProvider(text: verse.reference)
        return template
    }
    
    private func createGraphicCornerTemplate(verse: DailyVerse) -> CLKComplicationTemplateGraphicCornerTextImage {
        let template = CLKComplicationTemplateGraphicCornerTextImage()
        template.textProvider = CLKSimpleTextProvider(text: verse.reference)
        template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(systemName: "book.closed")!)
        return template
    }
    
    private func createGraphicBezelTemplate(verse: DailyVerse) -> CLKComplicationTemplateGraphicBezelCircularText {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.textProvider = CLKSimpleTextProvider(text: verse.reference)
        
        let circularTemplate = CLKComplicationTemplateGraphicCircularImage()
        circularTemplate.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(systemName: "book.closed")!)
        template.circularTemplate = circularTemplate
        
        return template
    }
    
    private func createGraphicCircularTemplate(verse: DailyVerse) -> CLKComplicationTemplateGraphicCircularImage {
        let template = CLKComplicationTemplateGraphicCircularImage()
        template.imageProvider = CLKFullColorImageProvider(fullColorImage: UIImage(systemName: "book.closed")!)
        return template
    }
    
    private func createGraphicRectangularTemplate(verse: DailyVerse) -> CLKComplicationTemplateGraphicRectangularStandardBody {
        let template = CLKComplicationTemplateGraphicRectangularStandardBody()
        template.headerTextProvider = CLKSimpleTextProvider(text: "Daily Verse")
        template.body1TextProvider = CLKSimpleTextProvider(text: verse.reference)
        template.body2TextProvider = CLKSimpleTextProvider(text: String(verse.text.prefix(80)) + "...")
        return template
    }
    
    // MARK: - Helper Methods
    
    private func getDailyVerse(for date: Date) -> DailyVerse {
        // In a real implementation, this would fetch from the service
        // For now, return a placeholder that indicates the need to open the app
        return DailyVerse(
            reference: "Open App",
            text: "Open Leavn to read today's verse",
            translation: ""
        )
    }
}

// MARK: - Supporting Models

public enum ComplicationUpdateFrequency: String, CaseIterable {
    case hourly = "Hourly"
    case daily = "Daily"
    case weekly = "Weekly"
}

public struct DailyVerse {
    public let reference: String
    public let text: String
    public let translation: String
    
    public init(reference: String, text: String, translation: String) {
        self.reference = reference
        self.text = text
        self.translation = translation
    }
    

}

public struct LastReadChapter {
    public let book: BibleBook
    public let chapter: Int
    public let translation: String
    
    public var reference: String {
        "\(book.name) \(chapter)"
    }
    
    public init(book: BibleBook, chapter: Int, translation: String) {
        self.book = book
        self.chapter = chapter
        self.translation = translation
    }
}

#endif