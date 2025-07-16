import Foundation
import CoreData
import Combine

// MARK: - DI Container
/// Main dependency injection container for the app
/// Provides singleton instances of all services without external dependencies
public final class DIContainer: ObservableObject {
    nonisolated(unsafe) public static let shared = DIContainer()
    
    // MARK: - Core Services
    private lazy var _configuration: LeavnConfiguration = {
        LeavnConfiguration(
            apiKey: ProcessInfo.processInfo.environment["LEAVN_API_KEY"] ?? "",
            environment: .production,
            esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"] ?? "",
            bibleComAPIKey: ProcessInfo.processInfo.environment["BIBLE_COM_API_KEY"] ?? "",
            elevenLabsAPIKey: ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? "",
            features: FeatureFlags.default
        )
    }()
    
    private lazy var _coreDataStack: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "LeavnDataModel")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        return container
    }()
    
    private lazy var _networkService: NetworkServiceProtocol = {
        DefaultNetworkService(configuration: self._configuration)
    }()
    
    private lazy var _userDataManager: UserDataManagerProtocol = {
        DefaultUserDataManager(
            context: self._coreDataStack.viewContext,
            secureStorage: KeychainStorage()
        )
    }()
    
    // MARK: - Bible Services
    private lazy var _bibleService: BibleServiceProtocol = {
        // Create cache manager
        let cacheManager = CoreDataBibleCacheManager(context: self._coreDataStack.viewContext)
        
        // Create a network service that implements the BibleService's expected NetworkService
        let networkServiceAdapter = NetworkServiceAdapter(networkService: self._networkService)
        
        // Use the existing DefaultBibleService which implements BibleService protocol
        // We need to wrap it to match BibleServiceProtocol
        let bibleService = DefaultBibleService(
            networkService: networkServiceAdapter,
            esvAPIKey: self._configuration.esvAPIKey,
            bibleComAPIKey: self._configuration.bibleComAPIKey,
            cacheManager: cacheManager
        )
        
        return BibleServiceAdapter(bibleService: bibleService)
    }()
    
    // MARK: - AI Services
    private lazy var _aiService: AIServiceProtocol = {
        // Use a safe AI service with guardrails until real implementation is ready
        SafeAIService(
            bibleService: self._bibleService,
            analyticsService: self._analyticsService
        )
    }()
    
    // MARK: - Audio Services
    private lazy var _audioService: AudioServiceProtocol = {
        DefaultAudioService(
            elevenLabsAPIKey: self._configuration.elevenLabsAPIKey,
            cacheManager: InMemoryAudioCacheManager()
        )
    }()
    
    // MARK: - Authentication Services
    private lazy var _authenticationService: AuthenticationServiceProtocol = {
        DefaultAuthenticationService(
            networkService: self._networkService,
            userDataManager: self._userDataManager,
            secureStorage: KeychainStorage()
        )
    }()
    
    // MARK: - Verse of the Day Service
    private lazy var _verseOfTheDayService: VerseOfTheDayServiceProtocol = {
        let cacheService = InMemoryCacheService()
        return VerseOfTheDayService(bibleService: self._bibleService, cacheService: cacheService)
    }()
    
    // MARK: - Other Services
    private lazy var _analyticsService: AnalyticsServiceProtocol = {
        let service = DefaultAnalyticsService(configuration: self._configuration)
        #if DEBUG
        service.addProvider(ConsoleAnalyticsProvider())
        #endif
        return service
    }()
    
    private lazy var _libraryRepository: LibraryRepositoryProtocol = {
        DefaultLibraryRepository(
            context: self._coreDataStack.viewContext,
            networkService: self._networkService
        )
    }()
    
    private lazy var _settingsRepository: SettingsRepositoryProtocol = {
        let localStorage = UserDefaultsStorage()
        let secureStorage = KeychainStorage()
        
        return DefaultSettingsRepository(
            context: self._coreDataStack.viewContext,
            localStorage: StorageSettingsLocalStorage(storage: localStorage),
            secureStorage: SecureStorageSettingsSecureStorage(storage: secureStorage)
        )
    }()
    
    private lazy var _searchRepository: SearchRepositoryProtocol = {
        DefaultSearchRepository(
            bibleService: self._bibleService,
            libraryRepository: self._libraryRepository,
            context: self._coreDataStack.viewContext
        )
    }()
    
    private lazy var _lifeSituationRepository: LifeSituationRepositoryProtocol = {
        RealLifeSituationRepository(
            networkService: self._networkService,
            bibleService: self._bibleService,
            context: self._coreDataStack.viewContext
        )
    }()
    
    private lazy var _communityService: CommunityServiceProtocol = {
        DefaultCommunityService(
            networkService: self._networkService,
            context: self._coreDataStack.viewContext,
            userDataManager: self._userDataManager
        )
    }()
    
    private lazy var _verseCardService: VerseCardServiceProtocol = {
        VerseCardService()
    }()
    
    // MARK: - Public Accessors
    public var configuration: LeavnConfiguration { _configuration }
    public var coreDataStack: NSPersistentContainer { _coreDataStack }
    public var networkService: NetworkServiceProtocol { _networkService }
    public var bibleService: BibleServiceProtocol { _bibleService }
    public var aiService: AIServiceProtocol { _aiService }
    public var audioService: AudioServiceProtocol { _audioService }
    public var authenticationService: AuthenticationServiceProtocol { _authenticationService }
    public var analyticsService: AnalyticsServiceProtocol { _analyticsService }
    public var libraryRepository: LibraryRepositoryProtocol { _libraryRepository }
    public var settingsRepository: SettingsRepositoryProtocol { _settingsRepository }
    public var searchRepository: SearchRepositoryProtocol { _searchRepository }
    public var lifeSituationRepository: LifeSituationRepositoryProtocol { _lifeSituationRepository }
    public var userDataManager: UserDataManagerProtocol { _userDataManager }
    public var communityService: CommunityServiceProtocol { _communityService }
    public var verseOfTheDayService: VerseOfTheDayServiceProtocol { _verseOfTheDayService }
    public var verseCardService: VerseCardServiceProtocol { _verseCardService }
    
    private init() {}
    
    // MARK: - Configuration
    public func configure(with configuration: LeavnConfiguration) {
        self._configuration = configuration
    }
    
    public func reset() {
        // Reset would recreate all lazy properties
        // For now, we'll just log this action
        print("[DIContainer] Reset requested - services will be recreated on next access")
    }
}

