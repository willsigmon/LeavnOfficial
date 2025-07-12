import XCTest
@testable import LeavnOfficial

final class SaveLibraryItemUseCaseTests: XCTestCase {
    private var sut: SaveLibraryItemUseCase!
    private var mockRepository: MockLibraryRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockLibraryRepository()
        sut = SaveLibraryItemUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecute_CallsRepositorySaveItem() async throws {
        // Given
        let item = LibraryItem.mock()
        
        // When
        try await sut.execute(item: item)
        
        // Then
        XCTAssertTrue(mockRepository.saveItemCalled)
        XCTAssertEqual(mockRepository.lastSavedItem, item)
    }
    
    func testExecute_RepositoryThrows_PropagatesError() async {
        // Given
        let item = LibraryItem.mock()
        mockRepository.errorToThrow = TestError.mock
        
        // When/Then
        do {
            try await sut.execute(item: item)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .mock)
            XCTAssertTrue(mockRepository.saveItemCalled)
        }
    }
    
    func testExecute_ItemIsSavedToRepository() async throws {
        // Given
        let item = LibraryItem.mock(title: "New Bookmark")
        XCTAssertTrue(mockRepository.itemsToReturn.isEmpty)
        
        // When
        try await sut.execute(item: item)
        
        // Then
        XCTAssertEqual(mockRepository.itemsToReturn.count, 1)
        XCTAssertEqual(mockRepository.itemsToReturn.first?.title, "New Bookmark")
    }
}