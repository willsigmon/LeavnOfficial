import Foundation

// MARK: - App Settings Models
public struct AppSettings: Codable {
    public let general: GeneralSettings
    public let bible: BibleSettings
    public let privacy: PrivacySettings
    public let sync: SyncSettings
    public let accessibility: AccessibilitySettings
    public let notifications: NotificationSettings
    public let display: DisplaySettings
    public let storage: StorageSettings
    public let analytics: AnalyticsSettings
    public let lastModified: Date
    public let version: String
    
    public init(
        general: GeneralSettings = GeneralSettings(),
        bible: BibleSettings = BibleSettings(),
        privacy: PrivacySettings = PrivacySettings(),
        sync: SyncSettings = SyncSettings(),
        accessibility: AccessibilitySettings = AccessibilitySettings(),
        notifications: NotificationSettings = NotificationSettings(),
        display: DisplaySettings = DisplaySettings(),
        storage: StorageSettings = StorageSettings(),
        analytics: AnalyticsSettings = AnalyticsSettings(),
        lastModified: Date = Date(),
        version: String = "1.0.0"
    ) {
        self.general = general
        self.bible = bible
        self.privacy = privacy
        self.sync = sync
        self.accessibility = accessibility
        self.notifications = notifications
        self.display = display
        self.storage = storage
        self.analytics = analytics
        self.lastModified = lastModified
        self.version = version
    }
}

// MARK: - General Settings
public struct GeneralSettings: Codable {
    public let language: SettingsLanguage
    public let region: SettingsRegion
    public let firstDayOfWeek: DayOfWeek
    public let timeFormat: TimeFormat
    public let autoSave: Bool
    public let autoBackup: Bool
    public let allowCellularSync: Bool
    public let hapticFeedback: Bool
    public let soundEffects: Bool
    public let backgroundRefresh: Bool
    
    public init(
        language: SettingsLanguage = .systemDefault,
        region: SettingsRegion = .systemDefault,
        firstDayOfWeek: DayOfWeek = .sunday,
        timeFormat: TimeFormat = .system,
        autoSave: Bool = true,
        autoBackup: Bool = true,
        allowCellularSync: Bool = false,
        hapticFeedback: Bool = true,
        soundEffects: Bool = true,
        backgroundRefresh: Bool = true
    ) {
        self.language = language
        self.region = region
        self.firstDayOfWeek = firstDayOfWeek
        self.timeFormat = timeFormat
        self.autoSave = autoSave
        self.autoBackup = autoBackup
        self.allowCellularSync = allowCellularSync
        self.hapticFeedback = hapticFeedback
        self.soundEffects = soundEffects
        self.backgroundRefresh = backgroundRefresh
    }
}

public enum SettingsLanguage: String, Codable, CaseIterable {
    case systemDefault = "system"
    case english = "en"
    case spanish = "es"
    case french = "fr"
    case german = "de"
    case portuguese = "pt"
    case korean = "ko"
    case chinese = "zh"
    case japanese = "ja"
    case arabic = "ar"
    case hindi = "hi"
    
    public var displayName: String {
        switch self {
        case .systemDefault: return "System Default"
        case .english: return "English"
        case .spanish: return "Español"
        case .french: return "Français"
        case .german: return "Deutsch"
        case .portuguese: return "Português"
        case .korean: return "한국어"
        case .chinese: return "中文"
        case .japanese: return "日本語"
        case .arabic: return "العربية"
        case .hindi: return "हिन्दी"
        }
    }
}

public enum SettingsRegion: String, Codable, CaseIterable {
    case systemDefault = "system"
    case unitedStates = "US"
    case canada = "CA"
    case unitedKingdom = "GB"
    case germany = "DE"
    case france = "FR"
    case spain = "ES"
    case brazil = "BR"
    case korea = "KR"
    case china = "CN"
    case japan = "JP"
    case australia = "AU"
    
    public var displayName: String {
        switch self {
        case .systemDefault: return "System Default"
        case .unitedStates: return "United States"
        case .canada: return "Canada"
        case .unitedKingdom: return "United Kingdom"
        case .germany: return "Germany"
        case .france: return "France"
        case .spain: return "Spain"
        case .brazil: return "Brazil"
        case .korea: return "South Korea"
        case .china: return "China"
        case .japan: return "Japan"
        case .australia: return "Australia"
        }
    }
}

