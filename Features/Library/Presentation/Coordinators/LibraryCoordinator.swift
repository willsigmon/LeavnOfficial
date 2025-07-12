import SwiftUI

@MainActor
public final class LibraryCoordinator: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var presentedItem: LibraryItem?
    @Published public var isAddingItem = false
    @Published public var editingItem: LibraryItem?
    
    public init() {}
    
    public func navigateToItem(_ item: LibraryItem) {
        path.append(item)
    }
    
    public func presentAddItem(ofType type: LibraryItemType) {
        isAddingItem = true
    }
    
    public func presentEditItem(_ item: LibraryItem) {
        editingItem = item
    }
    
    public func dismissCurrentView() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    public func popToRoot() {
        path.removeLast(path.count)
    }
}