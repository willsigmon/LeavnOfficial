import Foundation
import Combine

// MARK: - Mock Network Service
public final class MockNetworkService: NetworkServiceProtocol {
    public var isReachable: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }
    
    public init() {}
    
    public func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        // Return mock data based on endpoint
        throw LeavnError.networkError(underlying: "Mock network service - not implemented" as! Error)
    }
    
    public func request(_ endpoint: Endpoint) async throws -> Data {
        return Data()
    }
    
    public func upload(_ endpoint: Endpoint, data: Data) async throws -> Data {
        return Data()
    }
    
    public func download(_ endpoint: Endpoint) async throws -> URL {
        return URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("mock.tmp")
    }
}

// MARK: - Mock Analytics Service
public final class MockAnalyticsService: AnalyticsServiceProtocol {
    private var events: [(event: String, properties: [String: Any]?)] = []
    
    public init() {}
    
    public func track(event: String, properties: [String: Any]?) {
        events.append((event: event, properties: properties))
        print("[MockAnalytics] Event: \(event), Properties: \(properties ?? [:])")
    }
    
    public func trackError(_ error: Error, properties: [String: Any]?) {
        track(event: "error", properties: ["error": error.localizedDescription])
    }
    
    public func identify(userId: String, traits: [String: Any]?) {
        print("[MockAnalytics] Identify: \(userId), Traits: \(traits ?? [:])")
    }
    
    public func reset() {
        events.removeAll()
    }
    
    public func addProvider(_ provider: AnalyticsProvider) {
        // No-op for mock
    }
}

// MARK: - Console Analytics Provider
public final class ConsoleAnalyticsProvider: AnalyticsProvider {
    public init() {}
    
    public func track(event: String, properties: [String: Any]?) {
        print("[Analytics] \(event): \(properties ?? [:])")
    }
    
    public func identify(userId: String, traits: [String: Any]?) {
        print("[Analytics] User \(userId): \(traits ?? [:])")
    }
    
    public func reset() {
        print("[Analytics] Reset")
    }
}

// MARK: - Mock Bible Service
public final class MockBibleService: BibleServiceProtocol {
    public init() {}
    
    public func getChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter {
        BibleChapter(
            book: book,
            chapter: chapter,
            verses: [
                BibleVerse(
                    id: "mock-1",
                    reference: "\(book) \(chapter):1",
                    text: "Mock verse text",
                    book: book,
                    chapter: chapter,
                    verse: 1,
                    translation: translation
                )
            ],
            translation: translation
        )
    }
    
    public func getVerse(reference: String, translation: String) async throws -> BibleVerse {
        BibleVerse(
            id: "mock-verse",
            reference: reference,
            text: "Mock verse text for \(reference)",
            book: "Genesis",
            chapter: 1,
            verse: 1,
            translation: translation
        )
    }
    
    public func searchVerses(query: String, translation: String) async throws -> [BibleVerse] {
        []
    }
    
    public func getAvailableTranslations() async throws -> [BibleTranslation] {
        [
            BibleTranslation(id: "esv", name: "English Standard Version", abbreviation: "ESV", language: "en"),
            BibleTranslation(id: "niv", name: "New International Version", abbreviation: "NIV", language: "en")
        ]
    }
    
    public func getDailyVerse() async throws -> BibleVerse {
        BibleVerse(
            id: "daily",
            reference: "John 3:16",
            text: "For God so loved the world...",
            book: "John",
            chapter: 3,
            verse: 16,
            translation: "ESV"
        )
    }
}

// MARK: - Mock Authentication Service
public final class MockAuthenticationService: AuthenticationServiceProtocol {
    @Published private var _currentUser: AuthUser? = nil
    
    public var currentUser: AnyPublisher<AuthUser?, Never> {
        $_currentUser.eraseToAnyPublisher()
    }
    
    public var isAuthenticated: Bool {
        _currentUser != nil
    }
    
    public init() {}
    
    public func signIn(email: String, password: String) async throws -> AuthUser {
        let user = AuthUser(
            id: "mock-user",
            email: email,
            displayName: "Mock User",
            isEmailVerified: true
        )
        _currentUser = user
        return user
    }
    