public enum DayOfWeek: String, Codable, CaseIterable {
    case sunday = "sunday"
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    
    public var displayName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

public enum TimeFormat: String, Codable, CaseIterable {
    case system = "system"
    case twelve = "12"
    case twentyFour = "24"
    
    public var displayName: String {
        switch self {
        case .system: return "System Default"
        case .twelve: return "12-hour"
        case .twentyFour: return "24-hour"
        }
    }
}

// MARK: - Bible Settings
public struct BibleSettings: Codable {
    public let defaultTranslation: BibleTranslation
    public let secondaryTranslation: BibleTranslation?
    public let parallelReading: Bool
    public let verseNumbers: Bool
    public let redLetterText: Bool
    public let fontSize: BibleFontSize
    public let fontFamily: BibleFontFamily
    public let lineSpacing: BibleLineSpacing
    public let textAlignment: BibleTextAlignment
    public let theme: BibleTheme
    public let highlightColors: [HighlightColor]
    public let crossReferences: Bool
    public let footnotes: Bool
    public let studyNotes: Bool
    public let readingPlan: ReadingPlanSettings
    
    public init(
        defaultTranslation: BibleTranslation = .esv,
        secondaryTranslation: BibleTranslation? = nil,
        parallelReading: Bool = false,
        verseNumbers: Bool = true,
        redLetterText: Bool = true,
        fontSize: BibleFontSize = .medium,
        fontFamily: BibleFontFamily = .system,
        lineSpacing: BibleLineSpacing = .normal,
        textAlignment: BibleTextAlignment = .left,
        theme: BibleTheme = .light,
        highlightColors: [HighlightColor] = HighlightColor.defaultColors,
        crossReferences: Bool = true,
        footnotes: Bool = true,
        studyNotes: Bool = true,
        readingPlan: ReadingPlanSettings = ReadingPlanSettings()
    ) {
        self.defaultTranslation = defaultTranslation
        self.secondaryTranslation = secondaryTranslation
        self.parallelReading = parallelReading
        self.verseNumbers = verseNumbers
        self.redLetterText = redLetterText
        self.fontSize = fontSize
        self.fontFamily = fontFamily
        self.lineSpacing = lineSpacing
        self.textAlignment = textAlignment
        self.theme = theme
        self.highlightColors = highlightColors
        self.crossReferences = crossReferences
        self.footnotes = footnotes
        self.studyNotes = studyNotes
        self.readingPlan = readingPlan
    }
}

public enum BibleTranslation: String, Codable, CaseIterable {
    case esv = "ESV"
    case niv = "NIV"
    case nasb = "NASB"
    case kjv = "KJV"
    case nkjv = "NKJV"
    case csb = "CSB"
    case nlt = "NLT"
    case msg = "MSG"
    case amp = "AMP"
    case nrsv = "NRSV"
    
    public var displayName: String {
        switch self {
        case .esv: return "English Standard Version"
        case .niv: return "New International Version"
        case .nasb: return "New American Standard Bible"
        case .kjv: return "King James Version"
        case .nkjv: return "New King James Version"
        case .csb: return "Christian Standard Bible"
        case .nlt: return "New Living Translation"
        case .msg: return "The Message"
        case .amp: return "Amplified Bible"
        case .nrsv: return "New Revised Standard Version"
        }
    }
    
    public var abbreviation: String {
        return rawValue
    }
}

public enum BibleFontSize: String, Codable, CaseIterable {
    case extraSmall = "xs"
    case small = "sm"
    case medium = "md"
    case large = "lg"
    case extraLarge = "xl"
    case jumbo = "xxl"
    
    public var displayName: String {
        switch self {
        case .extraSmall: return "Extra Small"
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        case .jumbo: return "Jumbo"
        }
    }
    
    public var pointSize: CGFloat {
        switch self {
        case .extraSmall: return 12
        case .small: return 14
        case .medium: return 16
        case .large: return 18
        case .extraLarge: return 20
        case .jumbo: return 24
        }
    }
}

public enum BibleFontFamily: String, Codable, CaseIterable {
    case system = "system"
    case georgia = "georgia"
    case times = "times"
    case palatino = "palatino"
    case charter = "charter"
    case newYork = "new_york"
    
    public var displayName: String {
        switch self {
        case .system: return "System Font"
        case .georgia: return "Georgia"
        case .times: return "Times New Roman"
        case .palatino: return "Palatino"
        case .charter: return "Charter"
        case .newYork: return "New York"
        }
    }
}

public enum BibleLineSpacing: String, Codable, CaseIterable {
    case compact = "compact"
    case normal = "normal"
    case relaxed = "relaxed"
    case loose = "loose"
    
