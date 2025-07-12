import XCTest
@testable import LeavnOfficial

@MainActor
final class LibraryViewModelTests: XCTestCase {
    private var sut: LibraryViewModel!
    private var mockGetItemsUseCase: MockGetLibraryItemsUseCase!
    private var mockSaveItemUseCase: MockSaveLibraryItemUseCase!
    private var coordinator: LibraryCoordinator!
    
    override func setUp() {
        super.setUp()
        mockGetItemsUseCase = MockGetLibraryItemsUseCase()
        mockSaveItemUseCase = MockSaveLibraryItemUseCase()
        coordinator = LibraryCoordinator()
        
        sut = LibraryViewModel(
            getItemsUseCase: mockGetItemsUseCase,
            saveItemUseCase: mockSaveItemUseCase,
            coordinator: coordinator
        )
    }
    
    override func tearDown() {
        sut = nil
        mockGetItemsUseCase = nil
        mockSaveItemUseCase = nil
        coordinator = nil
        super.tearDown()
    }
    
    // MARK: - Load Items Tests
    
    func testLoadItems_Success_UpdatesState() async {
        // Given
        let expectedItems = [
            LibraryItem.mock(type: .bookmark),
            LibraryItem.mock(type: .note),
            LibraryItem.mock(type: .highlight)
        ]
        mockGetItemsUseCase.itemsToReturn = expectedItems
        
        // When
        await sut.loadItems()
        
        // Then
        XCTAssertEqual(sut.state.items, expectedItems)
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNil(sut.state.error)
        XCTAssertTrue(mockGetItemsUseCase.executeCalled)
    }
    
    func testLoadItems_Failure_SetsError() async {
        // Given
        let expectedError = TestError.mock
        mockGetItemsUseCase.errorToThrow = expectedError
        
        // When
        await sut.loadItems()
        
        // Then
        XCTAssertTrue(sut.state.items.isEmpty)
        XCTAssertFalse(sut.state.isLoading)
        XCTAssertNotNil(sut.state.error)
        XCTAssertTrue(mockGetItemsUseCase.executeCalled)
    }
    
    func testLoadItemsOfType_Success_FiltersCorrectly() async {
        // Given
        let bookmarks = [
            LibraryItem.mock(type: .bookmark),
            LibraryItem.mock(type: .bookmark)
        ]
        let notes = [LibraryItem.mock(type: .note)]
        mockGetItemsUseCase.itemsToReturn = bookmarks + notes
        
        // When
        await sut.loadItems(ofType: .bookmark)
        
        // Then
        XCTAssertEqual(sut.state.selectedType, .bookmark)
        XCTAssertEqual(mockGetItemsUseCase.lastRequestedType, .bookmark)
        XCTAssertTrue(mockGetItemsUseCase.executeWithTypeCalled)
    }
    
    // MARK: - Search Tests
    
    func testUpdateSearchQuery_PerformsSearch() async {
        // Given
        let items = [
            LibraryItem.mock(title: "Genesis Notes"),
            LibraryItem.mock(title: "Exodus Highlights"),
            LibraryItem.mock(title: "Prayer Requests")
        ]
        sut.state.items = items
        
        // When
        sut.updateSearchQuery("genesis")
        
        // Need to wait for debounce
        try? await Task.sleep(nanoseconds: 400_000_000) // 400ms
        
        // Then
        XCTAssertEqual(sut.state.searchQuery, "genesis")
        XCTAssertEqual(sut.state.filteredItems.count, 1)
        XCTAssertEqual(sut.state.filteredItems.first?.title, "Genesis Notes")
    }
    
    func testUpdateSearchQuery_EmptyQuery_ClearsFilteredItems() {
        // Given
        sut.state.filteredItems = [LibraryItem.mock()]
        
        // When
        sut.updateSearchQuery("")
        
        // Then
        XCTAssertTrue(sut.state.filteredItems.isEmpty)
    }
    
    // MARK: - Navigation Tests
    
    func testSelectItem_NavigatesToItem() {
        // Given
        let item = LibraryItem.mock()
        
        // When
        sut.selectItem(item)
        
        // Then
        XCTAssertEqual(coordinator.path.count, 1)
    }
    
    func testAddNewItem_PresentsAddView() {
        // When
        sut.addNewItem(ofType: .note)
        
        // Then
        XCTAssertTrue(coordinator.isAddingItem)
    }
    
    func testEditItem_PresentsEditView() {
        // Given
        let item = LibraryItem.mock()
        
        // When
        sut.editItem(item)
        
        // Then
        XCTAssertEqual(coordinator.editingItem, item)
    }
    
    // MARK: - Save Item Tests
    
    func testSaveItem_Success_ReloadsItems() async {
        // Given
        let newItem = LibraryItem.mock()
        let existingItems = [LibraryItem.mock()]
        mockGetItemsUseCase.itemsToReturn = existingItems + [newItem]
        
        // When
        await sut.saveItem(newItem)
        
        // Then
        XCTAssertTrue(mockSaveItemUseCase.executeCalled)
        XCTAssertEqual(mockSaveItemUseCase.lastSavedItem, newItem)
        XCTAssertTrue(mockGetItemsUseCase.executeCalled) // Reloads after save
        XCTAssertEqual(sut.state.items.count, 2)
    }
    
    func testSaveItem_Failure_SetsError() async {
        // Given
        let item = LibraryItem.mock()
        mockSaveItemUseCase.errorToThrow = TestError.mock
        
        // When
        await sut.saveItem(item)
        
        // Then
        XCTAssertNotNil(sut.state.error)
        XCTAssertTrue(mockSaveItemUseCase.executeCalled)
    }
    
    // MARK: - State Tests
    
    func testDisplayedItems_WithSelectedType_FiltersCorrectly() {
        // Given
        let bookmarks = [LibraryItem.mock(type: .bookmark)]
        let notes = [LibraryItem.mock(type: .note)]
        sut.state.items = bookmarks + notes
        sut.state.selectedType = .bookmark
        
        // Then
        XCTAssertEqual(sut.state.displayedItems.count, 1)
        XCTAssertEqual(sut.state.displayedItems.first?.type, .bookmark)
    }
    
    func testDisplayedItems_WithSearch_UsesFilteredItems() {
        // Given
        let allItems = [LibraryItem.mock(), LibraryItem.mock()]
        let filteredItems = [LibraryItem.mock()]
        sut.state.items = allItems
        sut.state.filteredItems = filteredItems
        sut.state.searchQuery = "test"
        
        // Then
        XCTAssertEqual(sut.state.displayedItems, filteredItems)
    }
    
    func testItemsByType_GroupsCorrectly() {
        // Given
        let bookmarks = [LibraryItem.mock(type: .bookmark)]
        let notes = [LibraryItem.mock(type: .note), LibraryItem.mock(type: .note)]
        sut.state.items = bookmarks + notes
        
        // Then
        let grouped = sut.state.itemsByType
        XCTAssertEqual(grouped[.bookmark]?.count, 1)
        XCTAssertEqual(grouped[.note]?.count, 2)
        XCTAssertNil(grouped[.highlight])
    }
}

// MARK: - Test Helpers

enum TestError: Error {
    case mock
}

extension LibraryItem {
    static func mock(
        id: UUID = UUID(),
        type: LibraryItemType = .bookmark,
        title: String = "Test Item",
        content: String? = "Test content",
        verse: LibraryVerse? = nil,
        tags: [String] = []
    ) -> LibraryItem {
        LibraryItem(
            id: id,
            type: type,
            title: title,
            content: content,
            verse: verse,
            tags: tags
        )
    }
}