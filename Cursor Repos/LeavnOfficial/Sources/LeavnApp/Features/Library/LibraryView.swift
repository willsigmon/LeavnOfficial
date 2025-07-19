import SwiftUI
import ComposableArchitecture

public struct LibraryView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    
    public init(store: StoreOf<LibraryReducer>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Library", selection: $store.selectedTab.sending(\.tabSelected)) {
                    ForEach(LibraryReducer.State.Tab.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                if store.isLoading {
                    ProgressView("Loading library...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    switch store.selectedTab {
                    case .bookmarks:
                        BookmarksView(
                            bookmarks: store.bookmarks,
                            searchQuery: store.searchQuery,
                            onBookmarkTapped: { store.send(.bookmarkTapped($0)) },
                            onBookmarkDeleted: { store.send(.bookmarkDeleted($0)) }
                        )
                    case .notes:
                        NotesView(
                            notes: store.notes,
                            searchQuery: store.searchQuery,
                            onNoteTapped: { store.send(.noteTapped($0)) },
                            onNoteDeleted: { store.send(.noteDeleted($0)) },
                            onNoteUpdated: { id, content in
                                store.send(.noteUpdated(id, content))
                            }
                        )
                    case .downloads:
                        DownloadsView(
                            downloads: store.downloads,
                            onDownloadTapped: { store.send(.downloadTapped($0)) },
                            onDownloadDeleted: { store.send(.downloadDeleted($0)) }
                        )
                    }
                }
                
                if let error = store.error {
                    ErrorBanner(message: error)
                }
            }
            .navigationTitle("Library")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $store.searchQuery.sending(\.searchQueryChanged))
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

// MARK: - Bookmarks View

struct BookmarksView: View {
    let bookmarks: IdentifiedArrayOf<Bookmark>
    let searchQuery: String
    let onBookmarkTapped: (Bookmark) -> Void
    let onBookmarkDeleted: (Bookmark.ID) -> Void
    
    var filteredBookmarks: [Bookmark] {
        guard !searchQuery.isEmpty else { return Array(bookmarks) }
        
        return bookmarks.filter { bookmark in
            bookmark.reference.localizedCaseInsensitiveContains(searchQuery) ||
            bookmark.title?.localizedCaseInsensitiveContains(searchQuery) == true
        }
    }
    
    var body: some View {
        if filteredBookmarks.isEmpty {
            ContentUnavailableView(
                "No Bookmarks",
                systemImage: "bookmark",
                description: Text("Your bookmarked passages will appear here")
            )
        } else {
            List {
                ForEach(filteredBookmarks) { bookmark in
                    BookmarkRow(
                        bookmark: bookmark,
                        onTap: { onBookmarkTapped(bookmark) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onBookmarkDeleted(bookmark.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct BookmarkRow: View {
    let bookmark: Bookmark
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Circle()
                    .fill(Color(bookmark.color.uiColor))
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(bookmark.title ?? bookmark.reference)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(bookmark.reference)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(bookmark.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notes View

struct NotesView: View {
    let notes: IdentifiedArrayOf<Note>
    let searchQuery: String
    let onNoteTapped: (Note) -> Void
    let onNoteDeleted: (Note.ID) -> Void
    let onNoteUpdated: (Note.ID, String) -> Void
    
    var filteredNotes: [Note] {
        guard !searchQuery.isEmpty else { return Array(notes) }
        
        return notes.filter { note in
            note.reference.localizedCaseInsensitiveContains(searchQuery) ||
            note.content.localizedCaseInsensitiveContains(searchQuery) ||
            note.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    var body: some View {
        if filteredNotes.isEmpty {
            ContentUnavailableView(
                "No Notes",
                systemImage: "note.text",
                description: Text("Your notes will appear here")
            )
        } else {
            List {
                ForEach(filteredNotes) { note in
                    NoteRow(
                        note: note,
                        onTap: { onNoteTapped(note) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onNoteDeleted(note.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct NoteRow: View {
    let note: Note
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(note.reference)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text(note.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                if !note.tags.isEmpty {
                    HStack {
                        ForEach(note.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Downloads View

struct DownloadsView: View {
    let downloads: IdentifiedArrayOf<Download>
    let onDownloadTapped: (Download) -> Void
    let onDownloadDeleted: (Download.ID) -> Void
    
    var body: some View {
        if downloads.isEmpty {
            ContentUnavailableView(
                "No Downloads",
                systemImage: "arrow.down.circle",
                description: Text("Downloaded content will appear here")
            )
        } else {
            List {
                ForEach(downloads) { download in
                    DownloadRow(
                        download: download,
                        onTap: { onDownloadTapped(download) }
                    )
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            onDownloadDeleted(download.id)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }
}

struct DownloadRow: View {
    let download: Download
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(download.book.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    switch download.status {
                    case .downloading:
                        ProgressView(value: download.progress)
                            .progressViewStyle(.linear)
                    case .completed:
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Downloaded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    case .failed:
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(download.error ?? "Download failed")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                if download.status == .completed {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(download.status != .completed)
    }
}