    public func signUp(email: String, password: String, name: String) async throws -> AuthUser {
        let user = AuthUser(
            id: "mock-user",
            email: email,
            displayName: name
        )
        _currentUser = user
        return user
    }
    
    public func signOut() async throws {
        _currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {
        // No-op
    }
    
    public func refreshToken() async throws {
        // No-op
    }
}

// MARK: - Mock Cache Managers
public final class InMemoryBibleCacheManager: BibleCacheManagerProtocol {
    private var cache: [String: Any] = [:]
    
    public init() {}
    
    public func cacheChapter(_ chapter: BibleChapter, translation: String) async throws {
        let key = "\(chapter.book)-\(chapter.chapter)-\(translation)"
        cache[key] = chapter
    }
    
    public func getCachedChapter(book: String, chapter: Int, translation: String) async throws -> BibleChapter? {
        let key = "\(book)-\(chapter)-\(translation)"
        return cache[key] as? BibleChapter
    }
    
    public func cacheVerse(_ verse: BibleVerse) async throws {
        cache[verse.reference] = verse
    }
    
    public func getCachedVerse(reference: String, translation: String) async throws -> BibleVerse? {
        cache[reference] as? BibleVerse
    }
    
    public func clearCache() async throws {
        cache.removeAll()
    }
    
    public func getCacheSize() async throws -> Int64 {
        Int64(cache.count * 1024) // Rough estimate
    }
}

public final class InMemoryAudioCacheManager: AudioCacheManagerProtocol {
    private var cache: [String: Data] = [:]
    
    public init() {}
    
    public func cacheAudio(for key: String, data: Data) async throws {
        cache[key] = data
    }
    
    public func getCachedAudio(for key: String) async throws -> Data? {
        cache[key]
    }
    
    public func getCachedAudioURL(for key: String) async throws -> URL? {
        guard let data = cache[key] else { return nil }
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(key).mp3")
        try data.write(to: url)
        return url
    }
    
    public func removeCachedAudio(for key: String) async throws {
        cache.removeValue(forKey: key)
    }
    
    public func clearCache() async throws {
        cache.removeAll()
    }
    
    public func getCacheSize() async throws -> Int64 {
        Int64(cache.values.reduce(0) { $0 + $1.count })
    }
}

// MARK: - Mock ElevenLabs Service
public final class MockElevenLabsService: ElevenLabsServiceProtocol {
    public init() {}
    
    public func generateSpeech(text: String, voiceId: String, modelId: String?) async throws -> Data {
        // Return empty audio data
        Data()
    }
    
    public func getVoices() async throws -> [ElevenLabsVoice] {
        [
            ElevenLabsVoice(id: "rachel", name: "Rachel", category: "news"),
            ElevenLabsVoice(id: "adam", name: "Adam", category: "narration")
        ]
    }
    
    public func getModels() async throws -> [ElevenLabsModel] {
        [
            ElevenLabsModel(id: "eleven_monolingual_v1", name: "Monolingual v1"),
            ElevenLabsModel(id: "eleven_multilingual_v2", name: "Multilingual v2")
        ]
    }
}

// MARK: - Mock Library Repository
public final class MockLibraryRepository: LibraryRepositoryProtocol {
    private var items: [LibraryItem] = []
    private var collections: [LibraryCollection] = []
    
    public init() {}
    
    public func getItems(filter: LibraryFilter?) async throws -> [LibraryItem] {
        items
    }
    
    public func getItem(id: String) async throws -> LibraryItem? {
        items.first { $0.id == id }
    }
    
    public func saveItem(_ item: LibraryItem) async throws {
        items.append(item)
    }
    
    public func updateItem(_ item: LibraryItem) async throws {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        }
    }
    
    public func deleteItem(id: String) async throws {
        items.removeAll { $0.id == id }
    }
    
    public func getCollections() async throws -> [LibraryCollection] {
        collections
    }
    
