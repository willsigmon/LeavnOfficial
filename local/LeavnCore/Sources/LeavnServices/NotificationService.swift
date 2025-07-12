import Foundation
import LeavnCore
@preconcurrency import UserNotifications

@MainActor
@preconcurrency
public final class NotificationService: ObservableObject, Sendable {
    public static let shared = NotificationService()
    
    @Published public var hasPermission = false
    @Published public var pendingNotifications: [PendingNotification] = []
    @Published public var unreadCount = 0
    @Published public var notifications: [AppNotification] = []
    
    private let notificationCenter: UNUserNotificationCenter
    private var bibleService: BibleServiceProtocol?
    
    @MainActor
    private init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        self.notificationCenter.delegate = NotificationDelegate.shared
        self.bibleService = DIContainer.shared.bibleService
        checkPermissionStatus()
        loadNotifications()
    }
    
    // MARK: - Permission
    public func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
            self.hasPermission = granted
            if granted {
                await setupCategories()
            }
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    private func checkPermissionStatus() {
        Task { [weak self] in
            guard let self = self else { return }
            let settings = await self.notificationCenter.notificationSettings()
            await MainActor.run {
                self.hasPermission = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Setup Categories
    private func setupCategories() async {
        let readAction = UNNotificationAction(
            identifier: "READ_ACTION",
            title: "Read Now",
            options: [.foreground]
        )
        
        let saveAction = UNNotificationAction(
            identifier: "SAVE_ACTION",
            title: "Save for Later",
            options: []
        )
        
        let replyAction = UNTextInputNotificationAction(
            identifier: "REPLY_ACTION",
            title: "Reply",
            options: [],
            textInputButtonTitle: "Send",
            textInputPlaceholder: "Type your reply..."
        )
        
        let dailyVerseCategory = UNNotificationCategory(
            identifier: "DAILY_VERSE",
            actions: [readAction, saveAction],
            intentIdentifiers: [],
            options: []
        )
        
        let communityCategory = UNNotificationCategory(
            identifier: "COMMUNITY_POST",
            actions: [replyAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([dailyVerseCategory, communityCategory])
    }
    
    // MARK: - Daily Verse
    public func scheduleDailyVerse(at time: DateComponents) async {
        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        
        // Cancel existing daily verse notifications
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-verse"])
        
        let content = UNMutableNotificationContent()
        content.title = "Daily Verse 📖"
        content.body = await getRandomVerse()
        content.categoryIdentifier = "DAILY_VERSE"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "daily-verse", content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
            print("Daily verse notification scheduled")
        } catch {
            print("Failed to schedule daily verse: \(error)")
        }
    }
    
    // MARK: - Reading Reminder
    public func scheduleReadingReminder(at time: DateComponents, message: String? = nil) async {
        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["reading-reminder"])
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Read 📚"
        content.body = message ?? "Continue your Bible reading journey"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: "reading-reminder", content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Failed to schedule reading reminder: \(error)")
        }
    }
    
    // MARK: - Achievement Notifications
    public func sendAchievementNotification(title: String, body: String) async {
        // Check permission
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound(named: UNNotificationSoundName("achievement.wav"))
        content.badge = NSNumber(value: unreadCount + 1)
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil // Immediate
        )
        
        do {
            try await notificationCenter.add(request)
            incrementUnreadCount()
        } catch {
            print("Failed to send achievement notification: \(error)")
        }
    }
    
    // MARK: - Community Notifications
    public func sendCommunityNotification(type: CommunityNotificationType, from user: String, postId: String? = nil) async {
        guard hasPermission else { return }
        
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "COMMUNITY_POST"
        content.sound = .default
        content.badge = NSNumber(value: unreadCount + 1)
        
        switch type {
        case .newReply:
            content.title = "New Reply 💬"
            content.body = "\(user) replied to your post"
        case .newLike:
            content.title = "New Like ❤️"
            content.body = "\(user) liked your post"
        case .newFollower:
            content.title = "New Follower 👋"
            content.body = "\(user) started following you"
        case .groupInvite:
            content.title = "Group Invite 👥"
            content.body = "\(user) invited you to join a study group"
        }
        
        if let postId = postId {
            content.userInfo = ["postId": postId]
        }
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        do {
            try await notificationCenter.add(request)
            incrementUnreadCount()
            addToNotificationCenter(type: type, from: user, postId: postId)
        } catch {
            print("Failed to send community notification: \(error)")
        }
    }
    
    // MARK: - Notification Center
    private func loadNotifications() {
        // Load from UserDefaults or Core Data
        if let data = UserDefaults.standard.data(forKey: "app_notifications"),
           let notifications = try? JSONDecoder().decode([AppNotification].self, from: data) {
            self.notifications = notifications
            self.unreadCount = notifications.filter { !$0.isRead }.count
        }
    }
    
    private func saveNotifications() {
        if let data = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(data, forKey: "app_notifications")
        }
    }
    
    private func addToNotificationCenter(type: CommunityNotificationType, from user: String, postId: String?) {
        let notification = AppNotification(
            id: UUID(),
            type: type,
            title: type.title,
            body: "\(user) \(type.action)",
            timestamp: Date(),
            isRead: false,
            userId: user,
            postId: postId
        )
        
        notifications.insert(notification, at: 0)
        if notifications.count > 50 {
            notifications.removeLast()
        }
        saveNotifications()
    }
    
    public func markAsRead(_ notificationId: UUID) {
        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            notifications[index].isRead = true
            unreadCount = max(0, unreadCount - 1)
            saveNotifications()
        }
    }
    
    public func markAllAsRead() {
        notifications.indices.forEach { notifications[$0].isRead = true }
        unreadCount = 0
        saveNotifications()
    }
    
    public func clearAll() {
        notifications.removeAll()
        unreadCount = 0
        saveNotifications()
    }
    
    private func incrementUnreadCount() {
        unreadCount += 1
    }
    
    // MARK: - Cancel Notifications
    public func cancelDailyVerse() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["daily-verse"])
    }
    
    public func cancelReadingReminder() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["reading-reminder"])
    }
    
    public func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    // MARK: - Helper
    nonisolated private func getRandomVerse() async -> String {
        // Get the bibleService from main actor context
        let service = await MainActor.run { self.bibleService }
        
        guard let bibleService = service else {
            // Fallback if service not available
            return "The Lord is my shepherd; I shall not want - Psalm 23:1"
        }
        
        do {
            // Get daily verse from the service
            let dailyVerse = try await bibleService.getDailyVerse(translation: .kjv)
            return "\(dailyVerse.text) - \(dailyVerse.reference)"
        } catch {
            // On error, return a fallback verse
            return "The Lord is my shepherd; I shall not want - Psalm 23:1"
        }
    }
}