// MARK: - Service Adapters

/// Adapter to bridge between NetworkServiceProtocol and NetworkService expected by BibleService
private final class NetworkServiceAdapter: NetworkService {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        return try await networkService.request(endpoint)
    }
    
    func request(_ endpoint: Endpoint) async throws -> Data {
        return try await networkService.request(endpoint)
    }
    
    func requestData(_ endpoint: Endpoint) async throws -> Data {
        return try await networkService.request(endpoint)
    }
    
    func upload<T: Decodable>(_ endpoint: Endpoint, data: Data) async throws -> T {
        return try await networkService.upload(endpoint, data: data)
    }
    
    func download(_ endpoint: Endpoint) async throws -> URL {
        return try await networkService.download(endpoint)
    }
}

// MARK: - Service Adapters

/// Adapter to bridge between BibleService and BibleServiceProtocol
private final class BibleServiceAdapter: BibleServiceProtocol {
    private let bibleService: BibleService
    
    init(bibleService: BibleService) {
        self.bibleService = bibleService
    }
    
    func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter {
        let chapter = try await bibleService.fetchChapter(book: book, chapter: chapter, translation: translation)
        return BibleChapter(
            book: chapter.book,
            chapter: chapter.chapter,
            verses: chapter.verses.map { verse in
                BibleVerse(
                    id: verse.id,
                    reference: verse.reference,
                    text: verse.text,
                    book: verse.book,
                    chapter: verse.chapter,
                    verse: verse.verse,
                    translation: verse.translation
                )
            },
            translation: chapter.translation
        )
    }
    
    func getVerse(reference: String, translation: String) async throws -> BibleVerse {
        let verse = try await bibleService.fetchVerse(reference: reference, translation: translation)
        return BibleVerse(
            id: verse.id,
            reference: verse.reference,
            text: verse.text,
            book: verse.book,
            chapter: verse.chapter,
            verse: verse.verse,
            translation: verse.translation
        )
    }
    