    public func getCollection(id: String) async throws -> LibraryCollection? {
        collections.first { $0.id == id }
    }
    
    public func createCollection(_ collection: LibraryCollection) async throws {
        collections.append(collection)
    }
    
    public func updateCollection(_ collection: LibraryCollection) async throws {
        if let index = collections.firstIndex(where: { $0.id == collection.id }) {
            collections[index] = collection
        }
    }
    
    public func deleteCollection(id: String) async throws {
        collections.removeAll { $0.id == id }
    }
    
    public func search(query: String, filter: LibraryFilter?) async throws -> [LibraryItem] {
        items.filter { $0.title.lowercased().contains(query.lowercased()) }
    }
    
    public func getStatistics() async throws -> LibraryStatistics {
        var itemsByType: [LibraryContentType: Int] = [:]
        for item in items {
            itemsByType[item.contentType, default: 0] += 1
        }
        return LibraryStatistics(
            totalItems: items.count,
            itemsByType: itemsByType,
            totalCollections: collections.count
        )
    }
    
    public func sync() async throws {
        // No-op
    }
    
    public func getLastSyncDate() async throws -> Date? {
        Date()
    }
}

// MARK: - Mock Settings Repository
public final class MockSettingsRepository: SettingsRepositoryProtocol {
    private var settings = AppSettings.default
    private var history: [SettingsChangeEvent] = []
    private var backups: [SettingsBackup] = []
    
    public init() {}
    
    public func getSettings() async throws -> AppSettings {
        settings
    }
    
    public func updateSettings(_ settings: AppSettings) async throws {
        self.settings = settings
        history.append(SettingsChangeEvent(
            timestamp: Date(),
            settingKey: "all",
            oldValue: nil,
            newValue: nil,
            userId: "mock"
        ))
    }
    
    public func updateSetting<T: Codable>(key: String, value: T) async throws {
        history.append(SettingsChangeEvent(
            timestamp: Date(),
            settingKey: key,
            oldValue: nil,
            newValue: nil,
            userId: "mock"
        ))
    }
    
    public func resetToDefaults() async throws {
        settings = AppSettings.default
    }
    
    public func exportSettings() async throws -> Data {
        try JSONEncoder().encode(settings)
    }
    
    public func importSettings(from data: Data) async throws {
        settings = try JSONDecoder().decode(AppSettings.self, from: data)
    }
    
    public func getSettingsHistory(limit: Int) async throws -> [SettingsChangeEvent] {
        Array(history.prefix(limit))
    }
    
    public func createBackup(name: String) async throws -> SettingsBackup {
        let backup = SettingsBackup(
            name: name,
            settings: settings,
            version: "1.0"
        )
        backups.append(backup)
        return backup
    }
    
    public func getBackups() async throws -> [SettingsBackup] {
        backups
    }
    
    public func restoreBackup(_ backup: SettingsBackup) async throws {
        settings = backup.settings
    }
}

// MARK: - Mock Use Cases
// These now use the protocols defined in LibraryTypes.swift

public final class MockGetLibraryItemsUseCase: GetLibraryItemsUseCaseProtocol {
    public init() {}
    
    public func execute(filter: LibraryFilter?) async throws -> [LibraryItem] {
        []
    }
}

public final class MockSaveContentToLibraryUseCase: SaveContentToLibraryUseCaseProtocol {
    public init() {}
    
    public func execute(item: LibraryItem) async throws {
        // No-op
    }
}

public final class MockManageCollectionsUseCase: ManageCollectionsUseCaseProtocol {
    public init() {}
    
    public func createCollection(_ collection: LibraryCollection) async throws {}
    public func updateCollection(_ collection: LibraryCollection) async throws {}
    public func deleteCollection(id: String) async throws {}
    public func addItemsToCollection(collectionId: String, itemIds: [String]) async throws {}
    public func removeItemsFromCollection(collectionId: String, itemIds: [String]) async throws {}
}

public final class MockManageDownloadsUseCase: ManageDownloadsUseCaseProtocol {
    public init() {}
    
