import Dependencies
import Foundation
import ComposableArchitecture

// MARK: - Bible Service
struct BibleServiceKey: DependencyKey {
    static let liveValue: BibleService = BibleService(
        esvClient: ESVClient.live,
        audioService: EnhancedAudioService.live,
        offlineService: OfflineService.live
    )
}

extension DependencyValues {
    var bibleService: BibleService {
        get { self[BibleServiceKey.self] }
        set { self[BibleServiceKey.self] = newValue }
    }
}

// MARK: - ESV Client
struct ESVClientKey: DependencyKey {
    static let liveValue: ESVClient = ESVClient.live
}

extension DependencyValues {
    var esvClient: ESVClient {
        get { self[ESVClientKey.self] }
        set { self[ESVClientKey.self] = newValue }
    }
}

// MARK: - ElevenLabs Client
struct ElevenLabsClientKey: DependencyKey {
    static let liveValue: ElevenLabsClient = ElevenLabsClient.live
}

extension DependencyValues {
    var elevenLabsClient: ElevenLabsClient {
        get { self[ElevenLabsClientKey.self] }
        set { self[ElevenLabsClientKey.self] = newValue }
    }
}

// MARK: - Audio Service
struct AudioServiceKey: DependencyKey {
    static let liveValue: AudioService = AudioService()
}

extension DependencyValues {
    var audioService: AudioService {
        get { self[AudioServiceKey.self] }
        set { self[AudioServiceKey.self] = newValue }
    }
}

// MARK: - Enhanced Audio Service
struct EnhancedAudioServiceKey: DependencyKey {
    static let liveValue: EnhancedAudioService = EnhancedAudioService.live
}

extension DependencyValues {
    var enhancedAudioService: EnhancedAudioService {
        get { self[EnhancedAudioServiceKey.self] }
        set { self[EnhancedAudioServiceKey.self] = newValue }
    }
}

// MARK: - Community Service
struct CommunityServiceKey: DependencyKey {
    static let liveValue: CommunityService = CommunityService.live
}

extension DependencyValues {
    var communityService: CommunityService {
        get { self[CommunityServiceKey.self] }
        set { self[CommunityServiceKey.self] = newValue }
    }
}

// MARK: - Community Client
struct CommunityClientKey: DependencyKey {
    static let liveValue: CommunityClient = CommunityClient.live
}

extension DependencyValues {
    var communityClient: CommunityClient {
        get { self[CommunityClientKey.self] }
        set { self[CommunityClientKey.self] = newValue }
    }
}

// MARK: - Library Service
struct LibraryServiceKey: DependencyKey {
    static let liveValue: LibraryService = LibraryService.live
}

extension DependencyValues {
    var libraryService: LibraryService {
        get { self[LibraryServiceKey.self] }
        set { self[LibraryServiceKey.self] = newValue }
    }
}

// MARK: - Settings Service
struct SettingsServiceKey: DependencyKey {
    static let liveValue: SettingsService = SettingsService.live
}

extension DependencyValues {
    var settingsService: SettingsService {
        get { self[SettingsServiceKey.self] }
        set { self[SettingsServiceKey.self] = newValue }
    }
}

// MARK: - Database Client
struct DatabaseClientKey: DependencyKey {
    static let liveValue: DatabaseClient = DatabaseClient.live
}

extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClientKey.self] }
        set { self[DatabaseClientKey.self] = newValue }
    }
}

// MARK: - Download Client
struct DownloadClientKey: DependencyKey {
    static let liveValue: DownloadClient = DownloadClient.live
}

extension DependencyValues {
    var downloadClient: DownloadClient {
        get { self[DownloadClientKey.self] }
        set { self[DownloadClientKey.self] = newValue }
    }
}

// MARK: - WebSocket Service
struct WebSocketServiceKey: DependencyKey {
    static let liveValue: WebSocketService = WebSocketService.live
}

extension DependencyValues {
    var webSocketService: WebSocketService {
        get { self[WebSocketServiceKey.self] }
        set { self[WebSocketServiceKey.self] = newValue }
    }
}

// MARK: - Offline Service
struct OfflineServiceKey: DependencyKey {
    static let liveValue: OfflineService = OfflineService.live
}

extension DependencyValues {
    var offlineService: OfflineService {
        get { self[OfflineServiceKey.self] }
        set { self[OfflineServiceKey.self] = newValue }
    }
}

// MARK: - Auth Client
struct AuthClientKey: DependencyKey {
    static let liveValue: AuthClient = AuthClient.live
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClientKey.self] }
        set { self[AuthClientKey.self] = newValue }
    }
}

// MARK: - Network Layer
struct NetworkLayerKey: DependencyKey {
    static let liveValue: NetworkLayer = NetworkLayer.live
}

extension DependencyValues {
    var networkLayer: NetworkLayer {
        get { self[NetworkLayerKey.self] }
        set { self[NetworkLayerKey.self] = newValue }
    }
}