    public var displayName: String {
        switch self {
        case .compact: return "Compact"
        case .normal: return "Normal"
        case .relaxed: return "Relaxed"
        case .loose: return "Loose"
        }
    }
    
    public var lineHeightMultiplier: CGFloat {
        switch self {
        case .compact: return 1.1
        case .normal: return 1.2
        case .relaxed: return 1.4
        case .loose: return 1.6
        }
    }
}

public enum BibleTextAlignment: String, Codable, CaseIterable {
    case left = "left"
    case center = "center"
    case justified = "justified"
    
    public var displayName: String {
        switch self {
        case .left: return "Left"
        case .center: return "Center"
        case .justified: return "Justified"
        }
    }
}

public enum BibleTheme: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case sepia = "sepia"
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .sepia: return "Sepia"
        case .blue: return "Blue"
        case .green: return "Green"
        case .purple: return "Purple"
        case .system: return "System"
        }
    }
}

public struct HighlightColor: Codable, Identifiable {
    public let id: String
    public let name: String
    public let color: String
    public let isDefault: Bool
    
    public init(id: String = UUID().uuidString, name: String, color: String, isDefault: Bool = false) {
        self.id = id
        self.name = name
        self.color = color
        self.isDefault = isDefault
    }
    
    public static let defaultColors: [HighlightColor] = [
        HighlightColor(name: "Yellow", color: "#FFEB3B", isDefault: true),
        HighlightColor(name: "Green", color: "#4CAF50"),
        HighlightColor(name: "Blue", color: "#2196F3"),
        HighlightColor(name: "Orange", color: "#FF9800"),
        HighlightColor(name: "Pink", color: "#E91E63"),
        HighlightColor(name: "Purple", color: "#9C27B0")
    ]
}

public struct ReadingPlanSettings: Codable {
    public let isEnabled: Bool
    public let currentPlan: ReadingPlan?
    public let reminderTime: Date?
    public let reminderDays: [DayOfWeek]
    public let allowMissedDays: Bool
    public let showProgress: Bool
    
    public init(
        isEnabled: Bool = false,
        currentPlan: ReadingPlan? = nil,
        reminderTime: Date? = nil,
        reminderDays: [DayOfWeek] = [],
        allowMissedDays: Bool = true,
        showProgress: Bool = true
    ) {
        self.isEnabled = isEnabled
        self.currentPlan = currentPlan
        self.reminderTime = reminderTime
        self.reminderDays = reminderDays
        self.allowMissedDays = allowMissedDays
        self.showProgress = showProgress
    }
}

public struct ReadingPlan: Codable, Identifiable {
    public let id: String
    public let name: String
    public let description: String
    public let duration: Int // days
    public let category: ReadingPlanCategory
    public let startDate: Date?
    public let currentDay: Int
    public let isCompleted: Bool
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        description: String,
        duration: Int,
        category: ReadingPlanCategory,
        startDate: Date? = nil,
        currentDay: Int = 1,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.duration = duration
        self.category = category
        self.startDate = startDate
        self.currentDay = currentDay
        self.isCompleted = isCompleted
    }
}

public enum ReadingPlanCategory: String, Codable, CaseIterable {
    case chronological = "chronological"
    case canonical = "canonical"
    case topical = "topical"
    case devotional = "devotional"
    case newTestament = "new_testament"
    case oldTestament = "old_testament"
    case psalmsProverbs = "psalms_proverbs"
    
    public var displayName: String {
        switch self {
        case .chronological: return "Chronological"
        case .canonical: return "Canonical"
        case .topical: return "Topical"
        case .devotional: return "Devotional"
        case .newTestament: return "New Testament"
        case .oldTestament: return "Old Testament"
        case .psalmsProverbs: return "Psalms & Proverbs"
        }
    }
}

// MARK: - Privacy Settings
public struct PrivacySettings: Codable {
    public let analyticsEnabled: Bool
    public let crashReportingEnabled: Bool
    public let personalizedAdsEnabled: Bool
    public let dataCollectionLevel: DataCollectionLevel
    public let shareUsageData: Bool
    public let locationServicesEnabled: Bool
    public let biometricAuthEnabled: Bool
    public let passcodeRequired: Bool
    public let sessionTimeout: SessionTimeout
    public let privateMode: Bool
    public let encryptLocal: Bool
    public let allowScreenshots: Bool
    