    func searchVerses(query: String, translation: String) async throws -> [BibleVerse] {
        let results = try await bibleService.search(query: query, translation: translation)
        return results.map { $0.verse }
    }
    
    func getAvailableTranslations() async throws -> [BibleTranslation] {
        let translations = try await bibleService.fetchTranslations()
        return translations.map { translation in
            BibleTranslation(
                id: translation.id,
                name: translation.name,
                abbreviation: translation.abbreviation,
                language: translation.language
            )
        }
    }
    
    func getDailyVerse() async throws -> BibleVerse {
        // For now, return a fixed verse - in production, this would fetch from a daily verse API
        return try await getVerse(reference: "John 3:16", translation: "ESV")
    }
}

// MARK: - Default Service Implementations

private final class DefaultNetworkService: NetworkServiceProtocol {
    private let configuration: LeavnConfiguration
    private let session: URLSession
    private let reachabilitySubject = CurrentValueSubject<Bool, Never>(true)
    
    init(configuration: LeavnConfiguration) {
        self.configuration = configuration
        self.session = URLSession.shared
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    func request(_ endpoint: Endpoint) async throws -> Data {
        guard let url = URL(string: configuration.baseURL)?.appendingPathComponent(endpoint.path) else {
            throw LeavnError.invalidInput("Invalid URL")
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let parameters = endpoint.parameters {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw LeavnError.networkError(underlying: nil)
        }
        
        return data
    }
    
    func upload(_ endpoint: Endpoint, data: Data) async throws -> Data {
        throw LeavnError.notImplemented("Upload not implemented")
    }
    
    func download(_ endpoint: Endpoint) async throws -> URL {
        throw LeavnError.notImplemented("Download not implemented")
    }
    
    var isReachable: AnyPublisher<Bool, Never> {
        reachabilitySubject.eraseToAnyPublisher()
    }
}

private final class DefaultAnalyticsService: AnalyticsServiceProtocol {
    private let configuration: LeavnConfiguration
    private var providers: [AnalyticsProvider] = []
    
    init(configuration: LeavnConfiguration) {
        self.configuration = configuration
    }
    
    func track(event: String, properties: [String: Any]?) {
        providers.forEach { $0.track(event: event, properties: properties) }
    }
    
    func trackError(_ error: Error, properties: [String: Any]?) {
        var props = properties ?? [:]
        props["error_description"] = error.localizedDescription
        track(event: "error", properties: props)
    }
    
    func identify(userId: String, traits: [String: Any]?) {
        providers.forEach { $0.identify(userId: userId, traits: traits) }
    }
    
    func reset() {
        providers.forEach { $0.reset() }
    }
    
    func addProvider(_ provider: AnalyticsProvider) {
        providers.append(provider)
    }
}

private struct ConsoleAnalyticsProvider: AnalyticsProvider {
    func track(event: String, properties: [String: Any]?) {
        print("[Analytics] Event: \(event), Properties: \(properties ?? [:])")
    }
    
    func identify(userId: String, traits: [String: Any]?) {
        print("[Analytics] Identify: \(userId), Traits: \(traits ?? [:])")
    }
    
    func reset() {
        print("[Analytics] Reset")
    }
}

// MARK: - Mock Implementations (to be replaced with real ones)

private final class DefaultLibraryRepository: LibraryRepositoryProtocol {
    private let context: NSManagedObjectContext
    private let networkService: NetworkServiceProtocol
    
    init(context: NSManagedObjectContext, networkService: NetworkServiceProtocol) {
        self.context = context
        self.networkService = networkService
    }
    
    func getItems(filter: LibraryFilter?) async throws -> [LibraryItem] {
        return try await context.perform {
            let request: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
            
            // Apply filters
            var predicates: [NSPredicate] = []
            
            if let types = filter?.types {
                let typeStrings = types.map { $0.rawValue }
                predicates.append(NSPredicate(format: "type IN %@", typeStrings))
            }
            
            if let dateRange = filter?.dateRange {
                predicates.append(NSPredicate(format: "createdAt >= %@ AND createdAt <= %@", 
                                            dateRange.startDate as NSDate, 
                                            dateRange.endDate as NSDate))
            }
            
            if let searchTerm = filter?.searchTerm, !searchTerm.isEmpty {
                predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR content CONTAINS[cd] %@", 
                                            searchTerm, searchTerm))
            }
            
            if !predicates.isEmpty {
                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            }
            
            request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { self.convertToLibraryItem($0) }
        }
    }
    