// MARK: - Notification Models
public struct AppNotification: Codable, Identifiable {
    public let id: UUID
    public let type: CommunityNotificationType
    public let title: String
    public let body: String
    public let timestamp: Date
    public var isRead: Bool
    public let userId: String?
    public let postId: String?
}

public enum CommunityNotificationType: String, Codable {
    case newReply = "new_reply"
    case newLike = "new_like"
    case newFollower = "new_follower"
    case groupInvite = "group_invite"
    
    var title: String {
        switch self {
        case .newReply: return "New Reply 💬"
        case .newLike: return "New Like ❤️"
        case .newFollower: return "New Follower 👋"
        case .groupInvite: return "Group Invite 👥"
        }
    }
    
    var action: String {
        switch self {
        case .newReply: return "replied to your post"
        case .newLike: return "liked your post"
        case .newFollower: return "started following you"
        case .groupInvite: return "invited you to join a group"
        }
    }
}

public struct PendingNotification: Identifiable {
    public let id = UUID()
    public let identifier: String
    public let content: UNNotificationContent
    public let trigger: UNNotificationTrigger?
}

// MARK: - Notification Delegate
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate, @unchecked Sendable {
    static let shared = NotificationDelegate()
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "READ_ACTION":
            // Navigate to Bible view
            NotificationCenter.default.post(name: .navigateToBible, object: nil, userInfo: userInfo)
        case "SAVE_ACTION":
            // Save verse to library
            NotificationCenter.default.post(name: .saveVerse, object: nil, userInfo: userInfo)
        case "REPLY_ACTION":
            if let textResponse = response as? UNTextInputNotificationResponse {
                // Handle reply
                NotificationCenter.default.post(
                    name: .replyToPost,
                    object: nil,
                    userInfo: ["text": textResponse.userText, "postId": userInfo["postId"] ?? ""]
                )
            }
        default:
            // Handle tap on notification
            if let postId = userInfo["postId"] as? String {
                NotificationCenter.default.post(
                    name: .navigateToPost,
                    object: nil,
                    userInfo: ["postId": postId]
                )
            }
        }
        
        completionHandler()
    }
}

// MARK: - Notification Names
extension Notification.Name {
    public static let navigateToBible = Notification.Name("navigateToBible")
    public static let saveVerse = Notification.Name("saveVerse")
    public static let navigateToPost = Notification.Name("navigateToPost")
    public static let replyToPost = Notification.Name("replyToPost")
    public static let navigateToProfile = Notification.Name("navigateToProfile")
    public static let navigateToGroups = Notification.Name("navigateToGroups")
}