    public init(
        analyticsEnabled: Bool = true,
        crashReportingEnabled: Bool = true,
        personalizedAdsEnabled: Bool = false,
        dataCollectionLevel: DataCollectionLevel = .balanced,
        shareUsageData: Bool = true,
        locationServicesEnabled: Bool = false,
        biometricAuthEnabled: Bool = false,
        passcodeRequired: Bool = false,
        sessionTimeout: SessionTimeout = .never,
        privateMode: Bool = false,
        encryptLocal: Bool = true,
        allowScreenshots: Bool = true
    ) {
        self.analyticsEnabled = analyticsEnabled
        self.crashReportingEnabled = crashReportingEnabled
        self.personalizedAdsEnabled = personalizedAdsEnabled
        self.dataCollectionLevel = dataCollectionLevel
        self.shareUsageData = shareUsageData
        self.locationServicesEnabled = locationServicesEnabled
        self.biometricAuthEnabled = biometricAuthEnabled
        self.passcodeRequired = passcodeRequired
        self.sessionTimeout = sessionTimeout
        self.privateMode = privateMode
        self.encryptLocal = encryptLocal
        self.allowScreenshots = allowScreenshots
    }
}

public enum DataCollectionLevel: String, Codable, CaseIterable {
    case minimal = "minimal"
    case balanced = "balanced"
    case full = "full"
    
    public var displayName: String {
        switch self {
        case .minimal: return "Minimal"
        case .balanced: return "Balanced"
        case .full: return "Full"
        }
    }
    
    public var description: String {
        switch self {
        case .minimal: return "Only essential data for app functionality"
        case .balanced: return "Core features plus some analytics for improvements"
        case .full: return "All features including personalization and recommendations"
        }
    }
}

public enum SessionTimeout: String, Codable, CaseIterable {
    case never = "never"
    case minutes15 = "15m"
    case minutes30 = "30m"
    case hour1 = "1h"
    case hours4 = "4h"
    case hours12 = "12h"
    case day1 = "1d"
    
    public var displayName: String {
        switch self {
        case .never: return "Never"
        case .minutes15: return "15 minutes"
        case .minutes30: return "30 minutes"
        case .hour1: return "1 hour"
        case .hours4: return "4 hours"
        case .hours12: return "12 hours"
        case .day1: return "1 day"
        }
    }
    
    public var timeInterval: TimeInterval? {
        switch self {
        case .never: return nil
        case .minutes15: return 15 * 60
        case .minutes30: return 30 * 60
        case .hour1: return 60 * 60
        case .hours4: return 4 * 60 * 60
        case .hours12: return 12 * 60 * 60
        case .day1: return 24 * 60 * 60
        }
    }
}

// MARK: - Sync Settings
public struct SyncSettings: Codable {
    public let cloudSyncEnabled: Bool
    public let syncProvider: SyncProvider
    public let syncFrequency: SyncFrequency
    public let syncOverCellular: Bool
    public let autoSyncEnabled: Bool
    public let syncConflictResolution: SyncConflictResolution
    public let lastSyncDate: Date?
    public let syncStatus: SyncStatus
    public let syncedDataTypes: [SyncDataType]
    public let encryptSyncData: Bool
    
    public init(
        cloudSyncEnabled: Bool = true,
        syncProvider: SyncProvider = .icloud,
        syncFrequency: SyncFrequency = .automatic,
        syncOverCellular: Bool = false,
        autoSyncEnabled: Bool = true,
        syncConflictResolution: SyncConflictResolution = .mostRecent,
        lastSyncDate: Date? = nil,
        syncStatus: SyncStatus = .idle,
        syncedDataTypes: [SyncDataType] = SyncDataType.allCases,
        encryptSyncData: Bool = true
    ) {
        self.cloudSyncEnabled = cloudSyncEnabled
        self.syncProvider = syncProvider
        self.syncFrequency = syncFrequency
        self.syncOverCellular = syncOverCellular
        self.autoSyncEnabled = autoSyncEnabled
        self.syncConflictResolution = syncConflictResolution
        self.lastSyncDate = lastSyncDate
        self.syncStatus = syncStatus
        self.syncedDataTypes = syncedDataTypes
        self.encryptSyncData = encryptSyncData
    }
}

public enum SyncProvider: String, Codable, CaseIterable {
    case icloud = "icloud"
    case googleDrive = "google_drive"
    case dropbox = "dropbox"
    case onedrive = "onedrive"
    
