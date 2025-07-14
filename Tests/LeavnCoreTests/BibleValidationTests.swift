import XCTest
@testable import LeavnCore

final class BibleValidationTests: XCTestCase {
    
    // MARK: - Book Support Tests
    
    func testSupportedBooksCount() {
        // Standard Protestant Bible has 66 books (39 OT + 27 NT)
        XCTAssertEqual(BibleValidation.supportedBooks.count, 66)
    }
    
    func testCommonBooksAreSupported() {
        // Test some common books
        let genesis = BibleBook.genesis
        let matthew = BibleBook.matthew
        let psalms = BibleBook.psalms
        let revelation = BibleBook.revelation
        
        XCTAssertTrue(BibleValidation.isBookSupported(genesis))
        XCTAssertTrue(BibleValidation.isBookSupported(matthew))
        XCTAssertTrue(BibleValidation.isBookSupported(psalms))
        XCTAssertTrue(BibleValidation.isBookSupported(revelation))
    }
    
    func testApocryphalBooksAreNotSupported() {
        // Test Apocryphal books that cause CancellationError
        let apocryphalBooks = BibleBook.allCases.filter { $0.testament == .apocrypha }
        
        for book in apocryphalBooks {
            XCTAssertFalse(BibleValidation.isBookSupported(book), 
                          "\(book.name) should not be supported")
        }
    }
    
    func testSpecificUnsupportedBooks() {
        // Test specific books mentioned in the error
        let unsupportedIds = ["1es", "2es", "man"] // 1 Esdras, 2 Esdras, Prayer of Manasseh
        
        for bookId in unsupportedIds {
            if let book = BibleBook.allCases.first(where: { $0.id == bookId }) {
                XCTAssertFalse(BibleValidation.isBookSupported(book),
                             "\(book.name) (\(bookId)) should not be supported")
            }
        }
    }
    
    // MARK: - Chapter Validation Tests
    
    func testValidChapterRanges() {
        let genesis = BibleBook.genesis
        
        // Valid chapters
        XCTAssertTrue(BibleValidation.isChapterValid(for: genesis, chapter: 1))
        XCTAssertTrue(BibleValidation.isChapterValid(for: genesis, chapter: 25))
        XCTAssertTrue(BibleValidation.isChapterValid(for: genesis, chapter: 50))
        
        // Invalid chapters
        XCTAssertFalse(BibleValidation.isChapterValid(for: genesis, chapter: 0))
        XCTAssertFalse(BibleValidation.isChapterValid(for: genesis, chapter: 51))
        XCTAssertFalse(BibleValidation.isChapterValid(for: genesis, chapter: -1))
    }
    
    func testChapterValidationForUnsupportedBook() {
        // Find an unsupported book
        if let unsupportedBook = BibleBook.allCases.first(where: { $0.testament == .apocrypha }) {
            // Any chapter should be invalid for unsupported books
            XCTAssertFalse(BibleValidation.isChapterValid(for: unsupportedBook, chapter: 1))
        }
    }
    
    // MARK: - Pre-flight Check Tests
    
    func testCanLoadChapterPreflightCheck() {
        let genesis = BibleBook.genesis
        
        // Valid scenarios
        XCTAssertTrue(BibleValidation.canLoadChapter(book: genesis, chapter: 1))
        XCTAssertTrue(BibleValidation.canLoadChapter(book: genesis, chapter: 50))
        
        // Invalid scenarios
        XCTAssertFalse(BibleValidation.canLoadChapter(book: nil, chapter: 1))
        XCTAssertFalse(BibleValidation.canLoadChapter(book: genesis, chapter: 0))
        XCTAssertFalse(BibleValidation.canLoadChapter(book: genesis, chapter: 51))
    }
    
    func testCanLoadChapterForUnsupportedBook() {
        if let esdras = BibleBook.allCases.first(where: { $0.id == "1es" }) {
            // Should return false for any chapter of unsupported book
            XCTAssertFalse(BibleValidation.canLoadChapter(book: esdras, chapter: 1))
        }
    }
    
    // MARK: - Supported Books Filter Tests
    
    func testSupportedBibleBooksFilter() {
        let supportedBooks = BibleValidation.supportedBibleBooks
        
        // Should only contain 66 books
        XCTAssertEqual(supportedBooks.count, 66)
        
        // Should not contain any apocryphal books
        let apocryphalInSupported = supportedBooks.filter { $0.testament == .apocrypha }
        XCTAssertTrue(apocryphalInSupported.isEmpty, 
                     "Supported books should not contain apocryphal books")
    }
    
    // MARK: - Error Message Tests
    
    func testUnsupportedBookErrorMessage() {
        if let esdras = BibleBook.allCases.first(where: { $0.id == "1es" }) {
            let error = BibleError.unsupportedBook(esdras)
            XCTAssertEqual(error.localizedDescription, 
                          "1 Esdras is not available in your current Bible version.")
        }
    }
    
    func testInvalidChapterErrorMessage() {
        let genesis = BibleBook.genesis
        let error = BibleError.invalidChapter(51, genesis)
        XCTAssertEqual(error.localizedDescription, 
                      "Chapter 51 does not exist in Genesis.")
    }
    
    // MARK: - Performance Tests
    
    func testBookValidationPerformance() {
        // Ensure validation is fast enough for UI operations
        measure {
            for book in BibleBook.allCases {
                _ = BibleValidation.isBookSupported(book)
            }
        }
    }
}