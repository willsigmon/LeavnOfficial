import ComposableArchitecture
import Foundation
import IdentifiedCollections
import UIKit

@Reducer
public struct BibleReducer {
    @ObservableState
    public struct State: Equatable {
        // Current Reading
        public var currentReference: BibleReference
        public var chapter: Chapter?
        public var isLoadingPassage: Bool = false
        public var passageError: String?
        
        // Audio
        public var audioState: AudioPlaybackState = .idle
        public var audioSettings: AudioSettings
        
        // Search
        public var searchQuery: String = ""
        public var searchResults: IdentifiedArrayOf<SearchResult> = []
        public var isSearching: Bool = false
        public var searchError: String?
        
        // Library Integration
        public var bookmarks: IdentifiedArrayOf<Bookmark> = []
        public var notes: IdentifiedArrayOf<Note> = []
        public var highlights: IdentifiedArrayOf<Highlight> = []
        
        // UI State
        public var selectedVerses: Set<Int> = []
        public var showingNoteEditor: Bool = false
        public var showingBookSelector: Bool = false
        public var showingChapterSelector: Bool = false
        public var showingShareSheet: Bool = false
        public var showingReadingPlanSheet: Bool = false
        
        // Reading Plans
        public var activeReadingPlan: ReadingPlan?
        public var todayReading: ReadingDay?
        
        // Verse of the Day
        public var verseOfTheDay: Verse?
        
        public init(
            reference: BibleReference = BibleReference(book: .genesis, chapter: 1),
            audioSettings: AudioSettings = AudioSettings()
        ) {
            self.currentReference = reference
            self.audioSettings = audioSettings
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onDisappear
        
        // Navigation
        case loadPassage(BibleReference)
        case passageLoaded(Result<Chapter, Error>)
        case selectBook(Book)
        case selectChapter(Int)
        case selectVerse(Int)
        case nextChapter
        case previousChapter
        case goToReference(BibleReference)
        
        // Audio
        case playAudio
        case pauseAudio
        case stopAudio
        case audioStateChanged(AudioPlaybackState)
        case setPlaybackSpeed(Double)
        case selectVoice(String)
        
        // Search
        case search
        case searchResultsReceived(Result<IdentifiedArrayOf<SearchResult>, Error>)
        case selectSearchResult(SearchResult)
        case clearSearch
        
        // Library Actions
        case toggleBookmark(BibleReference)
        case bookmarkUpdated(Result<Bookmark, Error>)
        case addNote(BibleReference, String)
        case noteAdded(Result<Note, Error>)
        case updateNote(NoteID, String)
        case noteUpdated(Result<Note, Error>)
        case deleteNote(NoteID)
        case noteDeleted(Result<NoteID, Error>)
        case highlightVerse(BibleReference, HighlightColor)
        case highlightUpdated(Result<Highlight, Error>)
        case removeHighlight(HighlightID)
        case highlightRemoved(Result<HighlightID, Error>)
        
        // Sharing
        case shareVerse(BibleReference)
        case copyVerse(BibleReference)
        
        // Reading Plans
        case loadTodayReading
        case todayReadingLoaded(Result<ReadingDay?, Error>)
        case markReadingComplete
        case readingMarkedComplete(Result<ReadingPlan, Error>)
        
        // Verse of the Day
        case loadVerseOfTheDay
        case verseOfTheDayLoaded(Result<Verse, Error>)
        
        // UI Actions
        case toggleNoteEditor
        case toggleBookSelector
        case toggleChapterSelector
        case toggleShareSheet
        case toggleReadingPlanSheet
        case dismissError
    }
    
    @Dependency(\.bibleService) var bibleService
    @Dependency(\.audioService) var audioService
    @Dependency(\.libraryService) var libraryService
    @Dependency(\.continuousClock) var clock
    @Dependency(\.mainQueue) var mainQueue
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { [reference = state.currentReference] send in
                        await send(.loadPassage(reference))
                    },
                    .run { send in
                        await send(.loadVerseOfTheDay)
                    },
                    .run { send in
                        await send(.loadTodayReading)
                    },
                    .run { send in
                        // Subscribe to audio state changes
                        for await audioState in await audioService.audioState() {
                            await send(.audioStateChanged(audioState))
                        }
                    }
                )
                
