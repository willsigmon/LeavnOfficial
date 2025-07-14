import SwiftUI
import AVFoundation
import LeavnServices

/// Audio player component for Bible narration with ElevenLabs integration
/// Works across all platforms with adaptive controls
public struct AudioPlayerView: View {
    @ObservedObject private var viewModel: AudioPlayerViewModel
    
    // Legacy support for direct state injection
    private let legacyAudioState: AudioPlayerState?
    private let legacyCurrentChapter: ChapterInfo?
    private let legacyOnPlayPause: (() -> Void)?
    private let legacyOnPrevious: (() -> Void)?
    private let legacyOnNext: (() -> Void)?
    private let legacyOnSeek: ((Double) -> Void)?
    private let legacyOnSpeedChange: ((PlaybackSpeed) -> Void)?
    
    // Computed properties that work with both approaches
    private var audioState: AudioPlayerState {
        legacyAudioState ?? viewModel.audioState
    }
    
    private var currentChapter: ChapterInfo? {
        legacyCurrentChapter ?? viewModel.currentChapter
    }
    
    // Use the types from AudioPlayerViewModel for consistency
    public typealias AudioPlayerState = LeavnServices.AudioPlayerState
    public typealias ChapterInfo = LeavnServices.ChapterInfo
    public typealias PlaybackSpeed = LeavnServices.PlaybackSpeed
    
    @State private var isDragging = false
    @State private var dragValue: Double = 0
    @State private var showSpeedPicker = false
    @Environment(\.hapticManager) private var hapticManager
    
