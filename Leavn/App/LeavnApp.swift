import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem
import LeavnSearch
import LeavnLibrary
import LeavnSettings
import LeavnCommunity
import AuthenticationModule
import Combine

#if os(macOS)
import AppKit
#elseif os(watchOS)
import WatchKit
#elseif os(visionOS)
import RealityKit
#endif

@main
struct LeavnApp: App {
    @StateObject private var appState = AppState()
    @Environment(\.scenePhase) private var scenePhase
    private let syncManager = SyncManager.shared
    
    init() {
        setupApplication()
        #if os(macOS)
        setupSyncObservers()
        #endif
    }
    
    #if os(macOS)
    private func setupSyncObservers() {
        // Sync when app becomes active
        NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)
            .sink { _ in
                Task { await self.handleAppBecameActive() }
            }
            .sink { _ in }
        
        // Sync when coming back to foreground
        NotificationCenter.default.publisher(for: NSApplication.willBecomeActiveNotification)
            .sink { _ in
                GlobalRules.triggerSyncIfNeeded()
            }
            .sink { _ in }
    }
    #endif
    
    @MainActor
    private func handleAppBecameActive() {
        // Initial sync check
        if GlobalRules.shouldSync {
            GlobalRules.syncNow()
        }
        
        // Schedule periodic syncs
        Task { await schedulePeriodicSync() }
    }
    
    @MainActor
    private func schedulePeriodicSync() async {
        // Schedule sync every 15 minutes while app is active
        while !Task.isCancelled {
            if GlobalRules.shouldSync {
                GlobalRules.syncNow()
            }
            try? await Task.sleep(for: .seconds(15 * 60))
        }
    }
    
    var body: some Scene {
        #if os(iOS)
        iOSScene
        #elseif os(macOS)
        macOSScene
        #elseif os(visionOS)
        visionOSScene
        #elseif os(watchOS)
        watchOSScene
        #endif
    }
    
    // MARK: - iOS Scene
    #if os(iOS)
    private var iOSScene: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(DIContainer.shared)
            .onAppear {
                setupiOSAppearance()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                handleScenePhaseChange(newPhase)
            }
        }
    }
    #endif
    
    // MARK: - macOS Scene
    #if os(macOS)
    private var macOSScene: some Scene {
        WindowGroup {
            MacMainView()
                .environmentObject(appState)
                .frame(
                    minWidth: AppConfiguration.MacOS.minimumWindowWidth,
                    idealWidth: AppConfiguration.MacOS.defaultWindowWidth,
                    minHeight: AppConfiguration.MacOS.minimumWindowHeight,
                    idealHeight: AppConfiguration.MacOS.defaultWindowHeight
                )
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Window") {
                    // Open new window
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("Bible") {
                Button("Go to Verse...") {
                    appState.showGoToVerse = true
                }
                .keyboardShortcut("g", modifiers: .command)
                
                Divider()
                
                Button("Next Chapter") {
                    appState.navigateChapter(.next)
                }
                .keyboardShortcut("]", modifiers: .command)
                
                Button("Previous Chapter") {
                    appState.navigateChapter(.previous)
                }
                .keyboardShortcut("[", modifiers: .command)
            }
        }
    }
    #endif
    
    // MARK: - visionOS Scene
    #if os(visionOS)
    private var visionOSScene: some Scene {
        WindowGroup(id: "main") {
            VisionMainView()
                .environmentObject(appState)
        }
        .windowStyle(.volumetric)
        .defaultSize(AppConfiguration.VisionOS.defaultVolumeSize)
        
        ImmersiveSpace(id: "bible-immersive") {
            Text("Immersive Bible View")
                .environmentObject(appState)
                // TODO: Replace with VisionImmersiveSpaceView()
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
    #endif
    
    // MARK: - watchOS Scene
    #if os(watchOS)
    private var watchOSScene: some Scene {
        WindowGroup {
            WatchMainView()
                .environmentObject(appState)
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "daily-verse")
    }
    #endif
    
    // MARK: - Setup Methods
    private func setupApplication() {
        // Initialize dependency injection with PRODUCTION services
        Task {
            await DIContainer.shared.initialize()
        }
        
        // Configure logging
        print("Leavn launching on \(platformName) with REAL SERVICES")
        
        // Setup crash reporting and analytics
        if AppConfiguration.Analytics.enabled {
            setupAnalytics()
        }
        
        // Migrate data if needed
        performDataMigrationIfNeeded()
        
        // Setup network monitoring
        NetworkMonitor.shared.startMonitoring()
        
        // Register for notifications
        registerForNotifications()
    }
    
    private func handleScenePhaseChange(_ phase: ScenePhase) {
        // Handle scene phase changes
        switch phase {
        case .active:
            // App became active - trigger sync if needed
            if GlobalRules.shouldSync {
                GlobalRules.syncNow()
            }
        case .inactive:
            // App is about to become inactive - perform any cleanup
            break
        case .background:
            // App moved to background - force a final sync
            GlobalRules.syncNow()
        @unknown default:
            break
        }
    }
    
    private var platformName: String {
        #if os(iOS)
        return "iOS"
        #elseif os(macOS)
        return "macOS"
        #elseif os(visionOS)
        return "visionOS"
        #elseif os(watchOS)
        return "watchOS"
        #endif
    }
}

// MARK: - App State
@MainActor
final class AppState: ObservableObject {
    // Services from DIContainer
    @Published var isInitialized = false
    
    // State
    @Published var selectedTab: TabItem = .bible
    @Published var showGoToVerse = false
    @Published var currentBook: BibleBook?
    @Published var currentChapter: Int = 1
    @Published var isOnboarded: Bool
    
    init() {
        // Load saved state
        self.isOnboarded = UserDefaults.standard.bool(forKey: "onboardingCompleted")
        
        loadSavedState()
        
        // Wait for services to initialize
        Task {
            await DIContainer.shared.initialize()
            await MainActor.run {
                self.isInitialized = true
            }
        }
    }
    
    func saveState() {
        UserDefaults.standard.set(currentBook?.id, forKey: "selectedBook")
        UserDefaults.standard.set(currentChapter, forKey: "selectedChapter")
    }
    
    func loadSavedState() {
        // Load last reading position
        if UserDefaults.standard.string(forKey: "selectedBook") != nil {
            // Load book from service when initialized
        }
        currentChapter = UserDefaults.standard.integer(forKey: "selectedChapter")
        if currentChapter == 0 { currentChapter = 1 }
    }
    
    func navigateChapter(_ direction: NavigationDirection) {
        switch direction {
        case .next:
            currentChapter += 1
        case .previous:
            currentChapter = max(1, currentChapter - 1)
        }
    }
}

enum NavigationDirection {
    case next, previous
}

// MARK: - Platform Specific Setup
#if os(iOS)
@MainActor
private func setupiOSAppearance() {
    // Configure navigation bar appearance
    let appearance = UINavigationBarAppearance()
    appearance.configureWithDefaultBackground()
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
}
#endif

// MARK: - Background Tasks
private func scheduleBackgroundTasks() {
    #if os(iOS)
    // Schedule background sync
    // Schedule daily verse notification
    #endif
}

// MARK: - Analytics
private func setupAnalytics() {
    // Initialize Firebase or other analytics
}

// MARK: - Data Migration
private func performDataMigrationIfNeeded() {
    // Check and perform any necessary data migrations
}

// MARK: - Notifications
private func registerForNotifications() {
    #if !os(watchOS)
    Task {
        do {
            let center = UNUserNotificationCenter.current()
            try await center.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("Failed to request notification permissions: \(error)")
        }
    }
    #endif
}

// MARK: - Network Monitor
final class NetworkMonitor: ObservableObject, @unchecked Sendable {
    static let shared = NetworkMonitor()
    @Published var isConnected = true
    
    func startMonitoring() {
        // Implement network monitoring
    }
}

// MARK: - Main Tab View
// MainTabView moved to Views/MainTabView.swift

// MARK: - Platform Main Views
#if os(macOS)
struct MacMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        MacBibleView()
    }
}
#endif

#if os(visionOS)
struct VisionMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VisionBibleStudyView()
    }
}
#endif

#if os(watchOS)
struct WatchMainView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        WatchBibleView()
    }
}

// Notification Controller
class NotificationController: WKUserNotificationHostingController<DailyVerseNotificationView> {
    override var body: DailyVerseNotificationView {
        DailyVerseNotificationView()
    }
}

struct DailyVerseNotificationView: View {
    var body: some View {
        Text("Daily Verse")
            .font(.headline)
    }
}
#endif

// MARK: - Tab Item
enum TabItem {
    case bible, search, library, community, settings
}

// MARK: - Temporary App Configuration
struct AppConfiguration {
    struct Analytics {
        static let enabled = false
    }
    
    struct APIKeys {
        // API keys will be extended via Secrets.swift
    }
    
    #if os(macOS)
    struct MacOS {
        static let minimumWindowWidth: CGFloat = 800
        static let defaultWindowWidth: CGFloat = 1200
        static let minimumWindowHeight: CGFloat = 600
        static let defaultWindowHeight: CGFloat = 800
    }
    #endif
    
    #if os(visionOS)
    struct VisionOS {
        static let defaultVolumeSize = CGSize(width: 800, height: 600)
    }
    #endif
}
