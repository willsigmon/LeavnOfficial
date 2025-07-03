import Foundation
import LeavnCore
import SwiftUI
import Combine
import AVFoundation

#if os(watchOS)
import WatchKit
import ClockKit
import UserNotifications

// MARK: - Watch Bible View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchBibleViewModel: ObservableObject {
    
    @Published var isInitialized = false
    @Published var currentTab = 0
    
    var container: DIContainer?
    
    public init() {}
    
    func initialize() async {
        isInitialized = true
    }
    
    func refreshContent() async {
        // Refresh current tab content
    }
}

// MARK: - Watch Daily Verse View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchDailyVerseViewModel: ObservableObject {
    
    @Published var dailyVerse: BibleVerse?
    @Published var isLoading = false
    @Published var isBookmarked = false
    @Published var error: Error?
    
    var container: DIContainer?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {}
    
    func loadDailyVerse() async {
        guard let bibleService = container?.bibleService else { return }
        
        isLoading = true
        error = nil
        
        do {
            let verse = try await bibleService.getDailyVerse(
                translation: BibleTranslation.defaultTranslations[0]
            )
            
            await MainActor.run {
                self.dailyVerse = verse
                self.isLoading = false
            }
            
            // Check if bookmarked
            await checkBookmarkStatus(verse)
            
        } catch {
            await MainActor.run {
                self.error = error
                self.isLoading = false
            }
        }
    }
    
    func getNewVerse() async {
        await loadDailyVerse()
    }
    
    func bookmarkVerse() {
        guard let verse = dailyVerse,
              let libraryService = container?.libraryService else { return }
        
        Task {
            do {
                if isBookmarked {
                    // Remove bookmark (would need bookmark ID)
                    // For simplicity, toggle the state
                    isBookmarked = false
                } else {
                    let bookmark = Bookmark(verse: verse)
                    try await libraryService.addBookmark(bookmark)
                    isBookmarked = true
                }
                
                // Provide haptic feedback
                WKInterfaceDevice.current().play(.success)
                
            } catch {
                // Provide error haptic
                WKInterfaceDevice.current().play(.failure)
            }
        }
    }
    
    func shareVerse() {
        guard let verse = dailyVerse else { return }
        
        let shareText = "\"\(verse.text)\" - \(verse.reference) (\(verse.translation))"
        
        // On watchOS, we can present a sharing interface
        // This would typically use WKInterfaceController presentation
        print("Sharing: \(shareText)")
        
        // Provide haptic feedback
        WKInterfaceDevice.current().play(.click)
    }
    
    private func checkBookmarkStatus(_ verse: BibleVerse) async {
        guard let libraryService = container?.libraryService else { return }
        
        do {
            let bookmarks = try await libraryService.getBookmarks()
            let isVerseBookmarked = bookmarks.contains { $0.verse.id == verse.id }
            
            await MainActor.run {
                self.isBookmarked = isVerseBookmarked
            }
        } catch {
            // Ignore errors for bookmark status check
        }
    }
}

// MARK: - Watch Quick Read View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchQuickReadViewModel: ObservableObject {
    
    @Published var lastReadChapter: LastReadChapter?
    
    var container: DIContainer?
    
    public init() {}
    
    func loadLastRead() async {
        // Load last read chapter from reading history
        guard let libraryService = container?.libraryService else { return }
        
        do {
            let history = try await libraryService.getReadingHistory()
            if let lastEntry = history.first {
                let book = BibleBook.allCases.first { $0.name == lastEntry.book } ?? .genesis
                lastReadChapter = LastReadChapter(
                    book: book,
                    chapter: lastEntry.chapter,
                    translation: lastEntry.translation
                )
            }
        } catch {
            print("Failed to load reading history: \(error)")
        }
    }
    
    func openBook(_ book: BibleBook) {
        // Navigate to book reading view
        // This would trigger navigation in the parent view
    }
    
    func continueReading(_ chapter: LastReadChapter) {
        // Continue reading from last position
        // This would trigger navigation to the specific chapter
    }
}

