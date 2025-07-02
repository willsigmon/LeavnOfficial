import Foundation
import LeavnCore
typealias User = LeavnCore.User
import CloudKit

// MARK: - Production CloudKit Sync Service

@available(iOS 14.0, macOS 11.0, watchOS 7.0, *)
public actor ProductionCloudSyncService: SyncServiceProtocol {
    
    // MARK: - Properties
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let publicDatabase: CKDatabase
    private let userService: UserServiceProtocol
    private let libraryService: LibraryServiceProtocol
    
    private var isInitialized = false
    private var syncInProgress = false
    private var lastSyncDate: Date?
    
    // CloudKit Record Types
    private enum RecordType {
        static let userProfile = "UserProfile"
        static let bookmark = "Bookmark"
        static let readingPlan = "ReadingPlan"
        static let readingHistory = "ReadingHistory"
        static let note = "Note"
    }
    
    // MARK: - Initialization
    
    public init(userService: UserServiceProtocol, libraryService: LibraryServiceProtocol) {
        self.container = CKContainer(identifier: "iCloud.com.leavn.bible")
        self.privateDatabase = container.privateCloudDatabase
        self.publicDatabase = container.publicCloudDatabase
        self.userService = userService
        self.libraryService = libraryService
    }
    
    public func initialize() async throws {
        // Check CloudKit availability
        let accountStatus = try await container.accountStatus()
        guard accountStatus == .available else {
            throw ServiceError.authenticationRequired
        }
        
        // Set up CloudKit subscriptions
        try await setupSubscriptions()
        
        isInitialized = true
        print("☁️ ProductionCloudSyncService initialized")
    }
    
    // MARK: - SyncServiceProtocol Implementation
    
    public func syncData() async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        guard !syncInProgress else {
            print("Sync already in progress")
            return
        }
        
        syncInProgress = true
        defer { syncInProgress = false }
        
        do {
            // Sync user profile
            try await syncUserProfile()
            
            // Sync library data
            try await syncBookmarks()
            try await syncReadingPlans()
            try await syncReadingHistory()
            
            lastSyncDate = Date()
            print("☁️ Sync completed successfully")
        } catch {
            print("☁️ Sync failed: \(error)")
            throw error
        }
    }
    
    public func enableSync() async throws {
        guard isInitialized else {
            throw ServiceError.notInitialized
        }
        
        // Enable automatic sync
        UserDefaults.standard.set(true, forKey: "cloudSyncEnabled")
        
        // Perform initial sync
        try await syncData()
    }
    
    public func disableSync() async throws {
        UserDefaults.standard.set(false, forKey: "cloudSyncEnabled")
        print("☁️ CloudKit sync disabled")
    }
    
    public func getSyncStatus() async -> SyncStatus {
        if syncInProgress {
            return .syncing
        }
        
        if lastSyncDate != nil {
            return .completed
        }
        
        if !UserDefaults.standard.bool(forKey: "cloudSyncEnabled") {
            return .disabled
        }
        
        return .failed
    }
    
    public func forceSyncUser() async throws {
        try await syncUserProfile()
    }
    
    public func forceSyncLibrary() async throws {
        try await syncBookmarks()
        try await syncReadingPlans()
        try await syncReadingHistory()
    }
    
    // MARK: - Private Sync Methods
    
    private func syncUserProfile() async throws {
        guard let user = try await userService.getCurrentUser() else {
            return
        }
        
        // Check if user profile exists in CloudKit
        let recordID = CKRecord.ID(recordName: "UserProfile_\(user.id)")
        
        do {
            let existingRecord = try await privateDatabase.record(for: recordID)
            // Update existing record
            updateUserProfileRecord(existingRecord, with: user)
            _ = try await privateDatabase.save(existingRecord)
        } catch CKError.unknownItem {
            // Create new record
            let newRecord = createUserProfileRecord(from: user)
            _ = try await privateDatabase.save(newRecord)
        }
    }
    
    private func syncBookmarks() async throws {
        let localBookmarks = try await libraryService.getBookmarks()
        
        // Fetch remote bookmarks
        let query = CKQuery(recordType: RecordType.bookmark, predicate: NSPredicate(value: true))
        let remoteRecords = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }
        
        // Convert to bookmarks
        let remoteBookmarks = remoteRecords.compactMap { createBookmark(from: $0) }
        
        // Merge and sync
        try await mergeAndSyncBookmarks(local: localBookmarks, remote: remoteBookmarks)
    }
    
    private func syncReadingPlans() async throws {
        let localPlans = try await libraryService.getReadingPlans()
        
        // Fetch remote reading plans
        let query = CKQuery(recordType: RecordType.readingPlan, predicate: NSPredicate(value: true))
        let remoteRecords = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }
        
        // Convert to reading plans
        let remotePlans = remoteRecords.compactMap { createReadingPlan(from: $0) }
        
        // Merge and sync
        try await mergeAndSyncReadingPlans(local: localPlans, remote: remotePlans)
    }
    
    private func syncReadingHistory() async throws {
        let localHistory = try await libraryService.getReadingHistory()
        
        // Fetch recent remote history (last 30 days)
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let predicate = NSPredicate(format: "timestamp >= %@", thirtyDaysAgo as NSDate)
        let query = CKQuery(recordType: RecordType.readingHistory, predicate: predicate)
        
        let remoteRecords = try await privateDatabase.records(matching: query).matchResults.compactMap { try? $0.1.get() }
        
        // Convert to reading history
        let remoteHistory = remoteRecords.compactMap { createReadingHistory(from: $0) }
        
        // Merge and sync
        try await mergeAndSyncReadingHistory(local: localHistory, remote: remoteHistory)
    }
    
    // MARK: - Record Creation Methods
    
    private func createUserProfileRecord(from user: User) -> CKRecord {
        let recordID = CKRecord.ID(recordName: "UserProfile_\(user.id)")
        let record = CKRecord(recordType: RecordType.userProfile, recordID: recordID)
        
        updateUserProfileRecord(record, with: user)
        return record
    }
    
    private func updateUserProfileRecord(_ record: CKRecord, with user: User) {
        record["name"] = user.name
        record["email"] = user.email
        record["defaultTranslation"] = user.preferences.defaultTranslation
        record["fontSize"] = user.preferences.fontSize
        record["theme"] = user.preferences.theme.rawValue
        record["dailyVerseEnabled"] = user.preferences.dailyVerseEnabled
        record["updatedAt"] = user.updatedAt
    }
    
    private func createBookmarkRecord(from bookmark: Bookmark) -> CKRecord {
        let recordID = CKRecord.ID(recordName: "Bookmark_\(bookmark.id)")
        let record = CKRecord(recordType: RecordType.bookmark, recordID: recordID)
        
        record["verseId"] = bookmark.verse.id
        record["verseName"] = bookmark.verse.bookName
        record["chapter"] = bookmark.verse.chapter
        record["verse"] = bookmark.verse.verse
        record["text"] = bookmark.verse.text
        record["translation"] = bookmark.verse.translation
        record["note"] = bookmark.note
        record["tags"] = bookmark.tags
        record["color"] = bookmark.color
        record["createdAt"] = bookmark.createdAt
        record["updatedAt"] = bookmark.updatedAt
        
        return record
    }
    
    private func createReadingPlanRecord(from plan: ReadingPlan) -> CKRecord {
        let recordID = CKRecord.ID(recordName: "ReadingPlan_\(plan.id)")
        let record = CKRecord(recordType: RecordType.readingPlan, recordID: recordID)
        
        record["name"] = plan.name
        record["description"] = plan.description
        record["duration"] = plan.duration
        record["isActive"] = plan.isActive
        record["startDate"] = plan.startDate
        record["progress"] = plan.progress
        
        // Store reading plan days as JSON
        if let daysData = try? JSONEncoder().encode(plan.days) {
            record["daysData"] = daysData
        }
        
        return record
    }
    
    private func createReadingHistoryRecord(from history: ReadingHistory) -> CKRecord {
        let recordID = CKRecord.ID(recordName: "ReadingHistory_\(history.id)")
        let record = CKRecord(recordType: RecordType.readingHistory, recordID: recordID)
        
        record["book"] = history.book
        record["chapter"] = history.chapter
        record["startVerse"] = history.startVerse
        record["endVerse"] = history.endVerse
        record["translation"] = history.translation
        record["duration"] = history.duration
        record["timestamp"] = history.timestamp
        
        return record
    }
    
    // MARK: - Model Creation Methods
    
    private func createBookmark(from record: CKRecord) -> Bookmark? {
        guard let verseName = record["verseName"] as? String,
              let chapter = record["chapter"] as? Int,
              let verseNumber = record["verse"] as? Int,
              let text = record["text"] as? String,
              let translation = record["translation"] as? String,
              let createdAt = record["createdAt"] as? Date,
              let updatedAt = record["updatedAt"] as? Date else {
            return nil
        }
        
        let verseObj = BibleVerse(
            id: record["verseId"] as? String ?? UUID().uuidString,
            bookName: verseName,
            bookId: verseName.lowercased().replacingOccurrences(of: " ", with: ""),
            chapter: chapter,
            verse: verseNumber,
            text: text,
            translation: translation
        )
        
        return Bookmark(
            id: record.recordID.recordName.replacingOccurrences(of: "Bookmark_", with: ""),
            verse: verseObj,
            note: record["note"] as? String,
            tags: record["tags"] as? [String] ?? [],
            color: record["color"] as? String,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func createReadingPlan(from record: CKRecord) -> ReadingPlan? {
        guard let name = record["name"] as? String,
              let description = record["description"] as? String,
              let duration = record["duration"] as? Int,
              let isActive = record["isActive"] as? Bool,
              let progress = record["progress"] as? Double else {
            return nil
        }
        
        var days: [ReadingPlanDay] = []
        if let daysData = record["daysData"] as? Data {
            days = (try? JSONDecoder().decode([ReadingPlanDay].self, from: daysData)) ?? []
        }
        
        return ReadingPlan(
            id: record.recordID.recordName.replacingOccurrences(of: "ReadingPlan_", with: ""),
            name: name,
            description: description,
            duration: duration,
            days: days,
            isActive: isActive,
            startDate: record["startDate"] as? Date,
            progress: progress
        )
    }
    
    private func createReadingHistory(from record: CKRecord) -> ReadingHistory? {
        guard let book = record["book"] as? String,
              let chapter = record["chapter"] as? Int,
              let translation = record["translation"] as? String,
              let timestamp = record["timestamp"] as? Date else {
            return nil
        }
        
        return ReadingHistory(
            id: record.recordID.recordName.replacingOccurrences(of: "ReadingHistory_", with: ""),
            book: book,
            chapter: chapter,
            startVerse: record["startVerse"] as? Int,
            endVerse: record["endVerse"] as? Int,
            translation: translation,
            timestamp: timestamp, duration: record["duration"] as? TimeInterval
        )
    }
    
    // MARK: - Merge Methods
    
    private func mergeAndSyncBookmarks(local: [Bookmark], remote: [Bookmark]) async throws {
        let remoteDict = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        
        for localBookmark in local {
            if let remoteBookmark = remoteDict[localBookmark.id] {
                // Merge conflicts (use most recent)
                if localBookmark.updatedAt > remoteBookmark.updatedAt {
                    // Upload local version
                    let record = createBookmarkRecord(from: localBookmark)
                    _ = try await privateDatabase.save(record)
                } else if remoteBookmark.updatedAt > localBookmark.updatedAt {
                    // Update local version
                    try await libraryService.updateBookmark(remoteBookmark)
                }
            } else {
                // Upload new local bookmark
                let record = createBookmarkRecord(from: localBookmark)
                _ = try await privateDatabase.save(record)
            }
        }
        
        // Download new remote bookmarks
        for remoteBookmark in remote {
            if !local.contains(where: { $0.id == remoteBookmark.id }) {
                try await libraryService.addBookmark(remoteBookmark)
            }
        }
    }
    
    private func mergeAndSyncReadingPlans(local: [ReadingPlan], remote: [ReadingPlan]) async throws {
        let remoteDict = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        
        for localPlan in local {
            if let remotePlan = remoteDict[localPlan.id] {
                // Simple merge - use the one with higher progress
                if localPlan.progress >= remotePlan.progress {
                    let record = createReadingPlanRecord(from: localPlan)
                    _ = try await privateDatabase.save(record)
                } else {
                    try await libraryService.updateReadingPlan(remotePlan)
                }
            } else {
                // Upload new local plan
                let record = createReadingPlanRecord(from: localPlan)
                _ = try await privateDatabase.save(record)
            }
        }
        
        // Download new remote plans
        for remotePlan in remote {
            if !local.contains(where: { $0.id == remotePlan.id }) {
                try await libraryService.addReadingPlan(remotePlan)
            }
        }
    }
    
    private func mergeAndSyncReadingHistory(local: [ReadingHistory], remote: [ReadingHistory]) async throws {
        let remoteDict = Dictionary(uniqueKeysWithValues: remote.map { ($0.id, $0) })
        
        // Upload new local history entries
        for localEntry in local {
            if remoteDict[localEntry.id] == nil {
                let record = createReadingHistoryRecord(from: localEntry)
                _ = try await privateDatabase.save(record)
            }
        }
        
        // Download new remote history entries
        for remoteEntry in remote {
            if !local.contains(where: { $0.id == remoteEntry.id }) {
                try await libraryService.addReadingEntry(remoteEntry)
            }
        }
    }
    
    // MARK: - CloudKit Setup
    
    private func setupSubscriptions() async throws {
        // Set up subscription for bookmarks
        let subscriptionID = "bookmark-changes"
        let bookmarkSubscription = CKQuerySubscription(
            recordType: RecordType.bookmark,
            predicate: NSPredicate(value: true),
            subscriptionID: subscriptionID,
            options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
        )
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        bookmarkSubscription.notificationInfo = notificationInfo
        
        // Save subscription
        do {
            _ = try await privateDatabase.save(bookmarkSubscription)
        } catch let error as CKError where error.code == .serverRejectedRequest {
            // This can happen if the subscription already exists.
            // For this specific case, we can ignore it.
            print("Subscription already exists, ignoring error: \(error)")
        }
    }
}

// MARK: - CloudKit Availability Check

extension ProductionCloudSyncService {
    public static func isCloudKitAvailable() async -> Bool {
        let container = CKContainer.default()
        do {
            let status = try await container.accountStatus()
            return status == .available
        } catch {
            return false
        }
    }
}