    func getItem(id: String) async throws -> LibraryItem? {
        return try await context.perform {
            let request: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            guard let entity = try self.context.fetch(request).first else {
                return nil
            }
            
            return self.convertToLibraryItem(entity)
        }
    }
    
    func saveItem(_ item: LibraryItem) async throws {
        try await context.perform {
            let entity = LibraryItemEntity(context: self.context)
            entity.id = item.id
            entity.type = item.type.rawValue
            entity.title = item.title
            entity.content = item.content
            entity.reference = item.reference
            entity.createdAt = item.createdAt
            entity.updatedAt = item.updatedAt
            
            if let metadata = item.metadata {
                entity.metadata = try? JSONEncoder().encode(metadata)
            }
            
            try self.context.save()
        }
    }
    
    func updateItem(_ item: LibraryItem) async throws {
        try await context.perform {
            let request: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", item.id)
            
            guard let entity = try self.context.fetch(request).first else {
                throw LeavnError.notFound
            }
            
            entity.type = item.type.rawValue
            entity.title = item.title
            entity.content = item.content
            entity.reference = item.reference
            entity.updatedAt = Date()
            
            if let metadata = item.metadata {
                entity.metadata = try? JSONEncoder().encode(metadata)
            }
            
            try self.context.save()
        }
    }
    
