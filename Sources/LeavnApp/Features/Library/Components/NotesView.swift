import SwiftUI
import ComposableArchitecture

struct NotesListPreview: View {
    let notes: [Note]
    let onViewAll: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(notes) { note in
                NotePreviewCard(note: note)
            }
            
            if notes.count >= 3 {
                Button(action: onViewAll) {
                    HStack {
                        Text("View All Notes")
                            .font(.callout.bold())
                        Image(systemName: "arrow.right")
                            .font(.caption)
                    }
                    .foregroundColor(.leavnPrimary)
                }
                .padding(.top, 8)
            }
        }
        .padding(.horizontal)
    }
}

struct NotePreviewCard: View {
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.reference)
                    .font(.headline)
                
                Spacer()
                
                Text(note.updatedAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(note.content)
                .font(.callout)
                .foregroundColor(.secondary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(note.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .foregroundColor(.leavnPrimary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.leavnPrimary.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(12)
    }
}

struct EnhancedNotesView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @State private var selectedNote: Note?
    @State private var isCreatingNote = false
    @State private var selectedFilter: NoteFilter = .all
    
    enum NoteFilter: String, CaseIterable {
        case all = "All"
        case recent = "Recent"
        case byBook = "By Book"
        case byTag = "By Tag"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(NoteFilter.allCases, id: \.self) { filter in
                        FilterPill(
                            title: filter.rawValue,
                            isSelected: selectedFilter == filter
                        ) {
                            selectedFilter = filter
                        }
                    }
                }
                .padding()
            }
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search notes...", text: $store.searchQuery.sending(\.searchQueryChanged))
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
            
            // Content
            if store.notes.isEmpty {
                EmptyStateView(
                    icon: "note.text",
                    title: "No Notes Yet",
                    message: "Start taking notes on verses",
                    buttonTitle: "Create Note",
                    action: {
                        isCreatingNote = true
                    }
                )
            } else {
                List {
                    ForEach(filteredNotes) { note in
                        NoteListItem(note: note) {
                            selectedNote = note
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                store.send(.noteDeleted(note.id))
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                // Share action
                            } label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            }
                            .tint(.blue)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isCreatingNote = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(item: $selectedNote) { note in
            NoteEditorView(note: note, store: store)
        }
        .sheet(isPresented: $isCreatingNote) {
            CreateNoteView(store: store)
        }
    }
    
    private var filteredNotes: [Note] {
        var notes = Array(store.notes)
        
        // Apply search
        if !store.searchQuery.isEmpty {
            notes = notes.filter { note in
                note.reference.localizedCaseInsensitiveContains(store.searchQuery) ||
                note.content.localizedCaseInsensitiveContains(store.searchQuery) ||
                note.tags.contains { $0.localizedCaseInsensitiveContains(store.searchQuery) }
            }
        }
        
        // Apply filter
        switch selectedFilter {
        case .all:
            break
        case .recent:
            notes = Array(notes.sorted { $0.updatedAt > $1.updatedAt }.prefix(20))
        case .byBook:
            // Group by book (handled in view)
            break
        case .byTag:
            // Group by tag (handled in view)
            break
        }
        
        return notes
    }
}

struct NoteListItem: View {
    let note: Note
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.reference)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(note.book.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(note.updatedAt, style: .relative)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        if note.isPrivate {
                            Image(systemName: "lock.fill")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Content Preview
                Text(note.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                
                // Tags
                if !note.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(note.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.leavnPrimary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.leavnPrimary.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

struct NoteEditorView: View {
    let note: Note
    @Bindable var store: StoreOf<LibraryReducer>
    @Environment(\.dismiss) var dismiss
    @State private var content: String
    @State private var tags: [String]
    @State private var isPrivate: Bool
    @State private var newTag = ""
    @FocusState private var isContentFocused: Bool
    
    init(note: Note, store: StoreOf<LibraryReducer>) {
        self.note = note
        self.store = store
        self._content = State(initialValue: note.content)
        self._tags = State(initialValue: note.tags)
        self._isPrivate = State(initialValue: note.isPrivate)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Reference Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(note.reference)
                            .font(.title2.bold())
                        
                        Text(note.book.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.leavnPrimary.opacity(0.1))
                    .cornerRadius(12)
                    
                    // Content Editor
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Note", systemImage: "note.text")
                            .font(.headline)
                        
                        TextEditor(text: $content)
                            .focused($isContentFocused)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                    
                    // Tags
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Tags", systemImage: "tag")
                            .font(.headline)
                        
                        HStack {
                            TextField("Add tag...", text: $newTag)
                                .textFieldStyle(.roundedBorder)
                                .onSubmit {
                                    addTag()
                                }
                            
                            Button("Add", action: addTag)
                                .disabled(newTag.isEmpty)
                        }
                        
                        if !tags.isEmpty {
                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    TagView(tag: tag) {
                                        tags.removeAll { $0 == tag }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Privacy Toggle
                    Toggle(isOn: $isPrivate) {
                        Label("Private Note", systemImage: "lock.fill")
                            .font(.headline)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .leavnPrimary))
                }
                .padding()
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .fontWeight(.semibold)
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isContentFocused = true
        }
    }
    
    private func addTag() {
        let trimmedTag = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedTag.isEmpty && !tags.contains(trimmedTag) {
            tags.append(trimmedTag)
            newTag = ""
        }
    }
    
    private func saveNote() {
        store.send(.noteUpdated(note.id, content))
        // Also update tags and privacy if needed
        dismiss()
    }
}

struct CreateNoteView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    @Environment(\.dismiss) var dismiss
    @State private var selectedBook: Book = .genesis
    @State private var selectedChapter = 1
    @State private var selectedVerse = 1
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var isPrivate = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Reference") {
                    Picker("Book", selection: $selectedBook) {
                        ForEach(Book.allCases, id: \.self) { book in
                            Text(book.name).tag(book)
                        }
                    }
                    
                    HStack {
                        Picker("Chapter", selection: $selectedChapter) {
                            ForEach(1...selectedBook.chapterCount, id: \.self) { chapter in
                                Text("\(chapter)").tag(chapter)
                            }
                        }
                        .pickerStyle(.wheel)
                        
                        Picker("Verse", selection: $selectedVerse) {
                            ForEach(1...50, id: \.self) { verse in
                                Text("\(verse)").tag(verse)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
                
                Section("Note") {
                    TextEditor(text: $content)
                        .frame(minHeight: 150)
                }
                
                Section("Tags") {
                    // Tags input similar to NoteEditorView
                }
                
                Section {
                    Toggle("Private Note", isOn: $isPrivate)
                }
            }
            .navigationTitle("Create Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createNote()
                    }
                    .fontWeight(.semibold)
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
    
    private func createNote() {
        // Create new note
        dismiss()
    }
}