    public var displayName: String {
        switch self {
        case .icloud: return "iCloud"
        case .googleDrive: return "Google Drive"
        case .dropbox: return "Dropbox"
        case .onedrive: return "OneDrive"
        }
    }
}

public enum SyncFrequency: String, Codable, CaseIterable {
    case automatic = "automatic"
    case manual = "manual"
    case hourly = "hourly"
    case daily = "daily"
    case weekly = "weekly"
    
    public var displayName: String {
        switch self {
        case .automatic: return "Automatic"
        case .manual: return "Manual"
        case .hourly: return "Every Hour"
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        }
    }
}

public enum SyncConflictResolution: String, Codable, CaseIterable {
    case mostRecent = "most_recent"
    case askUser = "ask_user"
    case keepBoth = "keep_both"
    case preferLocal = "prefer_local"
    case preferRemote = "prefer_remote"
    
    public var displayName: String {
        switch self {
        case .mostRecent: return "Most Recent"
        case .askUser: return "Ask Me"
        case .keepBoth: return "Keep Both"
        case .preferLocal: return "Prefer Local"
        case .preferRemote: return "Prefer Remote"
        }
    }
}

public enum SyncDataType: String, Codable, CaseIterable {
    case highlights = "highlights"
    case notes = "notes"
    case bookmarks = "bookmarks"
    case readingHistory = "reading_history"
    case readingPlans = "reading_plans"
    case prayers = "prayers"
    case library = "library"
    case settings = "settings"
    
    public var displayName: String {
        switch self {
        case .highlights: return "Highlights"
        case .notes: return "Notes"
        case .bookmarks: return "Bookmarks"
        case .readingHistory: return "Reading History"
        case .readingPlans: return "Reading Plans"
        case .prayers: return "Prayers"
        case .library: return "Library"
        case .settings: return "Settings"
        }
    }
}

// MARK: - Accessibility Settings
public struct AccessibilitySettings: Codable {
    public let largeTextEnabled: Bool
    public let boldTextEnabled: Bool
    public let highContrastEnabled: Bool
    public let reduceMotionEnabled: Bool
    public let voiceOverEnabled: Bool
    public let voiceOverRate: VoiceOverRate
    public let voiceOverVoice: VoiceOverVoice
    public let buttonShapesEnabled: Bool
    public let reduceTransparencyEnabled: Bool
    public let differentiateColorsEnabled: Bool
    public let onOffLabelsEnabled: Bool
    public let autoReadEnabled: Bool
    public let tapToSpeakEnabled: Bool
    
    public init(
        largeTextEnabled: Bool = false,
        boldTextEnabled: Bool = false,
        highContrastEnabled: Bool = false,
        reduceMotionEnabled: Bool = false,
        voiceOverEnabled: Bool = false,
        voiceOverRate: VoiceOverRate = .normal,
        voiceOverVoice: VoiceOverVoice = .system,
        buttonShapesEnabled: Bool = false,
        reduceTransparencyEnabled: Bool = false,
        differentiateColorsEnabled: Bool = false,
        onOffLabelsEnabled: Bool = false,
        autoReadEnabled: Bool = false,
        tapToSpeakEnabled: Bool = false
    ) {
        self.largeTextEnabled = largeTextEnabled
        self.boldTextEnabled = boldTextEnabled
        self.highContrastEnabled = highContrastEnabled
        self.reduceMotionEnabled = reduceMotionEnabled
        self.voiceOverEnabled = voiceOverEnabled
        self.voiceOverRate = voiceOverRate
        self.voiceOverVoice = voiceOverVoice
        self.buttonShapesEnabled = buttonShapesEnabled
        self.reduceTransparencyEnabled = reduceTransparencyEnabled
        self.differentiateColorsEnabled = differentiateColorsEnabled
        self.onOffLabelsEnabled = onOffLabelsEnabled
        self.autoReadEnabled = autoReadEnabled
        self.tapToSpeakEnabled = tapToSpeakEnabled
    }
}

public enum VoiceOverRate: String, Codable, CaseIterable {
    case slow = "slow"
    case normal = "normal"
    case fast = "fast"
    
    public var displayName: String {
        switch self {
        case .slow: return "Slow"
        case .normal: return "Normal"
        case .fast: return "Fast"
        }
    }
    
    public var rateValue: Float {
        switch self {
        case .slow: return 0.4
        case .normal: return 0.5
        case .fast: return 0.6
        }
    }
}

