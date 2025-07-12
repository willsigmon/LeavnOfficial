import Foundation
@preconcurrency import BackgroundTasks
import UserNotifications

@globalActor
public actor BackgroundTaskActor {
    public static let shared = BackgroundTaskActor()
}

// MARK: - Background Task Manager
@BackgroundTaskActor
public final class BackgroundTaskManager: Sendable {
    public static let shared = BackgroundTaskManager()
    
    private let refreshTaskIdentifier = "com.leavn3.background.refresh"
    private let processingTaskIdentifier = "com.leavn3.background.processing"
    
    private init() {}
    
    // MARK: - Setup
    public func setupBackgroundTasks() {
        // Register tasks
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: refreshTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingTaskIdentifier,
            using: nil
        ) { task in
            self.handleProcessing(task: task as! BGProcessingTask)
        }
    }
    
    // MARK: - Schedule Tasks
    public func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: refreshTaskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logInfo("Scheduled app refresh", category: .general)
        } catch {
            logError("Failed to schedule app refresh", error: error, category: .general)
        }
    }
    
    public func scheduleBackgroundProcessing() {
        let request = BGProcessingTaskRequest(identifier: processingTaskIdentifier)
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logInfo("Scheduled background processing", category: .general)
        } catch {
            logError("Failed to schedule background processing", error: error, category: .general)
        }
    }
    
    // MARK: - Handle Tasks
    private func handleAppRefresh(task: BGAppRefreshTask) {
        // Schedule next refresh
        scheduleAppRefresh()
        
        // Create operation
        let operation = RefreshOperation()
        
        // Handle expiration
        task.expirationHandler = {
            operation.cancel()
        }
        
        // Set task completion immediately before starting operation
        // to avoid capturing in closure
        let queue = OperationQueue.main
        queue.addOperation(operation)
        
        // Wait for completion in a Task
        Task { @MainActor in
            while !operation.isFinished {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            }
            task.setTaskCompleted(success: !operation.isCancelled)
        }
    }
    
    private func handleProcessing(task: BGProcessingTask) {
        // Schedule next processing
        scheduleBackgroundProcessing()
        
        // Perform heavy processing
        Task {
            // This would be injected or passed in from the app level
            // For now, just log
            logInfo("Background processing started", category: .general)
            
            // Update reading stats
            await updateReadingStats()
            
            task.setTaskCompleted(success: true)
        }
    }
    
    private func updateReadingStats() async {
        // Calculate and update reading stats
        let defaults = UserDefaults.standard
        
        // Update streak
        if let lastReadDate = defaults.object(forKey: "lastReadDate") as? Date {
            let calendar = Calendar.current
            let daysSinceLastRead = calendar.dateComponents([.day], from: lastReadDate, to: Date()).day ?? 0
            
            if daysSinceLastRead > 1 {
                // Reset streak
                defaults.set(0, forKey: "readingStreak")
                
                // Send notification about lost streak
                await NotificationManager.shared.sendStreakLostNotification()
            }
        }
    }
}

// MARK: - Refresh Operation
class RefreshOperation: Operation, @unchecked Sendable {
    override func main() {
        guard !isCancelled else { return }
        
        // Refresh data
        Task {
            // Check for new community posts
            await checkForNewPosts()
            
            // Update daily verse
            await updateDailyVerse()
            
            // Check achievements
            await checkAchievements()
        }
    }
    
    private func checkForNewPosts() async {
        // Check for new community posts and send notifications
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "communityUpdatesEnabled") else { return }
        
        // In a real app, check server for new posts
        // For now, simulate
        let hasNewPosts = Bool.random()
        if hasNewPosts {
            await NotificationManager.shared.sendCommunityUpdateNotification(
                title: "New Post in Your Group",
                body: "Sarah just shared an insight about Romans 8:28"
            )
        }
    }
    
    private func updateDailyVerse() async {
        // Update the daily verse
        // This would be injected from app level
        logInfo("Updating daily verse", category: .general)
        
        // For now, just save a placeholder
        UserDefaults.standard.set(Date(), forKey: "dailyVerseDate")
    }
    
    private func checkAchievements() async {
        // Check for new achievements
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: "achievementAlertsEnabled") else { return }
        
        let streak = defaults.integer(forKey: "readingStreak")
        let versesRead = defaults.integer(forKey: "totalVersesRead")
        
        // Check milestones
        switch streak {
        case 7:
            await NotificationManager.shared.sendAchievementNotification(
                title: "Week Warrior! 🎉",
                body: "You've read the Bible for 7 days straight!"
            )
        case 30:
            await NotificationManager.shared.sendAchievementNotification(
                title: "Monthly Master! 🏆",
                body: "30 days of consistent Bible reading!"
            )
        case 100:
            await NotificationManager.shared.sendAchievementNotification(
                title: "Century Champion! 💯",
                body: "100 days of reading God's Word!"
            )
        default:
            break
        }
        
        // Check verses milestones
        switch versesRead {
        case 100:
            await NotificationManager.shared.sendAchievementNotification(
                title: "100 Verses Read! 📖",
                body: "You've read 100 Bible verses!"
            )
        case 500:
            await NotificationManager.shared.sendAchievementNotification(
                title: "500 Verses! 🌟",
                body: "Half way to 1000 verses!"
            )
        case 1000:
            await NotificationManager.shared.sendAchievementNotification(
                title: "Biblical Scholar! 🎓",
                body: "You've read 1000 verses!"
            )
        default:
            break
        }
    }
}

