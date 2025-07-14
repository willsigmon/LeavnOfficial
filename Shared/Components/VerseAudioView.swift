import SwiftUI
import LeavnServices

/// Displays Bible verses with synchronized audio highlighting
public struct VerseAudioView: View {
    @ObservedObject private var viewModel: AudioPlayerViewModel
    private let verses: [BibleVerse]
    @State private var scrollProxy: ScrollViewProxy?
    
    public init(viewModel: AudioPlayerViewModel, verses: [BibleVerse]) {
        self.viewModel = viewModel
        self.verses = verses
    }
    
    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(verses) { verse in
                        VerseRow(
                            verse: verse,
                            isHighlighted: viewModel.currentVerse == verse.verse,
                            onTap: {
                                // Jump to specific verse
                                jumpToVerse(verse.verse)
                            }
                        )
                        .id(verse.verse)
                    }
                }
                .padding()
            }
            .onAppear {
                scrollProxy = proxy
            }
            .onChange(of: viewModel.currentVerse) { newVerse in
                // Auto-scroll to current verse
                if let verse = newVerse {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(verse, anchor: .center)
                    }
                }
            }
        }
    }
    
    private func jumpToVerse(_ verseNumber: Int) {
        // This would require exposing the current chapter from the viewModel
        // For now, we'll just seek based on verse position estimation
        viewModel.seek(to: TimeInterval(verseNumber * 30)) // Rough estimation
    }
}

// MARK: - Verse Row
struct VerseRow: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number
            Text("\(verse.verse)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isHighlighted ? .white : Color("BookmarkBlue"))
                .frame(width: 30, height: 30)
                .background(
                    Circle()
                        .fill(isHighlighted ? Color("BookmarkBlue") : Color("BookmarkBlue").opacity(0.1))
                )
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            
            // Verse text
            Text(verse.text)
                .font(.body)
                .foregroundColor(isHighlighted ? .primary : .secondary)
                .multilineTextAlignment(.leading)
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isHighlighted ? Color("BookmarkBlue").opacity(0.1) : Color.clear)
                .animation(.easeInOut(duration: 0.2), value: isHighlighted)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Compact Verse Display for Watch
public struct CompactVerseAudioView: View {
    @ObservedObject private var viewModel: AudioPlayerViewModel
    private let verses: [BibleVerse]
    
    public init(viewModel: AudioPlayerViewModel, verses: [BibleVerse]) {
        self.viewModel = viewModel
        self.verses = verses
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(verses) { verse in
                    CompactVerseRow(
                        verse: verse,
                        isHighlighted: viewModel.currentVerse == verse.verse
                    )
                }
            }
            .padding()
        }
    }
}

struct CompactVerseRow: View {
    let verse: BibleVerse
    let isHighlighted: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Verse \(verse.verse)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(isHighlighted ? Color("BookmarkBlue") : .secondary)
            
            Text(verse.text)
                .font(.caption)
                .foregroundColor(isHighlighted ? .primary : .secondary)
                .lineLimit(3)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color("BookmarkBlue").opacity(0.1) : Color.clear)
        )
    }
}

// MARK: - Voice Selection Sheet
public struct VoiceSelectionView: View {
    @ObservedObject private var voiceConfigService: VoiceConfigurationService
    @ObservedObject private var viewModel: AudioPlayerViewModel
    let book: String
    @Binding var isPresented: Bool
    @State private var selectedVoiceId: String = ""
    @State private var isPreviewPlaying = false
    @State private var previewingVoiceId: String?
    
    public init(
        voiceConfigService: VoiceConfigurationService,
        viewModel: AudioPlayerViewModel,
        book: String,
        isPresented: Binding<Bool>
    ) {
        self.voiceConfigService = voiceConfigService
        self.viewModel = viewModel
        self.book = book
        self._isPresented = isPresented
    }
    