// MARK: - Watch Bookmarks View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchBookmarksViewModel: ObservableObject {
    
    @Published var bookmarks: [Bookmark] = []
    @Published var isLoading = false
    
    var container: DIContainer?
    
    public init() {}
    
    func loadBookmarks() async {
        guard let libraryService = container?.libraryService else { return }
        
        isLoading = true
        
        do {
            let allBookmarks = try await libraryService.getBookmarks()
            
            await MainActor.run {
                self.bookmarks = Array(allBookmarks.prefix(20)) // Limit for watch performance
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
        }
    }
    
    func deleteBookmarks(at indexSet: IndexSet) async {
        guard let libraryService = container?.libraryService else { return }
        
        for index in indexSet {
            let bookmark = bookmarks[index]
            do {
                try await libraryService.removeBookmark(bookmark.id)
                bookmarks.remove(at: index)
            } catch {
                print("Failed to delete bookmark: \(error)")
            }
        }
    }
}

// MARK: - Watch Verse Detail View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchVerseDetailViewModel: ObservableObject {
    
    @Published var isBookmarked = false
    @Published var isReading = false
    
    var container: DIContainer?
    
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    public init() {}
    
    func checkBookmarkStatus(_ verse: BibleVerse) async {
        guard let libraryService = container?.libraryService else { return }
        
        do {
            let bookmarks = try await libraryService.getBookmarks()
            isBookmarked = bookmarks.contains { $0.verse.id == verse.id }
        } catch {
            // Ignore bookmark check errors
        }
    }
    
    func bookmarkVerse(_ verse: BibleVerse) async {
        guard let libraryService = container?.libraryService else { return }
        
        do {
            if isBookmarked {
                // Remove bookmark (simplified - would need actual bookmark ID)
                isBookmarked = false
            } else {
                let bookmark = Bookmark(verse: verse)
                try await libraryService.addBookmark(bookmark)
                isBookmarked = true
            }
            
            WKInterfaceDevice.current().play(.success)
        } catch {
            WKInterfaceDevice.current().play(.failure)
        }
    }
    
    func shareVerse(_ verse: BibleVerse) {
        let shareText = "\"\(verse.text)\" - \(verse.reference) (\(verse.translation))"
        
        // Share using watchOS mechanisms
        print("Sharing: \(shareText)")
        WKInterfaceDevice.current().play(.click)
    }
    
    func readAloud(_ verse: BibleVerse) {
        if isReading {
            speechSynthesizer.stopSpeaking(at: .immediate)
            isReading = false
        } else {
            let utterance = AVSpeechUtterance(string: "\(verse.reference). \(verse.text)")
            utterance.rate = 0.5
            utterance.pitchMultiplier = 1.0
            utterance.volume = 1.0
            
            speechSynthesizer.speak(utterance)
            isReading = true
            
            // Monitor completion
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(verse.text.count) * 0.1) {
                self.isReading = false
            }
        }
    }
}

// MARK: - Watch Settings View Model

@available(watchOS 11.0, *)
@MainActor
public final class WatchSettingsViewModel: ObservableObject {
    
    @Published var selectedTranslation: BibleTranslation = BibleTranslation.defaultTranslations[0]
    @Published var fontSize: Double = 14.0
    @Published var dailyNotificationsEnabled = true
    @Published var hapticFeedbackEnabled = true
    @Published var autoReadAloudEnabled = false
    @Published var complicationUpdateFrequency: ComplicationUpdateFrequency = .daily
    @Published var isSyncing = false
    
    @Published var availableTranslations: [BibleTranslation] = BibleTranslation.defaultTranslations
    
    var container: DIContainer?
    
    private let userDefaults = UserDefaults.standard
    
    public init() {}
    
    func loadSettings() async {
        // Load settings from UserDefaults
        fontSize = userDefaults.double(forKey: "watch_font_size")
        if fontSize == 0 { fontSize = 14.0 }
        
        dailyNotificationsEnabled = userDefaults.bool(forKey: "watch_daily_notifications")
        hapticFeedbackEnabled = userDefaults.bool(forKey: "watch_haptic_feedback")
        autoReadAloudEnabled = userDefaults.bool(forKey: "watch_auto_read_aloud")
        
        if let translationId = userDefaults.object(forKey: "watch_translation") as? String,
           let translation = availableTranslations.first(where: { $0.id == translationId }) {
            selectedTranslation = translation
        }
        
        if let frequencyRaw = userDefaults.object(forKey: "watch_complication_frequency") as? String,
           let frequency = ComplicationUpdateFrequency(rawValue: frequencyRaw) {
            complicationUpdateFrequency = frequency
        }
    }
    
