import Foundation
import SwiftUI

// MARK: - App Settings
public struct AppSettings: Equatable, Codable, Sendable {
    // API Keys
    public var esvAPIKey: String?
    public var elevenLabsAPIKey: String?
    
    // Bible Preferences
    public var biblePreferences: BiblePreferences
    
    // Appearance
    public var appearance: AppearanceSettings
    
    // Audio
    public var audio: AudioSettings
    
    // Notifications
    public var notifications: NotificationSettings
    
    // Privacy
    public var privacy: PrivacySettings
    
    // Advanced
    public var advanced: AdvancedSettings
    
    public init(
        esvAPIKey: String? = nil,
        elevenLabsAPIKey: String? = nil,
        biblePreferences: BiblePreferences = BiblePreferences(),
        appearance: AppearanceSettings = AppearanceSettings(),
        audio: AudioSettings = AudioSettings(),
        notifications: NotificationSettings = NotificationSettings(),
        privacy: PrivacySettings = PrivacySettings(),
        advanced: AdvancedSettings = AdvancedSettings()
    ) {
        self.esvAPIKey = esvAPIKey
        self.elevenLabsAPIKey = elevenLabsAPIKey
        self.biblePreferences = biblePreferences
        self.appearance = appearance
        self.audio = audio
        self.notifications = notifications
        self.privacy = privacy
        self.advanced = advanced
    }
}

// MARK: - Bible Preferences
public struct BiblePreferences: Equatable, Codable, Sendable {
    public var defaultTranslation: BibleTranslation
    public var fontSize: Double
    public var lineSpacing: Double
    public var showVerseNumbers: Bool
    public var showHeadings: Bool
    public var showFootnotes: Bool
    public var showCrossReferences: Bool
    public var highlightJesusWords: Bool
    
    public init(
        defaultTranslation: BibleTranslation = .esv,
        fontSize: Double = 16,
        lineSpacing: Double = 1.5,
        showVerseNumbers: Bool = true,
        showHeadings: Bool = true,
        showFootnotes: Bool = false,
        showCrossReferences: Bool = false,
        highlightJesusWords: Bool = true
    ) {
        self.defaultTranslation = defaultTranslation
        self.fontSize = fontSize
        self.lineSpacing = lineSpacing
        self.showVerseNumbers = showVerseNumbers
        self.showHeadings = showHeadings
        self.showFootnotes = showFootnotes
        self.showCrossReferences = showCrossReferences
        self.highlightJesusWords = highlightJesusWords
    }
}

public enum BibleTranslation: String, CaseIterable, Codable, Sendable {
    case esv = "ESV"
    case niv = "NIV"
    case nlt = "NLT"
    case kjv = "KJV"
    case nkjv = "NKJV"
    case nasb = "NASB"
    case csb = "CSB"
    case amp = "AMP"
    case msg = "MSG"
    
    public var fullName: String {
        switch self {
        case .esv: return "English Standard Version"
        case .niv: return "New International Version"
        case .nlt: return "New Living Translation"
        case .kjv: return "King James Version"
        case .nkjv: return "New King James Version"
        case .nasb: return "New American Standard Bible"
        case .csb: return "Christian Standard Bible"
        case .amp: return "Amplified Bible"
        case .msg: return "The Message"
        }
    }
}

// MARK: - Appearance Settings
public struct AppearanceSettings: Equatable, Codable, Sendable {
    public var colorScheme: ColorSchemeOption
    public var accentColor: AccentColorOption
    public var iconStyle: IconStyle
    
    public enum ColorSchemeOption: String, CaseIterable, Codable, Sendable {
        case system = "System"
        case light = "Light"
        case dark = "Dark"
        case sepia = "Sepia"
    }
    
    public enum AccentColorOption: String, CaseIterable, Codable, Sendable {
        case blue = "Blue"
        case purple = "Purple"
        case green = "Green"
        case orange = "Orange"
        case red = "Red"
        case pink = "Pink"
        case indigo = "Indigo"
        case teal = "Teal"
    }
    
