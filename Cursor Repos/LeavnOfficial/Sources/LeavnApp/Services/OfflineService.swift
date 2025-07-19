import Foundation
import Dependencies
import Network
import Combine

// MARK: - Offline Service
@MainActor
public final class OfflineService {
    // Network monitoring
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.leavn.networkMonitor")
    
    // Published properties
    @Published public private(set) var isOnline = true
    @Published public private(set) var connectionType: ConnectionType = .unknown
    @Published public private(set) var syncStatus: SyncStatus = .idle
    @Published public private(set) var pendingSyncItems: Int = 0
    
    // Offline storage
    private let offlineStorage = OfflineStorage()
    
    // Sync queue
    private var syncQueue: [SyncItem] = []
    private var syncTimer: Timer?
    
    public init() {
        setupNetworkMonitoring()
        loadPendingSyncItems()
    }
    
    // MARK: - Public Methods
    
    // Bible content
    public func downloadPassageForOffline(_ reference: BibleReference) async throws {
        @Dependency(\.bibleService) var bibleService
        @Dependency(\.elevenLabsClient) var elevenLabs
        @Dependency(\.settingsService) var settings
        
        // Get passage text
        let passage = try await bibleService.fetchPassage(reference)
        
        // Get audio settings
        let audioSettings = await settings.getAudioSettings()
        
        // Generate audio if voice is set
        var audioData: Data?
        if !audioSettings.defaultVoice.isEmpty {
            let voices = try await elevenLabs.getVoices()
            if let voice = voices.first(where: { $0.name == audioSettings.defaultVoice }) {
                audioData = try await elevenLabs.textToSpeech(passage.text, voice.id)
            }
        }
        
        // Save offline
        try await offlineStorage.savePassage(
            reference: reference,
            text: passage.text,
            audioData: audioData
        )
    }
    
    public func getOfflinePassage(_ reference: BibleReference) async throws -> OfflinePassage? {
        try await offlineStorage.getPassage(reference)
    }
    
    public func deleteOfflinePassage(_ reference: BibleReference) async throws {
        try await offlineStorage.deletePassage(reference)
    }
    
    public func getAllOfflinePassages() async throws -> [OfflinePassage] {
        try await offlineStorage.getAllPassages()
    }
    
    // Community content
    public func queuePrayerForSync(_ prayer: Prayer, action: SyncAction) {
        let syncItem = SyncItem(
            id: UUID(),
            type: .prayer,
            action: action,
            data: try? JSONEncoder().encode(prayer),
            timestamp: Date(),
            retryCount: 0
        )
        
        syncQueue.append(syncItem)
        pendingSyncItems = syncQueue.count
        
        // Try to sync if online
        if isOnline {
            Task {
                await processSyncQueue()
            }
        }
    }
    
    public func queueGroupActionForSync(_ groupId: GroupID, action: SyncAction, metadata: [String: String]? = nil) {
        let data = GroupSyncData(groupId: groupId, metadata: metadata)
        
        let syncItem = SyncItem(
            id: UUID(),
            type: .group,
            action: action,
            data: try? JSONEncoder().encode(data),
            timestamp: Date(),
            retryCount: 0
        )
        
        syncQueue.append(syncItem)
        pendingSyncItems = syncQueue.count
        
        // Try to sync if online
        if isOnline {
            Task {
                await processSyncQueue()
            }
        }
    }
    
    // Library content
    public func saveLibraryItemOffline<T: Codable>(_ item: T, type: LibraryItemType) async throws {
        let syncItem = SyncItem(
            id: UUID(),
            type: .library(type),
            action: .create,
            data: try JSONEncoder().encode(item),
            timestamp: Date(),
            retryCount: 0
        )
        
        try await offlineStorage.saveSyncItem(syncItem)
        syncQueue.append(syncItem)
        pendingSyncItems = syncQueue.count
    }
    
    // MARK: - Private Methods
    
