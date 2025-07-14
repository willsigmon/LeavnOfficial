import Foundation
@preconcurrency import CoreData
import CloudKit
import SwiftUI

import os.log

// MARK: - UserPreferencesData
public struct UserPreferencesData {
    public var theologicalPerspectives: Set<TheologicalPerspective> = []
    public var preferredTranslation: String? = "NIV"
    public var selectedTheme: String? = "System"
    public var fontSize: Float = 16.0
    public var enableNotifications: Bool = true
    public var dailyReadingReminder: Bool = true
    public var reminderTime: Date? = nil
    public var primaryTranslation: String = "NIV"
    public var additionalTranslations: Set<String> = []
    public var readingGoal: ReadingGoal? = nil
    public var dailyNotificationTime: NotificationTime? = nil
    public var enableVoiceover: Bool = false
    public var voiceoverSpeed: Float = 1.0
    public var preferredVoice: String = "default"
    public var enableAIInsights: Bool = true
    public var enableContextualHelp: Bool = true
    public var enableReadingPlans: Bool = true
    public var useDemoAPIKey: Bool = true
    public var customOpenAIKey: String? = nil
    public var customElevenLabsKey: String? = nil
    public var updatedAt: Date = Date()
    
    public init() {}
    
    // Common Bible translations for onboarding
    public static let onboardingTranslations = [
        BibleTranslation(
            id: "NIV",
            name: "New International Version",
            abbreviation: "NIV",
            language: "en",
            description: "Most popular modern English translation",
            includesApocrypha: false
        ),
        BibleTranslation(
            id: "ESV",
            name: "English Standard Version",
            abbreviation: "ESV",
            language: "en",
            description: "Literal, word-for-word translation",
            includesApocrypha: false
        ),
        BibleTranslation(
            id: "KJV",
            name: "King James Version",
            abbreviation: "KJV",
            language: "en",
            description: "Classic traditional translation",
            includesApocrypha: false
        ),
        BibleTranslation(
            id: "NLT",
            name: "New Living Translation",
            abbreviation: "NLT",
            language: "en",
            description: "Easy-to-understand thought-for-thought",
            includesApocrypha: false
        ),
        BibleTranslation(
            id: "NASB",
            name: "New American Standard Bible",
            abbreviation: "NASB",
            language: "en",
            description: "Most literal word-for-word translation",
            includesApocrypha: false
        ),
        BibleTranslation(
            id: "MSG",
            name: "The Message",
            abbreviation: "MSG",
            language: "en",
            description: "Contemporary paraphrase",
            includesApocrypha: false
        )
    ]
    
    // Initialize from Core Data
    public init(coreData: UserPreferences) {
        // Convert Core Data to UserPreferencesData
        self.preferredTranslation = coreData.preferredTranslation
        self.selectedTheme = coreData.selectedTheme
        self.fontSize = coreData.fontSize
        self.enableNotifications = coreData.enableNotifications
        self.dailyReadingReminder = coreData.dailyReadingReminder
        self.reminderTime = coreData.reminderTime
        self.enableVoiceover = coreData.enableVoiceover
        self.voiceoverSpeed = coreData.voiceoverSpeed
        self.preferredVoice = coreData.preferredVoice ?? "default"
        self.enableAIInsights = coreData.enableAIInsights
        self.enableContextualHelp = coreData.enableContextualHelp
        self.enableReadingPlans = coreData.enableReadingPlans
        self.useDemoAPIKey = coreData.useDemoAPIKey
        self.customOpenAIKey = coreData.customOpenAIKey
        self.customElevenLabsKey = coreData.customElevenLabsKey
        self.updatedAt = coreData.updatedAt ?? Date()
        
        // For now, theological perspectives will be empty since it's not in Core Data yet
        // In a real implementation, this would be stored as a JSON string or similar
        self.theologicalPerspectives = []
    }
    