            case .onDisappear:
                return .run { _ in
                    await audioService.stopAudio()
                }
                
            case let .loadPassage(reference):
                state.currentReference = reference
                state.isLoadingPassage = true
                state.passageError = nil
                
                return .run { send in
                    await send(
                        .passageLoaded(
                            Result {
                                try await bibleService.fetchPassage(reference)
                            }
                        )
                    )
                }
                
            case let .passageLoaded(.success(chapter)):
                state.isLoadingPassage = false
                state.chapter = chapter
                
                // Load bookmarks, notes, and highlights for this chapter
                return .merge(
                    loadLibraryDataForChapter(state: &state, chapter: chapter),
                    // Stop any existing audio when loading new passage
                    .run { _ in
                        await audioService.stopAudio()
                    }
                )
                
            case let .passageLoaded(.failure(error)):
                state.isLoadingPassage = false
                state.passageError = error.localizedDescription
                return .none
                
            case let .selectBook(book):
                let newReference = BibleReference(book: book, chapter: 1)
                return .send(.loadPassage(newReference))
                
            case let .selectChapter(chapter):
                let newReference = BibleReference(
                    book: state.currentReference.book,
                    chapter: chapter
                )
                return .send(.loadPassage(newReference))
                
            case let .selectVerse(verse):
                if state.selectedVerses.contains(verse) {
                    state.selectedVerses.remove(verse)
                } else {
                    state.selectedVerses.insert(verse)
                }
                return .none
                
            case .nextChapter:
                let currentChapter = state.currentReference.chapter.rawValue
                let maxChapter = state.currentReference.book.chapterCount
                
                if currentChapter < maxChapter {
                    let newReference = BibleReference(
                        book: state.currentReference.book,
                        chapter: currentChapter + 1
                    )
                    return .send(.loadPassage(newReference))
                } else if let nextBook = state.currentReference.book.next {
                    let newReference = BibleReference(book: nextBook, chapter: 1)
                    return .send(.loadPassage(newReference))
                }
                return .none
                
            case .previousChapter:
                let currentChapter = state.currentReference.chapter.rawValue
                
                if currentChapter > 1 {
                    let newReference = BibleReference(
                        book: state.currentReference.book,
                        chapter: currentChapter - 1
                    )
                    return .send(.loadPassage(newReference))
                } else if let previousBook = state.currentReference.book.previous {
                    let newReference = BibleReference(
                        book: previousBook,
                        chapter: previousBook.chapterCount
                    )
                    return .send(.loadPassage(newReference))
                }
                return .none
                
            case let .goToReference(reference):
                return .send(.loadPassage(reference))
                
            case .playAudio:
                guard let chapter = state.chapter else { return .none }
                
                let text = chapter.verses.map { $0.text }.joined(separator: " ")
                let voiceId = state.audioSettings.voiceId
                
                return .run { send in
                    do {
                        let audioData = try await audioService.generateAudio(text, voiceId)
                        try await audioService.playAudio(audioData)
                    } catch {
                        await send(.audioStateChanged(.error(error.localizedDescription)))
                    }
                }
                
            case .pauseAudio:
                return .run { _ in
                    await audioService.pauseAudio()
                }
                
            case .stopAudio:
                return .run { _ in
                    await audioService.stopAudio()
                }
                
            case let .audioStateChanged(audioState):
                state.audioState = audioState
                return .none
                
            case let .setPlaybackSpeed(speed):
                state.audioSettings.playbackSpeed = speed
                return .run { _ in
                    await audioService.setPlaybackSpeed(speed)
                }
                
            case let .selectVoice(voiceId):
                state.audioSettings.voiceId = voiceId
                return .none
                