    private func setupNetworkMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isOnline = path.status == .satisfied
                self?.updateConnectionType(path)
                
                // If we're back online, process sync queue
                if path.status == .satisfied {
                    Task {
                        await self?.processSyncQueue()
                    }
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    private func updateConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
    
    private func loadPendingSyncItems() {
        Task {
            syncQueue = await offlineStorage.getPendingSyncItems()
            pendingSyncItems = syncQueue.count
        }
    }
    
    private func processSyncQueue() async {
        guard isOnline && !syncQueue.isEmpty && syncStatus != .syncing else { return }
        
        syncStatus = .syncing
        
        @Dependency(\.communityService) var communityService
        @Dependency(\.libraryService) var libraryService
        
        var failedItems: [SyncItem] = []
        
        for item in syncQueue {
            do {
                switch item.type {
                case .prayer:
                    if let prayer = try? JSONDecoder().decode(Prayer.self, from: item.data ?? Data()) {
                        switch item.action {
                        case .create:
                            _ = try await communityService.createPrayer(prayer)
                        case .update:
                            _ = try await communityService.updatePrayer(prayer)
                        case .delete:
                            try await communityService.deletePrayer(prayer.id)
                        }
                    }
                    
                case .group:
                    if let data = try? JSONDecoder().decode(GroupSyncData.self, from: item.data ?? Data()) {
                        switch item.action {
                        case .create:
                            // Handle group creation
                            break
                        case .update:
                            // Handle group update
                            break
                        case .delete:
                            try await communityService.deleteGroup(data.groupId)
                        }
                    }
                    
                case .library(let type):
                    switch type {
                    case .bookmark:
                        if let bookmark = try? JSONDecoder().decode(Bookmark.self, from: item.data ?? Data()) {
                            switch item.action {
                            case .create:
                                _ = try await libraryService.createBookmark(bookmark)
                            case .update:
                                _ = try await libraryService.updateBookmark(bookmark)
                            case .delete:
                                try await libraryService.deleteBookmark(bookmark.id)
                            }
                        }
                        
                    case .note:
                        if let note = try? JSONDecoder().decode(Note.self, from: item.data ?? Data()) {
                            switch item.action {
                            case .create:
                                _ = try await libraryService.createNote(note)
                            case .update:
                                _ = try await libraryService.updateNote(note)
                            case .delete:
                                try await libraryService.deleteNote(note.id)
                            }
                        }
                        
                    case .highlight:
                        if let highlight = try? JSONDecoder().decode(Highlight.self, from: item.data ?? Data()) {
                            switch item.action {
                            case .create:
                                _ = try await libraryService.createHighlight(highlight)
                            case .update:
                                _ = try await libraryService.updateHighlight(highlight)
                            case .delete:
                                try await libraryService.deleteHighlight(highlight.id)
                            }
                        }
                    }
                }
                
                // Remove successful item from storage
                try await offlineStorage.deleteSyncItem(item.id)
                
            } catch {
                // Increment retry count
                var failedItem = item
                failedItem.retryCount += 1
                
                // If too many retries, remove from queue
                if failedItem.retryCount < 3 {
                    failedItems.append(failedItem)
                } else {
                    try? await offlineStorage.deleteSyncItem(item.id)
                }
            }
        }
        
        // Update queue with failed items
        syncQueue = failedItems
        pendingSyncItems = syncQueue.count
        
        syncStatus = syncQueue.isEmpty ? .completed : .failed
        
        // Schedule next sync if there are pending items
        if !syncQueue.isEmpty {
            scheduleSyncRetry()
        }
    }
    
    private func scheduleSyncRetry() {
        syncTimer?.invalidate()
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30, repeats: false) { [weak self] _ in
            Task {
                await self?.processSyncQueue()
            }
        }
    }
}

// MARK: - Models
public enum ConnectionType {
    case wifi
    case cellular
    case ethernet
    case unknown
}

