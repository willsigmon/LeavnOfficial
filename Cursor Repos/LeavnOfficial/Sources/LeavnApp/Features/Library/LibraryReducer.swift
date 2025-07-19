import ComposableArchitecture
import Foundation

@Reducer
public struct LibraryReducer {
    @ObservableState
    public struct State: Equatable {
        public var bookmarks: IdentifiedArrayOf<Bookmark> = []
        public var notes: IdentifiedArrayOf<Note> = []
        public var downloads: IdentifiedArrayOf<Download> = []
        public var selectedTab: Tab = .bookmarks
        public var isLoading: Bool = false
        public var error: String? = nil
        public var searchQuery: String = ""
        
        public init() {}
        
        public enum Tab: String, CaseIterable {
            case bookmarks = "Bookmarks"
            case notes = "Notes"
            case downloads = "Downloads"
        }
    }
    
    public enum Action {
        case onAppear
        case tabSelected(State.Tab)
        case loadContent
        case contentLoaded(bookmarks: [Bookmark], notes: [Note], downloads: [Download])
        case contentLoadFailed(Error)
        case searchQueryChanged(String)
        
        // Bookmark actions
        case bookmarkTapped(Bookmark)
        case bookmarkDeleted(Bookmark.ID)
        
        // Note actions
        case noteTapped(Note)
        case noteDeleted(Note.ID)
        case noteUpdated(Note.ID, String)
        
        // Download actions
        case downloadTapped(Download)
        case downloadDeleted(Download.ID)
        case downloadBook(Book)
        case downloadProgress(Download.ID, Double)
        case downloadCompleted(Download.ID)
        case downloadFailed(Download.ID, Error)
    }
    
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.downloadClient) var downloadClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadContent)
                
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .loadContent:
                state.isLoading = true
                state.error = nil
                
                return .run { send in
                    do {
                        async let bookmarks = databaseClient.loadBookmarks()
                        async let notes = databaseClient.loadNotes()
                        async let downloads = downloadClient.loadDownloads()
                        
                        let (loadedBookmarks, loadedNotes, loadedDownloads) = try await (bookmarks, notes, downloads)
                        
                        await send(.contentLoaded(
                            bookmarks: loadedBookmarks,
                            notes: loadedNotes,
                            downloads: loadedDownloads
                        ))
                    } catch {
                        await send(.contentLoadFailed(error))
                    }
                }
                
            case let .contentLoaded(bookmarks, notes, downloads):
                state.isLoading = false
                state.bookmarks = IdentifiedArray(uniqueElements: bookmarks)
                state.notes = IdentifiedArray(uniqueElements: notes)
                state.downloads = IdentifiedArray(uniqueElements: downloads)
                return .none
                
            case let .contentLoadFailed(error):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case let .searchQueryChanged(query):
                state.searchQuery = query
                return .none
                
            case let .bookmarkTapped(bookmark):
                // Navigate to the bookmarked passage
                // This would typically be handled by a coordinator or navigation dependency
                return .none
                
            case let .bookmarkDeleted(id):
                state.bookmarks.remove(id: id)
                return .run { _ in
                    try await databaseClient.deleteBookmark(id)
                }
                
            case let .noteTapped(note):
                // Navigate to the note's passage
                return .none
                
            case let .noteDeleted(id):
                state.notes.remove(id: id)
                return .run { _ in
                    try await databaseClient.deleteNote(id)
                }
                
            case let .noteUpdated(id, content):
                state.notes[id: id]?.content = content
                state.notes[id: id]?.updatedAt = Date()
                
                return .run { [note = state.notes[id: id]] _ in
                    if let note {
                        try await databaseClient.updateNote(note)
                    }
                }
                
            case let .downloadTapped(download):
                // Open downloaded content
                return .none
                
            case let .downloadDeleted(id):
                state.downloads.remove(id: id)
                return .run { _ in
                    try await downloadClient.deleteDownload(id)
                }
                
            case let .downloadBook(book):
                let download = Download(
                    book: book,
                    progress: 0,
                    status: .downloading
                )
                state.downloads.append(download)
                
                return .run { send in
                    for await progress in downloadClient.downloadBook(book) {
                        await send(.downloadProgress(download.id, progress))
                    }
                    await send(.downloadCompleted(download.id))
                } catch: { error, send in
                    await send(.downloadFailed(download.id, error))
                }
                
            case let .downloadProgress(id, progress):
                state.downloads[id: id]?.progress = progress
                return .none
                
            case let .downloadCompleted(id):
                state.downloads[id: id]?.status = .completed
                state.downloads[id: id]?.progress = 1.0
                return .none
                
            case let .downloadFailed(id, error):
                state.downloads[id: id]?.status = .failed
                state.downloads[id: id]?.error = error.localizedDescription
                return .none
            }
        }
    }
}