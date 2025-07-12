import SwiftUI
import LeavnCore
import LeavnServices

struct VerseView: View {
    let verse: BibleVerse
    let onTap: () -> Void
    
    // MARK: - Properties
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isPressed = false
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Verse number
            Text("\(verse.verse)")
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(Color(.systemGray))
                .frame(width: 24, alignment: .trailing)
                .padding(.top, 4)
            
            // Verse text
            Text(verse.text)
                .font(.system(size: 18, weight: .regular, design: .serif))
                .foregroundColor(textColor)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
        }
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onTapGesture(perform: onTap)
        .onLongPressGesture(minimumDuration: 0.2, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .background(highlightBackground)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view options")
    }
    
    // MARK: - Private Helpers
    
    private var textColor: Color {
        colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.9)
    }
    
    private var highlightBackground: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isPressed ? Color(.systemGray5) : Color.clear)
            .padding(.horizontal, -8)
            .padding(.vertical, -4)
    }
    
    private var accessibilityLabel: String {
        "Verse \(verse.verse): \(verse.text)"
    }
}

// MARK: - Preview

struct VerseView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            VerseView(
                verse: BibleVerse(
                    id: "GEN-1-1",
                    bookName: "Genesis",
                    bookId: "GEN",
                    chapter: 1,
                    verse: 1,
                    text: "In the beginning, God created the heavens and the earth.",
                    translation: "ESV"
                ),
                onTap: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            
            VerseView(
                verse: BibleVerse(
                    id: "JHN-3-16",
                    bookName: "John",
                    bookId: "JHN",
                    chapter: 3,
                    verse: 16,
                    text: "For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.",
                    translation: "KJV",
                    isRedLetter: true
                ),
                onTap: {}
            )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
        }
    }
}