public enum SyncStatus {
    case idle
    case syncing
    case completed
    case failed
}

public enum SyncAction: String, Codable {
    case create
    case update
    case delete
}

public struct SyncItem: Codable, Identifiable {
    let id: UUID
    let type: SyncItemType
    let action: SyncAction
    let data: Data?
    let timestamp: Date
    var retryCount: Int
}

public enum SyncItemType: Codable {
    case prayer
    case group
    case library(LibraryItemType)
    
    private enum CodingKeys: String, CodingKey {
        case type
        case subtype
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "prayer":
            self = .prayer
        case "group":
            self = .group
        case "library":
            let subtype = try container.decode(LibraryItemType.self, forKey: .subtype)
            self = .library(subtype)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown sync item type")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .prayer:
            try container.encode("prayer", forKey: .type)
        case .group:
            try container.encode("group", forKey: .type)
        case .library(let subtype):
            try container.encode("library", forKey: .type)
            try container.encode(subtype, forKey: .subtype)
        }
    }
}

public enum LibraryItemType: String, Codable {
    case bookmark
    case note
    case highlight
}

struct GroupSyncData: Codable {
    let groupId: GroupID
    let metadata: [String: String]?
}

public struct OfflinePassage: Identifiable {
    public let id: UUID
    public let reference: BibleReference
    public let text: String
    public let audioURL: URL?
    public let downloadedAt: Date
    public let sizeInBytes: Int64
}