            case .search:
                guard !state.searchQuery.isEmpty else { return .none }
                
                state.isSearching = true
                state.searchError = nil
                
                return .run { [query = state.searchQuery] send in
                    await send(
                        .searchResultsReceived(
                            Result {
                                try await bibleService.searchPassages(query)
                            }
                        )
                    )
                }
                
            case let .searchResultsReceived(.success(results)):
                state.isSearching = false
                state.searchResults = results
                return .none
                
            case let .searchResultsReceived(.failure(error)):
                state.isSearching = false
                state.searchError = error.localizedDescription
                return .none
                
            case let .selectSearchResult(result):
                state.searchQuery = ""
                state.searchResults = []
                return .send(.loadPassage(result.reference))
                
            case .clearSearch:
                state.searchQuery = ""
                state.searchResults = []
                state.searchError = nil
                return .none
                
            case let .toggleBookmark(reference):
                if let bookmark = state.bookmarks.first(where: { $0.reference == reference }) {
                    return .run { send in
                        await send(
                            .bookmarkUpdated(
                                Result {
                                    try await libraryService.deleteBookmark(bookmark.id)
                                    return bookmark
                                }
                            )
                        )
                    }
                } else {
                    let bookmark = Bookmark(reference: reference)
                    return .run { send in
                        await send(
                            .bookmarkUpdated(
                                Result {
                                    try await libraryService.createBookmark(bookmark)
                                }
                            )
                        )
                    }
                }
                
            case let .bookmarkUpdated(.success(bookmark)):
                if state.bookmarks.contains(bookmark) {
                    state.bookmarks.remove(bookmark)
                } else {
                    state.bookmarks.append(bookmark)
                }
                return .none
                
