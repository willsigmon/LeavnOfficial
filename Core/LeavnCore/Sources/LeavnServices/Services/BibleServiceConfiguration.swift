import Foundation
import CoreData
import LeavnCore

// MARK: - Bible Service Configuration
public struct BibleServiceConfiguration {
    public let esvAPIKey: String
    public let bibleComAPIKey: String
    public let defaultTranslation: String
    public let includeApocrypha: Bool
    public let cacheEnabled: Bool
    public let maxCacheSize: Int64
    
    public init(
        esvAPIKey: String = "",
        bibleComAPIKey: String = "",
        defaultTranslation: String = "ESV",
        includeApocrypha: Bool = false,
        cacheEnabled: Bool = true,
        maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
    ) {
        self.esvAPIKey = esvAPIKey
        self.bibleComAPIKey = bibleComAPIKey
        self.defaultTranslation = defaultTranslation
        self.includeApocrypha = includeApocrypha
        self.cacheEnabled = cacheEnabled
        self.maxCacheSize = maxCacheSize
    }
}

// MARK: - Bible Service Factory
public final class BibleServiceFactory {
    public static func createBibleService(
        configuration: BibleServiceConfiguration,
        networkService: NetworkService,
        persistentContainer: NSPersistentContainer? = nil
    ) -> BibleService {
        // Create cache manager
        let cacheManager: BibleCacheManager
        if configuration.cacheEnabled {
            if let container = persistentContainer {
                let context = container.viewContext
                cacheManager = CoreDataBibleCacheManager(context: context)
            } else {
                cacheManager = InMemoryBibleCacheManager()
            }
        } else {
            cacheManager = InMemoryBibleCacheManager()
        }
        
        // Create and return the service
        return DefaultBibleService(
            networkService: networkService,
            esvAPIKey: configuration.esvAPIKey,
            bibleComAPIKey: configuration.bibleComAPIKey,
            cacheManager: cacheManager
        )
    }
    
    public static func createBibleRepository(
        bibleService: BibleService,
        localStorage: Storage,
        cacheManager: BibleCacheManager
    ) -> BibleRepository {
        return DefaultBibleRepository(
            bibleService: bibleService,
            localStorage: localStorage,
            cacheManager: cacheManager
        )
    }
    
    public static func createPersistentContainer() -> NSPersistentContainer {
        let bundle = Bundle.module
        guard let modelURL = bundle.url(forResource: "BibleCache", withExtension: "momd") else {
            fatalError("Failed to find BibleCache.xcdatamodeld in bundle")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model")
        }
        
        let container = NSPersistentContainer(name: "BibleCache", managedObjectModel: model)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error {
                fatalError("Failed to load Core Data store: \(error)")
            }
        }
        
        // Configure for performance
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }
}

// MARK: - Usage Examples
public struct BibleServiceExamples {
    
    /// Example: Basic setup with ESV API
    public static func setupWithESVAPI(apiKey: String) -> BibleService {
        let configuration = BibleServiceConfiguration(
            esvAPIKey: apiKey,
            defaultTranslation: "ESV",
            includeApocrypha: false
        )
        
        let leavnConfig = LeavnConfiguration(apiKey: "your-api-key")
        let networkService = DefaultNetworkService(configuration: leavnConfig)
        
        return BibleServiceFactory.createBibleService(
            configuration: configuration,
            networkService: networkService
        )
    }
    
    /// Example: Setup with Apocrypha support
    public static func setupWithApocrypha(esvKey: String, bibleComKey: String) -> BibleService {
        let configuration = BibleServiceConfiguration(
            esvAPIKey: esvKey,
            bibleComAPIKey: bibleComKey,
            defaultTranslation: "NRSV",
            includeApocrypha: true
        )
        
        let leavnConfig = LeavnConfiguration(apiKey: "your-api-key")
        let networkService = DefaultNetworkService(configuration: leavnConfig)
        let container = BibleServiceFactory.createPersistentContainer()
        
        return BibleServiceFactory.createBibleService(
            configuration: configuration,
            networkService: networkService,
            persistentContainer: container
        )
    }
    
    /// Example: In-memory caching only
    public static func setupInMemoryOnly() -> BibleService {
        let configuration = BibleServiceConfiguration(
            cacheEnabled: true
        )
        
        let leavnConfig = LeavnConfiguration(apiKey: "your-api-key")
        let networkService = DefaultNetworkService(configuration: leavnConfig)
        
        return BibleServiceFactory.createBibleService(
            configuration: configuration,
            networkService: networkService
        )
    }
    
    /// Example: Complete setup with repository
    public static func setupComplete(esvKey: String) -> (BibleService, BibleRepository) {
        let configuration = BibleServiceConfiguration(
            esvAPIKey: esvKey,
            includeApocrypha: true
        )
        
        let leavnConfig = LeavnConfiguration(apiKey: "your-api-key")
        let networkService = DefaultNetworkService(configuration: leavnConfig)
        let container = BibleServiceFactory.createPersistentContainer()
        let localStorage = try! FileStorage()
        
        let bibleService = BibleServiceFactory.createBibleService(
            configuration: configuration,
            networkService: networkService,
            persistentContainer: container
        )
        
        let cacheManager = CoreDataBibleCacheManager(context: container.viewContext)
        let repository = BibleServiceFactory.createBibleRepository(
            bibleService: bibleService,
            localStorage: localStorage,
            cacheManager: cacheManager
        )
        
        return (bibleService, repository)
    }
}

// MARK: - API Key Management
public struct BibleAPIKeys {
    /// ESV API is free for non-commercial use
    /// Sign up at: https://api.esv.org/
    public static let esvRegistrationURL = "https://api.esv.org/"
    
    /// Bible.com API requires approval
    /// Contact: https://scripture.api.bible/
    public static let bibleComRegistrationURL = "https://scripture.api.bible/"
    
    /// Free verse of the day API (no key required)
    public static let verseOfDayURL = "https://labs.bible.org/api/?passage=votd&type=json"
    
    public static func validateESVKey(_ key: String) -> Bool {
        // Basic validation - should be a non-empty string
        return !key.isEmpty && key.count > 10
    }
    
    public static func validateBibleComKey(_ key: String) -> Bool {
        // Bible.com API keys are typically longer
        return !key.isEmpty && key.count > 20
    }
}

// MARK: - Translation Presets
public extension BibleServiceConfiguration {
    /// Protestant Bible configuration
    static let protestant = BibleServiceConfiguration(
        defaultTranslation: "ESV",
        includeApocrypha: false
    )
    
    /// Catholic Bible configuration with Apocrypha
    static let catholic = BibleServiceConfiguration(
        defaultTranslation: "NAB",
        includeApocrypha: true
    )
    
    /// Orthodox Bible configuration
    static let orthodox = BibleServiceConfiguration(
        defaultTranslation: "NRSV",
        includeApocrypha: true
    )
    
    /// Academic/scholarly configuration
    static let scholarly = BibleServiceConfiguration(
        defaultTranslation: "NRSV",
        includeApocrypha: true,
        maxCacheSize: 500 * 1024 * 1024 // 500MB for extensive research
    )
}