    func deleteItem(id: String) async throws {
        try await context.perform {
            let request: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            guard let entity = try self.context.fetch(request).first else {
                throw LeavnError.notFound
            }
            
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    func getCollections() async throws -> [LibraryCollection] {
        return try await context.perform {
            let request: NSFetchRequest<LibraryCollectionEntity> = LibraryCollectionEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
            
            let entities = try self.context.fetch(request)
            return entities.compactMap { self.convertToLibraryCollection($0) }
        }
    }
    
    func getCollection(id: String) async throws -> LibraryCollection? {
        return try await context.perform {
            let request: NSFetchRequest<LibraryCollectionEntity> = LibraryCollectionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            request.fetchLimit = 1
            
            guard let entity = try self.context.fetch(request).first else {
                return nil
            }
            
            return self.convertToLibraryCollection(entity)
        }
    }
    
    func createCollection(_ collection: LibraryCollection) async throws {
        try await context.perform {
            let entity = LibraryCollectionEntity(context: self.context)
            entity.id = collection.id
            entity.name = collection.name
            entity.collectionDescription = collection.description
            entity.createdAt = collection.createdAt
            entity.updatedAt = collection.updatedAt
            
            try self.context.save()
        }
    }
    
    func updateCollection(_ collection: LibraryCollection) async throws {
        try await context.perform {
            let request: NSFetchRequest<LibraryCollectionEntity> = LibraryCollectionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", collection.id)
            
            guard let entity = try self.context.fetch(request).first else {
                throw LeavnError.notFound
            }
            
            entity.name = collection.name
            entity.collectionDescription = collection.description
            entity.updatedAt = Date()
            
            // Update items relationship
            if !collection.itemIds.isEmpty {
                let itemRequest: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
                itemRequest.predicate = NSPredicate(format: "id IN %@", collection.itemIds)
                let items = try self.context.fetch(itemRequest)
                entity.items = NSSet(array: items)
            }
            
            try self.context.save()
        }
    }
    
    func deleteCollection(id: String) async throws {
        try await context.perform {
            let request: NSFetchRequest<LibraryCollectionEntity> = LibraryCollectionEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id)
            
            guard let entity = try self.context.fetch(request).first else {
                throw LeavnError.notFound
            }
            
            self.context.delete(entity)
            try self.context.save()
        }
    }
    
    func search(query: String, filter: LibraryFilter?) async throws -> [LibraryItem] {
        var searchFilter = filter ?? LibraryFilter()
        searchFilter.searchTerm = query
        return try await getItems(filter: searchFilter)
    }
    
    func getStatistics() async throws -> LibraryStatistics {
        return try await context.perform {
            let itemRequest: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
            let totalItems = try self.context.count(for: itemRequest)
            
            let collectionRequest: NSFetchRequest<LibraryCollectionEntity> = LibraryCollectionEntity.fetchRequest()
            let totalCollections = try self.context.count(for: collectionRequest)
            
            // Count by type
            var itemsByType: [LibraryContentType: Int] = [:]
            for type in LibraryContentType.allCases {
                let typeRequest: NSFetchRequest<LibraryItemEntity> = LibraryItemEntity.fetchRequest()
                typeRequest.predicate = NSPredicate(format: "type == %@", type.rawValue)
                let count = try self.context.count(for: typeRequest)
                if count > 0 {
                    itemsByType[type] = count
                }
            }
            
            return LibraryStatistics(
                totalItems: totalItems,
                itemsByType: itemsByType,
                totalCollections: totalCollections
            )
        }
    }
    
    func sync() async throws {
        // TODO: Implement cloud sync when backend is ready
        UserDefaults.standard.set(Date(), forKey: "lastLibrarySync")
    }
    
    func getLastSyncDate() async throws -> Date? {
        return UserDefaults.standard.object(forKey: "lastLibrarySync") as? Date
    }
    
    // MARK: - Private Helpers
    
    private func convertToLibraryItem(_ entity: LibraryItemEntity) -> LibraryItem? {
        guard let id = entity.id,
              let typeString = entity.type,
              let type = LibraryContentType(rawValue: typeString),
              let title = entity.title,
              let content = entity.content else {
            return nil
        }
        
        var metadata: [String: String]?
        if let metadataData = entity.metadata {
            metadata = try? JSONDecoder().decode([String: String].self, from: metadataData)
        }
        
        return LibraryItem(
            id: id,
            type: type,
            title: title,
            content: content,
            reference: entity.reference,
            metadata: metadata,
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
    
    private func convertToLibraryCollection(_ entity: LibraryCollectionEntity) -> LibraryCollection? {
        guard let id = entity.id,
              let name = entity.name else {
            return nil
        }
        
        let itemIds = (entity.items?.allObjects as? [LibraryItemEntity])?.compactMap { $0.id } ?? []
        
        return LibraryCollection(
            id: id,
            name: name,
            description: entity.collectionDescription,
            itemIds: itemIds,
            createdAt: entity.createdAt ?? Date(),
            updatedAt: entity.updatedAt ?? Date()
        )
    }
}

private final class DefaultSearchRepository: SearchRepositoryProtocol {
    private let bibleService: BibleServiceProtocol
    private let libraryRepository: LibraryRepositoryProtocol
    private let context: NSManagedObjectContext
    
    init(bibleService: BibleServiceProtocol, libraryRepository: LibraryRepositoryProtocol, context: NSManagedObjectContext) {
        self.bibleService = bibleService
        self.libraryRepository = libraryRepository
        self.context = context
    }
    
    func searchBible(query: String, translation: String?, books: [String]?) async throws -> [BibleSearchResult] {
        let verses = try await bibleService.searchVerses(query: query, translation: translation ?? "ESV")
        return verses.map { verse in
            BibleSearchResult(
                id: verse.id,
                verse: verse,
                relevance: 1.0
            )
        }
    }
    
    func searchLibrary(query: String) async throws -> [LibrarySearchResult] {
        let items = try await libraryRepository.search(query: query, filter: nil)
        return items.map { item in
            LibrarySearchResult(
                id: item.id,
                item: item,
                relevance: 1.0
            )
        }
    }
    
    func getRecentSearches(limit: Int) async throws -> [SearchQuery] {
        // TODO: Implement Core Data fetch
        return []
    }
    
    func saveSearch(_ query: SearchQuery) async throws {
        // TODO: Implement Core Data save
    }
    
    func clearSearchHistory() async throws {
        // TODO: Implement Core Data delete
    }
}

private final class DefaultLifeSituationRepository: LifeSituationRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let bibleService: BibleServiceProtocol
    
    init(networkService: NetworkServiceProtocol, bibleService: BibleServiceProtocol) {
        self.networkService = networkService
        self.bibleService = bibleService
    }
    
    func getSituations() async throws -> [LifeSituation] {
        // TODO: Implement network fetch or use local data
        return []
    }
    
    func getSituation(id: String) async throws -> LifeSituation? {
        // TODO: Implement
        return nil
    }
    
    func getRelatedVerses(for situationId: String) async throws -> [BibleVerse] {
        // TODO: Implement
        return []
    }
    
    func getRelatedContent(for situationId: String) async throws -> [RelatedContent] {
        // TODO: Implement
        return []
    }
}

// MARK: - Settings Storage Protocols

public protocol SettingsLocalStorage {
    func loadAppSettings() async throws -> AppSettings?
    func saveAppSettings(_ settings: AppSettings) async throws
    func getSetting<T: Codable>(key: String, type: T.Type) async throws -> T?
    func setSetting<T: Codable>(key: String, value: T) async throws
    func removeSetting(key: String) async throws
    func getAllSettings() async throws -> [String: Any]
    func getSettingsHistory(limit: Int, offset: Int) async throws -> [SettingsChangeEvent]
    func getSettingChanges(for key: String, limit: Int) async throws -> [SettingsChangeEvent]
    func trackSettingChange(_ event: SettingsChangeEvent) async throws
    func saveBackup(_ backup: SettingsBackup) async throws
    func getBackups(limit: Int) async throws -> [SettingsBackup]
    func deleteBackup(_ backupId: String) async throws
    func getSettingsVersion() async throws -> String?
}

public protocol SettingsSecureStorage {
    func store<T: Codable>(_ value: T, forKey key: String) async throws
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
}

// MARK: - Storage Adapters

private final class StorageSettingsLocalStorage: SettingsLocalStorage {
    private let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func loadAppSettings() async throws -> AppSettings? {
        try await storage.load(AppSettings.self, forKey: "app_settings")
    }
    
    func saveAppSettings(_ settings: AppSettings) async throws {
        try await storage.save(settings, forKey: "app_settings")
    }
    
    func getSetting<T: Codable>(key: String, type: T.Type) async throws -> T? {
        try await storage.load(type, forKey: key)
    }
    
    func setSetting<T: Codable>(key: String, value: T) async throws {
        try await storage.save(value, forKey: key)
    }
    
    func removeSetting(key: String) async throws {
        try await storage.remove(forKey: key)
    }
    
    func getAllSettings() async throws -> [String: Any] {
        guard let settings = try await loadAppSettings() else {
            return [:]
        }
        
        let data = try JSONEncoder().encode(settings)
        let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return json as? [String: Any] ?? [:]
    }
    
    func getSettingsHistory(limit: Int, offset: Int) async throws -> [SettingsChangeEvent] {
        try await storage.load([SettingsChangeEvent].self, forKey: "settings_history") ?? []
    }
    
    func getSettingChanges(for key: String, limit: Int) async throws -> [SettingsChangeEvent] {
        let allChanges = try await getSettingsHistory(limit: 1000, offset: 0)
        return Array(allChanges.filter { $0.settingKey == key }.prefix(limit))
    }
    
    func trackSettingChange(_ event: SettingsChangeEvent) async throws {
        var history = try await getSettingsHistory(limit: 1000, offset: 0)
        history.append(event)
        if history.count > 1000 {
            history = Array(history.suffix(1000))
        }
        try await storage.save(history, forKey: "settings_history")
    }
    
    func saveBackup(_ backup: SettingsBackup) async throws {
        var backups = try await getBackups(limit: 100)
        backups.append(backup)
        try await storage.save(backups, forKey: "settings_backups")
    }
    
    func getBackups(limit: Int) async throws -> [SettingsBackup] {
        let allBackups = try await storage.load([SettingsBackup].self, forKey: "settings_backups") ?? []
        return Array(allBackups.prefix(limit))
    }
    
    func deleteBackup(_ backupId: String) async throws {
        var backups = try await getBackups(limit: 100)
        backups.removeAll { $0.id == backupId }
        try await storage.save(backups, forKey: "settings_backups")
    }
    
    func getSettingsVersion() async throws -> String? {
        try await storage.load(String.self, forKey: "settings_version")
    }
}

private final class SecureStorageSettingsSecureStorage: SettingsSecureStorage {
    private let storage: SecureStorage
    
    init(storage: SecureStorage) {
        self.storage = storage
    }
    
    func store<T: Codable>(_ value: T, forKey key: String) async throws {
        try await storage.save(value, forKey: key)
    }
    
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T? {
        try await storage.load(type, forKey: key)
    }
    
    func remove(forKey key: String) async throws {
        try await storage.remove(forKey: key)
    }
}

// MARK: - Missing Protocols

public protocol AIServiceProtocol {
    func generateInsight(for verse: BibleVerse) async throws -> String
    func generateSummary(for chapter: BibleChapter) async throws -> String
    func answerQuestion(_ question: String, context: [BibleVerse]) async throws -> String
}

public protocol UserDataManagerProtocol {
    var currentUser: User? { get }
    func updateUser(_ user: User) async throws
    func clearUserData() async throws
}

public protocol CommunityServiceProtocol {
    func getPosts() async throws -> [CommunityPost]
    func createPost(_ post: CommunityPost) async throws
    func deletePost(_ postId: String) async throws
}

public struct CommunityPost: Identifiable {
    public let id: String
    public let userId: String
    public let content: String
    public let createdAt: Date
}

// MARK: - Library Types

// LibraryItem is defined in LibraryTypes.swift

public enum LibraryContentType: String, Codable, CaseIterable {
    case verse
    case note
    case highlight
    case bookmark
    case favorite
}

public struct LibraryCollection: Identifiable, Codable {
    public let id: String
    public let name: String
    public let description: String?
    public let itemIds: [String]
    public let createdAt: Date
    public let updatedAt: Date
}

public struct LibraryFilter {
    public let types: [LibraryContentType]?
    public let dateRange: DateRange?
    public let searchTerm: String?
    
    public init(types: [LibraryContentType]? = nil, dateRange: DateRange? = nil, searchTerm: String? = nil) {
        self.types = types
        self.dateRange = dateRange
        self.searchTerm = searchTerm
    }
}

// DateRange is defined in CommonTypes.swift

public struct LibraryStatistics {
    public let totalItems: Int
    public let totalCollections: Int
    public let totalVerses: Int
    public let totalNotes: Int
    public let totalHighlights: Int
    public let lastUpdated: Date
    
    public init(totalItems: Int, totalCollections: Int, totalVerses: Int, totalNotes: Int, totalHighlights: Int, lastUpdated: Date) {
        self.totalItems = totalItems
        self.totalCollections = totalCollections
        self.totalVerses = totalVerses
        self.totalNotes = totalNotes
        self.totalHighlights = totalHighlights
        self.lastUpdated = lastUpdated
    }
}

// MARK: - Mock Implementations

private final class MockAIService: AIServiceProtocol {
    func generateInsight(for verse: BibleVerse) async throws -> String {
        return "This verse teaches us about God's love and grace."
    }
    
    func generateSummary(for chapter: BibleChapter) async throws -> String {
        return "Chapter \(chapter.chapter) of \(chapter.book) contains \(chapter.verses.count) verses."
    }
    
    func answerQuestion(_ question: String, context: [BibleVerse]) async throws -> String {
        return "Based on the provided verses, here's an answer to your question."
    }
}

private final class MockAuthenticationService: AuthenticationServiceProtocol {
    private let userSubject = CurrentValueSubject<AuthUser?, Never>(nil)
    
    func signIn(email: String, password: String) async throws -> AuthUser {
        let user = AuthUser(id: "mock-id", email: email, name: "Mock User")
        userSubject.send(user)
        return user
    }
    
    func signUp(email: String, password: String, name: String) async throws -> AuthUser {
        let user = AuthUser(id: "mock-id", email: email, name: name)
        userSubject.send(user)
        return user
    }
    
    func signOut() async throws {
        userSubject.send(nil)
    }
    
    func resetPassword(email: String) async throws {
        // Mock implementation
    }
    
    func refreshToken() async throws {
        // Mock implementation
    }
    
    var currentUser: AnyPublisher<AuthUser?, Never> {
        userSubject.eraseToAnyPublisher()
    }
    
    var isAuthenticated: Bool {
        userSubject.value != nil
    }
}

private final class MockUserDataManager: UserDataManagerProtocol {
    var currentUser: User?
    
    func updateUser(_ user: User) async throws {
        currentUser = user
    }
    
    func clearUserData() async throws {
        currentUser = nil
    }
}

private final class MockAudioService: AudioServiceProtocol {
    private let isPlayingSubject = CurrentValueSubject<Bool, Never>(false)
    private let progressSubject = CurrentValueSubject<Double, Never>(0.0)
    
    func playVerse(_ verse: BibleVerse, voice: VoiceConfiguration?) async throws {
        isPlayingSubject.send(true)
    }
    
    func pause() {
        isPlayingSubject.send(false)
    }
    
    func resume() {
        isPlayingSubject.send(true)
    }
    
    func stop() {
        isPlayingSubject.send(false)
        progressSubject.send(0.0)
    }
    
    func generateAudio(text: String, voice: VoiceConfiguration) async throws -> URL {
        return URL(string: "file:///mock/audio.mp3")!
    }
    
    var isPlaying: AnyPublisher<Bool, Never> {
        isPlayingSubject.eraseToAnyPublisher()
    }
    
    var progress: AnyPublisher<Double, Never> {
        progressSubject.eraseToAnyPublisher()
    }
}

private final class MockSettingsRepository: SettingsRepositoryProtocol {
    private var settings = AppSettings()
    
    func getSettings() async throws -> AppSettings {
        return settings
    }
    
    func updateSettings(_ settings: AppSettings) async throws {
        self.settings = settings
    }
    
    func updateSetting<T: Codable>(key: String, value: T) async throws {
        // Mock implementation
    }
    
    func resetToDefaults() async throws {
        settings = AppSettings()
    }
    
    func exportSettings() async throws -> Data {
        return try JSONEncoder().encode(settings)
    }
    
    func importSettings(from data: Data) async throws {
        settings = try JSONDecoder().decode(AppSettings.self, from: data)
    }
    
    func getSettingsHistory(limit: Int) async throws -> [SettingsChangeEvent] {
        return []
    }
    
    func createBackup(name: String) async throws -> SettingsBackup {
        return SettingsBackup(settings: settings)
    }
    
    func getBackups() async throws -> [SettingsBackup] {
        return []
    }
    
    func restoreBackup(_ backup: SettingsBackup) async throws {
        settings = backup.settings
    }
}

// MARK: - Missing Extensions for SettingsChangeEvent
extension SettingsChangeEvent {
    var settingKey: String {
        return setting
    }
}

extension SettingsBackup {
    var id: String {
        return "\(createdAt.timeIntervalSince1970)"
    }
}

// MARK: - Environment Key for SwiftUI

public struct DIContainerKey: EnvironmentKey {
    public static let defaultValue = DIContainer.shared
}

public extension EnvironmentValues {
    var diContainer: DIContainer {
        get { self[DIContainerKey.self] }
        set { self[DIContainerKey.self] = newValue }
    }
}

// MARK: - Property Wrappers

@propertyWrapper
public struct Injected<T> {
    private let keyPath: KeyPath<DIContainer, T>
    
    public init(_ keyPath: KeyPath<DIContainer, T>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        DIContainer.shared[keyPath: keyPath]
    }
}

@propertyWrapper
public struct LazyInjected<T> {
    private let keyPath: KeyPath<DIContainer, T>
    private var instance: T?
    
    public init(_ keyPath: KeyPath<DIContainer, T>) {
        self.keyPath = keyPath
    }
    
    public var wrappedValue: T {
        mutating get {
            if instance == nil {
                instance = DIContainer.shared[keyPath: keyPath]
            }
            return instance!
        }
    }
}