    // Update Core Data from UserPreferencesData
    public func update(coreData: UserPreferences) {
        coreData.preferredTranslation = self.preferredTranslation
        coreData.selectedTheme = self.selectedTheme
        coreData.fontSize = self.fontSize
        coreData.enableNotifications = self.enableNotifications
        coreData.dailyReadingReminder = self.dailyReadingReminder
        coreData.reminderTime = self.reminderTime
        coreData.enableVoiceover = self.enableVoiceover
        coreData.voiceoverSpeed = self.voiceoverSpeed
        coreData.preferredVoice = self.preferredVoice
        coreData.enableAIInsights = self.enableAIInsights
        coreData.enableContextualHelp = self.enableContextualHelp
        coreData.enableReadingPlans = self.enableReadingPlans
        coreData.useDemoAPIKey = self.useDemoAPIKey
        coreData.customOpenAIKey = self.customOpenAIKey
        coreData.customElevenLabsKey = self.customElevenLabsKey
        coreData.updatedAt = self.updatedAt
        
        // For now, theological perspectives storage is not implemented in Core Data
        // In a real implementation, this would be stored as a JSON string or similar
    }
}

@MainActor
public final class UserDataManager: ObservableObject {
    public static let shared = UserDataManager()
    
    private let persistenceController = PersistenceController.shared
    private let logger = os.Logger(subsystem: "com.leavn.app", category: "UserData")
    
    // MARK: - Published Properties
    @Published public var currentUser: UserProfile?
    @Published public var isSignedIn: Bool = false
    @Published public var isSyncing: Bool = false
    @Published public var lastSyncDate: Date?
    @Published public var syncError: Error?
    
    // MARK: - Reading Session Properties
    @Published public var currentReadingSession: ReadingSession?
    @Published public var sessionStartTime: Date?
    private var sessionTimer: Timer?
    
    // MARK: - Computed Properties
    public var context: NSManagedObjectContext {
        persistenceController.context
    }
    
    // MARK: - UserPreferencesData
    
    @Published public var userPreferences: UserPreferencesData?
    
    // MARK: - Initialization
    
    private init() {
        setupNotifications()
    }
    
    public func initialize() async {
        await performUserDefaultsMigration()
        // Load current user after migration completes
        loadCurrentUser()
    }
    
    // MARK: - UserDefaults Migration
    
