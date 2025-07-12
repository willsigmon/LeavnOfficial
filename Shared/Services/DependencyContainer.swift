import SwiftUI

// MARK: - Dependency Keys

// Library
private struct LibraryRepositoryKey: EnvironmentKey {
    static let defaultValue: LibraryRepositoryProtocol? = nil
}

private struct GetLibraryItemsUseCaseKey: EnvironmentKey {
    static let defaultValue: GetLibraryItemsUseCaseProtocol? = nil
}

private struct SaveLibraryItemUseCaseKey: EnvironmentKey {
    static let defaultValue: SaveLibraryItemUseCaseProtocol? = nil
}

// Search
private struct SearchRepositoryKey: EnvironmentKey {
    static let defaultValue: SearchRepositoryProtocol? = nil
}

private struct SearchBibleUseCaseKey: EnvironmentKey {
    static let defaultValue: SearchBibleUseCaseProtocol? = nil
}

private struct ManageRecentSearchesUseCaseKey: EnvironmentKey {
    static let defaultValue: ManageRecentSearchesUseCaseProtocol? = nil
}

// Bible
private struct BibleRepositoryKey: EnvironmentKey {
    static let defaultValue: BibleRepositoryProtocol? = nil
}

private struct BibleAnnotationRepositoryKey: EnvironmentKey {
    static let defaultValue: BibleAnnotationRepositoryProtocol? = nil
}

private struct BibleInsightRepositoryKey: EnvironmentKey {
    static let defaultValue: BibleInsightRepositoryProtocol? = nil
}

// MARK: - Environment Extensions

extension EnvironmentValues {
    // Library
    var libraryRepository: LibraryRepositoryProtocol? {
        get { self[LibraryRepositoryKey.self] }
        set { self[LibraryRepositoryKey.self] = newValue }
    }
    
    var getLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol? {
        get { self[GetLibraryItemsUseCaseKey.self] }
        set { self[GetLibraryItemsUseCaseKey.self] = newValue }
    }
    
    var saveLibraryItemUseCase: SaveLibraryItemUseCaseProtocol? {
        get { self[SaveLibraryItemUseCaseKey.self] }
        set { self[SaveLibraryItemUseCaseKey.self] = newValue }
    }
    
    // Search
    var searchRepository: SearchRepositoryProtocol? {
        get { self[SearchRepositoryKey.self] }
        set { self[SearchRepositoryKey.self] = newValue }
    }
    
    var searchBibleUseCase: SearchBibleUseCaseProtocol? {
        get { self[SearchBibleUseCaseKey.self] }
        set { self[SearchBibleUseCaseKey.self] = newValue }
    }
    
    var manageRecentSearchesUseCase: ManageRecentSearchesUseCaseProtocol? {
        get { self[ManageRecentSearchesUseCaseKey.self] }
        set { self[ManageRecentSearchesUseCaseKey.self] = newValue }
    }
}

// MARK: - Dependency Container

@MainActor
public final class DependencyContainer: ObservableObject {
    // MARK: - Repositories
    
    private lazy var libraryRepository: LibraryRepositoryProtocol = {
        LibraryRepository(
            remoteDataSource: libraryRemoteDataSource,
            localDataSource: libraryLocalDataSource
        )
    }()
    
    private lazy var searchRepository: SearchRepositoryProtocol = {
        SearchRepository(
            remoteDataSource: searchRemoteDataSource,
            localDataSource: searchLocalDataSource,
            cacheService: cacheService
        )
    }()
    
    // MARK: - Data Sources
    
    private lazy var libraryRemoteDataSource: LibraryRemoteDataSourceProtocol = {
        // This would be replaced with actual implementation
        MockLibraryRemoteDataSource()
    }()
    
    private lazy var libraryLocalDataSource: LibraryLocalDataSourceProtocol = {
        // This would be replaced with actual implementation
        MockLibraryLocalDataSource()
    }()
    
    private lazy var searchRemoteDataSource: SearchRemoteDataSourceProtocol = {
        // This would be replaced with actual implementation
        MockSearchRemoteDataSource()
    }()
    
    private lazy var searchLocalDataSource: SearchLocalDataSourceProtocol = {
        // This would be replaced with actual implementation
        MockSearchLocalDataSource()
    }()
    
    // MARK: - Services
    
    private lazy var cacheService: CacheServiceProtocol = {
        // This would be replaced with actual implementation
        MockCacheService()
    }()
    
    // MARK: - Use Cases
    
    // Library
    private lazy var getLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol = {
        GetLibraryItemsUseCase(repository: libraryRepository)
    }()
    
    private lazy var saveLibraryItemUseCase: SaveLibraryItemUseCaseProtocol = {
        SaveLibraryItemUseCase(repository: libraryRepository)
    }()
    
    // Search
    private lazy var searchBibleUseCase: SearchBibleUseCaseProtocol = {
        SearchBibleUseCase(repository: searchRepository)
    }()
    
