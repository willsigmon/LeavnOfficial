import SwiftUI
import LeavnCore

struct ChapterPickerView: View {
    let book: BibleBook
    let onSelection: (Int) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedChapter: Int = 1
    
    private let columns = [
        GridItem(.adaptive(minimum: 50, maximum: 60), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(1...book.chapterCount, id: \.self) { chapter in
                        Button(action: {
                            selectedChapter = chapter
                            onSelection(chapter)
                            dismiss()
                        }) {
                            Text("\(chapter)")
                                .font(.headline)
                                .frame(width: 44, height: 44)
                                .background(selectedChapter == chapter ? Color.accentColor : Color(.systemGray5))
                                .foregroundColor(selectedChapter == chapter ? .white : .primary)
                                .clipShape(Circle())
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .id(String(chapter))
                    }
                }
                .padding()
            }
            .navigationTitle("\(book.name) Chapters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ChapterPickerView(
        book: .genesis,
        onSelection: { _ in }
    )
}