    /// Primary initializer using AudioPlayerViewModel
    public init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
        self.legacyAudioState = nil
        self.legacyCurrentChapter = nil
        self.legacyOnPlayPause = nil
        self.legacyOnPrevious = nil
        self.legacyOnNext = nil
        self.legacyOnSeek = nil
        self.legacyOnSpeedChange = nil
    }
    
    /// Legacy initializer for backward compatibility
    public init(
        audioState: AudioPlayerState,
        currentChapter: ChapterInfo,
        onPlayPause: @escaping () -> Void,
        onPrevious: @escaping () -> Void,
        onNext: @escaping () -> Void,
        onSeek: @escaping (Double) -> Void,
        onSpeedChange: @escaping (PlaybackSpeed) -> Void
    ) {
        // Create a dummy view model for legacy mode
        self.viewModel = AudioPlayerViewModel(
            audioService: DummyAudioService(),
            bibleService: DummyBibleService(),
            voiceConfigService: DummyVoiceConfigService(),
            elevenLabsService: DummyElevenLabsService(),
            cacheManager: DummyCacheManager()
        )
        
        self.legacyAudioState = audioState
        self.legacyCurrentChapter = currentChapter
        self.legacyOnPlayPause = onPlayPause
        self.legacyOnPrevious = onPrevious
        self.legacyOnNext = onNext
        self.legacyOnSeek = onSeek
        self.legacyOnSpeedChange = onSpeedChange
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            // Chapter info
            if let chapter = currentChapter {
                VStack(spacing: 4) {
                    HStack {
                        Text("\(chapter.book) \(chapter.chapter)")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let currentVerse = viewModel.currentVerse {
                            Text("• Verse \(currentVerse)")
                                .font(.caption)
                                .foregroundColor(Color("BookmarkBlue"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color("BookmarkBlue").opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Text(chapter.narrator)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(chapter.translation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if audioState.isDownloaded {
                            Image(systemName: "arrow.down.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        } else if viewModel.isDownloading {
                            ProgressView(value: viewModel.downloadProgress)
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("BookmarkBlue")))
                                .scaleEffect(0.6)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            } else {
                Text("No chapter loaded")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        // Progress track
                        Rectangle()
                            .fill(Color("BookmarkBlue"))
                            .frame(
                                width: geometry.size.width * (isDragging ? dragValue : audioState.progress),
                                height: 4
                            )
                            .cornerRadius(2)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                dragValue = min(max(0, value.location.x / geometry.size.width), 1)
                            }
                            .onEnded { _ in
                                hapticManager.triggerFeedback(.light)
                                let seekTime = dragValue * audioState.duration
                                if let legacySeek = legacyOnSeek {
                                    legacySeek(seekTime)
                                } else {
                                    viewModel.seek(to: seekTime)
                                }
                                isDragging = false
                            }
                    )
                }
                .frame(height: 4)
                
                // Time labels
                HStack {
                    Text(formatTime(isDragging ? dragValue * audioState.duration : audioState.currentTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                    
                    Spacer()
                    
                    Text("-\(formatTime(audioState.remainingTime))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
            }
            
            // Controls
            HStack(spacing: 20) {
                // Previous chapter
                Button(action: { 
                    hapticManager.triggerFeedback(.medium)
                    if let legacyPrevious = legacyOnPrevious {
                        legacyPrevious()
                    } else {
                        Task { await viewModel.skipToPrevious() }
                    }
                }) {
                    Image(systemName: "backward.end.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Play/Pause
                Button(action: { 
                    hapticManager.triggerFeedback(.medium)
                    if let legacyPlayPause = legacyOnPlayPause {
                        legacyPlayPause()
                    } else {
                        Task { await viewModel.togglePlayPause() }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(Color("BookmarkBlue"))
                            .frame(width: 64, height: 64)
                        
                        if audioState.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: audioState.isPlaying ? "pause.fill" : "play.fill")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(audioState.isLoading)
                
                Spacer()
                
                // Next chapter
                Button(action: { 
                    hapticManager.triggerFeedback(.medium)
                    if let legacyNext = legacyOnNext {
                        legacyNext()
                    } else {
                        Task { await viewModel.skipToNext() }
                    }
                }) {
                    Image(systemName: "forward.end.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            
            // Secondary controls
            HStack {
                // Playback speed
                Button(action: { 
                    hapticManager.triggerFeedback(.light)
                    showSpeedPicker = true 
                }) {
                    Text(audioState.playbackSpeed.title)
                        .font(.subheadline)
                        .foregroundColor(Color("BookmarkBlue"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color("BookmarkBlue").opacity(0.1))
                        .cornerRadius(16)
                }
                .actionSheet(isPresented: $showSpeedPicker) {
                    ActionSheet(
                        title: Text("Playback Speed"),
                        buttons: PlaybackSpeed.allCases.map { speed in
                            .default(Text(speed.title)) {
                                hapticManager.triggerFeedback(.light)
                                if let legacySpeedChange = legacyOnSpeedChange {
                                    legacySpeedChange(speed)
                                } else {
                                    viewModel.changePlaybackSpeed(speed)
                                }
                            }
                        } + [.cancel()]
                    )
                }
                
                Spacer()
                
                // Download button
                if !audioState.isDownloaded && !viewModel.isDownloading {
                    Button(action: {
                        hapticManager.triggerFeedback(.light)
                        if let chapter = currentChapter {
                            Task {
                                await viewModel.downloadChapter(
                                    book: chapter.book,
                                    chapter: chapter.chapter,
                                    translation: chapter.translation
                                )
                            }
                        }
                    }) {
                        Image(systemName: "arrow.down.circle")
                            .font(.title3)
                            .foregroundColor(Color("BookmarkBlue"))
                    }
                }
                
                // Voice selection
                Button(action: {
                    hapticManager.triggerFeedback(.light)
                    // This would open a voice selection sheet
                    // For now, just show current voice
                }) {
                    Image(systemName: "person.wave.2")
                        .font(.title3)
                        .foregroundColor(Color("BookmarkBlue"))
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Compact Audio Player for Apple Watch
public struct CompactAudioPlayerView: View {
    let audioState: AudioPlayerView.AudioPlayerState
    let currentChapter: AudioPlayerView.ChapterInfo
    let onPlayPause: () -> Void
    
    @Environment(\.hapticManager) private var hapticManager
    
    public init(
        audioState: AudioPlayerView.AudioPlayerState,
        currentChapter: AudioPlayerView.ChapterInfo,
        onPlayPause: @escaping () -> Void
    ) {
        self.audioState = audioState
        self.currentChapter = currentChapter
        self.onPlayPause = onPlayPause
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Chapter info
            Text("\(currentChapter.book) \(currentChapter.chapter)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // Play/Pause button
            Button(action: { 
                hapticManager.triggerFeedback(.medium)
                onPlayPause() 
            }) {
                ZStack {
                    Circle()
                        .fill(Color("BookmarkBlue"))
                        .frame(width: 44, height: 44)
                    
                    if audioState.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.6)
                    } else {
                        Image(systemName: audioState.isPlaying ? "pause.fill" : "play.fill")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(audioState.isLoading)
            
            // Progress
            ProgressView(value: audioState.progress)
                .tint(Color("BookmarkBlue"))
                .scaleEffect(y: 0.5)
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Mini Audio Player (for overlays)
public struct MiniAudioPlayerView: View {
    let audioState: AudioPlayerView.AudioPlayerState
    let currentChapter: AudioPlayerView.ChapterInfo
    let onPlayPause: () -> Void
    let onExpand: () -> Void
    
    public init(
        audioState: AudioPlayerView.AudioPlayerState,
        currentChapter: AudioPlayerView.ChapterInfo,
        onPlayPause: @escaping () -> Void,
        onExpand: @escaping () -> Void
    ) {
        self.audioState = audioState
        self.currentChapter = currentChapter
        self.onPlayPause = onPlayPause
        self.onExpand = onExpand
    }
    
    public var body: some View {
        Button(action: onExpand) {
            HStack(spacing: 12) {
                // Play/Pause button
                Button(action: onPlayPause) {
                    ZStack {
                        Circle()
                            .fill(Color("BookmarkBlue"))
                            .frame(width: 32, height: 32)
                        
                        if audioState.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.5)
                        } else {
                            Image(systemName: audioState.isPlaying ? "pause.fill" : "play.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .disabled(audioState.isLoading)
                
                // Chapter info
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(currentChapter.book) \(currentChapter.chapter)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    ProgressView(value: audioState.progress)
                        .tint(Color("BookmarkBlue"))
                        .scaleEffect(y: 0.5)
                }
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Dummy Services for Legacy Mode
@MainActor
private final class DummyAudioService: AudioService {
    @Published var isPlaying = false
    @Published var isLoading = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackSpeed: Float = 1.0
    @Published var currentChapter: AudioChapter? = nil
    @Published var playbackQueue: [AudioChapter] = []
    
    func loadChapter(_ chapter: AudioChapter) async throws {}
    func play() async throws {}
    func pause() {}
    func stop() {}
    func seek(to time: TimeInterval) {}
    func setPlaybackSpeed(_ speed: Float) {}
    func skipToNext() async throws {}
    func skipToPrevious() async throws {}
    func addToQueue(_ chapter: AudioChapter) {}
    func removeFromQueue(at index: Int) {}
    func clearQueue() {}
}

private final class DummyBibleService: BibleService {
    func fetchVerse(reference: String, translation: String?) async throws -> BibleVerse {
        throw LeavnError.notImplemented("Dummy service")
    }
    func fetchChapter(book: String, chapter: Int, translation: String?) async throws -> BibleChapter {
        throw LeavnError.notImplemented("Dummy service")
    }
    func fetchTranslations() async throws -> [BibleTranslation] { [] }
    func search(query: String, translation: String?) async throws -> [BibleSearchResult] { [] }
    func getBooks(includeApocrypha: Bool) async throws -> [BibleBook] { [] }
    func fetchPassage(reference: String, translation: String?) async throws -> BiblePassage {
        throw LeavnError.notImplemented("Dummy service")
    }
}

@MainActor
private final class DummyVoiceConfigService: VoiceConfigurationService {
    @Published var selectedVoices: [String: String] = [:]
    @Published var userPreferences = VoicePreferences()
    @Published var availableVoices: [Voice] = []
    
    func setVoice(_ voiceId: String, for book: String) {}
    func getVoice(for book: String) -> String { "" }
    func resetToDefaults() {}
    func updatePreferences(_ preferences: VoicePreferences) {}
    func loadVoices() async {}
    func previewVoice(_ voiceId: String, text: String) async throws {}
}

private final class DummyElevenLabsService: ElevenLabsService {
    func synthesizeText(_ text: String, voiceId: String, settings: VoiceSettings?) async throws -> AudioData {
        throw LeavnError.notImplemented("Dummy service")
    }
    func getAvailableVoices() async throws -> [Voice] { [] }
    func getVoiceSettings(voiceId: String) async throws -> VoiceSettings {
        throw LeavnError.notImplemented("Dummy service")
    }
    func getUserSubscription() async throws -> SubscriptionInfo {
        throw LeavnError.notImplemented("Dummy service")
    }
}

private final class DummyCacheManager: AudioCacheManager {
    func cacheAudio(_ data: Data, for chapter: AudioChapter) async throws -> URL {
        throw LeavnError.notImplemented("Dummy service")
    }
    func getCachedAudioURL(for chapter: AudioChapter) -> URL? { nil }
    func isCached(_ chapter: AudioChapter) -> Bool { false }
    func removeCachedAudio(for chapter: AudioChapter) throws {}
    func getCacheSize() -> Int64 { 0 }
    func clearCache() throws {}
    func getCachedChapters() -> [AudioChapter] { [] }
}

// MARK: - Preview
struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Legacy mode preview
            AudioPlayerView(
                audioState: AudioPlayerState(
                    isPlaying: true,
                    currentTime: 125,
                    duration: 847,
                    playbackSpeed: .normal,
                    isDownloaded: true
                ),
                currentChapter: ChapterInfo(
                    book: "Psalms",
                    chapter: 23,
                    narrator: "David Suchet",
                    translation: "NIV"
                ),
                onPlayPause: {},
                onPrevious: {},
                onNext: {},
                onSeek: { _ in },
                onSpeedChange: { _ in }
            )
            
            CompactAudioPlayerView(
                audioState: AudioPlayerState(
                    isPlaying: false,
                    currentTime: 0,
                    duration: 543,
                    isDownloaded: false
                ),
                currentChapter: ChapterInfo(
                    book: "John",
                    chapter: 3,
                    narrator: "Max McLean",
                    translation: "ESV"
                ),
                onPlayPause: {}
            )
            
            MiniAudioPlayerView(
                audioState: AudioPlayerState(
                    isPlaying: true,
                    currentTime: 67,
                    duration: 234
                ),
                currentChapter: ChapterInfo(
                    book: "Romans",
                    chapter: 8,
                    narrator: "Johnny Cash",
                    translation: "NIV"
                ),
                onPlayPause: {},
                onExpand: {}
            )
        }
        .padding()
    }
}