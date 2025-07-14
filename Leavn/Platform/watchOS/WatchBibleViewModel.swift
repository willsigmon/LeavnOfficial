import Foundation
import SwiftUI

class WatchBibleViewModel: ObservableObject {
    @Published var currentBook = "John"
    @Published var currentChapter = 3
    @Published var verses: [String] = []
    @Published var isLoading = false
    @Published var isBookmarked = false
    @Published var showBookPicker = false
    
    init() {
        loadChapter()
    }
    
    func loadChapter() {
        isLoading = true
        
        // Simulate loading verses
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.verses = [
                "16 For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                "17 For God did not send his Son into the world to condemn the world, but to save the world through him.",
                "18 Whoever believes in him is not condemned, but whoever does not believe stands condemned already because they have not believed in the name of God's one and only Son."
            ]
            self.isLoading = false
        }
    }
    
    func toggleBookmark() {
        isBookmarked.toggle()
    }
    
    func nextChapter() {
        currentChapter += 1
        loadChapter()
    }
    
    func previousChapter() {
        if currentChapter > 1 {
            currentChapter -= 1
            loadChapter()
        }
    }
}