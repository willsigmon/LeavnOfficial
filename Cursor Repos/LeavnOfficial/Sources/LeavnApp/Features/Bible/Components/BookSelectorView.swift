import SwiftUI
import ComposableArchitecture

struct BookSelectorView: View {
    @Bindable var store: StoreOf<BibleReducer>
    @State private var selectedTestament: Testament = .old
    @State private var searchQuery = ""
    
    enum Testament: String, CaseIterable {
        case old = "Old Testament"
        case new = "New Testament"
        
        var books: [Book] {
            switch self {
            case .old:
                return Book.oldTestamentBooks
            case .new:
                return Book.newTestamentBooks
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search books...", text: $searchQuery)
                        .textFieldStyle(.plain)
                    
                    if !searchQuery.isEmpty {
                        Button(action: { searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()
                
                // Testament Picker
                Picker("Testament", selection: $selectedTestament) {
                    ForEach(Testament.allCases, id: \.self) { testament in
                        Text(testament.rawValue).tag(testament)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Books Grid
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 16) {
                        ForEach(filteredBooks) { book in
                            BookCard(
                                book: book,
                                currentBook: store.currentBook,
                                chaptersRead: store.chaptersRead[book] ?? []
                            ) {
                                store.send(.selectBook(book))
                                store.send(.toggleBookSelector)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        store.send(.toggleBookSelector)
                    }
                }
            }
        }
    }
    
    private var filteredBooks: [Book] {
        let books = selectedTestament.books
        
        if searchQuery.isEmpty {
            return books
        } else {
            return books.filter { book in
                book.name.localizedCaseInsensitiveContains(searchQuery) ||
                book.abbreviation.localizedCaseInsensitiveContains(searchQuery)
            }
        }
    }
}

struct BookCard: View {
    let book: Book
    let currentBook: Book
    let chaptersRead: Set<Int>
    let action: () -> Void
    
    private var readProgress: Double {
        Double(chaptersRead.count) / Double(book.chapterCount)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                // Book Icon
                Image(systemName: book.icon)
                    .font(.largeTitle)
                    .foregroundColor(book == currentBook ? .white : .leavnPrimary)
                
                // Book Name
                Text(book.name)
                    .font(.headline)
                    .foregroundColor(book == currentBook ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                // Chapter Count
                Text("\(book.chapterCount) chapters")
                    .font(.caption)
                    .foregroundColor(book == currentBook ? .white.opacity(0.8) : .secondary)
                
                // Progress Bar
                if readProgress > 0 {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(book == currentBook ? Color.white : Color.leavnPrimary)
                                .frame(width: geometry.size.width * readProgress, height: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.top, 4)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(book == currentBook ? Color.leavnPrimary : Color.leavnSecondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(book == currentBook ? Color.clear : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ChapterSelectorView: View {
    let book: Book
    let currentChapter: Int
    let chaptersRead: Set<Int>
    let onSelect: (Int) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                ForEach(1...book.chapterCount, id: \.self) { chapter in
                    ChapterButton(
                        chapter: chapter,
                        isCurrentChapter: chapter == currentChapter,
                        isRead: chaptersRead.contains(chapter),
                        action: { onSelect(chapter) }
                    )
                }
            }
            .padding()
        }
    }
}

struct ChapterButton: View {
    let chapter: Int
    let isCurrentChapter: Bool
    let isRead: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(chapter)")
                .font(.headline)
                .foregroundColor(foregroundColor)
                .frame(width: 60, height: 60)
                .background(backgroundColor)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
        .buttonStyle(.plain)
    }
    
    private var foregroundColor: Color {
        if isCurrentChapter {
            return .white
        } else if isRead {
            return .leavnPrimary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isCurrentChapter {
            return .leavnPrimary
        } else if isRead {
            return .leavnPrimary.opacity(0.1)
        } else {
            return .leavnSecondaryBackground
        }
    }
    
    private var borderColor: Color {
        if isCurrentChapter {
            return .clear
        } else if isRead {
            return .leavnPrimary.opacity(0.3)
        } else {
            return .gray.opacity(0.2)
        }
    }
}

struct BibleNavigationHeader: View {
    @Bindable var store: StoreOf<BibleReducer>
    
    var body: some View {
        Button(action: { store.send(.toggleBookSelector) }) {
            HStack(spacing: 4) {
                Text("\(store.currentBook.name) \(store.currentChapter)")
                    .font(.headline)
                Image(systemName: "chevron.down.circle.fill")
                    .font(.caption)
            }
            .foregroundColor(.primary)
        }
    }
}

// Book Extensions
extension Book {
    static var oldTestamentBooks: [Book] {
        // Return old testament books based on actual enum
        [.genesis, .exodus, .leviticus, .numbers, .deuteronomy, .psalms, .proverbs]
    }
    
    static var newTestamentBooks: [Book] {
        // Return new testament books based on actual enum
        [.matthew, .mark, .luke, .john, .acts, .romans, .revelation]
    }
    
    var abbreviation: String {
        // Return standard abbreviation
        String(name.prefix(3))
    }
    
    var chapterCount: Int {
        // Return actual chapter count based on book
        switch self {
        case .genesis: return 50
        case .exodus: return 40
        case .psalms: return 150
        case .matthew: return 28
        case .revelation: return 22
        default: return 20
        }
    }
}