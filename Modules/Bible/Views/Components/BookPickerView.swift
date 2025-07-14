import SwiftUI

struct BookPickerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedBook = "Genesis"
    @State private var selectedChapter = 1
    
    let books = ["Genesis", "Exodus", "Leviticus", "Numbers", "Deuteronomy"]
    let chapters = Array(1...50)
    
    var body: some View {
        NavigationView {
            VStack {
                Picker("Book", selection: $selectedBook) {
                    ForEach(books, id: \.self) { book in
                        Text(book).tag(book)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                
                Picker("Chapter", selection: $selectedChapter) {
                    ForEach(chapters, id: \.self) { chapter in
                        Text("\(chapter)").tag(chapter)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            .navigationTitle("Select Book & Chapter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BookPickerView()
}