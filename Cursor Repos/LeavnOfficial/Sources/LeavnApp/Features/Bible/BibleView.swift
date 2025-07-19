import SwiftUI
import ComposableArchitecture

public struct BibleView: View {
    @Bindable var store: StoreOf<BibleReducer>
    
    public init(store: StoreOf<BibleReducer>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if store.isLoading {
                    ProgressView("Loading passage...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = store.error {
                    ErrorView(message: error) {
                        store.send(.loadPassage(store.currentBook, store.currentChapter, nil))
                    }
                } else {
                    ScrollView {
                        PassageTextView(
                            text: store.passageText,
                            highlightedVerses: store.highlightedVerses,
                            onVerseSelected: { verse in
                                store.send(.verseSelected(verse))
                            },
                            onVerseLongPressed: { reference in
                                // Show context menu
                            }
                        )
                        .padding()
                    }
                    
                    AudioControlBar(
                        isPlaying: store.isAudioPlaying,
                        progress: store.audioProgress,
                        onPlayPause: {
                            if store.isAudioPlaying {
                                store.send(.pauseAudioTapped)
                            } else {
                                store.send(.playAudioTapped)
                            }
                        }
                    )
                }
            }
            .navigationTitle("\(store.currentBook.name) \(store.currentChapter)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { store.send(.previousChapterTapped) }) {
                        Image(systemName: "chevron.left")
                    }
                    .disabled(store.currentBook == .genesis && store.currentChapter == 1)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { store.send(.nextChapterTapped) }) {
                        Image(systemName: "chevron.right")
                    }
                    .disabled(store.currentBook == .revelation && store.currentChapter == 22)
                }
                
                ToolbarItem(placement: .principal) {
                    Menu {
                        ForEach(Book.allCases, id: \.self) { book in
                            Button(book.name) {
                                store.send(.loadPassage(book, 1, nil))
                            }
                        }
                    } label: {
                        HStack {
                            Text("\(store.currentBook.name) \(store.currentChapter)")
                                .font(.headline)
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.caption)
                        }
                    }
                }
            }
            .searchable(text: $store.searchQuery.sending(\.searchQueryChanged))
            .onSubmit(of: .search) {
                store.send(.searchSubmitted)
            }
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

struct PassageTextView: View {
    let text: String
    let highlightedVerses: Set<String>
    let onVerseSelected: (Int) -> Void
    let onVerseLongPressed: (String) -> Void
    
    var body: some View {
        Text(text)
            .font(.body)
            .lineSpacing(8)
            .textSelection(.enabled)
    }
}

struct AudioControlBar: View {
    let isPlaying: Bool
    let progress: Double
    let onPlayPause: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ProgressView(value: progress)
                .progressViewStyle(.linear)
            
            HStack {
                Button(action: onPlayPause) {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Text(formatTime(progress))
                    .font(.caption)
                    .monospacedDigit()
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func formatTime(_ progress: Double) -> String {
        let minutes = Int(progress * 60)
        let seconds = Int((progress * 60).truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Retry", action: retry)
                .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}