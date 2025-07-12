import Foundation

public struct LibraryState: Equatable {
    public var items: [LibraryItem] = []
    public var filteredItems: [LibraryItem] = []
    public var selectedType: LibraryItemType?
    public var searchQuery: String = ""
    public var isLoading: Bool = false
    public var error: Error?
    
    public static func == (lhs: LibraryState, rhs: LibraryState) -> Bool {
        lhs.items == rhs.items &&
        lhs.filteredItems == rhs.filteredItems &&
        lhs.selectedType == rhs.selectedType &&
        lhs.searchQuery == rhs.searchQuery &&
        lhs.isLoading == rhs.isLoading &&
        (lhs.error == nil && rhs.error == nil || lhs.error != nil && rhs.error != nil)
    }
    
    public var displayedItems: [LibraryItem] {
        let baseItems = searchQuery.isEmpty ? items : filteredItems
        
        if let selectedType = selectedType {
            return baseItems.filter { $0.type == selectedType }
        }
        
        return baseItems
    }
    
    public var itemsByType: [LibraryItemType: [LibraryItem]] {
        Dictionary(grouping: items, by: { $0.type })
    }
}