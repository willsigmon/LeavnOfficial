import Foundation
import SwiftUI
import Combine

// import Factory - Removed external dependency

@MainActor
public final class LifeSituationsViewModel: StatefulViewModel<LifeSituationsViewState, LifeSituationsViewEvent> {
    // TODO: Restore when Factory is available
    // @Injected(\.networkService) private var networkService
    // @Injected(\.analyticsService) private var analyticsService
    // @Injected(\.userDefaultsStorage) private var localStorage
    // @Injected(\.cacheStorage) private var cacheStorage
    
    private let repository: LifeSituationRepository
    private let getLifeSituationsUseCase: GetLifeSituationsUseCase
    
    public override init(initialState: LifeSituationsViewState = .init()) {
        // TODO: Restore when Factory is available
        self.repository = MockLifeSituationRepository()
        self.getLifeSituationsUseCase = MockGetLifeSituationsUseCase()
        
        super.init(initialState: initialState)
    }
    
    public override func send(_ event: LifeSituationsViewEvent) {
        Task {
            await handle(event)
        }
    }
    
    private func handle(_ event: LifeSituationsViewEvent) async {
        switch event {
        case .loadSituations:
            await loadSituations()
            
        case .selectCategory(let category):
            await updateState { $0.selectedCategory = category }
            await loadSituations()
            
        case .search(let query):
            await updateState { $0.searchQuery = query }
            await performSearch(query: query)
            
        case .selectSituation(let situation):
            await markAsViewed(situation)
            updateState { $0.selectedSituation = situation }
            
        case .toggleFavorite(let situation):
            await toggleFavorite(situation)
            
        case .loadRecentlyViewed:
            await loadRecentlyViewed()
            
        case .loadFavorites:
            await loadFavorites()
        }
    }
    
    private func loadSituations() async {
        await updateState { $0.isLoading = true }
        
        do {
            let input = GetLifeSituationsInput(
                category: state.selectedCategory,
                searchQuery: nil,
                sortBy: .relevance
            )
            let situations = try await getLifeSituationsUseCase.execute(input)
            
            updateState {
                $0.situations = situations
                $0.isLoading = false
                $0.error = nil
            }
            
            // TODO: Track analytics when service is available
            // analyticsService.track(event: LifeSituationAnalyticsEvent.listViewed(
            //     category: state.selectedCategory?.rawValue
            // ))
        } catch {
            await updateState {
                $0.isLoading = false
                $0.error = error
            }
        }
    }
    
    private func performSearch(query: String) async {
        guard !query.isEmpty else {
            await loadSituations()
            return
        }
        
        await updateState { $0.isSearching = true }
        
        do {
            let results = try await repository.searchLifeSituations(query: query)
            updateState {
                $0.searchResults = results
                $0.isSearching = false
                $0.error = nil
            }
            
            // TODO: Track analytics when service is available
            // analyticsService.track(event: CommonAnalyticsEvent.search(
            //     query: query,
            //     category: "life_situations"
            // ))
        } catch {
            await updateState {
                $0.isSearching = false
                $0.error = error
            }
        }
    }
    
    private func markAsViewed(_ situation: LifeSituation) async {
        do {
            try await repository.markAsViewed(situation)
            
            // TODO: Track analytics when service is available
            // analyticsService.track(event: LifeSituationAnalyticsEvent.situationViewed(
            //     situationId: situation.id,
            //     title: situation.title,
            //     category: situation.category.rawValue
            // ))
        } catch {
            // Silently fail for analytics
            print("Failed to mark as viewed: \\(error)")
        }
    }
    
    private func toggleFavorite(_ situation: LifeSituation) async {
        do {
            try await repository.toggleFavorite(situation)
            
            // Update local state
            if state.favoriteSituations.contains(where: { $0.id == situation.id }) {
                updateState {
                    $0.favoriteSituations.removeAll { $0.id == situation.id }
                }
            } else {
                updateState {
                    $0.favoriteSituations.append(situation)
                }
            }
            
            // TODO: Track analytics when service is available
            // analyticsService.track(event: LifeSituationAnalyticsEvent.situationFavorited(
            //     situationId: situation.id,
            //     title: situation.title
            // ))
        } catch {
            await updateState { $0.error = error }
        }
    }
    
    private func loadRecentlyViewed() async {
        do {
            let recent = try await repository.getRecentlyViewed()
            updateState { $0.recentlyViewed = recent }
        } catch {
            // Silently fail
            print("Failed to load recently viewed: \\(error)")
        }
    }
    
    private func loadFavorites() async {
        do {
            let favorites = try await repository.getFavorites()
            updateState { $0.favoriteSituations = favorites }
        } catch {
            // Silently fail
            print("Failed to load favorites: \\(error)")
        }
    }
}

// MARK: - View State
public struct LifeSituationsViewState: ViewState {
    public var situations: [LifeSituation] = []
    public var searchResults: [LifeSituation] = []
    public var recentlyViewed: [LifeSituation] = []
    public var favoriteSituations: [LifeSituation] = []
    public var selectedCategory: LifeSituationCategory?
    public var selectedSituation: LifeSituation?
    public var searchQuery: String = ""
    public var isLoading: Bool = false
    public var isSearching: Bool = false
    public var error: Error?
    
    public init() {}
}

// MARK: - View Events
public enum LifeSituationsViewEvent {
    case loadSituations
    case selectCategory(LifeSituationCategory?)
    case search(query: String)
    case selectSituation(LifeSituation)
    case toggleFavorite(LifeSituation)
    case loadRecentlyViewed
    case loadFavorites
}

// MARK: - Analytics Events
enum LifeSituationAnalyticsEvent: AnalyticsEvent {
    case listViewed(category: String?)
    case situationViewed(situationId: String, title: String, category: String)
    case situationFavorited(situationId: String, title: String)
    case resourceOpened(situationId: String, resourceType: String)
    
    var name: String {
        switch self {
        case .listViewed: return "life_situations_list_viewed"
        case .situationViewed: return "life_situation_viewed"
        case .situationFavorited: return "life_situation_favorited"
        case .resourceOpened: return "life_situation_resource_opened"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .listViewed(let category):
            var params: [String: Any] = [:]
            if let category = category {
                params["category"] = category
            }
            return params
            
        case .situationViewed(let id, let title, let category):
            return [
                "situation_id": id,
                "title": title,
                "category": category
            ]
            
        case .situationFavorited(let id, let title):
            return [
                "situation_id": id,
                "title": title
            ]
            
        case .resourceOpened(let id, let type):
            return [
                "situation_id": id,
                "resource_type": type
            ]
        }
    }
}
