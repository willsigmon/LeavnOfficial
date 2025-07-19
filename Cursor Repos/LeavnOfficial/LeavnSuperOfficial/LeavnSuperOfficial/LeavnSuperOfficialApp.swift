import SwiftUI
import LeavnApp
import ComposableArchitecture
import CoreData
import BackgroundTasks

@main
struct LeavnSuperOfficialApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    let store: StoreOf<AppReducer>
    let persistenceController: PersistenceController
    
    init() {
        // Initialize Core Data
        self.persistenceController = PersistenceController.shared
        
        // Configure dependencies
        @Dependency(\.databaseClient) var databaseClient
        databaseClient.configure(persistenceController.container)
        
        // Initialize the store with proper dependencies
        self.store = Store(initialState: AppReducer.State()) {
            AppReducer()
                .dependency(\.databaseClient, databaseClient)
                ._printChanges()
        }
        
        // Register background tasks
        registerBackgroundTasks()
        
        // Configure app appearance
        configureAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            AppView(store: store)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    private func registerBackgroundTasks() {
        // Register background fetch for offline content
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.leavn.app.refresh",
            using: nil
        ) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            handleAppRefresh(task: refreshTask)
        }
        
        // Register processing task for large downloads
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: "com.leavn.app.process",
            using: nil
        ) { task in
            guard let processingTask = task as? BGProcessingTask else { return }
            handleProcessingTask(task: processingTask)
        }
    }
    
    private func configureAppearance() {
        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle deep links
        // Examples: leavn://bible/john/3/16, leavn://community/post/123
        ViewStore(store, observe: { $0 }).send(.handleDeepLink(url))
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            // Schedule background tasks
            scheduleAppRefresh()
            // Save any pending changes
            ViewStore(store, observe: { $0 }).send(.saveState)
        case .inactive:
            break
        case .active:
            // Resume any paused operations
            ViewStore(store, observe: { $0 }).send(.resumeOperations)
        @unknown default:
            break
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "com.leavn.app.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Perform refresh operations
        Task {
            do {
                await ViewStore(store, observe: { $0 }).send(.performBackgroundRefresh).finish()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
    
    private func handleProcessingTask(task: BGProcessingTask) {
        Task {
            do {
                await ViewStore(store, observe: { $0 }).send(.performBackgroundProcessing).finish()
                task.setTaskCompleted(success: true)
            } catch {
                task.setTaskCompleted(success: false)
            }
        }
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure remote notifications
        UNUserNotificationCenter.current().delegate = self
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Send device token to server
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        // Send token to backend
        Task {
            @Dependency(\.authClient) var authClient
            @Dependency(\.networkLayer) var networkLayer
            
            do {
                _ = try await networkLayer.request(
                    endpoint: "/notifications/device",
                    method: .post,
                    body: ["token": token, "platform": "ios"]
                )
            } catch {
                print("Failed to register device token: \(error)")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications: \(error)")
    }
}

// MARK: - Notification Delegate
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification actions
        completionHandler()
    }
}

// MARK: - Persistence Controller
class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LeavnDataModel")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                // In production, handle this more gracefully
                print("Core Data failed to load: \(error), \(error.userInfo)")
                
                // Try to recover by removing the store and recreating
                if let storeURL = container.persistentStoreDescriptions.first?.url {
                    try? FileManager.default.removeItem(at: storeURL)
                    
                    // Retry loading
                    container.loadPersistentStores { _, retryError in
                        if let retryError = retryError {
                            // Log to crash reporting service
                            print("Failed to recover Core Data: \(retryError)")
                        }
                    }
                }
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}