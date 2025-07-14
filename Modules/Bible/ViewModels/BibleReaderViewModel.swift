import Foundation
import SwiftUI

class BibleReaderViewModel: ObservableObject {
    @Published var currentChapter: String = ""
    @Published var currentVerse: Int = 1
    @Published var fontSize: CGFloat = 16
    @Published var isLoading = false
    
    func loadChapter(book: String, chapter: Int) {
        // Load chapter logic
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentChapter = "Chapter \(chapter) content"
            self.isLoading = false
        }
    }
    
    func nextChapter() {
        // Next chapter logic
    }
    
    func previousChapter() {
        // Previous chapter logic
    }
}