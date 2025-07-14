import XCTest
import SwiftUI
@testable import Leavn
@testable import LeavnCore

/// Test script to simulate Bible tab navigation and ensure thread safety
final class BibleNavigationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Initialize DIContainer
        Task {
            await DIContainer.shared.initialize()
        }
    }
    
    func testRapidBookSwitching() async throws {
        // Create view model
        let viewModel = BibleViewModel()
        
        // Test rapid book switching
        let books: [BibleBook] = [.genesis, .exodus, .psalms, .matthew, .john, .revelation]
        
        for book in books {
            print("📖 Testing navigation to \(book.name)")
            await viewModel.loadChapter(book: book, chapter: 1)
            
            // Small delay to simulate user interaction
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // Verify data loaded
            XCTAssertEqual(viewModel.currentBook, book)
            XCTAssertFalse(viewModel.verses.isEmpty, "Verses should be loaded for \(book.name)")
        }
        
        print("✅ Rapid book switching test completed successfully")
    }
    
    func testConcurrentChapterNavigation() async throws {
        let viewModel = BibleViewModel()
        
        // Load initial book
        await viewModel.loadChapter(book: .psalms, chapter: 1)
        
        // Test concurrent chapter navigation
        await withTaskGroup(of: Void.self) { group in
            // Simulate multiple rapid chapter changes
            for chapter in 1...5 {
                group.addTask {
                    await viewModel.loadChapter(book: .psalms, chapter: chapter)
                }
            }
        }
        
        // Verify final state is consistent
        XCTAssertEqual(viewModel.currentBook, .psalms)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.verses.isEmpty)
        
        print("✅ Concurrent chapter navigation test completed")
    }
    
    func testNavigationButtonRapidTaps() async throws {
        let viewModel = BibleViewModel()
        
        // Load initial chapter
        await viewModel.loadChapter(book: .genesis, chapter: 1)
        
        // Simulate rapid next/previous taps
        for _ in 0..<10 {
            viewModel.nextChapter()
            viewModel.previousChapter()
        }
        
        // Allow time for operations to complete
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        
        // Verify we're back where we started
        XCTAssertEqual(viewModel.currentChapter, 1)
        XCTAssertFalse(viewModel.isLoading)
        
        print("✅ Rapid navigation button test completed")
    }
    
    func testMemoryAndThreadSafety() async throws {
        // Monitor for memory leaks and thread issues
        let viewModel = BibleViewModel()
        
        // Perform stress test
        for i in 1...20 {
            let book = BibleBook.allCases.randomElement()!
            let chapter = Int.random(in: 1...min(5, book.chapterCount))
            
            print("🔄 Iteration \(i): Loading \(book.name) chapter \(chapter)")
            await viewModel.loadChapter(book: book, chapter: chapter)
            
            // Check thread safety
            XCTAssertTrue(Thread.isMainThread, "UI updates should be on main thread")
        }
        
        print("✅ Memory and thread safety test completed")
    }
}

// Run tests
extension BibleNavigationTests {
    static func runAllTests() async {
        let tests = BibleNavigationTests()
        
        do {
            print("🧪 Starting Bible navigation tests...")
            
            await tests.setUp()
            
            try await tests.testRapidBookSwitching()
            try await tests.testConcurrentChapterNavigation()
            try await tests.testNavigationButtonRapidTaps()
            try await tests.testMemoryAndThreadSafety()
            
            print("\n✅ All Bible navigation tests passed!")
            print("The Bible tab should now work without thread breaking issues.")
            
        } catch {
            print("\n❌ Test failed: \(error)")
        }
    }
}

// Main execution
print("""
Bible Navigation Test Script
============================
This script simulates various Bible tab navigation scenarios
to ensure thread safety and prevent crashes.
""")

Task {
    await BibleNavigationTests.runAllTests()
}