    public func downloadItem(id: String) async throws -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(id).tmp")
    }
    public func cancelDownload(id: String) async throws {}
    public func deleteDownload(id: String) async throws {}
    public func getDownloadProgress(id: String) -> Double { 0.0 }
}

public final class MockSearchLibraryUseCase: SearchLibraryUseCaseProtocol {
    public init() {}
    
    public func execute(query: String, filter: LibraryFilter?) async throws -> [LibraryItem] {
        []
    }
}

public final class MockGetLibraryStatisticsUseCase: GetLibraryStatisticsUseCaseProtocol {
    public init() {}
    
    public func execute() async throws -> LibraryStatistics {
        LibraryStatistics(
            totalItems: 0,
            itemsByType: [:],
            totalCollections: 0
        )
    }
}

public final class MockSyncLibraryUseCase: SyncLibraryUseCaseProtocol {
    public init() {}
    
    public func execute() async throws {}
    public func getLastSyncDate() async throws -> Date? { Date() }
}

// MARK: - Mock Settings View Model
public protocol SettingsViewModelProtocol: ObservableObject {
    var appSettings: AppSettings { get }
    func updateSettings(_ settings: AppSettings) async throws
}

public final class MockSettingsViewModel: SettingsViewModelProtocol {
    @Published public var appSettings = AppSettings.default
    
    public init() {}
    
    public func updateSettings(_ settings: AppSettings) async throws {
        appSettings = settings
    }
}

// MARK: - Mock Library View Model
public final class MockLibraryViewModel: LibraryViewModelProtocol {
    public typealias State = LibraryViewState
    public typealias Event = LibraryViewEvent
    
    @Published public var currentState = LibraryViewState()
    
    public init() {}
    
    public func handle(event: LibraryViewEvent) {
        // Mock implementation
        switch event {
        case .loadItems:
            currentState.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentState.isLoading = false
                self.currentState.items = []
            }
        default:
            break
        }
    }
}

// MARK: - Mock Auth Repository
public final class MockAuthRepository: AuthRepositoryProtocol {
    private var _currentUser: AuthUser?
    private let continuation = AsyncStream<AuthState>.makeStream()
    
    public var currentUser: AuthUser? {
        get async { _currentUser }
    }
    
    public var isAuthenticated: Bool {
        get async { _currentUser != nil }
    }
    
    public var authState: AsyncStream<AuthState> {
        continuation.stream
    }
    
    public init() {}
    
    public func signIn(credentials: AuthCredentials) async throws -> AuthUser {
        let user = AuthUser(
            id: UUID().uuidString,
            email: credentials.email,
            displayName: "Test User"
        )
        _currentUser = user
        continuation.continuation.yield(.authenticated(user))
        return user
    }
    
    public func signInWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser {
        let user = AuthUser(
            id: UUID().uuidString,
            email: "apple@example.com",
            displayName: "Apple User",
            authProvider: .apple
        )
        _currentUser = user
        continuation.continuation.yield(.authenticated(user))
        return user
    }
    
    public func signInWithGoogle(idToken: String) async throws -> AuthUser {
        let user = AuthUser(
            id: UUID().uuidString,
            email: "google@example.com",
            displayName: "Google User",
            authProvider: .google
        )
        _currentUser = user
        continuation.continuation.yield(.authenticated(user))
        return user
    }
    
    public func signUp(credentials: SignUpCredentials) async throws -> AuthUser {
        let user = AuthUser(
            id: UUID().uuidString,
            email: credentials.email,
            displayName: credentials.displayName
        )
        _currentUser = user
        continuation.continuation.yield(.authenticated(user))
        return user
    }
    
    public func signOut() async throws {
        _currentUser = nil
        continuation.continuation.yield(.unauthenticated)
    }
    
    public func refreshSession() async throws -> AuthSession {
        AuthSession(
            accessToken: "mock-token",
            refreshToken: "mock-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userId: _currentUser?.id ?? "unknown"
        )
    }
    
    public func getCurrentSession() async throws -> AuthSession? {
        guard let user = _currentUser else { return nil }
        return AuthSession(
            accessToken: "mock-token",
            refreshToken: "mock-refresh",
            expiresAt: Date().addingTimeInterval(3600),
            userId: user.id
        )
    }
    
