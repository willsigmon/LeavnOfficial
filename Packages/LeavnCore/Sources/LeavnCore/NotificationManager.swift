import Foundation
import UserNotifications

@globalActor
public actor NotificationActor {
    public static let shared = NotificationActor()
}

// MARK: - Notification Manager
@NotificationActor
public final class NotificationManager: Sendable {
    public static let shared = NotificationManager()
    
    private init() {}
    
    // MARK: - Authorization
    public func requestAuthorization() async throws -> Bool {
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
    
    // MARK: - Daily Verse Notifications
    public func scheduleDailyVerse(at time: DateComponents) async {
        let content = UNMutableNotificationContent()
        content.title = "Daily Verse 📖"
        content.body = "Start your day with God's Word"
        content.sound = .default
        content.categoryIdentifier = "DAILY_VERSE"
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_verse",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            logInfo("Scheduled daily verse notification", category: .general)
        } catch {
            logError("Failed to schedule daily verse", error: error, category: .general)
        }
    }
    
    // MARK: - Reading Reminders
    public func scheduleReadingReminder(title: String, body: String, afterMinutes minutes: Int) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = "READING_REMINDER"
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(minutes * 60),
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
    
    // MARK: - Cancel Notifications
    public func cancelNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    public func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // MARK: - Check Authorization Status
    public func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
}
