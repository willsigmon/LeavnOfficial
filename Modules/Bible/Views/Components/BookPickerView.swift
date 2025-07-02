import SwiftUI
import LeavnCore

struct BookPickerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let selectedBook: BibleBook?
    let selectedChapter: Int
    let onSelect: (BibleBook, Int) -> Void
    
    @State private var searchText = ""
    @State private var selectedTab: Testament = .old
    @State private var showingChapterPicker = false
    @State private var tempSelectedBook: BibleBook?
    @State private var tempSelectedChapter: Int = 1
    
    private var filteredBooks: [BibleBook] {
        let books = selectedTab == .old ? BibleBook.oldTestament : BibleBook.newTestament
        
        if searchText.isEmpty {
            return books
        }
        
        return books.filter { 
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.abbreviation.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var selectedBookName: String {
        selectedBook?.name ?? "Select Book"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search books...")
                    .padding()
                
                // Testament selector
                Picker("Testament", selection: $selectedTab) {
                    Text("Old Testament").tag(Testament.old)
                    Text("New Testament").tag(Testament.new)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Book list
                List {
                    ForEach(filteredBooks, id: \.self) { book in
                        Button(action: {
                            tempSelectedBook = book
                            tempSelectedChapter = 1
                            showingChapterPicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(book.name)
                                        .font(.headline)
                                    Text(book.testament.rawValue)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                if selectedBook == book {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingChapterPicker) {
                if let book = tempSelectedBook {
                    ChapterPickerSheet(
                        book: book,
                        selectedChapter: $tempSelectedChapter,
                        isPresented: $showingChapterPicker
                    ) { chapter in
                        onSelect(book, chapter)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct BookPickerView_Previews: PreviewProvider {
    static var previews: some View {
        BookPickerView(
            selectedBook: .genesis,
            selectedChapter: 1,
            onSelect: { _, _ in }
        )
    }
}