            case let .bookmarkUpdated(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .addNote(reference, content):
                let note = Note(reference: reference, content: content)
                return .run { send in
                    await send(
                        .noteAdded(
                            Result {
                                try await libraryService.createNote(note)
                            }
                        )
                    )
                }
                
            case let .noteAdded(.success(note)):
                state.notes.append(note)
                state.showingNoteEditor = false
                return .none
                
            case let .noteAdded(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .updateNote(id, content):
                guard var note = state.notes[id: id] else { return .none }
                
                note.content = content
                note.updatedAt = Date()
                
                return .run { send in
                    await send(
                        .noteUpdated(
                            Result {
                                try await libraryService.updateNote(note)
                            }
                        )
                    )
                }
                
            case let .noteUpdated(.success(note)):
                state.notes[id: note.id] = note
                return .none
                
            case let .noteUpdated(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .deleteNote(id):
                return .run { send in
                    await send(
                        .noteDeleted(
                            Result {
                                try await libraryService.deleteNote(id)
                                return id
                            }
                        )
                    )
                }
                
            case let .noteDeleted(.success(id)):
                state.notes.remove(id: id)
                return .none
                
            case let .noteDeleted(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .highlightVerse(reference, color):
                let highlight = Highlight(
                    reference: reference,
                    text: state.chapter?.verses.first { $0.reference == reference }?.text ?? "",
                    color: color
                )
                
                return .run { send in
                    await send(
                        .highlightUpdated(
                            Result {
                                try await libraryService.createHighlight(highlight)
                            }
                        )
                    )
                }
                
            case let .highlightUpdated(.success(highlight)):
                state.highlights.append(highlight)
                return .none
                
            case let .highlightUpdated(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .removeHighlight(id):
                return .run { send in
                    await send(
                        .highlightRemoved(
                            Result {
                                try await libraryService.deleteHighlight(id)
                                return id
                            }
                        )
                    )
                }
                
            case let .highlightRemoved(.success(id)):
                state.highlights.remove(id: id)
                return .none
                
            case let .highlightRemoved(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case let .shareVerse(reference):
                // Implement sharing functionality
                state.showingShareSheet = true
                return .none
                
            case let .copyVerse(reference):
                guard let verse = state.chapter?.verses.first(where: { $0.reference == reference }) else {
                    return .none
                }
                
                UIPasteboard.general.string = "\(verse.text)\n- \(reference.displayText)"
                return .none
                
            case .loadTodayReading:
                return .run { send in
                    await send(
                        .todayReadingLoaded(
                            Result {
                                try await libraryService.fetchActiveReadingPlan()?.days.first {
                                    $0.dayNumber == calculateTodayReadingDay()
                                }
                            }
                        )
                    )
                }
                
            case let .todayReadingLoaded(.success(reading)):
                state.todayReading = reading
                return .none
                
            case let .todayReadingLoaded(.failure(error)):
                // Silently fail for reading plan
                return .none
                
            case .markReadingComplete:
                guard let plan = state.activeReadingPlan,
                      let todayReading = state.todayReading else {
                    return .none
                }
                
                return .run { send in
                    await send(
                        .readingMarkedComplete(
                            Result {
                                try await libraryService.markDayComplete(plan.id, todayReading.dayNumber)
                            }
                        )
                    )
                }
                
            case let .readingMarkedComplete(.success(plan)):
                state.activeReadingPlan = plan
                return .none
                
            case let .readingMarkedComplete(.failure(error)):
                state.passageError = error.localizedDescription
                return .none
                
            case .loadVerseOfTheDay:
                return .run { send in
                    await send(
                        .verseOfTheDayLoaded(
                            Result {
                                try await bibleService.getVerseOfTheDay()
                            }
                        )
                    )
                }
                
            case let .verseOfTheDayLoaded(.success(verse)):
                state.verseOfTheDay = verse
                return .none
                
            case let .verseOfTheDayLoaded(.failure(error)):
                // Silently fail for verse of the day
                return .none
                
            case .toggleNoteEditor:
                state.showingNoteEditor.toggle()
                return .none
                
            case .toggleBookSelector:
                state.showingBookSelector.toggle()
                return .none
                
            case .toggleChapterSelector:
                state.showingChapterSelector.toggle()
                return .none
                
            case .toggleShareSheet:
                state.showingShareSheet.toggle()
                return .none
                
            case .toggleReadingPlanSheet:
                state.showingReadingPlanSheet.toggle()
                return .none
                
            case .dismissError:
                state.passageError = nil
                state.searchError = nil
                return .none
                
            case .binding:
                return .none
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadLibraryDataForChapter(state: inout State, chapter: Chapter) -> Effect<Action> {
        let reference = BibleReference(
            book: chapter.book,
            chapter: chapter.number.rawValue
        )
        
        return .run { send in
            async let bookmarks = libraryService.fetchBookmarks()
            async let notes = libraryService.fetchNotes(
                NotesFilter(book: chapter.book)
            )
            async let highlights = libraryService.fetchHighlights(
                HighlightFilter(book: chapter.book)
            )
            
            do {
                let (fetchedBookmarks, fetchedNotes, fetchedHighlights) = try await (bookmarks, notes, highlights)
                
                // Filter to current chapter
                let chapterBookmarks = fetchedBookmarks.filter { bookmark in
                    bookmark.reference.book == chapter.book &&
                    bookmark.reference.chapter == chapter.number
                }
                
                let chapterNotes = fetchedNotes.filter { note in
                    note.reference.book == chapter.book &&
                    note.reference.chapter == chapter.number
                }
                
                let chapterHighlights = fetchedHighlights.filter { highlight in
                    highlight.reference.book == chapter.book &&
                    highlight.reference.chapter == chapter.number
                }
                
                await MainActor.run {
                    state.bookmarks = IdentifiedArray(uniqueElements: chapterBookmarks)
                    state.notes = IdentifiedArray(uniqueElements: chapterNotes)
                    state.highlights = IdentifiedArray(uniqueElements: chapterHighlights)
                }
            } catch {
                // Silently fail for library data
            }
        }
    }
}

// MARK: - Utilities

private func calculateTodayReadingDay() -> Int {
    // Calculate which day of the reading plan we're on
    // This would be based on the plan start date
    return 1
}