import Foundation

// MARK: - Reading Progress & Statistics Extensions

extension BibleViewModel {
    
    func loadUserReadingProgress() {
        if let bookName = userDataManager.getCurrentBook(),
           let chapter = userDataManager.getCurrentChapter() {
            selectedBook = bookName
            selectedChapter = chapter
            print("Restored reading progress: \(bookName) \(chapter)")
        }
    }
    
    func trackChapterChange() {
        userDataManager.setCurrentBook(selectedBook)
        userDataManager.setCurrentChapter(selectedChapter)
        userDataManager.setCurrentTranslation(selectedTranslation)
        
        analyticsService.track(event: "chapter_changed", properties: [
            "book": selectedBook,
            "chapter": selectedChapter,
            "translation": selectedTranslation
        ])
    }
    
    func trackBookChange() {
        userDataManager.setCurrentBook(selectedBook)
        userDataManager.setCurrentChapter(selectedChapter)
        userDataManager.setCurrentTranslation(selectedTranslation)
        
        analyticsService.track(event: "book_changed", properties: [
            "book": selectedBook,
            "chapter": selectedChapter,
            "translation": selectedTranslation
        ])
    }
    
    func trackVerseInteraction(verse: BibleVerse) {
        userDataManager.setCurrentBook(selectedBook)
        userDataManager.setCurrentChapter(verse.chapter)
        userDataManager.setCurrentTranslation(selectedTranslation)
        
        analyticsService.track(event: "verse_interaction", properties: [
            "reference": verse.reference,
            "book": selectedBook,
            "chapter": verse.chapter,
            "verse": verse.verse,
            "translation": selectedTranslation
        ])
    }
    
    func startReadingSession() {
        trackChapterChange()
        
        analyticsService.track(event: "reading_session_started", properties: [
            "book": selectedBook,
            "chapter": selectedChapter,
            "translation": selectedTranslation
        ])
    }
    
    func endReadingSession() {
        analyticsService.track(event: "reading_session_ended", properties: [
            "book": selectedBook,
            "chapter": selectedChapter,
            "translation": selectedTranslation
        ])
    }
} 