public enum VoiceOverVoice: String, Codable, CaseIterable {
    case system = "system"
    case alex = "alex"
    case samantha = "samantha"
    case victoria = "victoria"
    case daniel = "daniel"
    
    public var displayName: String {
        switch self {
        case .system: return "System Voice"
        case .alex: return "Alex"
        case .samantha: return "Samantha"
        case .victoria: return "Victoria"
        case .daniel: return "Daniel"
        }
    }
}

// MARK: - Notification Settings
public struct NotificationSettings: Codable {
    public let pushNotificationsEnabled: Bool
    public let readingReminders: ReminderSettings
    public let prayerReminders: ReminderSettings
    public let verseOfTheDay: ReminderSettings
    public let devotionalReminders: ReminderSettings
    public let communityUpdates: Bool
    public let libraryUpdates: Bool
    public let appUpdates: Bool
    public let soundEnabled: Bool
    public let vibrationEnabled: Bool
    public let badgeEnabled: Bool
    public let quietHours: QuietHours?
    
    public init(
        pushNotificationsEnabled: Bool = true,
        readingReminders: ReminderSettings = ReminderSettings(),
        prayerReminders: ReminderSettings = ReminderSettings(),
        verseOfTheDay: ReminderSettings = ReminderSettings(isEnabled: true, time: Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()),
        devotionalReminders: ReminderSettings = ReminderSettings(),
        communityUpdates: Bool = true,
        libraryUpdates: Bool = true,
        appUpdates: Bool = true,
        soundEnabled: Bool = true,
        vibrationEnabled: Bool = true,
        badgeEnabled: Bool = true,
        quietHours: QuietHours? = nil
    ) {
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.readingReminders = readingReminders
        self.prayerReminders = prayerReminders
        self.verseOfTheDay = verseOfTheDay
        self.devotionalReminders = devotionalReminders
        self.communityUpdates = communityUpdates
        self.libraryUpdates = libraryUpdates
        self.appUpdates = appUpdates
        self.soundEnabled = soundEnabled
        self.vibrationEnabled = vibrationEnabled
        self.badgeEnabled = badgeEnabled
        self.quietHours = quietHours
    }
}

public struct ReminderSettings: Codable {
    public let isEnabled: Bool
    public let time: Date
    public let days: [DayOfWeek]
    public let title: String?
    public let message: String?
    
    public init(
        isEnabled: Bool = false,
        time: Date = Calendar.current.date(from: DateComponents(hour: 9, minute: 0)) ?? Date(),
        days: [DayOfWeek] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday],
        title: String? = nil,
        message: String? = nil
    ) {
        self.isEnabled = isEnabled
        self.time = time
        self.days = days
        self.title = title
        self.message = message
    }
    
    private enum CodingKeys: String, CodingKey {
        case isEnabled, time, days, title, message
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isEnabled = try container.decode(Bool.self, forKey: .isEnabled)
        time = try container.decode(Date.self, forKey: .time)
        days = try container.decode([DayOfWeek].self, forKey: .days)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        message = try container.decodeIfPresent(String.self, forKey: .message)
    }
    
    private static let allDays: [DayOfWeek] = [.sunday, .monday, .tuesday, .wednesday, .thursday, .friday, .saturday]
}

extension DayOfWeek {
    public static var fullWeek: [DayOfWeek] {
        return allCases
    }
}

public struct QuietHours: Codable {
    public let startTime: Date
    public let endTime: Date
    public let isEnabled: Bool
    
    public init(
        startTime: Date = Calendar.current.date(from: DateComponents(hour: 22, minute: 0)) ?? Date(),
        endTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
        isEnabled: Bool = false
    ) {
        self.startTime = startTime
        self.endTime = endTime
        self.isEnabled = isEnabled
    }
}

// MARK: - Display Settings
public struct DisplaySettings: Codable {
    public let appearanceMode: AppearanceMode
    public let colorScheme: ColorScheme
    public let accentColor: AccentColor
    public let iconTheme: IconTheme
    public let animationsEnabled: Bool
    public let transitionsEnabled: Bool
    public let parallaxEnabled: Bool
    public let screenBrightness: Double
    public let keepScreenOn: Bool
    public let orientationLock: OrientationLock
    public let statusBarStyle: StatusBarStyle
    
