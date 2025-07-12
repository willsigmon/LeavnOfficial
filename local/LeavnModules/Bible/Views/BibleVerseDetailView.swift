import SwiftUI

struct BibleVerseDetailView: View {
    let book: String
    let chapter: Int
    let verse: Int
    
    var body: some View {
        VStack {
            Text("\(book) \(chapter):\(verse)")
                .font(.largeTitle)
            
            Text("Verse detail view - Coming soon")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}