    public func deleteSession() async throws {
        _currentUser = nil
    }
    
    public func resetPassword(email: String) async throws {}
    
    public func updatePassword(request: PasswordUpdateRequest) async throws {}
    
    public func verifyPassword(password: String) async throws -> Bool { true }
    
    public func updateProfile(request: ProfileUpdateRequest) async throws -> AuthUser {
        guard var user = _currentUser else {
            throw LeavnError.authenticationError("Not authenticated")
        }
        if let displayName = request.displayName {
            user = AuthUser(
                id: user.id,
                email: user.email,
                displayName: displayName,
                photoURL: request.photoURL ?? user.photoURL,
                isEmailVerified: user.isEmailVerified,
                authProvider: user.authProvider,
                createdAt: user.createdAt
            )
            _currentUser = user
        }
        return user
    }
    
    public func uploadProfilePhoto(imageData: Data) async throws -> URL {
        URL(string: "https://example.com/photo.jpg")!
    }
    
    public func deleteAccount() async throws {
        _currentUser = nil
    }
    
    public func sendEmailVerification() async throws {}
    
    public func verifyEmail(code: String) async throws {}
    
    public func resendEmailVerification() async throws {}
}

// MARK: - Mock Auth Use Cases
public final class MockSignInUseCase: SignInUseCaseProtocol {
    public init() {}
    
    public func execute(credentials: AuthCredentials) async throws -> AuthUser {
        AuthUser(
            id: "mock-user",
            email: credentials.email,
            displayName: "Mock User"
        )
    }
    
    public func executeWithApple(credentials: AppleAuthCredentials) async throws -> AuthUser {
        AuthUser(
            id: "mock-apple-user",
            email: "apple@example.com",
            displayName: "Apple User",
            authProvider: .apple
        )
    }
    
    public func executeWithGoogle(idToken: String) async throws -> AuthUser {
        AuthUser(
            id: "mock-google-user",
            email: "google@example.com",
            displayName: "Google User",
            authProvider: .google
        )
    }
}

public final class MockSignUpUseCase: SignUpUseCaseProtocol {
    public init() {}
    
    public func execute(credentials: SignUpCredentials) async throws -> AuthUser {
        AuthUser(
            id: "mock-new-user",
            email: credentials.email,
            displayName: credentials.displayName
        )
    }
}

public final class MockSignOutUseCase: SignOutUseCaseProtocol {
    public init() {}
    
    public func execute() async throws {}
}

public final class MockResetPasswordUseCase: ResetPasswordUseCaseProtocol {
    public init() {}
    
    public func execute(email: String) async throws {}
}

public final class MockUpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    public init() {}
    
    public func execute(request: ProfileUpdateRequest) async throws -> AuthUser {
        AuthUser(
            id: "mock-user",
            email: "user@example.com",
            displayName: request.displayName ?? "Updated User",
            photoURL: request.photoURL
        )
    }
    
    public func uploadPhoto(imageData: Data) async throws -> URL {
        URL(string: "https://example.com/photo.jpg")!
    }
}

public final class MockVerifyEmailUseCase: VerifyEmailUseCaseProtocol {
    public init() {}
    
    public func sendVerification() async throws {}
    
    public func verify(code: String) async throws {}
    
    public func resendVerification() async throws {}
}

// MARK: - Mock Auth View Model
public final class MockAuthViewModel: AuthViewModelProtocol {
    @Published public var currentState = AuthViewState()
    
    public init() {}
    
    public func handle(event: AuthViewEvent) {
        // Mock implementation
        switch event {
        case .updateEmail(let email):
            currentState.email = email
        case .updatePassword(let password):
            currentState.password = password
        case .signIn:
            currentState.isLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.currentState.isLoading = false
                self.currentState.isAuthenticated = true
                self.currentState.user = AuthUser(
                    id: "mock",
                    email: self.currentState.email,
                    displayName: "Mock User"
                )
            }
        default:
            break
        }
    }
}

