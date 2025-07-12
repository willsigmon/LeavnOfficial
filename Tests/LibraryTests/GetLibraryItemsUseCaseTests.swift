import XCTest
@testable import LeavnOfficial

final class GetLibraryItemsUseCaseTests: XCTestCase {
    private var sut: GetLibraryItemsUseCase!
    private var mockRepository: MockLibraryRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockLibraryRepository()
        sut = GetLibraryItemsUseCase(repository: mockRepository)
    }
    
    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }
    
    func testExecute_CallsRepository() async throws {
        // Given
        let expectedItems = [
            LibraryItem.mock(),
            LibraryItem.mock()
        ]
        mockRepository.itemsToReturn = expectedItems
        
        // When
        let result = try await sut.execute()
        
        // Then
        XCTAssertTrue(mockRepository.fetchAllItemsCalled)
        XCTAssertEqual(result, expectedItems)
    }
    
    func testExecute_RepositoryThrows_PropagatesError() async {
        // Given
        mockRepository.errorToThrow = TestError.mock
        
        // When/Then
        do {
            _ = try await sut.execute()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? TestError, .mock)
        }
    }
    
    func testExecuteWithType_CallsRepositoryWithType() async throws {
        // Given
        let bookmarks = [
            LibraryItem.mock(type: .bookmark),
            LibraryItem.mock(type: .bookmark)
        ]
        let notes = [LibraryItem.mock(type: .note)]
        mockRepository.itemsToReturn = bookmarks + notes
        
        // When
        let result = try await sut.execute(ofType: .bookmark)
        
        // Then
        XCTAssertTrue(mockRepository.fetchItemsOfTypeCalled)
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.type == .bookmark })
    }
}