// MARK: - Offline Storage
private actor OfflineStorage {
    private let documentsDirectory: URL
    private let passagesDirectory: URL
    private let syncDirectory: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        self.documentsDirectory = documentsPath
        self.passagesDirectory = documentsPath.appendingPathComponent("OfflinePassages")
        self.syncDirectory = documentsPath.appendingPathComponent("SyncQueue")
        
        // Create directories if needed
        try? FileManager.default.createDirectory(at: passagesDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: syncDirectory, withIntermediateDirectories: true)
    }
    
    func savePassage(reference: BibleReference, text: String, audioData: Data?) throws {
        let passageId = UUID()
        let passageDir = passagesDirectory.appendingPathComponent(passageId.uuidString)
        try FileManager.default.createDirectory(at: passageDir, withIntermediateDirectories: true)
        
        // Save text
        let textFile = passageDir.appendingPathComponent("text.txt")
        try text.write(to: textFile, atomically: true, encoding: .utf8)
        
        // Save audio if available
        var audioURL: URL?
        if let audioData = audioData {
            let audioFile = passageDir.appendingPathComponent("audio.mp3")
            try audioData.write(to: audioFile)
            audioURL = audioFile
        }
        
        // Save metadata
        let metadata = PassageMetadata(
            id: passageId,
            reference: reference,
            audioAvailable: audioURL != nil,
            downloadedAt: Date(),
            sizeInBytes: calculateDirectorySize(passageDir)
        )
        
        let metadataFile = passageDir.appendingPathComponent("metadata.json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let metadataData = try encoder.encode(metadata)
        try metadataData.write(to: metadataFile)
    }
    
    func getPassage(_ reference: BibleReference) throws -> OfflinePassage? {
        // Find passage directory
        let contents = try FileManager.default.contentsOfDirectory(at: passagesDirectory, includingPropertiesForKeys: nil)
        
        for dir in contents {
            let metadataFile = dir.appendingPathComponent("metadata.json")
            guard FileManager.default.fileExists(atPath: metadataFile.path) else { continue }
            
            let data = try Data(contentsOf: metadataFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadata = try decoder.decode(PassageMetadata.self, from: data)
            
            if metadata.reference == reference {
                let textFile = dir.appendingPathComponent("text.txt")
                let text = try String(contentsOf: textFile)
                
                var audioURL: URL?
                if metadata.audioAvailable {
                    let audioFile = dir.appendingPathComponent("audio.mp3")
                    if FileManager.default.fileExists(atPath: audioFile.path) {
                        audioURL = audioFile
                    }
                }
                
                return OfflinePassage(
                    id: metadata.id,
                    reference: metadata.reference,
                    text: text,
                    audioURL: audioURL,
                    downloadedAt: metadata.downloadedAt,
                    sizeInBytes: metadata.sizeInBytes
                )
            }
        }
        
        return nil
    }
    
    func deletePassage(_ reference: BibleReference) throws {
        let contents = try FileManager.default.contentsOfDirectory(at: passagesDirectory, includingPropertiesForKeys: nil)
        
        for dir in contents {
            let metadataFile = dir.appendingPathComponent("metadata.json")
            guard FileManager.default.fileExists(atPath: metadataFile.path) else { continue }
            
            let data = try Data(contentsOf: metadataFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadata = try decoder.decode(PassageMetadata.self, from: data)
            
            if metadata.reference == reference {
                try FileManager.default.removeItem(at: dir)
                break
            }
        }
    }
    
    func getAllPassages() throws -> [OfflinePassage] {
        var passages: [OfflinePassage] = []
        let contents = try FileManager.default.contentsOfDirectory(at: passagesDirectory, includingPropertiesForKeys: nil)
        
        for dir in contents {
            let metadataFile = dir.appendingPathComponent("metadata.json")
            guard FileManager.default.fileExists(atPath: metadataFile.path) else { continue }
            
            let data = try Data(contentsOf: metadataFile)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let metadata = try decoder.decode(PassageMetadata.self, from: data)
            
            let textFile = dir.appendingPathComponent("text.txt")
            let text = try String(contentsOf: textFile)
            
            var audioURL: URL?
            if metadata.audioAvailable {
                let audioFile = dir.appendingPathComponent("audio.mp3")
                if FileManager.default.fileExists(atPath: audioFile.path) {
                    audioURL = audioFile
                }
            }
            
            passages.append(OfflinePassage(
                id: metadata.id,
                reference: metadata.reference,
                text: text,
                audioURL: audioURL,
                downloadedAt: metadata.downloadedAt,
                sizeInBytes: metadata.sizeInBytes
            ))
        }
        
        return passages
    }
    
    func saveSyncItem(_ item: SyncItem) throws {
        let file = syncDirectory.appendingPathComponent("\(item.id.uuidString).json")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(item)
        try data.write(to: file)
    }
    
    func deleteSyncItem(_ id: UUID) throws {
        let file = syncDirectory.appendingPathComponent("\(id.uuidString).json")
        try FileManager.default.removeItem(at: file)
    }
    
    func getPendingSyncItems() -> [SyncItem] {
        var items: [SyncItem] = []
        
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: syncDirectory, includingPropertiesForKeys: nil)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            for file in contents where file.pathExtension == "json" {
                if let data = try? Data(contentsOf: file),
                   let item = try? decoder.decode(SyncItem.self, from: data) {
                    items.append(item)
                }
            }
        } catch {
            print("Failed to load sync items: \(error)")
        }
        
        return items.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func calculateDirectorySize(_ url: URL) -> Int64 {
        var size: Int64 = 0
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.fileSizeKey]) {
            for case let fileURL as URL in enumerator {
                if let attributes = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
                   let fileSize = attributes.fileSize {
                    size += Int64(fileSize)
                }
            }
        }
        
        return size
    }
}

private struct PassageMetadata: Codable {
    let id: UUID
    let reference: BibleReference
    let audioAvailable: Bool
    let downloadedAt: Date
    let sizeInBytes: Int64
}

// MARK: - Dependency
struct OfflineServiceKey: DependencyKey {
    static let liveValue = OfflineService()
}

extension DependencyValues {
    var offlineService: OfflineService {
        get { self[OfflineServiceKey.self] }
        set { self[OfflineServiceKey.self] = newValue }
    }
}