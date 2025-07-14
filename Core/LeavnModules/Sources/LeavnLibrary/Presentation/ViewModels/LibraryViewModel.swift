import Foundation
import SwiftUI
import Combine
import LeavnCore
import Factory

@MainActor
public final class LibraryViewModel: BaseViewModel<LibraryViewState, LibraryViewEvent> {
    // Dependencies injected through initializer
    private let libraryRepository: LibraryRepositoryProtocol
    private let analyticsService: AnalyticsServiceProtocol
    
    // Use Cases
    private let getLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol
    private let saveContentToLibraryUseCase: SaveContentToLibraryUseCaseProtocol
    private let manageCollectionsUseCase: ManageCollectionsUseCaseProtocol
    private let manageDownloadsUseCase: ManageDownloadsUseCaseProtocol
    private let searchLibraryUseCase: SearchLibraryUseCaseProtocol
    private let getLibraryStatisticsUseCase: GetLibraryStatisticsUseCaseProtocol
    private let syncLibraryUseCase: SyncLibraryUseCaseProtocol
    
    // Tasks for cancellation
    private var loadItemsTask: Task<Void, Never>?
    private var syncTask: Task<Void, Never>?
    private var downloadTask: Task<Void, Never>?
    private var searchTask: Task<Void, Never>?
    
    // Timer for periodic sync
    private var syncTimer: Timer?
    
    public init(
        libraryRepository: LibraryRepositoryProtocol,
        analyticsService: AnalyticsServiceProtocol,
        getLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol,
        saveContentToLibraryUseCase: SaveContentToLibraryUseCaseProtocol,
        manageCollectionsUseCase: ManageCollectionsUseCaseProtocol,
        manageDownloadsUseCase: ManageDownloadsUseCaseProtocol,
        searchLibraryUseCase: SearchLibraryUseCaseProtocol,
        getLibraryStatisticsUseCase: GetLibraryStatisticsUseCaseProtocol,
        syncLibraryUseCase: SyncLibraryUseCaseProtocol,
        initialState: LibraryViewState = .init()
    ) {
        self.libraryRepository = libraryRepository
        self.analyticsService = analyticsService
        self.getLibraryItemsUseCase = getLibraryItemsUseCase
        self.saveContentToLibraryUseCase = saveContentToLibraryUseCase
        self.manageCollectionsUseCase = manageCollectionsUseCase
        self.manageDownloadsUseCase = manageDownloadsUseCase
        self.searchLibraryUseCase = searchLibraryUseCase
        self.getLibraryStatisticsUseCase = getLibraryStatisticsUseCase
        self.syncLibraryUseCase = syncLibraryUseCase
        
        super.init(initialState: initialState)
        
        setupPeriodicSync()
    }
    
    deinit {
        syncTimer?.invalidate()
        loadItemsTask?.cancel()
        syncTask?.cancel()
        downloadTask?.cancel()
        searchTask?.cancel()
    }
    
    // MARK: - Event Handling
    
    public override func handle(event: LibraryViewEvent) {
        switch event {
        case .loadItems:
            loadItems()
        case .loadCollections:
            loadCollections()
        case .searchItems(let query):
            searchItems(query: query)
        case .filterItems(let filter):
            filterItems(filter: filter)
        case .selectItem(let id):
            selectItem(id: id)
        case .selectCollection(let id):
            selectCollection(id: id)
        case .deleteItem(let id):
            deleteItem(id: id)
        case .deleteCollection(let id):
            deleteCollection(id: id)
        case .downloadItem(let id):
            downloadItem(id: id)
        case .cancelDownload(let id):
            cancelDownload(id: id)
        case .syncLibrary:
            syncLibrary()
        case .refreshStatistics:
            refreshStatistics()
        case .createCollection(let name, let description):
            createCollection(name: name, description: description)
        case .addItemsToCollection(let collectionId, let itemIds):
            addItemsToCollection(collectionId: collectionId, itemIds: itemIds)
        case .removeItemsFromCollection(let collectionId, let itemIds):
            removeItemsFromCollection(collectionId: collectionId, itemIds: itemIds)
        }
    }
    
    // MARK: - Private Methods
    
