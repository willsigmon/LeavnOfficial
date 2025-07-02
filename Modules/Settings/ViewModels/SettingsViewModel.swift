import Foundation
import LeavnCore
import LeavnServices
import SwiftUI
import Combine

@MainActor
public class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published public var user: User?
    @Published public var readingStreak = 0
    @Published public var versesRead = 0
    @Published public var timeInWord = 0
    @Published public var selectedTheme = "Vibrant"
    @Published public var fontSize: Double = 18
    @Published public var dailyVerseTime = Date()
    @Published public var isLoading = false
    @Published public var error: Error?

    // Reading Preferences
    @Published public var readingTranslation: BibleTranslation = .kjv
    @Published public var showRedLetterWords = true
    @Published public var showVerseNumbers = true
    @Published public var autoPlayAudio = false

    // Notification Settings
    @Published public var notificationsEnabled = true
    @Published public var dailyVerseEnabled = true
    @Published public var readingRemindersEnabled = true
    @Published public var communityUpdatesEnabled = true
    @Published public var achievementAlertsEnabled = true

    public func enableNotifications() {
        notificationsEnabled = true
        Task {
            guard let notificationManager = self.notificationManager else { return }
            do {
                _ = try await notificationManager.requestAuthorization()
            } catch {
                // Handle authorization error if needed
            }
        }
        Task {
            await analyticsService.track(event: AnalyticsEvent(name: "notifications_enabled"))
        }
    }

    // MARK: - Services
    private let userService: UserServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let libraryService: LibraryServiceProtocol?
    private var notificationManager: NotificationManager?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init() {
        guard let userService = DIContainer.shared.userService,
              let analyticsService = DIContainer.shared.analyticsService else {
            fatalError("Services not initialized")
        }
        self.userService = userService
        self.analyticsService = analyticsService
        self.libraryService = DIContainer.shared.libraryService
        
        Task {
            // Access NotificationManager.shared in actor-isolated context
            self.notificationManager = await NotificationManager.shared
            await loadUserData()
            loadSettings()
            await loadStats()
            setupBindings()
        }
    }

    // MARK: - Public Methods
    public func signOut() async {
        do {
            try await userService.signOut()
            clearUserData()
            await analyticsService.track(event: AnalyticsEvent(name: "user_signed_out"))
        } catch {
            self.error = error
        }
    }

    public func updateUserProfile(name: String, email: String) async {
        guard let currentUser = user else { return }
        let updatedUser = User(
            id: currentUser.id,
            name: name,
            email: email,
            preferences: currentUser.preferences,
            createdAt: currentUser.createdAt,
            updatedAt: Date()
        )

        do {
            try await userService.updateUser(updatedUser)
            self.user = updatedUser
            await analyticsService.track(event: AnalyticsEvent(name: "user_profile_updated"))
        } catch {
            self.error = error
        }
    }

    public func scheduleDailyVerseNotification() async {
        guard dailyVerseEnabled else { return }
        guard let notificationManager = self.notificationManager else { return }
        let components = Calendar.current.dateComponents([.hour, .minute], from: dailyVerseTime)
        await notificationManager.scheduleDailyVerse(at: components)
    }

    public func exportUserData() async {
        let data = await gatherExportData()
        let fileURL = createExportFile(data: data)
        await shareFile(fileURL)
        await analyticsService.track(event: AnalyticsEvent(name: "user_data_exported"))
    }

    public func deleteAccount() async {
        do {
            try await userService.deleteUser()
            clearUserData()
            await analyticsService.track(event: AnalyticsEvent(name: "user_account_deleted"))
        } catch {
            self.error = error
        }
    }

    // MARK: - Private Methods
    private func setupBindings() {
        $dailyVerseTime
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                Task {
                    await self?.scheduleDailyVerseNotification()
                }
            }
            .store(in: &cancellables)

        $selectedTheme.sink { theme in UserDefaults.standard.set(theme, forKey: "selectedTheme") }.store(in: &cancellables)
        $fontSize.sink { size in UserDefaults.standard.set(size, forKey: "fontSize") }.store(in: &cancellables)
        $readingTranslation.sink { translation in
            if let data = try? JSONEncoder().encode(translation) {
                UserDefaults.standard.set(data, forKey: "readingTranslation")
            }
        }.store(in: &cancellables)
    }

    private func loadUserData() async {
        self.isLoading = true
        do {
            self.user = try await userService.getCurrentUser()
        } catch {
            self.error = error
        }
        self.isLoading = false
    }

    private func loadSettings() {
        let defaults = UserDefaults.standard
        selectedTheme = defaults.string(forKey: "selectedTheme") ?? "Vibrant"
        fontSize = defaults.double(forKey: "fontSize") > 0 ? defaults.double(forKey: "fontSize") : 18
        if let translationData = defaults.data(forKey: "readingTranslation") {
            do {
                readingTranslation = try JSONDecoder().decode(BibleTranslation.self, from: translationData)
            } catch {
                readingTranslation = .kjv
            }
        } else {
            readingTranslation = .kjv
        }
    }

    private func loadStats() async {
        guard let libraryService = libraryService else {
            // If no library service, set to zero instead of mock data
            readingStreak = 0
            versesRead = 0
            timeInWord = 0
            return
        }
        
        do {
            let stats = try await libraryService.getReadingStats()
            readingStreak = stats.currentStreak
            versesRead = stats.totalVersesRead
            timeInWord = Int(stats.averageReadingTime)
        } catch {
            // On error, set to zero instead of mock data
            readingStreak = 0
            versesRead = 0
            timeInWord = 0
            self.error = error
        }
    }

    private func clearUserData() {
        let defaults = UserDefaults.standard
        let keys = ["selectedTheme", "fontSize", "readingTranslation"]
        keys.forEach { defaults.removeObject(forKey: $0) }

        user = nil
        readingStreak = 0
        versesRead = 0
        timeInWord = 0
        loadSettings()
    }

    private func gatherExportData() async -> [String: Any] {
        return [
            "user": ["name": user?.name ?? "", "email": user?.email ?? ""],
            "stats": ["readingStreak": readingStreak, "versesRead": versesRead, "timeInWord": timeInWord],
            "exportDate": Date().ISO8601Format()
        ]
    }

    private func createExportFile(data: [String: Any]) -> URL {
        let fileName = "Leavn_Export_\(Date().ISO8601Format()).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted) {
            try? jsonData.write(to: fileURL)
        }
        return fileURL
    }

    private func shareFile(_ fileURL: URL) async {
        print("Sharing file: \(fileURL)")
    }
}
