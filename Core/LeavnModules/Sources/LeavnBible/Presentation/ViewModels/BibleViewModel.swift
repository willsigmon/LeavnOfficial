import Foundation
import SwiftUI
import Combine

@MainActor
public final class BibleViewModel: BaseViewModel {
    @Published public var state = BibleViewState()
    
    private let bibleService: BibleServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let localStorage: UserDataManagerProtocol
    
    private let fetchVerseUseCase: FetchVerseUseCase
    private let searchBibleUseCase: SearchBibleUseCase
    private let bibleRepository: BibleRepository
    
    public override init() {
        let container = DIContainer.shared
        self.bibleService = container.bibleService
        self.analyticsService = container.analyticsService
        self.localStorage = container.userDataManager
        
        self.fetchVerseUseCase = FetchVerseUseCase(bibleService: bibleService)
        self.searchBibleUseCase = SearchBibleUseCase(bibleService: bibleService)
        self.bibleRepository = DefaultBibleRepository(
            bibleService: bibleService,
            localStorage: localStorage,
            cacheManager: container.bibleCacheManager
        )
        
        super.init()
    }
    
    private func updateState(_ update: (inout BibleViewState) -> Void) {
        update(&state)
    }
    
    public func send(_ event: BibleViewEvent) {
        Task {
            await handle(event)
        }
    }
    
    private func handle(_ event: BibleViewEvent) async {
        switch event {
        case .loadVerse(let reference):
            await loadVerse(reference: reference)
            
        case .searchBible(let query):
            await searchBible(query: query)
            
        case .selectTranslation(let translation):
            updateState { $0.selectedTranslation = translation }
            
        case .toggleFavorite(let verse):
            await toggleFavorite(verse: verse)
            
        case .loadFavorites:
            await loadFavorites()
            
        case .loadTranslations:
            await loadTranslations()
            
        case .selectTab(let tab):
            updateState { $0.selectedTab = tab }
            analyticsService.track(
                event: CommonAnalyticsEvent.screenView(
                    screenName: "Bible_\(tab.rawValue)",
                    screenClass: "BibleView"
                ).name,
                properties: CommonAnalyticsEvent.screenView(
                    screenName: "Bible_\(tab.rawValue)",
                    screenClass: "BibleView"
                ).parameters
            )
        }
    }
    
    private func loadVerse(reference: String) async {
        updateState { $0.isLoading = true }
        
        do {
            let verse = try await fetchVerseUseCase.execute(reference)
            updateState {
                $0.currentVerse = verse
                $0.isLoading = false
                $0.error = nil
            }
            
            analyticsService.track(
                event: BibleAnalyticsEvent.verseViewed(
                    reference: reference,
                    translation: verse.translation
                ).name,
                properties: BibleAnalyticsEvent.verseViewed(
                    reference: reference,
                    translation: verse.translation
                ).parameters
            )
        } catch {
            updateState {
                $0.isLoading = false
                $0.error = error
            }
        }
    }
    
    private func searchBible(query: String) async {
        updateState {
            $0.isSearching = true
            $0.searchResults = []
        }
        
        do {
            let input = SearchBibleInput(
                query: query,
                translation: state.selectedTranslation?.abbreviation
            )
            let results = try await searchBibleUseCase.execute(input)
            
            updateState {
                $0.searchResults = results
                $0.isSearching = false
                $0.error = nil
            }
            
            analyticsService.track(
                event: CommonAnalyticsEvent.search(
                    query: query,
                    category: "bible"
                ).name,
                properties: CommonAnalyticsEvent.search(
                    query: query,
                    category: "bible"
                ).parameters
            )
        } catch {
            updateState {
                $0.isSearching = false
                $0.error = error
            }
        }
    }
    
    private func toggleFavorite(verse: BibleVerse) async {
        do {
            if state.favoriteVerses.contains(where: { $0.id == verse.id }) {
                try await bibleRepository.removeFavoriteVerse(verse.id)
                updateState {
                    $0.favoriteVerses.removeAll(where: { $0.id == verse.id })
                }
            } else {
                try await bibleRepository.addFavoriteVerse(verse)
                updateState {
                    $0.favoriteVerses.append(verse)
                }
            }
        } catch {
            updateState { $0.error = error }
        }
    }
    
    private func loadFavorites() async {
        do {
            let favorites = try await bibleRepository.getFavoriteVerses()
            updateState { $0.favoriteVerses = favorites }
        } catch {
            updateState { $0.error = error }
        }
    }
    
    private func loadTranslations() async {
        updateState { $0.isLoadingTranslations = true }
        
        do {
            let translations = try await bibleRepository.getTranslations()
            updateState {
                $0.translations = translations
                $0.isLoadingTranslations = false
                
                // Set default translation if none selected
                if $0.selectedTranslation == nil, let first = translations.first {
                    $0.selectedTranslation = first
                }
            }
        } catch {
            updateState {
                $0.isLoadingTranslations = false
                $0.error = error
            }
        }
    }
}

// MARK: - View State
public struct BibleViewState: ViewState {
    public var selectedTab: BibleTab = .read
    public var currentVerse: BibleVerse?
    public var searchResults: [BibleSearchResult] = []
    public var favoriteVerses: [BibleVerse] = []
    public var translations: [BibleTranslation] = []
    public var selectedTranslation: BibleTranslation?
    public var isLoading: Bool = false
    public var isSearching: Bool = false
    public var isLoadingTranslations: Bool = false
    public var error: Error?
    
    public init() {}
}

// MARK: - View Events
public enum BibleViewEvent {
    case loadVerse(reference: String)
    case searchBible(query: String)
    case selectTranslation(BibleTranslation)
    case toggleFavorite(verse: BibleVerse)
    case loadFavorites
    case loadTranslations
    case selectTab(BibleTab)
}

// MARK: - Bible Tab
public enum BibleTab: String, CaseIterable {
    case read = "Read"
    case search = "Search"
    case favorites = "Favorites"
    
    var icon: String {
        switch self {
        case .read: return "book"
        case .search: return "magnifyingglass"
        case .favorites: return "heart"
        }
    }
}

// MARK: - Analytics Events
enum BibleAnalyticsEvent: AnalyticsEvent {
    case verseViewed(reference: String, translation: String)
    case verseFavorited(reference: String)
    case verseShared(reference: String)
    
    var name: String {
        switch self {
        case .verseViewed: return "bible_verse_viewed"
        case .verseFavorited: return "bible_verse_favorited"
        case .verseShared: return "bible_verse_shared"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .verseViewed(let reference, let translation):
            return ["reference": reference, "translation": translation]
        case .verseFavorited(let reference):
            return ["reference": reference]
        case .verseShared(let reference):
            return ["reference": reference]
        }
    }
}