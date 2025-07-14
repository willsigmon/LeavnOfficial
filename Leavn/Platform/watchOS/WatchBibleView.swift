import SwiftUI

struct WatchBibleView: View {
    @StateObject private var viewModel = WatchBibleViewModel()
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                ProgressView()
                    .navigationTitle("Bible")
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        // Book and Chapter Selector
                        Button(action: { viewModel.showBookPicker = true }) {
                            HStack {
                                Text("\(viewModel.currentBook) \(viewModel.currentChapter)")
                                    .font(.caption)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .font(.caption2)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        // Verse Content
                        ForEach(viewModel.verses, id: \.self) { verse in
                            Text(verse)
                                .font(.caption2)
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                }
                .navigationTitle("Bible")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: viewModel.toggleBookmark) {
                            Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                        }
                    }
                }
                .sheet(isPresented: $viewModel.showBookPicker) {
                    WatchBookPickerView(
                        selectedBook: $viewModel.currentBook,
                        selectedChapter: $viewModel.currentChapter
                    )
                }
            }
        }
    }
}

struct WatchBookPickerView: View {
    @Binding var selectedBook: String
    @Binding var selectedChapter: Int
    @Environment(\.dismiss) var dismiss
    
    let books = ["Genesis", "Exodus", "Psalms", "Matthew", "John"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(books, id: \.self) { book in
                    Button(action: {
                        selectedBook = book
                        selectedChapter = 1
                        dismiss()
                    }) {
                        HStack {
                            Text(book)
                                .font(.caption)
                            Spacer()
                            if selectedBook == book {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Book")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    WatchBibleView()
}