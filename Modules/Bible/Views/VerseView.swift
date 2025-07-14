import SwiftUI

struct VerseView: View {
    let verseNumber: Int
    let verseText: String
    let isHighlighted: Bool
    
    init(verseNumber: Int = 1, 
         verseText: String = "In the beginning God created the heavens and the earth.",
         isHighlighted: Bool = false) {
        self.verseNumber = verseNumber
        self.verseText = verseText
        self.isHighlighted = isHighlighted
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("\(verseNumber)")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(minWidth: 20, alignment: .trailing)
            
            Text(verseText)
                .font(.body)
                .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
                .onTapGesture {
                    // Handle verse tap
                }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

#Preview {
    VStack {
        VerseView(verseNumber: 1, verseText: "In the beginning God created the heavens and the earth.")
        VerseView(verseNumber: 2, verseText: "Now the earth was formless and empty, darkness was over the surface of the deep, and the Spirit of God was hovering over the waters.", isHighlighted: true)
    }
}