    func saveSettings() async {
        userDefaults.set(selectedTranslation.id, forKey: "watch_translation")
        userDefaults.set(fontSize, forKey: "watch_font_size")
        userDefaults.set(dailyNotificationsEnabled, forKey: "watch_daily_notifications")
        userDefaults.set(hapticFeedbackEnabled, forKey: "watch_haptic_feedback")
        userDefaults.set(autoReadAloudEnabled, forKey: "watch_auto_read_aloud")
        userDefaults.set(complicationUpdateFrequency.rawValue, forKey: "watch_complication_frequency")
        
        // Update user preferences in the main service
        if let userService = container?.userService {
            do {
                let user = try await userService.getCurrentUser()
                if var user = user {
                    user.preferences.defaultTranslation = selectedTranslation.abbreviation
                    user.preferences.fontSize = fontSize
                    try await userService.updateUser(user)
                }
            } catch {
                print("Failed to update user preferences: \(error)")
            }
        }
        
        // Schedule complication updates
        scheduleComplicationUpdates()
    }
    
    func syncData() async {
        guard let syncService = container?.syncService else { return }
        
        isSyncing = true
        
        do {
            try await syncService.syncData()
            WKInterfaceDevice.current().play(.success)
        } catch {
            WKInterfaceDevice.current().play(.failure)
            print("Sync failed: \(error)")
        }
        
        isSyncing = false
    }
    
    private func scheduleComplicationUpdates() {
        // Schedule complication timeline updates based on frequency
        // This would integrate with ClockKit to update complications
        
        #if os(watchOS)
        let server = CLKComplicationServer.sharedInstance()
        for complication in server.activeComplications ?? [] {
            server.reloadTimeline(for: complication)
        }
        #endif
    }
}

// MARK: - Watch Notification Manager

@available(watchOS 11.0, *)
public class WatchNotificationManager: ObservableObject {
    
    public static let shared = WatchNotificationManager()
    
    private init() {}
    
    func scheduleDailyVerseNotification() {
        // Schedule daily verse notifications
        let content = UNMutableNotificationContent()
        content.title = "Daily Verse"
        content.body = "Your daily Bible verse is ready!"
        content.sound = .default
        content.categoryIdentifier = "DAILY_VERSE"
        
        // Schedule for 8 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_verse", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                scheduleDailyVerseNotification()
            }
            return granted
        } catch {
            return false
        }
    }
}

// MARK: - Watch Haptic Manager

@available(watchOS 11.0, *)
public class WatchHapticManager {
    
    public static let shared = WatchHapticManager()
    
    private init() {}
    
    func playSelectionHaptic() {
        WKInterfaceDevice.current().play(.click)
    }
    
    func playSuccessHaptic() {
        WKInterfaceDevice.current().play(.success)
    }
    
    func playErrorHaptic() {
        WKInterfaceDevice.current().play(.failure)
    }
    
    func playNotificationHaptic() {
        WKInterfaceDevice.current().play(.notification)
    }
}

// MARK: - Watch Workout Integration

@available(watchOS 11.0, *)
public class WatchWorkoutManager: ObservableObject {
    
    @Published var isTrackingReadingSession = false
    @Published var readingSessionDuration: TimeInterval = 0
    
    private var sessionStartTime: Date?
    private var timer: Timer?
    
    public init() {}
    
    func startReadingSession() {
        guard !isTrackingReadingSession else { return }
        
        sessionStartTime = Date()
        isTrackingReadingSession = true
        readingSessionDuration = 0
        
        // Start timer to update duration
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateDuration()
        }
        
        WKInterfaceDevice.current().play(.start)
    }
    
    func endReadingSession() {
        guard isTrackingReadingSession else { return }
        
        timer?.invalidate()
        timer = nil
        isTrackingReadingSession = false
        
        // Save reading session to health data or reading history
        saveReadingSession()
        
        WKInterfaceDevice.current().play(.stop)
    }
    
    private func updateDuration() {
        guard let startTime = sessionStartTime else { return }
        readingSessionDuration = Date().timeIntervalSince(startTime)
    }
    
    private func saveReadingSession() {
        // Save reading session data
        // This could integrate with HealthKit or save to reading history
        print("Reading session completed: \(readingSessionDuration) seconds")
    }
}

#endif