    public init(
        appearanceMode: AppearanceMode = .system,
        colorScheme: ColorScheme = .blue,
        accentColor: AccentColor = .blue,
        iconTheme: IconTheme = .classic,
        animationsEnabled: Bool = true,
        transitionsEnabled: Bool = true,
        parallaxEnabled: Bool = true,
        screenBrightness: Double = 0.5,
        keepScreenOn: Bool = false,
        orientationLock: OrientationLock = .none,
        statusBarStyle: StatusBarStyle = .automatic
    ) {
        self.appearanceMode = appearanceMode
        self.colorScheme = colorScheme
        self.accentColor = accentColor
        self.iconTheme = iconTheme
        self.animationsEnabled = animationsEnabled
        self.transitionsEnabled = transitionsEnabled
        self.parallaxEnabled = parallaxEnabled
        self.screenBrightness = screenBrightness
        self.keepScreenOn = keepScreenOn
        self.orientationLock = orientationLock
        self.statusBarStyle = statusBarStyle
    }
}

public enum AppearanceMode: String, Codable, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    public var displayName: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
}

public enum ColorScheme: String, Codable, CaseIterable {
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case orange = "orange"
    case red = "red"
    case teal = "teal"
    case indigo = "indigo"
    case pink = "pink"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

public enum AccentColor: String, Codable, CaseIterable {
    case blue = "blue"
    case green = "green"
    case purple = "purple"
    case orange = "orange"
    case red = "red"
    case teal = "teal"
    case indigo = "indigo"
    case pink = "pink"
    case gold = "gold"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

public enum IconTheme: String, Codable, CaseIterable {
    case classic = "classic"
    case modern = "modern"
    case minimal = "minimal"
    case colorful = "colorful"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

public enum OrientationLock: String, Codable, CaseIterable {
    case none = "none"
    case portrait = "portrait"
    case landscape = "landscape"
    
    public var displayName: String {
        switch self {
        case .none: return "Auto-rotate"
        case .portrait: return "Portrait"
        case .landscape: return "Landscape"
        }
    }
}

public enum StatusBarStyle: String, Codable, CaseIterable {
    case automatic = "automatic"
    case light = "light"
    case dark = "dark"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Storage Settings
public struct StorageSettings: Codable {
    public let cacheSize: Int64
    public let maxCacheSize: Int64
    public let offlineContentEnabled: Bool
    public let offlineContentSize: Int64
    public let maxOfflineContentSize: Int64
    public let autoClearCache: Bool
    public let autoClearInterval: ClearInterval
    public let downloadQuality: DownloadQuality
    public let downloadLocation: DownloadLocation
    public let compressDownloads: Bool
    
    public init(
        cacheSize: Int64 = 0,
        maxCacheSize: Int64 = 100 * 1024 * 1024, // 100MB
        offlineContentEnabled: Bool = true,
        offlineContentSize: Int64 = 0,
        maxOfflineContentSize: Int64 = 500 * 1024 * 1024, // 500MB
        autoClearCache: Bool = true,
        autoClearInterval: ClearInterval = .weekly,
        downloadQuality: DownloadQuality = .standard,
        downloadLocation: DownloadLocation = .internal,
        compressDownloads: Bool = true
    ) {
        self.cacheSize = cacheSize
        self.maxCacheSize = maxCacheSize
        self.offlineContentEnabled = offlineContentEnabled
        self.offlineContentSize = offlineContentSize
        self.maxOfflineContentSize = maxOfflineContentSize
        self.autoClearCache = autoClearCache
        self.autoClearInterval = autoClearInterval
        self.downloadQuality = downloadQuality
        self.downloadLocation = downloadLocation
        self.compressDownloads = compressDownloads
    }
}

public enum ClearInterval: String, Codable, CaseIterable {
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case never = "never"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

public enum DownloadQuality: String, Codable, CaseIterable {
    case low = "low"
    case standard = "standard"
    case high = "high"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

public enum DownloadLocation: String, Codable, CaseIterable {
    case internalStorage = "internal"
    case external = "external"
    
    public var displayName: String {
        switch self {
        case .internalStorage: return "Internal Storage"
        case .external: return "External Storage"
        }
    }
}

// MARK: - Analytics Settings
public struct AnalyticsSettings: Codable {
    public let enabled: Bool
    public let trackingLevel: TrackingLevel
    public let personalizedContent: Bool
    public let crashReporting: Bool
    public let performanceMonitoring: Bool
    public let usageStatistics: Bool
    public let anonymizeData: Bool
    public let retentionPeriod: RetentionPeriod
    
