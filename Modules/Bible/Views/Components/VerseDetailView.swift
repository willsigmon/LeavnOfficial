import SwiftUI

struct VerseDetailView: View {
    let verse: BibleVerse
    @State private var showingShareCard = false
    @State private var showingCopyAlert = false
    @State private var isBookmarked = false
    @StateObject private var libraryViewModel = LibraryViewModel()
    
    var body: some View {
        BibleVerseCard(
            verse: verse,
            isBookmarked: isBookmarked,
            onBookmark: toggleBookmark,
            onShare: { showingShareCard = true },
            onNote: { /* TODO: Add note functionality */ }
        )
        .sheet(isPresented: $showingShareCard) {
            ShareableVerseCardView(verse: verse)
        }
        .alert("Copied!", isPresented: $showingCopyAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Verse copied to clipboard")
        }
        .task {
            await checkIfBookmarked()
        }
    }
    
    // MARK: - Actions
    
    private func copyVerse() {
        let verseText = "\"\(verse.text)\"\n\n- \(verse.reference) (\(verse.translation))"
        UIPasteboard.general.string = verseText
        showingCopyAlert = true
    }
    
    private func toggleBookmark() {
        Task {
            if isBookmarked {
                // Remove from favorites
                if let favoriteItem = libraryViewModel.libraryItems.first(where: { 
                    $0.type == .favorite && $0.reference == verse.reference 
                }) {
                    await libraryViewModel.deleteItem(favoriteItem)
                }
            } else {
                // Add to favorites
                await libraryViewModel.addFavorite(verse: verse)
            }
            isBookmarked.toggle()
        }
    }
    
    private func checkIfBookmarked() async {
        await libraryViewModel.loadLibraryData()
        isBookmarked = libraryViewModel.libraryItems.contains { 
            $0.type == .favorite && $0.reference == verse.reference 
        }
    }
}

#Preview {
    VerseDetailView(
        verse: BibleVerse(
            id: "gen-1-1",
            bookId: "genesis",
            bookName: "Genesis",
            chapter: 1,
            verse: 1,
            text: "In the beginning God created the heavens and the earth.",
            translation: "ESV"
        )
    )
}