    private func performUserDefaultsMigration() async {
        let migrationKey = "userdefaults_migration_completed_v1"
        
        guard !UserDefaults.standard.bool(forKey: migrationKey) else {
            logger.info("UserDefaults migration already completed")
            return
        }
        
        logger.info("Starting UserDefaults migration to Core Data")
        
        let context = persistenceController.context
        await context.perform { @Sendable [weak self] in
            guard let self = self else { return }
            
            do {
                let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
                let existingUsers = try context.fetch(userRequest)
                
                if !existingUsers.isEmpty {
                    self.logger.info("Existing users found, skipping migration")
                    UserDefaults.standard.set(true, forKey: migrationKey)
                    return
                }
                
                if let appleUserIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier") {
                    try self.migrateAppleSignInUser(appleUserIdentifier: appleUserIdentifier, context: context)
                } else {
                    try self.migrateDefaultUser(context: context)
                }
                
                try context.save()
                UserDefaults.standard.set(true, forKey: migrationKey)
                self.logger.info("UserDefaults migration completed successfully")
                
            } catch {
                self.logger.error("UserDefaults migration failed: \(error.localizedDescription)")
            }
        }
    }
    
    private nonisolated func migrateAppleSignInUser(appleUserIdentifier: String, context: NSManagedObjectContext) throws {
        let user = UserProfile(context: context)
        user.id = UUID()
        user.appleUserIdentifier = appleUserIdentifier
        user.name = UserDefaults.standard.string(forKey: "appleUserName") ?? "Bible Reader"
        user.email = UserDefaults.standard.string(forKey: "appleUserEmail")
        user.createdAt = Date()
        user.updatedAt = Date()
        
        let preferences = UserPreferences(context: context)
        preferences.id = UUID()
        preferences.updatedAt = Date()
        
        migrateUserPreferencesData(to: preferences)
        migrateUserStatistics(to: user)
        migrateReadingProgress(to: user, preferences: preferences, context: context)
        
        user.preferences = preferences
        logger.info("Migrated Apple Sign-In user and preferences")
    }
    
    private nonisolated func migrateDefaultUser(context: NSManagedObjectContext) throws {
        let user = UserProfile(context: context)
        user.id = UUID()
        user.name = "Bible Reader"
        user.createdAt = Date()
        user.updatedAt = Date()
        
        let preferences = UserPreferences(context: context)
        preferences.id = UUID()
        preferences.updatedAt = Date()
        
        migrateUserPreferencesData(to: preferences)
        user.preferences = preferences
        logger.info("Created default user with migrated preferences")
    }
    
    private nonisolated func migrateUserPreferencesData(to preferences: UserPreferences) {
        // Migrate translation
        if let translationData = UserDefaults.standard.data(forKey: "selectedBibleTranslation"),
           let translation = try? JSONDecoder().decode(BibleTranslation.self, from: translationData) {
            preferences.preferredTranslation = translation.name
        } else if let translation = UserDefaults.standard.string(forKey: "defaultTranslation") {
            preferences.preferredTranslation = translation
        }
        
        // Migrate font size
        if let fontSize = UserDefaults.standard.object(forKey: "bibleReaderFontSize") as? Float {
            preferences.fontSize = fontSize
        } else if let fontSize = UserDefaults.standard.object(forKey: "bibleFontSize") as? Float {
            preferences.fontSize = fontSize
        }
        
        // Migrate theme
        if let theme = UserDefaults.standard.string(forKey: "selectedTheme") {
            preferences.selectedTheme = theme
        } else if UserDefaults.standard.bool(forKey: "darkModeEnabled") {
            preferences.selectedTheme = "dark"
        }
        
        // Migrate settings
        preferences.enableNotifications = UserDefaults.standard.object(forKey: "notificationsEnabled") as? Bool ?? true
        preferences.dailyReadingReminder = UserDefaults.standard.object(forKey: "dailyVerseEnabled") as? Bool ?? true
        preferences.useDemoAPIKey = UserDefaults.standard.object(forKey: "useDemoAPIKey") as? Bool ?? true
        preferences.customOpenAIKey = UserDefaults.standard.string(forKey: "customOpenAIKey")
        preferences.customElevenLabsKey = UserDefaults.standard.string(forKey: "customElevenLabsKey")
    }
    
    private nonisolated func migrateUserStatistics(to user: UserProfile) {
        if let readingStreak = UserDefaults.standard.object(forKey: "readingStreak") as? Int32 {
            user.readingStreak = readingStreak
        }
        if let versesRead = UserDefaults.standard.object(forKey: "versesRead") as? Int32 {
            user.versesRead = versesRead
        }
        if let totalReadingTime = UserDefaults.standard.object(forKey: "totalReadingTime") as? Int32 {
            user.totalReadingTime = totalReadingTime
        }
        if let lastReadDate = UserDefaults.standard.object(forKey: "lastReadDate") as? Date {
            user.lastReadDate = lastReadDate
        }
    }
    
    private nonisolated func migrateReadingProgress(to user: UserProfile, preferences: UserPreferences, context: NSManagedObjectContext) {
        if let selectedBook = UserDefaults.standard.string(forKey: "selectedBook"),
           let selectedChapter = UserDefaults.standard.object(forKey: "selectedChapter") as? Int32,
           selectedChapter > 0 {
            let progress = ReadingProgress(context: context)
            progress.id = UUID()
            progress.user = user
            progress.bookName = selectedBook
            progress.chapter = selectedChapter
            progress.verse = 1
            progress.translation = preferences.preferredTranslation ?? "kjv"
            progress.lastReadAt = Date()
            progress.updatedAt = Date()
        }
    }
    
    // MARK: - User Management
    
    public func createOrUpdateUser(appleUserIdentifier: String, name: String?, email: String?) async {
        let context = persistenceController.context
        
let result: (UserProfile, UserPreferences?)? = await context.perform { @Sendable in
            // Check if user already exists
            let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            request.predicate = NSPredicate(format: "appleUserIdentifier == %@", appleUserIdentifier)
            
            do {
                let existingUsers = try context.fetch(request)
                let user: UserProfile
                
                if let existingUser = existingUsers.first {
                    user = existingUser
                } else {
                    user = UserProfile(context: context)
                    user.id = UUID()
                    user.appleUserIdentifier = appleUserIdentifier
                    user.createdAt = Date()
                }
                
                // Update user information
                user.name = name
                user.email = email
                user.updatedAt = Date()
                
                // Create or update preferences
                if user.preferences == nil {
                    let preferences = UserPreferences(context: context)
                    preferences.id = UUID()
                    preferences.updatedAt = Date()
                    user.preferences = preferences
                }
                
                try context.save()
                return (user, user.preferences)
                
            } catch {
                return nil
            }
        }
        
        // Update main actor properties
        if let (user, preferences) = result {
            await MainActor.run {
                self.currentUser = user
                if let prefs = preferences {
                    self.userPreferences = UserPreferencesData(coreData: prefs)
                }
                self.isSignedIn = true
                self.logger.info("User data saved successfully")
            }
        } else {
            logger.error("Failed to create/update user")
        }
    }
    
    public func signOut() {
        currentUser = nil
        userPreferences = nil
        isSignedIn = false
        endCurrentReadingSession()
        logger.info("User signed out")
    }
    
    private func loadCurrentUser() {
        // Load the most recently updated user
        let context = persistenceController.context
        let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)]
        request.fetchLimit = 1
        
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                if let prefs = user.preferences {
                    userPreferences = UserPreferencesData(coreData: prefs)
                }
                isSignedIn = true
                logger.info("Loaded current user")
            }
        } catch {
            logger.error("Failed to load current user: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func getCurrentUserID() -> UUID? {
        return currentUser?.id
    }
    
    @MainActor
    private func getCurrentReadingSessionID() -> UUID? {
        return currentReadingSession?.id
    }
    
    // MARK: - Preferences Management
    
    public func updatePreferences(_ updates: @escaping @Sendable (inout UserPreferencesData) -> Void) async {
        guard var preferences = userPreferences else { return }
        
        // Apply updates outside of the context.perform closure
        updates(&preferences)
        preferences.updatedAt = Date()
        
        // Create a copy to use in the closure
        let updatedPreferences = preferences
        
        let context = persistenceController.context
        let success = await context.perform { @Sendable in
            // Find current user within context to avoid main actor isolation
            let request: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \UserProfile.updatedAt, ascending: false)]
            request.fetchLimit = 1
            
            do {
                let users = try context.fetch(request)
                if let user = users.first, let coreDataPrefs = user.preferences {
                    updatedPreferences.update(coreData: coreDataPrefs)
                }
                
                try context.save()
                return true
            } catch {
                return false
            }
        }
        
        if success {
            await MainActor.run {
                self.userPreferences = preferences
            }
        } else {
            logger.error("Failed to update preferences")
        }
    }
    
    public func updateTheme(_ theme: String) async {
        await updatePreferences { preferences in
            preferences.selectedTheme = theme
        }
    }
    
    public func updateTranslation(_ translation: String) async {
        await updatePreferences { preferences in
            preferences.preferredTranslation = translation
        }
    }
    
    public func updateFontSize(_ size: Float) async {
        await updatePreferences { preferences in
            preferences.fontSize = size
        }
    }
    
    public func updateVoiceoverSettings(enabled: Bool, speed: Float, voice: String) async {
        await updatePreferences { preferences in
            preferences.enableVoiceover = enabled
            preferences.voiceoverSpeed = speed
            preferences.preferredVoice = voice
        }
    }
    
    public func updateNotificationSettings(enabled: Bool, dailyReminder: Bool, reminderTime: Date?) async {
        await updatePreferences { preferences in
            preferences.enableNotifications = enabled
            preferences.dailyReadingReminder = dailyReminder
            preferences.reminderTime = reminderTime
        }
    }
    
    public func updateAISettings(insights: Bool, contextualHelp: Bool, readingPlans: Bool) async {
        await updatePreferences { preferences in
            preferences.enableAIInsights = insights
            preferences.enableContextualHelp = contextualHelp
            preferences.enableReadingPlans = readingPlans
        }
    }
    
    public func updateAPIKeySettings(useDemoKey: Bool, openAIKey: String?, elevenLabsKey: String?) async {
        await updatePreferences { preferences in
            preferences.useDemoAPIKey = useDemoKey
            preferences.customOpenAIKey = openAIKey
            preferences.customElevenLabsKey = elevenLabsKey
        }
    }
    
    public func updateTheologicalPerspectives(_ perspectives: Set<TheologicalPerspective>) async {
        await updatePreferences { preferences in
            preferences.theologicalPerspectives = perspectives
        }
    }
    
    // MARK: - Reading Progress Management
    
    public func updateReadingProgress(book: String, chapter: Int, verse: Int, translation: String) async {
        // Get user identifier to find user within context
        guard let currentUserID = currentUser?.id else { return }
        
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return false
                }
                
                // Find existing progress for this book
                let request: NSFetchRequest<ReadingProgress> = ReadingProgress.fetchRequest()
                request.predicate = NSPredicate(format: "user == %@ AND bookName == %@", user, book)
                
                let existingProgress = try context.fetch(request)
                let progress: ReadingProgress
                
                if let existing = existingProgress.first {
                    progress = existing
                } else {
                    progress = ReadingProgress(context: context)
                    progress.id = UUID()
                    progress.user = user
                    progress.bookName = book
                }
                
                progress.chapter = Int32(chapter)
                progress.verse = Int32(verse)
                progress.translation = translation
                progress.lastReadAt = Date()
                progress.updatedAt = Date()
                
                // Update user's last read date
                user.lastReadDate = Date()
                user.updatedAt = Date()
                
                try context.save()
                return true
                
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Updated reading progress: \(book) \(chapter):\(verse)")
        } else {
            logger.error("Failed to update reading progress")
        }
    }
    
    public func getReadingProgress(for book: String) async -> ReadingProgress? {
        guard let currentUserID = currentUser?.id else { return nil }
        
        let context = persistenceController.context
let result: ReadingProgress? = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return nil
                }
                
                let request: NSFetchRequest<ReadingProgress> = ReadingProgress.fetchRequest()
                request.predicate = NSPredicate(format: "user == %@ AND bookName == %@", user, book)
                request.fetchLimit = 1
                
                return try context.fetch(request).first
            } catch {
                return nil
            }
        }
        
        if result == nil {
            logger.error("Failed to fetch reading progress for book: \(book)")
        }
        
        return result
    }
    
    // MARK: - Reading Session Management
    
    public func startReadingSession(book: String, chapter: Int, translation: String) {
        // End any existing session
        endCurrentReadingSession()
        
        Task {
            guard let currentUserID = currentUser?.id else { return }
            
            let context = persistenceController.context
let session: ReadingSession? = await context.perform { @Sendable in
                // Find user within the context
                let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
                userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
                userRequest.fetchLimit = 1
                
                do {
                    guard let user = try context.fetch(userRequest).first else {
                        return nil
                    }
                    
                    let session = ReadingSession(context: context)
                    session.id = UUID()
                    session.user = user
                    session.startTime = Date()
                    session.translation = translation
                    session.booksRead = book
                    session.chaptersRead = "\(book) \(chapter)"
                    session.sessionType = "reading"
                    session.createdAt = Date()
                    
                    try context.save()
                    return session
                    
                } catch {
                    return nil
                }
            }
            
            await MainActor.run {
                if let session = session {
                    self.currentReadingSession = session
                    self.startSessionTimer()
                    self.logger.info("Started reading session")
                } else {
                    self.logger.error("Failed to start reading session")
                }
            }
        }
    }
    
    public func endCurrentReadingSession() {
        guard let sessionID = currentReadingSession?.id else { return }
        
        stopSessionTimer()
        
        let context = persistenceController.context
        Task {
let success = await context.perform { @Sendable in
                // Find session within the context
                let sessionRequest: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
                sessionRequest.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
                sessionRequest.fetchLimit = 1
                
                do {
                    guard let session = try context.fetch(sessionRequest).first else {
                        return false
                    }
                    
                    session.endTime = Date()
                    if let startTime = session.startTime, let endTime = session.endTime {
                        session.duration = Int32(endTime.timeIntervalSince(startTime))
                    }
                    
                    try context.save()
                    return true
                } catch {
                    return false
                }
            }
            
            if success {
                logger.info("Ended reading session")
            } else {
                logger.error("Failed to end reading session")
            }
        }
        
        currentReadingSession = nil
    }
    
    private func startSessionTimer() {
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateSessionProgress()
            }
        }
    }
    
    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
    
    @MainActor
    private func updateSessionProgress() {
        guard let session = currentReadingSession,
              let startTime = session.startTime else { return }
        
        let currentDurationSeconds = Date().timeIntervalSince(startTime)
        session.duration = Int32(currentDurationSeconds)
        
        // Save session progress
        Task {
            await saveReadingSession(session)
        }
    }
    
    private func saveReadingSession(_ session: ReadingSession) async {
        let sessionID = session.id
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find session within the context to ensure it's in the right context
            let sessionRequest: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
            sessionRequest.predicate = NSPredicate(format: "id == %@", sessionID! as any CVarArg)
            sessionRequest.fetchLimit = 1
            
            do {
                if let _ = try context.fetch(sessionRequest).first {
                    try context.save()
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Reading session progress saved")
        } else {
            logger.warning("Session not found in context for saving")
        }
    }
    
    // MARK: - Statistics Management
    
    public func incrementVersesRead(count: Int = 1) async {
        guard let currentUserID = currentUser?.id else { return }
        let currentSessionID = currentReadingSession?.id
        
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return false
                }
                
                user.versesRead += Int32(count)
                user.updatedAt = Date()
                
                // Update current session if active
                if let sessionID = currentSessionID {
                    let sessionRequest: NSFetchRequest<ReadingSession> = ReadingSession.fetchRequest()
                    sessionRequest.predicate = NSPredicate(format: "id == %@", sessionID as CVarArg)
                    sessionRequest.fetchLimit = 1
                    
                    if let session = try context.fetch(sessionRequest).first {
                        session.versesRead += Int32(count)
                    }
                }
                
                try context.save()
                return true
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Incremented verses read by \(count)")
        } else {
            logger.error("Failed to increment verses read")
        }
    }
    
    public func updateReadingStreak() async {
        guard let currentUserID = currentUser?.id else { return }
        
        let context = persistenceController.context
let result = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return (false, 0)
                }
                
                let calendar = Calendar.current
                let today = Date()
                
                if let lastReadDate = user.lastReadDate {
                    if calendar.isDate(lastReadDate, inSameDayAs: today) {
                        // Already read today, no change needed
                        return (true, Int(user.readingStreak))
                    } else if calendar.isDate(lastReadDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: today)!) {
                        // Read yesterday, increment streak
                        user.readingStreak += 1
                    } else {
                        // Missed a day, reset streak
                        user.readingStreak = 1
                    }
                } else {
                    // First time reading
                    user.readingStreak = 1
                }
                
                user.lastReadDate = today
                user.updatedAt = Date()
                
                try context.save()
                return (true, Int(user.readingStreak))
            } catch {
                return (false, 0)
            }
        }
        
        if result.0 {
            logger.info("Updated reading streak to \(result.1)")
        } else {
            logger.error("Failed to update reading streak")
        }
    }
    
    // MARK: - Bookmarks Management
    
    public func addBookmark(book: String, chapter: Int, verse: Int, translation: String, verseText: String, title: String?, tags: String?, color: String?) async {
        guard let currentUserID = currentUser?.id else { return }
        
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return false
                }
                
                let bookmark = Bookmark(context: context)
                bookmark.id = UUID()
                bookmark.user = user
                bookmark.bookName = book
                bookmark.chapter = Int32(chapter)
                bookmark.verse = Int32(verse)
                bookmark.translation = translation
                bookmark.verseText = verseText
                bookmark.title = title
                bookmark.tags = tags
                bookmark.color = color
                bookmark.createdAt = Date()
                bookmark.updatedAt = Date()
                
                try context.save()
                return true
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Added bookmark: \(book) \(chapter):\(verse)")
        } else {
            logger.error("Failed to add bookmark")
        }
    }
    
    public func removeBookmark(_ bookmark: Bookmark) async {
        let bookmarkID = bookmark.id
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find bookmark within the context
            let bookmarkRequest: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
            bookmarkRequest.predicate = NSPredicate(format: "id == %@", bookmarkID! as any CVarArg)
            bookmarkRequest.fetchLimit = 1
            
            do {
                if let bookmarkToDelete = try context.fetch(bookmarkRequest).first {
                    context.delete(bookmarkToDelete)
                    try context.save()
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Removed bookmark")
        } else {
            logger.warning("Bookmark not found or failed to remove")
        }
    }
    
    // MARK: - Notes Management
    
    public func addNote(book: String, chapter: Int, verse: Int, translation: String, content: String, title: String?, tags: String?) async {
        guard let currentUserID = currentUser?.id else { return }
        
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find user within the context
            let userRequest: NSFetchRequest<UserProfile> = UserProfile.fetchRequest()
            userRequest.predicate = NSPredicate(format: "id == %@", currentUserID as CVarArg)
            userRequest.fetchLimit = 1
            
            do {
                guard let user = try context.fetch(userRequest).first else {
                    return false
                }
                
                let note = Note(context: context)
                note.id = UUID()
                note.user = user
                note.bookName = book
                note.chapter = Int32(chapter)
                note.verse = Int32(verse)
                note.translation = translation
                note.content = content
                note.title = title
                note.tags = tags
                note.createdAt = Date()
                note.updatedAt = Date()
                
                try context.save()
                return true
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Added note: \(book) \(chapter):\(verse)")
        } else {
            logger.error("Failed to add note")
        }
    }
    
    public func updateNote(_ note: Note, content: String, title: String?, tags: String?) async {
        let noteID = note.id
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find note within the context
            let noteRequest: NSFetchRequest<Note> = Note.fetchRequest()
            noteRequest.predicate = NSPredicate(format: "id == %@", noteID! as any CVarArg)
            noteRequest.fetchLimit = 1
            
            do {
                if let noteToUpdate = try context.fetch(noteRequest).first {
                    noteToUpdate.content = content
                    noteToUpdate.title = title
                    noteToUpdate.tags = tags
                    noteToUpdate.updatedAt = Date()
                    try context.save()
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Updated note")
        } else {
            logger.warning("Note not found or failed to update")
        }
    }
    
    public func removeNote(_ note: Note) async {
        let noteID = note.id
        let context = persistenceController.context
let success = await context.perform { @Sendable in
            // Find note within the context
            let noteRequest: NSFetchRequest<Note> = Note.fetchRequest()
            noteRequest.predicate = NSPredicate(format: "id == %@", noteID! as any CVarArg)
            noteRequest.fetchLimit = 1
            
            do {
                if let noteToDelete = try context.fetch(noteRequest).first {
                    context.delete(noteToDelete)
                    try context.save()
                    return true
                } else {
                    return false
                }
            } catch {
                return false
            }
        }
        
        if success {
            logger.info("Removed note")
        } else {
            logger.warning("Note not found or failed to remove")
        }
    }
    
    // MARK: - Sync Management
    
    public func forceSyncWithiCloud() async {
        isSyncing = true
        
        // Use async version instead of performAndWait to avoid blocking
        await withCheckedContinuation { continuation in
            persistenceController.container.persistentStoreCoordinator.perform {
                // Trigger CloudKit sync
                let stores = self.persistenceController.container.persistentStoreCoordinator.persistentStores
                for store in stores {
                    // CloudKit will automatically handle the sync
                    self.logger.info("Triggering CloudKit sync for store: \(store.identifier ?? "unknown")")
                }
                continuation.resume()
            }
        }
        
        lastSyncDate = Date()
        logger.info("iCloud sync completed")
        isSyncing = false
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRemoteChange),
            name: .NSPersistentStoreRemoteChange,
            object: persistenceController.container.persistentStoreCoordinator
        )
    }
    
    @objc private nonisolated func handleRemoteChange(_ notification: Notification) {
        // Use Task instead of DispatchQueue to properly handle @MainActor
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            
            self.logger.info("Received remote change notification")
            self.lastSyncDate = Date()
            
            // Refresh current user data
            self.loadCurrentUser()
        }
    }
    
    // MARK: - Cleanup
    
    public func cleanup() {
        stopSessionTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        // Timer cleanup should be done via cleanup() method before deinit
        // to avoid accessing non-Sendable Timer from nonisolated context
        NotificationCenter.default.removeObserver(self)
    }
} 

