import Foundation
@testable import LeavnOfficial

final class MockGetLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol {
    var executeCalled = false
    var executeWithTypeCalled = false
    var itemsToReturn: [LibraryItem] = []
    var errorToThrow: Error?
    var lastRequestedType: LibraryItemType?
    
    func execute() async throws -> [LibraryItem] {
        executeCalled = true
        if let error = errorToThrow { throw error }
        return itemsToReturn
    }
    
    func execute(ofType type: LibraryItemType) async throws -> [LibraryItem] {
        executeWithTypeCalled = true
        lastRequestedType = type
        if let error = errorToThrow { throw error }
        return itemsToReturn.filter { $0.type == type }
    }
}

final class MockSaveLibraryItemUseCase: SaveLibraryItemUseCaseProtocol {
    var executeCalled = false
    var lastSavedItem: LibraryItem?
    var errorToThrow: Error?
    
    func execute(item: LibraryItem) async throws {
        executeCalled = true
        lastSavedItem = item
        if let error = errorToThrow { throw error }
    }
}