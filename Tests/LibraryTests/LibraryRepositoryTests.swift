import XCTest
@testable import LeavnOfficial

final class LibraryRepositoryTests: XCTestCase {
    private var sut: LibraryRepository!
    private var mockRemoteDataSource: MockLibraryRemoteDataSource!
    private var mockLocalDataSource: MockLibraryLocalDataSource!
    
    override func setUp() {
        super.setUp()
        mockRemoteDataSource = MockLibraryRemoteDataSource()
        mockLocalDataSource = MockLibraryLocalDataSource()
        sut = LibraryRepository(
            remoteDataSource: mockRemoteDataSource,
            localDataSource: mockLocalDataSource
        )
    }
    
    override func tearDown() {
        sut = nil
        mockRemoteDataSource = nil
        mockLocalDataSource = nil
        super.tearDown()
    }
    
    // MARK: - Fetch All Items Tests
    
    func testFetchAllItems_RemoteSuccess_ReturnsRemoteData() async throws {
        // Given
        let remoteItems = [LibraryItem.mock(title: "Remote Item")]
        mockRemoteDataSource.itemsToReturn = remoteItems
        
        // When
        let result = try await sut.fetchAllItems()
        
        // Then
        XCTAssertEqual(result, remoteItems)
        XCTAssertTrue(mockRemoteDataSource.fetchAllItemsCalled)
        XCTAssertTrue(mockLocalDataSource.saveItemCalled) // Items cached locally
    }
    
    func testFetchAllItems_RemoteFailure_FallsBackToLocal() async throws {
        // Given
        let localItems = [LibraryItem.mock(title: "Local Item")]
        mockRemoteDataSource.errorToThrow = TestError.mock
        mockLocalDataSource.itemsToReturn = localItems
        
        // When
        let result = try await sut.fetchAllItems()
        
        // Then
        XCTAssertEqual(result, localItems)
        XCTAssertTrue(mockRemoteDataSource.fetchAllItemsCalled)
        XCTAssertTrue(mockLocalDataSource.fetchAllItemsCalled)
    }
    
    // MARK: - Save Item Tests
    
    func testSaveItem_SavesToBothDataSources() async throws {
        // Given
        let item = LibraryItem.mock()
        
        // When
        try await sut.saveItem(item)
        
        // Then
        XCTAssertTrue(mockLocalDataSource.saveItemCalled)
        XCTAssertTrue(mockRemoteDataSource.saveItemCalled)
        XCTAssertEqual(mockLocalDataSource.lastSavedItem, item)
        XCTAssertEqual(mockRemoteDataSource.lastSavedItem, item)
    }
    
    func testSaveItem_LocalSuccessRemoteFailure_ThrowsError() async {
        // Given
        let item = LibraryItem.mock()
        mockRemoteDataSource.errorToThrow = TestError.mock
        
        // When/Then
        do {
            try await sut.saveItem(item)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(mockLocalDataSource.saveItemCalled) // Local save happens first
            XCTAssertTrue(mockRemoteDataSource.saveItemCalled)
        }
    }
    
    // MARK: - Search Tests
    
    func testSearchItems_RemoteSuccess_ReturnsRemoteResults() async throws {
        // Given
        let searchResults = [LibraryItem.mock(title: "Search Result")]
        mockRemoteDataSource.searchResultsToReturn = searchResults
        
        // When
        let result = try await sut.searchItems(query: "test")
        
        // Then
        XCTAssertEqual(result, searchResults)
        XCTAssertEqual(mockRemoteDataSource.lastSearchQuery, "test")
    }
    
    func testSearchItems_RemoteFailure_FallsBackToLocal() async throws {
        // Given
        let localResults = [LibraryItem.mock(title: "Local Result")]
        mockRemoteDataSource.errorToThrow = TestError.mock
        mockLocalDataSource.searchResultsToReturn = localResults
        
        // When
        let result = try await sut.searchItems(query: "test")
        
        // Then
        XCTAssertEqual(result, localResults)
        XCTAssertEqual(mockLocalDataSource.lastSearchQuery, "test")
    }
}

// MARK: - Mock Data Sources

final class MockLibraryRemoteDataSource: LibraryRemoteDataSourceProtocol {
    var fetchAllItemsCalled = false
    var saveItemCalled = false
    var itemsToReturn: [LibraryItem] = []
    var searchResultsToReturn: [LibraryItem] = []
    var errorToThrow: Error?
    var lastSavedItem: LibraryItem?
    var lastSearchQuery: String?
    
    func fetchAllItems() async throws -> [LibraryItem] {
        fetchAllItemsCalled = true
        if let error = errorToThrow { throw error }
        return itemsToReturn
    }
    
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.type == type }
    }
    
    func fetchItem(withId id: UUID) async throws -> LibraryItem? {
        if let error = errorToThrow { throw error }
        return itemsToReturn.first { $0.id == id }
    }
    
    func saveItem(_ item: LibraryItem) async throws {
        saveItemCalled = true
        lastSavedItem = item
        if let error = errorToThrow { throw error }
    }
    
    func updateItem(_ item: LibraryItem) async throws {
        if let error = errorToThrow { throw error }
    }
    
    func deleteItem(withId id: UUID) async throws {
        if let error = errorToThrow { throw error }
    }
    
    func searchItems(query: String) async throws -> [LibraryItem] {
        lastSearchQuery = query
        if let error = errorToThrow { throw error }
        return searchResultsToReturn
    }
    
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.tags.contains(tag) }
    }
}

final class MockLibraryLocalDataSource: LibraryLocalDataSourceProtocol {
    var fetchAllItemsCalled = false
    var saveItemCalled = false
    var itemsToReturn: [LibraryItem] = []
    var searchResultsToReturn: [LibraryItem] = []
    var errorToThrow: Error?
    var lastSavedItem: LibraryItem?
    var lastSearchQuery: String?
    
    func fetchAllItems() async throws -> [LibraryItem] {
        fetchAllItemsCalled = true
        if let error = errorToThrow { throw error }
        return itemsToReturn
    }
    
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.type == type }
    }
    
    func fetchItem(withId id: UUID) async throws -> LibraryItem? {
        if let error = errorToThrow { throw error }
        return itemsToReturn.first { $0.id == id }
    }
    
    func saveItem(_ item: LibraryItem) async throws {
        saveItemCalled = true
        lastSavedItem = item
        if let error = errorToThrow { throw error }
    }
    
    func updateItem(_ item: LibraryItem) async throws {
        if let error = errorToThrow { throw error }
    }
    
    func deleteItem(withId id: UUID) async throws {
        if let error = errorToThrow { throw error }
    }
    
    func searchItems(query: String) async throws -> [LibraryItem] {
        lastSearchQuery = query
        if let error = errorToThrow { throw error }
        return searchResultsToReturn
    }
    
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.tags.contains(tag) }
    }
}