import SwiftUI
import LeavnServices
import LeavnCore
import NetworkingKit

/// Example of how to integrate the ElevenLabs audio narration into a Bible reading view
public struct BibleAudioIntegrationView: View {
    @StateObject private var viewModel: AudioPlayerViewModel
    @StateObject private var voiceConfigService: VoiceConfigurationService
    @State private var showVoiceSelection = false
    @State private var showDownloadManager = false
    @State private var isAudioExpanded = false
    
    private let bibleService: BibleService
    private let audioService: AudioService
    private let elevenLabsService: ElevenLabsService
    private let cacheManager: AudioCacheManager
    
    public init() {
        // Initialize services (in a real app, these would be injected)
        let networkService = DefaultNetworkService(configuration: LeavnConfiguration.current)
        
        // Initialize ElevenLabs with API key
        let elevenLabsService = DefaultElevenLabsService(
            networkService: networkService,
            apiKey: ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
        )
        
        // Initialize cache manager
        let cacheManager = try! DefaultAudioCacheManager()
        
        // Initialize Bible service
        let bibleService = DefaultBibleService(
            networkService: networkService,
            cacheManager: BibleCacheManager()
        )
        
        // Initialize voice configuration
        let voiceConfigService = DefaultVoiceConfigurationService(
            elevenLabsService: elevenLabsService
        )
        
        // Initialize audio service
        let audioService = DefaultAudioService(
            elevenLabsService: elevenLabsService,
            cacheManager: cacheManager,
            bibleService: bibleService
        )
        
        // Store services
        self.bibleService = bibleService
        self.audioService = audioService
        self.elevenLabsService = elevenLabsService
        self.cacheManager = cacheManager
        
        // Initialize view models
        _viewModel = StateObject(wrappedValue: AudioPlayerViewModel(
            audioService: audioService,
            bibleService: bibleService,
            voiceConfigService: voiceConfigService,
            elevenLabsService: elevenLabsService,
            cacheManager: cacheManager
        ))
        
        _voiceConfigService = StateObject(wrappedValue: voiceConfigService)
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        // Chapter selector
                        ChapterSelectorView { book, chapter in
                            Task {
                                await viewModel.loadChapter(
                                    book: book,
                                    chapter: chapter,
                                    translation: "ESV"
                                )
                            }
                        }
                        
                        // Verse display with audio sync
                        if let chapter = viewModel.currentChapter {
                            VerseAudioView(
                                viewModel: viewModel,
                                verses: sampleVerses(for: chapter)
                            )
                        }
                    }
                    .padding()
                }
                
                // Audio player (collapsible)
                if viewModel.currentChapter != nil {
                    if isAudioExpanded {
                        AudioPlayerView(viewModel: viewModel)
                            .transition(.move(edge: .bottom))
                    } else {
                        MiniAudioPlayerView(
                            audioState: viewModel.audioState,
                            currentChapter: viewModel.currentChapter!,
                            onPlayPause: {
                                Task { await viewModel.togglePlayPause() }
                            },
                            onExpand: {
                                withAnimation {
                                    isAudioExpanded = true
                                }
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
            }
            .navigationTitle("Bible Audio")
            .navigationBarItems(
                leading: Button(action: {
                    showDownloadManager = true
                }) {
                    Image(systemName: "arrow.down.circle")
                },
                trailing: Button(action: {
                    showVoiceSelection = true
                }) {
                    Image(systemName: "person.wave.2")
                }
            )
            .sheet(isPresented: $showVoiceSelection) {
                if let chapter = viewModel.currentChapter {
                    VoiceSelectionView(
                        voiceConfigService: voiceConfigService,
                        viewModel: viewModel,
                        book: chapter.book,
                        isPresented: $showVoiceSelection
                    )
                }
            }
            .sheet(isPresented: $showDownloadManager) {
                AudioDownloadManagerView(
                    viewModel: viewModel,
                    cacheManager: cacheManager
                )
            }
        }
    }
    
    // Sample verses for demo
    private func sampleVerses(for chapter: ChapterInfo) -> [BibleVerse] {
        // In a real app, these would come from BibleService
        return [
            BibleVerse(
                id: "1",
                reference: "\(chapter.book) \(chapter.chapter):1",
                text: "In the beginning was the Word, and the Word was with God, and the Word was God.",
                translation: chapter.translation,
                book: chapter.book,
                chapter: chapter.chapter,
                verse: 1
            ),
            BibleVerse(
                id: "2",
                reference: "\(chapter.book) \(chapter.chapter):2",
                text: "The same was in the beginning with God.",
                translation: chapter.translation,
                book: chapter.book,
                chapter: chapter.chapter,
                verse: 2
            ),
            BibleVerse(
                id: "3",
                reference: "\(chapter.book) \(chapter.chapter):3",
                text: "All things were made by him; and without him was not any thing made that was made.",
                translation: chapter.translation,
                book: chapter.book,
                chapter: chapter.chapter,
                verse: 3
            )
        ]
    }
}

// MARK: - Chapter Selector
struct ChapterSelectorView: View {
    let onSelect: (String, Int) -> Void
    @State private var selectedBook = "John"
    @State private var selectedChapter = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Chapter")
                .font(.headline)
            
            HStack {
                // Book selector
                Menu {
                    ForEach(["Genesis", "Psalms", "John", "Romans"], id: \.self) { book in
                        Button(book) {
                            selectedBook = book
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedBook)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Chapter selector
                Menu {
                    ForEach(1...20, id: \.self) { chapter in
                        Button("Chapter \(chapter)") {
                            selectedChapter = chapter
                        }
                    }
                } label: {
                    HStack {
                        Text("Chapter \(selectedChapter)")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
            
            Button(action: {
                onSelect(selectedBook, selectedChapter)
            }) {
                Text("Load Chapter")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("BookmarkBlue"))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Usage Example
struct BibleAudioIntegration_Previews: PreviewProvider {
    static var previews: some View {
        BibleAudioIntegrationView()
    }
}