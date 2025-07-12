import SwiftUI
import Combine

@MainActor
public final class LibraryViewModel: ObservableObject {
    @Published private(set) var state = LibraryState()
    
    private let getItemsUseCase: GetLibraryItemsUseCaseProtocol
    private let saveItemUseCase: SaveLibraryItemUseCaseProtocol
    private let coordinator: LibraryCoordinator
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        getItemsUseCase: GetLibraryItemsUseCaseProtocol,
        saveItemUseCase: SaveLibraryItemUseCaseProtocol,
        coordinator: LibraryCoordinator
    ) {
        self.getItemsUseCase = getItemsUseCase
        self.saveItemUseCase = saveItemUseCase
        self.coordinator = coordinator
        
        setupBindings()
    }
    
    private func setupBindings() {
        // React to search query changes
        $state
            .map(\.searchQuery)
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] query in
                self?.performSearch(query)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Actions
    
    public func loadItems() async {
        state.isLoading = true
        state.error = nil
        
        do {
            let items = try await getItemsUseCase.execute()
            state.items = items
            state.isLoading = false
        } catch {
            state.error = error
            state.isLoading = false
        }
    }
    
    public func loadItems(ofType type: LibraryItemType) async {
        state.isLoading = true
        state.error = nil
        state.selectedType = type
        
        do {
            let items = try await getItemsUseCase.execute(ofType: type)
            state.items = items
            state.isLoading = false
        } catch {
            state.error = error
            state.isLoading = false
        }
    }
    
    public func selectType(_ type: LibraryItemType?) {
        state.selectedType = type
    }
    
    public func updateSearchQuery(_ query: String) {
        state.searchQuery = query
    }
    
    public func selectItem(_ item: LibraryItem) {
        coordinator.navigateToItem(item)
    }
    
    public func addNewItem(ofType type: LibraryItemType) {
        coordinator.presentAddItem(ofType: type)
    }
    
    public func editItem(_ item: LibraryItem) {
        coordinator.presentEditItem(item)
    }
    
    public func saveItem(_ item: LibraryItem) async {
        do {
            try await saveItemUseCase.execute(item: item)
            await loadItems() // Reload to get updated list
        } catch {
            state.error = error
        }
    }
    
    // MARK: - Private Methods
    
    private func performSearch(_ query: String) {
        guard !query.isEmpty else {
            state.filteredItems = []
            return
        }
        
        state.filteredItems = state.items.filter { item in
            item.title.localizedCaseInsensitiveContains(query) ||
            (item.content?.localizedCaseInsensitiveContains(query) ?? false) ||
            item.tags.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }
}