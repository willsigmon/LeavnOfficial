import Foundation
import LeavnCore
import SwiftUI
import Combine

#if os(visionOS)

// MARK: - Vision Bible Study View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionBibleStudyViewModel: ObservableObject {
    
    @Published var isImmersiveSpaceOpen = false
    @Published var selectedEnvironment: StudyEnvironment = .sanctuary
    @Published var isReadingModeActive = false
    @Published var spatialControlsEnabled = false
    
    var container: DIContainer?
    
    public init() {}
    
    func initialize() async {
        // Initialize the vision study environment
    }
    
    func toggleReadingMode() {
        isReadingModeActive.toggle()
    }
    
    func toggleSpatialControls() {
        spatialControlsEnabled.toggle()
    }
}

// MARK: - Vision Sidebar View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionSidebarViewModel: ObservableObject {
    
    @Published var selectedEnvironment: StudyEnvironment = .sanctuary
    
    var container: DIContainer?
    
    public init() {}
    
    func selectEnvironment(_ environment: StudyEnvironment) {
        selectedEnvironment = environment
    }
}

// MARK: - Vision Main Content View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionMainContentViewModel: ObservableObject {
    
    @Published var verses: [BibleVerse] = []
    @Published var highlightedVerses: Set<String> = []
    @Published var currentBook: BibleBook = .genesis
    @Published var currentChapter: Int = 1
    @Published var currentTranslation: BibleTranslation = BibleTranslation.defaultTranslations[0]
    @Published var isLoading = false
    @Published var error: Error?
    
    var container: DIContainer?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    var currentChapterTitle: String {
        "\(currentBook.name) \(currentChapter)"
    }
    
    func loadCurrentChapter() async {
        guard let bibleService = container?.bibleService else { return }
        
        isLoading = true
        error = nil
        
        do {
            let chapterVerses = try await bibleService.getChapter(
                book: currentBook,
                chapter: currentChapter,
                translation: currentTranslation
            )
            
            await MainActor.run {
                self.verses = chapterVerses
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func toggleHighlight(_ verse: BibleVerse) {
        if highlightedVerses.contains(verse.id) {
            highlightedVerses.remove(verse.id)
        } else {
            highlightedVerses.insert(verse.id)
        }
    }
}

// MARK: - Vision Detail View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionDetailViewModel: ObservableObject {
    
    @Published var selectedVerse: BibleVerse?
    @Published var insights: [AIInsight] = []
    @Published var crossReferences: [BibleVerse] = []
    @Published var commentary: String?
    @Published var isLoading = false
    
    var container: DIContainer?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    func loadVerseDetails(_ verse: BibleVerse) async {
        selectedVerse = verse
        isLoading = true
        
        // Load AI insights
        if let aiService = container?.aiService {
            do {
                let verseInsights = try await aiService.getInsights(for: verse)
                await MainActor.run {
                    self.insights = verseInsights
                }
            } catch {
                print("Failed to load AI insights: \(error)")
            }
        }
        
        // Load cross references (mock data for now)
        crossReferences = generateMockCrossReferences(for: verse)
        
        // Load commentary (mock data for now)
        commentary = generateMockCommentary(for: verse)
        
        isLoading = false
    }
    
    private func generateMockCrossReferences(for verse: BibleVerse) -> [BibleVerse] {
        // Mock cross references
        return [
            BibleVerse(
                bookName: "Romans",
                bookId: "rom",
                chapter: 8,
                verse: 28,
                text: "And we know that in all things God works for the good of those who love him, who have been called according to his purpose.",
                translation: verse.translation
            ),
            BibleVerse(
                bookName: "Philippians",
                bookId: "php",
                chapter: 4,
                verse: 13,
                text: "I can do all this through him who gives me strength.",
                translation: verse.translation
            )
        ]
    }
    
    private func generateMockCommentary(for verse: BibleVerse) -> String {
        return """
        This verse highlights the central theme of God's love and redemptive plan for humanity. The Greek word 'agape' used here represents unconditional, sacrificial love that seeks the highest good of the beloved.
        
        The verse emphasizes the universality of God's love ('the world') and the simplicity of the response required ('believe'). This has been a cornerstone of Christian theology and evangelism throughout history.
        """
    }
}

// MARK: - Vision Chapter Navigation View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionChapterNavigationViewModel: ObservableObject {
    
    @Published var selectedBook: BibleBook = .genesis
    @Published var selectedChapter: Int = 1
    @Published var selectedTranslation: BibleTranslation = BibleTranslation.defaultTranslations[0]
    
    public init() {}
    
    var canGoPrevious: Bool {
        if selectedChapter > 1 {
            return true
        }
        return selectedBook != BibleBook.allCases.first
    }
    
    var canGoNext: Bool {
        if selectedChapter < selectedBook.chapterCount {
            return true
        }
        return selectedBook != BibleBook.allCases.last
    }
    
    func selectBook(_ book: BibleBook) {
        selectedBook = book
        selectedChapter = 1
    }
    
    func selectTranslation(_ translation: BibleTranslation) {
        selectedTranslation = translation
    }
    
    func previousChapter() {
        if selectedChapter > 1 {
            selectedChapter -= 1
        } else {
            // Go to previous book
            if let currentIndex = BibleBook.allCases.firstIndex(of: selectedBook),
               currentIndex > 0 {
                selectedBook = BibleBook.allCases[currentIndex - 1]
                selectedChapter = selectedBook.chapterCount
            }
        }
    }
    
    func nextChapter() {
        if selectedChapter < selectedBook.chapterCount {
            selectedChapter += 1
        } else {
            // Go to next book
            if let currentIndex = BibleBook.allCases.firstIndex(of: selectedBook),
               currentIndex < BibleBook.allCases.count - 1 {
                selectedBook = BibleBook.allCases[currentIndex + 1]
                selectedChapter = 1
            }
        }
    }
}