    public init(
        enabled: Bool = true,
        trackingLevel: TrackingLevel = .standard,
        personalizedContent: Bool = true,
        crashReporting: Bool = true,
        performanceMonitoring: Bool = true,
        usageStatistics: Bool = true,
        anonymizeData: Bool = true,
        retentionPeriod: RetentionPeriod = .months12
    ) {
        self.enabled = enabled
        self.trackingLevel = trackingLevel
        self.personalizedContent = personalizedContent
        self.crashReporting = crashReporting
        self.performanceMonitoring = performanceMonitoring
        self.usageStatistics = usageStatistics
        self.anonymizeData = anonymizeData
        self.retentionPeriod = retentionPeriod
    }
}

public enum TrackingLevel: String, Codable, CaseIterable {
    case minimal = "minimal"
    case standard = "standard"
    case enhanced = "enhanced"
    
    public var displayName: String {
        return rawValue.capitalized
    }
    
    public var description: String {
        switch self {
        case .minimal: return "Essential functionality only"
        case .standard: return "Core features and basic analytics"
        case .enhanced: return "All features including personalization"
        }
    }
}

public enum RetentionPeriod: String, Codable, CaseIterable {
    case months3 = "3_months"
    case months6 = "6_months"
    case months12 = "12_months"
    case months24 = "24_months"
    case indefinite = "indefinite"
    
    public var displayName: String {
        switch self {
        case .months3: return "3 months"
        case .months6: return "6 months"
        case .months12: return "12 months"
        case .months24: return "24 months"
        case .indefinite: return "Indefinite"
        }
    }
}

// MARK: - Settings Change Events
public struct SettingsChangeEvent: Codable {
    public let settingKey: String
    public let oldValue: AnyCodable?
    public let newValue: AnyCodable
    public let userId: String?
    public let timestamp: Date
    public let source: SettingsChangeSource
    
    public init(
        settingKey: String,
        oldValue: AnyCodable? = nil,
        newValue: AnyCodable,
        userId: String? = nil,
        timestamp: Date = Date(),
        source: SettingsChangeSource = .user
    ) {
        self.settingKey = settingKey
        self.oldValue = oldValue
        self.newValue = newValue
        self.userId = userId
        self.timestamp = timestamp
        self.source = source
    }
}

public enum SettingsChangeSource: String, Codable {
    case user = "user"
    case system = "system"
    case sync = "sync"
    case migration = "migration"
    case reset = "reset"
    
    public var displayName: String {
        return rawValue.capitalized
    }
}

// MARK: - Settings Export/Import
public struct SettingsExport: Codable {
    public let settings: AppSettings
    public let exportDate: Date
    public let appVersion: String
    public let deviceInfo: DeviceInfo
    public let exportId: String
    
    public init(
        settings: AppSettings,
        exportDate: Date = Date(),
        appVersion: String,
        deviceInfo: DeviceInfo,
        exportId: String = UUID().uuidString
    ) {
        self.settings = settings
        self.exportDate = exportDate
        self.appVersion = appVersion
        self.deviceInfo = deviceInfo
        self.exportId = exportId
    }
}

public struct DeviceInfo: Codable {
    public let platform: String
    public let osVersion: String
    public let appVersion: String
    public let deviceModel: String
    
    public init(
        platform: String,
        osVersion: String,
        appVersion: String,
        deviceModel: String
    ) {
        self.platform = platform
        self.osVersion = osVersion
        self.appVersion = appVersion
        self.deviceModel = deviceModel
    }
}

// MARK: - Settings Validation
public struct SettingsValidationError: Error, LocalizedError {
    public let field: String
    public let reason: String
    public let suggestedValue: Any?
    
    public init(field: String, reason: String, suggestedValue: Any? = nil) {
        self.field = field
        self.reason = reason
        self.suggestedValue = suggestedValue
    }
    
    public var errorDescription: String? {
        return "Invalid setting '\(field)': \(reason)"
    }
}

public struct SettingsConstraints {
    public static let maxCacheSize: Int64 = 1024 * 1024 * 1024 // 1GB
    public static let minCacheSize: Int64 = 10 * 1024 * 1024 // 10MB
    public static let maxOfflineContentSize: Int64 = 5 * 1024 * 1024 * 1024 // 5GB
    public static let minOfflineContentSize: Int64 = 50 * 1024 * 1024 // 50MB
    public static let maxHighlightColors: Int = 20
    public static let minHighlightColors: Int = 1
    public static let maxReadingPlanDuration: Int = 365 * 3 // 3 years
    public static let minReadingPlanDuration: Int = 1
}