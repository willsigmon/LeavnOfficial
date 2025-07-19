import XCTest
import SnapshotTesting
import SwiftUI
import ComposableArchitecture
@testable import LeavnApp

final class SnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Uncomment to record new snapshots
        // isRecording = true
    }
    
    // MARK: - Bible View Snapshots
    
    func testBibleViewSnapshots() {
        let store = Store(
            initialState: BibleReducer.State(
                selectedBook: .john,
                selectedChapter: 3,
                currentChapter: TestFixtures.sampleChapter,
                highlights: [TestFixtures.sampleHighlight],
                bookmarks: [TestFixtures.sampleBookmark]
            ),
            reducer: { BibleReducer() },
            withDependencies: {
                $0.bibleService = .mock
            }
        )
        
        let view = BibleView(store: store)
        
        // Test on different devices
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13ProMax)))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13mini)))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPadPro11)))
        
        // Test dark mode
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: UITraitCollection(userInterfaceStyle: .dark)
            )
        )
    }
    
    func testBibleReaderViewSnapshots() {
        let verses = TestFixtures.sampleChapter.verses
        let view = BibleReaderView(
            book: .genesis,
            chapter: 1,
            verses: verses,
            highlights: [TestFixtures.sampleHighlight],
            fontSize: .medium,
            fontFamily: .default,
            lineSpacing: .normal,
            showVerseNumbers: true,
            showRedLetters: true,
            onVerseSelection: { _ in },
            onHighlight: { _, _ in },
            onAddNote: { _ in }
        )
        
        // Different font sizes
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 844)))
        
        let largeFontView = BibleReaderView(
            book: .genesis,
            chapter: 1,
            verses: verses,
            highlights: [],
            fontSize: .extraLarge,
            fontFamily: .serif,
            lineSpacing: .loose,
            showVerseNumbers: true,
            showRedLetters: true,
            onVerseSelection: { _ in },
            onHighlight: { _, _ in },
            onAddNote: { _ in }
        )
        
        assertSnapshot(of: largeFontView, as: .image(layout: .fixed(width: 390, height: 844)))
    }
    
    // MARK: - Search View Snapshots
    
    func testSearchViewSnapshots() {
        let searchResults = IdentifiedArrayOf<SearchResult>([
            TestFixtures.sampleSearchResult,
            SearchResult(
                reference: BibleReference(book: .romans, chapter: 8, verse: 28),
                text: "And we know that in all things God works for the good...",
                context: "Romans 8:28-29"
            )
        ])
        
        let view = BibleSearchView(
            searchQuery: .constant("God"),
            searchResults: searchResults,
            isSearching: false,
            onResultTap: { _ in }
        )
        
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
        
        // Empty state
        let emptyView = BibleSearchView(
            searchQuery: .constant(""),
            searchResults: [],
            isSearching: false,
            onResultTap: { _ in }
        )
        
        assertSnapshot(of: emptyView, as: .image(layout: .device(config: .iPhone13Pro)))
        
        // Loading state
        let loadingView = BibleSearchView(
            searchQuery: .constant("love"),
            searchResults: [],
            isSearching: true,
            onResultTap: { _ in }
        )
        
        assertSnapshot(of: loadingView, as: .image(layout: .device(config: .iPhone13Pro)))
    }
    
    // MARK: - Library View Snapshots
    
    func testLibraryViewSnapshots() {
        let store = Store(
            initialState: LibraryReducer.State(
                highlights: [TestFixtures.sampleHighlight],
                bookmarks: [TestFixtures.sampleBookmark],
                notes: [TestFixtures.sampleNote],
                readingPlans: [TestFixtures.sampleReadingPlan],
                downloads: []
            ),
            reducer: { LibraryReducer() }
        )
        
        let view = LibraryView(store: store)
        
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: UITraitCollection(userInterfaceStyle: .dark)
            )
        )
    }
    
    // MARK: - Settings View Snapshots
    
    func testSettingsViewSnapshots() {
        let store = Store(
            initialState: SettingsReducer.State(
                settings: Settings(
                    theme: .system,
                    fontSize: .medium,
                    fontFamily: .default,
                    lineSpacing: .normal,
                    translation: .esv,
                    showVerseNumbers: true,
                    showRedLetters: true
                ),
                isLoggedIn: true
            ),
            reducer: { SettingsReducer() }
        )
        
        let view = SettingsView(store: store)
        
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPadPro11)))
    }
    
    // MARK: - Community View Snapshots
    
    func testCommunityViewSnapshots() {
        let store = Store(
            initialState: CommunityReducer.State(
                groups: [
                    Group(
                        name: "Bible Study Group",
                        description: "Weekly Bible study",
                        memberCount: 25,
                        imageURL: nil,
                        isPrivate: false,
                        createdAt: Date()
                    )
                ],
                prayers: [
                    Prayer(
                        userId: UUID(),
                        userName: "John Doe",
                        content: "Please pray for healing",
                        prayerCount: 42,
                        isPraying: false,
                        createdAt: Date()
                    )
                ],
                activityFeed: []
            ),
            reducer: { CommunityReducer() }
        )
        
        let view = CommunityView(store: store)
        
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
    }
    
    // MARK: - Component Snapshots
    
    func testHighlightColorPickerSnapshot() {
        let colors: [HighlightColor] = [.yellow, .green, .blue, .pink, .purple]
        let view = HStack(spacing: 16) {
            ForEach(colors, id: \.self) { color in
                Circle()
                    .fill(color.color)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: 2)
                    )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 320, height: 100)))
    }
    
    func testAudioControlsSnapshot() {
        let view = AudioControlsOverlay(
            isPlaying: true,
            currentBook: .matthew,
            currentChapter: 5,
            currentVerse: 1,
            duration: 600,
            currentTime: 120,
            playbackRate: 1.0,
            onPlayPause: {},
            onSeek: { _ in },
            onPlaybackRateChange: { _ in },
            onClose: {}
        )
        
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)))
    }
    
    func testErrorViewSnapshot() {
        let view = ErrorView(
            title: "Something went wrong",
            message: "We couldn't load the chapter. Please check your internet connection and try again.",
            retryAction: {}
        )
        
        assertSnapshot(of: view, as: .image(layout: .fixed(width: 390, height: 300)))
    }
    
    // MARK: - Accessibility Snapshots
    
    func testAccessibilitySnapshots() {
        let view = BibleReaderView(
            book: .john,
            chapter: 3,
            verses: [TestFixtures.sampleVerse],
            highlights: [],
            fontSize: .accessibility1,
            fontFamily: .default,
            lineSpacing: .loose,
            showVerseNumbers: true,
            showRedLetters: true,
            onVerseSelection: { _ in },
            onHighlight: { _, _ in },
            onAddNote: { _ in }
        )
        
        // Test with accessibility sizes
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraLarge)
            )
        )
        
        assertSnapshot(
            of: view,
            as: .image(
                layout: .device(config: .iPhone13Pro),
                traits: UITraitCollection(preferredContentSizeCategory: .accessibilityExtraExtraLarge)
            )
        )
    }
    
    // MARK: - Onboarding Snapshots
    
    func testOnboardingViewSnapshots() {
        let onboardingSteps = [
            OnboardingView.Step(
                title: "Welcome to Leavn",
                description: "Your personal Bible companion",
                image: "book.fill"
            ),
            OnboardingView.Step(
                title: "Read & Study",
                description: "Access multiple translations and study tools",
                image: "text.book.closed.fill"
            ),
            OnboardingView.Step(
                title: "Connect & Grow",
                description: "Join a community of believers",
                image: "person.3.fill"
            )
        ]
        
        for (index, step) in onboardingSteps.enumerated() {
            let view = OnboardingStepView(step: step, currentStep: index, totalSteps: onboardingSteps.count)
            assertSnapshot(
                of: view,
                as: .image(layout: .device(config: .iPhone13Pro)),
                named: "step\(index + 1)"
            )
        }
    }
}

// MARK: - Helper Views

private struct OnboardingStepView: View {
    let step: OnboardingView.Step
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: step.image)
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            HStack {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Circle()
                        .fill(index == currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Test Fixtures Extension
private extension TestFixtures {
    static let sampleSearchResult = SearchResult(
        reference: BibleReference(book: .john, chapter: 3, verse: 16),
        text: "For God so loved the world, that he gave his only Son...",
        context: "John 3:16-17"
    )
}