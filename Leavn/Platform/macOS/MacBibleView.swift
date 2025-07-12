#if canImport(AppKit)
import AppKit
#endif
import SwiftUI
import LeavnCore

#if os(macOS)
struct MacBibleView: View {
    @StateObject private var viewModel = MacBibleViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                // Book and chapter selection
                BookAndChapterPicker(
                    selectedBook: $viewModel.selectedBook,
                    selectedChapter: $viewModel.selectedChapter,
                    books: viewModel.books
                )
                
                // Verse list
                List(viewModel.verses) { verse in
                    Text(verse.text)
                        .font(.body)
                }
                .navigationTitle("Leavn Bible")
            }
        }
    }
}

struct BookAndChapterPicker: View {
    @Binding var selectedBook: BibleBook
    @Binding var selectedChapter: Int
    let books: [BibleBook]
    
    var body: some View {
        HStack {
            Picker("Book", selection: $selectedBook) {
                ForEach(books) { book in
                    Text(book.name).tag(book)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Picker("Chapter", selection: $selectedChapter) {
                ForEach(1...selectedBook.chapterCount, id: \.self) { chapter in
                    Text("\(chapter)").tag(chapter)
                }
            }
            .pickerStyle(MenuPickerStyle())
        }
        .padding()
    }
}
#endif