    private func loadItems() {
        loadItemsTask?.cancel()
        loadItemsTask = Task {
            await updateState { state in
                state.isLoading = true
                state.error = nil
            }
            
            do {
                let items = try await getLibraryItemsUseCase.execute(filter: currentState.selectedFilter)
                await updateState { state in
                    state.items = items
                    state.isLoading = false
                }
                
                analyticsService.track(event: "library_items_loaded", properties: [
                    "count": items.count,
                    "filter": currentState.selectedFilter
                ])
            } catch {
                await updateState { state in
                    state.error = error
                    state.isLoading = false
                }
                
                analyticsService.trackError(error, properties: [
                    "action": "load_library_items"
                ])
            }
        }
    }
    
    private func loadCollections() {
        Task {
            do {
                let collections = try await libraryRepository.getCollections()
                await updateState { state in
                    state.collections = collections
                }
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func searchItems(query: String) {
        searchTask?.cancel()
        
        await updateState { state in
            state.searchQuery = query
        }
        
        guard !query.isEmpty else {
            loadItems()
            return
        }
        
        searchTask = Task {
            do {
                let items = try await searchLibraryUseCase.execute(
                    query: query,
                    filter: currentState.selectedFilter
                )
                await updateState { state in
                    state.items = items
                }
                
                analyticsService.track(event: "library_search", properties: [
                    "query": query,
                    "results_count": items.count
                ])
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func filterItems(filter: LibraryFilter) {
        Task {
            await updateState { state in
                state.selectedFilter = filter
            }
            loadItems()
        }
    }
    
    private func selectItem(id: String) {
        Task {
            await updateState { state in
                state.selectedItemId = id
            }
            
            analyticsService.track(event: "library_item_selected", properties: [
                "item_id": id
            ])
        }
    }
    
    private func selectCollection(id: String) {
        Task {
            await updateState { state in
                state.selectedCollectionId = id
            }
        }
    }
    
    private func deleteItem(id: String) {
        Task {
            do {
                try await libraryRepository.deleteItem(id: id)
                await updateState { state in
                    state.items.removeAll { $0.id == id }
                }
                
                analyticsService.track(event: "library_item_deleted", properties: [
                    "item_id": id
                ])
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func deleteCollection(id: String) {
        Task {
            do {
                try await libraryRepository.deleteCollection(id: id)
                await updateState { state in
                    state.collections.removeAll { $0.id == id }
                }
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func downloadItem(id: String) {
        downloadTask = Task {
            do {
                let url = try await manageDownloadsUseCase.downloadItem(id: id)
                
                await updateState { state in
                    if let index = state.items.firstIndex(where: { $0.id == id }) {
                        var item = state.items[index]
                        // Update item download status
                        state.items[index] = item
                    }
                }
                
                analyticsService.track(event: "library_item_downloaded", properties: [
                    "item_id": id,
                    "url": url.absoluteString
                ])
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func cancelDownload(id: String) {
        Task {
            do {
                try await manageDownloadsUseCase.cancelDownload(id: id)
                await updateState { state in
                    state.downloadProgress.removeValue(forKey: id)
                }
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func syncLibrary() {
        syncTask?.cancel()
        syncTask = Task {
            await updateState { state in
                state.isSyncing = true
            }
            
            do {
                try await syncLibraryUseCase.execute()
                await loadItems()
                await loadCollections()
                await refreshStatistics()
                
                await updateState { state in
                    state.isSyncing = false
                }
                
                analyticsService.track(event: "library_synced", properties: nil)
            } catch {
                await updateState { state in
                    state.isSyncing = false
                    state.error = error
                }
            }
        }
    }
    
    private func refreshStatistics() {
        Task {
            do {
                let statistics = try await getLibraryStatisticsUseCase.execute()
                await updateState { state in
                    state.statistics = statistics
                }
            } catch {
                // Ignore statistics errors
            }
        }
    }
    
    private func createCollection(name: String, description: String) {
        Task {
            do {
                let collection = LibraryCollection(
                    name: name,
                    description: description
                )
                try await manageCollectionsUseCase.createCollection(collection)
                await loadCollections()
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func addItemsToCollection(collectionId: String, itemIds: [String]) {
        Task {
            do {
                try await manageCollectionsUseCase.addItemsToCollection(
                    collectionId: collectionId,
                    itemIds: itemIds
                )
                await loadCollections()
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func removeItemsFromCollection(collectionId: String, itemIds: [String]) {
        Task {
            do {
                try await manageCollectionsUseCase.removeItemsFromCollection(
                    collectionId: collectionId,
                    itemIds: itemIds
                )
                await loadCollections()
            } catch {
                await updateState { state in
                    state.error = error
                }
            }
        }
    }
    
    private func setupPeriodicSync() {
        syncTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            Task { @MainActor in
                self.syncLibrary()
            }
        }
    }
}