    private lazy var manageRecentSearchesUseCase: ManageRecentSearchesUseCaseProtocol = {
        ManageRecentSearchesUseCase(repository: searchRepository)
    }()
    
    // MARK: - Factory Methods
    
    public func makeLibraryViewModel(coordinator: LibraryCoordinator) -> LibraryViewModel {
        LibraryViewModel(
            getItemsUseCase: getLibraryItemsUseCase,
            saveItemUseCase: saveLibraryItemUseCase,
            coordinator: coordinator
        )
    }
    
    public func makeSearchViewModel(coordinator: SearchCoordinator) -> SearchViewModel {
        SearchViewModel(
            searchBibleUseCase: searchBibleUseCase,
            recentSearchesUseCase: manageRecentSearchesUseCase,
            coordinator: coordinator
        )
    }
    
    // MARK: - Environment Setup
    
    public func setupEnvironment<Content: View>(_ content: Content) -> some View {
        content
            // Library
            .environment(\.libraryRepository, libraryRepository)
            .environment(\.getLibraryItemsUseCase, getLibraryItemsUseCase)
            .environment(\.saveLibraryItemUseCase, saveLibraryItemUseCase)
            // Search
            .environment(\.searchRepository, searchRepository)
            .environment(\.searchBibleUseCase, searchBibleUseCase)
            .environment(\.manageRecentSearchesUseCase, manageRecentSearchesUseCase)
    }
}

// MARK: - Mock Implementations (for demonstration)

// Library Mocks
private final class MockLibraryRemoteDataSource: LibraryRemoteDataSourceProtocol {
    func fetchAllItems() async throws -> [LibraryItem] { [] }
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] { [] }
    func fetchItem(withId id: UUID) async throws -> LibraryItem? { nil }
    func saveItem(_ item: LibraryItem) async throws {}
    func updateItem(_ item: LibraryItem) async throws {}
    func deleteItem(withId id: UUID) async throws {}
    func searchItems(query: String) async throws -> [LibraryItem] { [] }
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] { [] }
}

private final class MockLibraryLocalDataSource: LibraryLocalDataSourceProtocol {
    private var items: [LibraryItem] = []
    
    func fetchAllItems() async throws -> [LibraryItem] { items }
    func fetchItems(ofType type: LibraryItemType) async throws -> [LibraryItem] { 
        items.filter { $0.type == type }
    }
    func fetchItem(withId id: UUID) async throws -> LibraryItem? { 
        items.first { $0.id == id }
    }
    func saveItem(_ item: LibraryItem) async throws {
        items.append(item)
    }
    func updateItem(_ item: LibraryItem) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    func deleteItem(withId id: UUID) async throws {
        items.removeAll { $0.id == id }
    }
    func searchItems(query: String) async throws -> [LibraryItem] {
        items.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }
    func fetchItemsByTag(_ tag: String) async throws -> [LibraryItem] {
        items.filter { $0.tags.contains(tag) }
    }
}

// Search Mocks
private final class MockSearchRemoteDataSource: SearchRemoteDataSourceProtocol {
    func search(query: SearchQuery) async throws -> [SearchResult] {
        // Return mock search results
        return [
            SearchResult(
                bookId: "JHN",
                bookName: "John",
                chapter: 3,
                verse: 16,
                text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                translation: "NIV",
                highlights: [HighlightRange(start: 8, length: 5)]
            )
        ]
    }
    
    func getPopularSearches() async throws -> [String] {
        ["Love", "Faith", "Peace", "Hope", "Grace", "Prayer"]
    }
}

private final class MockSearchLocalDataSource: SearchLocalDataSourceProtocol {
    private var recentSearches: [String] = []
    
    func search(query: SearchQuery) async throws -> [SearchResult] {
        // Return empty for local mock
        return []
    }
    
    func getRecentSearches() async throws -> [String] {
        recentSearches
    }
    
    func addRecentSearch(_ query: String) async throws {
        // Remove if exists and add to front
        recentSearches.removeAll { $0 == query }
        recentSearches.insert(query, at: 0)
        // Keep only last 10
        if recentSearches.count > 10 {
            recentSearches = Array(recentSearches.prefix(10))
        }
    }
    
    func clearRecentSearches() async throws {
        recentSearches = []
    }
}

private final class MockCacheService: CacheServiceProtocol {
    private var cache: [String: Data] = [:]
    
    func get<T: Decodable>(_ key: String, type: T.Type) async throws -> T? {
        guard let data = cache[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func set<T: Encodable>(_ key: String, value: T, ttl: TimeInterval) async throws {
        let data = try JSONEncoder().encode(value)
        cache[key] = data
    }
    
    func delete(_ key: String) async throws {
        cache.removeValue(forKey: key)
    }
    
    func clear() async throws {
        cache.removeAll()
    }
}