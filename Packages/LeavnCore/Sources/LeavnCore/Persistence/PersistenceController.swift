import Foundation
import CoreData
import CloudKit
import os.log

@MainActor
public final class PersistenceController: ObservableObject {
    public static let shared = PersistenceController()
    
    private let logger = os.Logger(subsystem: "com.leavn.app", category: "Persistence")
    
    // MARK: - Published Properties
    @Published public var cloudKitStatus: CloudKitStatus = .unknown
    @Published public var syncProgress: Double = 0.0
    @Published public var lastSyncDate: Date?
    @Published public var syncError: Error?
    
    // MARK: - Core Data Stack
    public lazy var container: NSPersistentCloudKitContainer = {
        // Load the model from the module bundle
        guard let modelURL = Bundle.module.url(forResource: "LeavnDataModel", withExtension: "momd") else {
            fatalError("Failed to find the Core Data model in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load the Core Data model")
        }
        
        let container = NSPersistentCloudKitContainer(name: "LeavnDataModel", managedObjectModel: model)
        
        // Configure for CloudKit
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        // Enable CloudKit
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Configure CloudKit schema initialization
        #if DEBUG
        // Temporarily disable CloudKit in debug builds to avoid crashes
        print("CloudKit sync disabled in debug mode")
        description.cloudKitContainerOptions = nil
        #else
        let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.leavn.app")
        cloudKitContainerOptions.databaseScope = .private
        description.cloudKitContainerOptions = cloudKitContainerOptions
        #endif
        
        container.loadPersistentStores { [weak self] storeDescription, error in
            if let error = error as NSError? {
                print("Core Data failed to load: \(error.localizedDescription)")
                
                // Check if it's a CloudKit error
                if error.domain == CKErrorDomain {
                    print("CloudKit error: \(error)")
                    // For development, continue without CloudKit
                    #if DEBUG
                    print("Continuing without CloudKit sync in debug mode")
                    #else
                    fatalError("Core Data error: \(error), \(error.userInfo)")
                    #endif
                } else {
                    fatalError("Core Data error: \(error), \(error.userInfo)")
                }
            } else {
                print("Core Data loaded successfully")
                print("Store URL: \(storeDescription.url?.absoluteString ?? "unknown")")
                print("CloudKit enabled: \(storeDescription.cloudKitContainerOptions != nil)")
            }
        }
        
        // Enable automatic merging with proper concurrency handling
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        // Don't setup notifications here - they'll be setup in init after container loads
        
        return container
    }()
    
    public var context: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    private init() {
        // Force container initialization
        _ = container
        
        // Now setup notifications
        setupNotifications()
        
        Task {
            await checkCloudKitStatus()
        }
    }
    
    // MARK: - CloudKit Status
    public enum CloudKitStatus {
        case unknown
        case available
        case restricted
        case noAccount
        case networkUnavailable
        case temporaryFailure
    }
    
    // MARK: - CloudKit Status Checking
    public func checkCloudKitStatus() async {
        do {
            let container = CKContainer(identifier: "iCloud.com.leavn.app")
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                self.cloudKitStatus = .available
                self.logger.info("CloudKit available")
                
                // Additional TestFlight compatibility check
                Task {
                    await self.verifyCloudKitPermissions()
                }
                
            case .restricted:
                self.cloudKitStatus = .restricted
                self.logger.warning("CloudKit restricted")
                
            case .noAccount:
                self.cloudKitStatus = .noAccount
                self.logger.warning("No iCloud account")
                
            case .couldNotDetermine:
                self.cloudKitStatus = .temporaryFailure
                self.logger.error("Could not determine CloudKit status")
                
            case .temporarilyUnavailable:
                self.cloudKitStatus = .temporaryFailure
                self.logger.warning("CloudKit temporarily unavailable")
                
            @unknown default:
                self.cloudKitStatus = .unknown
                self.logger.error("Unknown CloudKit status")
            }
        } catch {
            self.cloudKitStatus = .networkUnavailable
            self.syncError = error
            self.logger.error("CloudKit status check failed: \(error.localizedDescription)")
        }
    }
    
    private func verifyCloudKitPermissions() async {
        do {
            let container = CKContainer(identifier: "iCloud.com.leavn.app")
            let database = container.privateCloudDatabase
            
            // Test query to verify permissions
            let query = CKQuery(recordType: "UserProfile", predicate: NSPredicate(value: true))
            
            do {
                let (_, _) = try await database.records(matching: query, resultsLimit: 1)
                logger.info("CloudKit permissions verified - query successful")
            } catch {
                logger.warning("CloudKit permission test failed: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextDidSave),
            name: .NSManagedObjectContextDidSave,
            object: container.viewContext
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(remoteChangeOccurred),
            name: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator
        )
    }
    
    @objc private nonisolated func contextDidSave(_ notification: Notification) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.logger.debug("Core Data context saved")
            self.lastSyncDate = Date()
        }
    }
    
    @objc private nonisolated func remoteChangeOccurred(_ notification: Notification) {
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            self.logger.info("Remote CloudKit change detected")
            
            // The context will automatically merge changes due to our configuration
            self.logger.debug("Processing remote changes")
            
            // Update sync date on main thread
            self.lastSyncDate = Date()
        }
    }
    
    // MARK: - Save Operations
    public func save() async throws {
        guard context.hasChanges else { return }
        
        do {
            try context.save()
            self.logger.debug("Context saved successfully")
        } catch {
            self.logger.error("Failed to save context: \(error.localizedDescription)")
            throw error
        }
    }
    
    public func saveSync() throws {
        guard context.hasChanges else { return }
        
        try context.save()
        print("Context saved synchronously")
    }
    
    // MARK: - Preview Support
    static let preview: PersistenceController = {
        let controller = PersistenceController()
        let context = controller.container.viewContext
        
        // Add sample data for previews
        let sampleUser = UserProfile(context: context)
        sampleUser.id = UUID()
        sampleUser.name = "Preview User"
        sampleUser.email = "preview@example.com"
        sampleUser.createdAt = Date()
        sampleUser.updatedAt = Date()
        
        let samplePrefs = UserPreferences(context: context)
        samplePrefs.id = UUID()
        samplePrefs.preferredTranslation = "ESV"
        samplePrefs.fontSize = 18.0
        samplePrefs.selectedTheme = "automatic"
        samplePrefs.enableNotifications = true
        samplePrefs.reminderTime = Date()
        samplePrefs.user = sampleUser
        
        try? context.save()
        return controller
    }()
} 