// MARK: - Vision Immersive Space View Model

@available(visionOS 2.0, *)
@MainActor
public final class VisionImmersiveSpaceViewModel: ObservableObject {
    
    @Published var currentEnvironment: StudyEnvironment = .sanctuary
    @Published var spatialAnchors: [SpatialAnchor] = []
    @Published var handTrackingEnabled = false
    @Published var eyeTrackingEnabled = false
    
    public init() {}
    
    func changeEnvironment(_ environment: StudyEnvironment) {
        currentEnvironment = environment
        // Update RealityKit scene
    }
    
    func toggleHandTracking() {
        handTrackingEnabled.toggle()
    }
    
    func toggleEyeTracking() {
        eyeTrackingEnabled.toggle()
    }
    
    func addSpatialAnchor(at position: SIMD3<Float>) {
        let anchor = SpatialAnchor(
            id: UUID().uuidString,
            position: position,
            environment: currentEnvironment
        )
        spatialAnchors.append(anchor)
    }
    
    func removeSpatialAnchor(_ anchorId: String) {
        spatialAnchors.removeAll { $0.id == anchorId }
    }
}

// MARK: - Supporting Models

public struct SpatialAnchor {
    public let id: String
    public let position: SIMD3<Float>
    public let environment: StudyEnvironment
    public let createdAt: Date
    
    public init(id: String, position: SIMD3<Float>, environment: StudyEnvironment) {
        self.id = id
        self.position = position
        self.environment = environment
        self.createdAt = Date()
    }
}

// MARK: - Extensions for VisionOS Compatibility

extension InsightType {
    var iconName: String {
        switch self {
        case .historical: return "building.columns"
        case .theological: return "book.closed"
        case .practical: return "lightbulb"
        case .devotional: return "heart"
        }
    }
    
    var color: Color {
        switch self {
        case .historical: return .brown
        case .theological: return .blue
        case .practical: return .green
        case .devotional: return .pink
        }
    }
    
    var backgroundColor: Color {
        color.opacity(0.1)
    }
}

#endif