    public enum IconStyle: String, CaseIterable, Codable, Sendable {
        case filled = "Filled"
        case outlined = "Outlined"
        case rounded = "Rounded"
    }
    
    public init(
        colorScheme: ColorSchemeOption = .system,
        accentColor: AccentColorOption = .blue,
        iconStyle: IconStyle = .filled
    ) {
        self.colorScheme = colorScheme
        self.accentColor = accentColor
        self.iconStyle = iconStyle
    }
}

// MARK: - Audio Settings
public struct AudioSettings: Equatable, Codable, Sendable {
    public var voiceId: String
    public var playbackSpeed: Double
    public var autoPlayNext: Bool
    public var sleepTimer: SleepTimerOption?
    
    public enum SleepTimerOption: Int, CaseIterable, Codable, Sendable {
        case fiveMinutes = 5
        case tenMinutes = 10
        case fifteenMinutes = 15
        case thirtyMinutes = 30
        case oneHour = 60
        case twoHours = 120
        
        public var displayText: String {
            switch self {
            case .fiveMinutes: return "5 minutes"
            case .tenMinutes: return "10 minutes"
            case .fifteenMinutes: return "15 minutes"
            case .thirtyMinutes: return "30 minutes"
            case .oneHour: return "1 hour"
            case .twoHours: return "2 hours"
            }
        }
    }
    
    public init(
        voiceId: String = "21m00Tcm4TlvDq8ikWAM", // Rachel voice
        playbackSpeed: Double = 1.0,
        autoPlayNext: Bool = true,
        sleepTimer: SleepTimerOption? = nil
    ) {
        self.voiceId = voiceId
        self.playbackSpeed = playbackSpeed
        self.autoPlayNext = autoPlayNext
        self.sleepTimer = sleepTimer
    }
}

// MARK: - Notification Settings
public struct NotificationSettings: Equatable, Codable, Sendable {
    public var dailyReading: Bool
    public var dailyReadingTime: Date
    public var prayerReminders: Bool
    public var communityUpdates: Bool
    public var studyStreaks: Bool
    
    public init(
        dailyReading: Bool = true,
        dailyReadingTime: Date = Calendar.current.date(from: DateComponents(hour: 7, minute: 0)) ?? Date(),
        prayerReminders: Bool = false,
        communityUpdates: Bool = true,
        studyStreaks: Bool = true
    ) {
        self.dailyReading = dailyReading
        self.dailyReadingTime = dailyReadingTime
        self.prayerReminders = prayerReminders
        self.communityUpdates = communityUpdates
        self.studyStreaks = studyStreaks
    }
}

// MARK: - Privacy Settings
public struct PrivacySettings: Equatable, Codable, Sendable {
    public var shareActivity: Bool
    public var publicProfile: Bool
    public var allowAnalytics: Bool
    public var syncAcrossDevices: Bool
    
    public init(
        shareActivity: Bool = false,
        publicProfile: Bool = false,
        allowAnalytics: Bool = true,
        syncAcrossDevices: Bool = true
    ) {
        self.shareActivity = shareActivity
        self.publicProfile = publicProfile
        self.allowAnalytics = allowAnalytics
        self.syncAcrossDevices = syncAcrossDevices
    }
}

// MARK: - Advanced Settings
public struct AdvancedSettings: Equatable, Codable, Sendable {
    public var cacheSize: CacheSize
    public var offlineMode: Bool
    public var developerMode: Bool
    public var crashReporting: Bool
    
    public enum CacheSize: String, CaseIterable, Codable, Sendable {
        case small = "100 MB"
        case medium = "500 MB"
        case large = "1 GB"
        case unlimited = "Unlimited"
    }
    
    public init(
        cacheSize: CacheSize = .medium,
        offlineMode: Bool = false,
        developerMode: Bool = false,
        crashReporting: Bool = true
    ) {
        self.cacheSize = cacheSize
        self.offlineMode = offlineMode
        self.developerMode = developerMode
        self.crashReporting = crashReporting
    }
}