// MARK: - Enhanced Notification Manager
extension NotificationManager {
    // Community Notifications
    func sendCommunityUpdateNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "COMMUNITY_UPDATE"
        content.threadIdentifier = "community"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logError("Failed to send community notification", error: error, category: .general)
        }
    }
    
    // Achievement Notifications
    func sendAchievementNotification(title: String, body: String) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName("achievement.caf"))
        content.categoryIdentifier = "ACHIEVEMENT"
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logError("Failed to send achievement notification", error: error, category: .general)
        }
    }
    
    // Streak Notifications
    func sendStreakLostNotification() async {
        let content = UNMutableNotificationContent()
        content.title = "Don't Break Your Streak! 🔥"
        content.body = "You haven't read today. Keep your reading streak alive!"
        content.sound = .default
        content.categoryIdentifier = "STREAK_REMINDER"
        
        let request = UNNotificationRequest(
            identifier: "streak_lost",
            content: content,
            trigger: nil
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logError("Failed to send streak notification", error: error, category: .general)
        }
    }
    
    // Setup Notification Categories
    func setupNotificationCategories() {
        let categories: Set<UNNotificationCategory> = [
            // Daily Verse Category
            UNNotificationCategory(
                identifier: "DAILY_VERSE",
                actions: [
                    UNNotificationAction(
                        identifier: "READ_NOW",
                        title: "Read Now",
                        options: .foreground
                    ),
                    UNNotificationAction(
                        identifier: "SAVE_VERSE",
                        title: "Save",
                        options: []
                    )
                ],
                intentIdentifiers: []
            ),
            
            // Community Update Category
            UNNotificationCategory(
                identifier: "COMMUNITY_UPDATE",
                actions: [
                    UNNotificationAction(
                        identifier: "VIEW_POST",
                        title: "View",
                        options: .foreground
                    ),
                    UNNotificationAction(
                        identifier: "LIKE_POST",
                        title: "Like",
                        options: []
                    )
                ],
                intentIdentifiers: []
            ),
            
            // Achievement Category
            UNNotificationCategory(
                identifier: "ACHIEVEMENT",
                actions: [
                    UNNotificationAction(
                        identifier: "SHARE_ACHIEVEMENT",
                        title: "Share",
                        options: .foreground
                    )
                ],
                intentIdentifiers: []
            ),
            
            // Streak Reminder Category
            UNNotificationCategory(
                identifier: "STREAK_REMINDER",
                actions: [
                    UNNotificationAction(
                        identifier: "READ_NOW",
                        title: "Read Now",
                        options: .foreground
                    ),
                    UNNotificationAction(
                        identifier: "REMIND_LATER",
                        title: "Later",
                        options: []
                    )
                ],
                intentIdentifiers: []
            )
        ]
        
        UNUserNotificationCenter.current().setNotificationCategories(categories)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let openDailyVerse = Notification.Name("openDailyVerse")
    static let navigateToCommunity = Notification.Name("navigateToCommunity")
    static let navigateToBible = Notification.Name("navigateToBible")
    static let shareAchievement = Notification.Name("shareAchievement")
}

// MARK: - Enhanced Reading Reminder
extension NotificationManager {
    func scheduleReadingReminder(afterHours hours: Int = 0) async {
        let content = UNMutableNotificationContent()
        content.title = "Time for Your Daily Reading 📖"
        content.body = getRandomReminderMessage()
        content.sound = .default
        content.categoryIdentifier = "READING_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(hours * 3600),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "reading_reminder_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            logError("Failed to schedule reading reminder", error: error, category: .general)
        }
    }
    
    private func getRandomReminderMessage() -> String {
        let messages = [
            "A few minutes in God's Word can change your whole day",
            "Your daily bread awaits! 🍞",
            "Take a moment to read and reflect",
            "God's Word is waiting for you",
            "Continue your reading journey",
            "Keep your streak alive! 🔥",
            "Time to nourish your soul",
            "Your next chapter awaits"
        ]
        return messages.randomElement() ?? messages[0]
    }
}