    public var body: some View {
        NavigationView {
            List {
                // Recommended voices section
                Section(header: Text("Recommended Voices")) {
                    ForEach(recommendedVoices) { voice in
                        VoiceRowView(
                            voice: voice,
                            isSelected: selectedVoiceId == voice.id,
                            isPreviewing: previewingVoiceId == voice.id,
                            onSelect: {
                                selectedVoiceId = voice.id
                            },
                            onPreview: {
                                previewVoice(voice)
                            }
                        )
                    }
                }
                
                // All voices section
                Section(header: Text("All Voices")) {
                    ForEach(voiceConfigService.availableVoices) { voice in
                        VoiceRowView(
                            voice: voice,
                            isSelected: selectedVoiceId == voice.id,
                            isPreviewing: previewingVoiceId == voice.id,
                            onSelect: {
                                selectedVoiceId = voice.id
                            },
                            onPreview: {
                                previewVoice(voice)
                            }
                        )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Select Voice")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Done") {
                    voiceConfigService.setVoice(selectedVoiceId, for: book)
                    isPresented = false
                }
                .disabled(selectedVoiceId.isEmpty)
            )
            .onAppear {
                selectedVoiceId = voiceConfigService.getVoice(for: book)
                Task {
                    await voiceConfigService.loadVoices()
                }
            }
        }
    }
    
    private var recommendedVoices: [Voice] {
        let category = BibleVoiceCategory.category(for: book)
        let recommendedIds = category.recommendedVoices
        
        return voiceConfigService.availableVoices.filter { voice in
            recommendedIds.contains(voice.id)
        }
    }
    
    private func previewVoice(_ voice: Voice) {
        guard !isPreviewPlaying else { return }
        
        isPreviewPlaying = true
        previewingVoiceId = voice.id
        
        Task {
            do {
                try await voiceConfigService.previewVoice(
                    voice.id,
                    text: getPreviewText(for: book)
                )
            } catch {
                print("Preview failed: \(error)")
            }
            
            isPreviewPlaying = false
            previewingVoiceId = nil
        }
    }
    
    private func getPreviewText(for book: String) -> String {
        // Return appropriate preview text based on book
        let category = BibleVoiceCategory.category(for: book)
        
        switch category {
        case .psalms:
            return "The Lord is my shepherd; I shall not want. He makes me lie down in green pastures."
        case .gospels:
            return "In the beginning was the Word, and the Word was with God, and the Word was God."
        case .prophecy:
            return "For unto us a child is born, unto us a son is given, and the government shall be upon his shoulder."
        case .wisdom:
            return "Trust in the Lord with all your heart, and do not lean on your own understanding."
        case .epistles:
            return "Love is patient and kind; love does not envy or boast; it is not arrogant."
        default:
            return "In the beginning, God created the heavens and the earth."
        }
    }
}

struct VoiceRowView: View {
    let voice: Voice
    let isSelected: Bool
    let isPreviewing: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(voice.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                if let description = voice.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Preview button
            Button(action: onPreview) {
                if isPreviewing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "play.circle")
                        .font(.title2)
                        .foregroundColor(Color("BookmarkBlue"))
                }
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isPreviewing)
            
            // Selection indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(Color("BookmarkBlue"))
            } else {
                Circle()
                    .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Download Manager View
public struct AudioDownloadManagerView: View {
    @ObservedObject private var viewModel: AudioPlayerViewModel
    private let cacheManager: AudioCacheManager
    @State private var showDeleteConfirmation = false
    @State private var chapterToDelete: AudioChapter?
    @State private var cachedChapters: [AudioChapter] = []
    @State private var cacheSize: Int64 = 0
    
    public init(viewModel: AudioPlayerViewModel, cacheManager: AudioCacheManager) {
        self.viewModel = viewModel
        self.cacheManager = cacheManager
    }
    
    public var body: some View {
        NavigationView {
            List {
                // Storage info
                Section(header: Text("Storage")) {
                    HStack {
                        Text("Total Cache Size")
                        Spacer()
                        Text(formatBytes(cacheSize))
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        do {
                            try cacheManager.clearCache()
                            refreshCacheData()
                        } catch {
                            print("Failed to clear cache: \(error)")
                        }
                    }) {
                        Text("Clear All Downloads")
                            .foregroundColor(.red)
                    }
                }
                
                // Downloaded chapters
                Section(header: Text("Downloaded Chapters")) {
                    ForEach(cachedChapters) { chapter in
                        DownloadedChapterRow(
                            chapter: chapter,
                            onDelete: {
                                chapterToDelete = chapter
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Downloads")
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Download"),
                    message: Text("Are you sure you want to delete \(chapterToDelete?.title ?? "")?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let chapter = chapterToDelete {
                            do {
                                try cacheManager.removeCachedAudio(for: chapter)
                                refreshCacheData()
                            } catch {
                                print("Failed to delete: \(error)")
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                refreshCacheData()
            }
        }
    }
    
    private func refreshCacheData() {
        cachedChapters = cacheManager.getCachedChapters()
        cacheSize = cacheManager.getCacheSize()
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct DownloadedChapterRow: View {
    let chapter: AudioChapter
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(chapter.title)
                    .font(.headline)
                
                HStack {
                    Text(chapter.translation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let size = chapter.fileSize {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatBytes(size))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let duration = chapter.duration {
                        Text("•")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(formatDuration(duration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}