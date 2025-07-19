import XCTest
import ComposableArchitecture
@testable import LeavnApp

@MainActor
final class SettingsReducerTests: XCTestCase {
    
    // MARK: - Theme Tests
    
    func testThemeChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                settings: Settings(theme: .light)
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.themeChanged(.dark)) {
            $0.settings.theme = .dark
        }
        
        await store.send(.themeChanged(.system)) {
            $0.settings.theme = .system
        }
    }
    
    // MARK: - Font Settings Tests
    
    func testFontSizeChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.fontSizeChanged(.large)) {
            $0.settings.fontSize = .large
        }
        
        await store.send(.fontSizeChanged(.small)) {
            $0.settings.fontSize = .small
        }
    }
    
    func testFontFamilyChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.fontFamilyChanged(.serif)) {
            $0.settings.fontFamily = .serif
        }
        
        await store.send(.fontFamilyChanged(.sansSerif)) {
            $0.settings.fontFamily = .sansSerif
        }
    }
    
    func testLineSpacingChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.lineSpacingChanged(.loose)) {
            $0.settings.lineSpacing = .loose
        }
        
        await store.send(.lineSpacingChanged(.tight)) {
            $0.settings.lineSpacing = .tight
        }
    }
    
    // MARK: - Bible Settings Tests
    
    func testTranslationChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.translationChanged(.niv)) {
            $0.settings.translation = .niv
        }
        
        await store.send(.translationChanged(.kjv)) {
            $0.settings.translation = .kjv
        }
    }
    
    func testToggleVerseNumbers() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                settings: Settings(showVerseNumbers: true)
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.toggleVerseNumbers) {
            $0.settings.showVerseNumbers = false
        }
        
        await store.send(.toggleVerseNumbers) {
            $0.settings.showVerseNumbers = true
        }
    }
    
    func testToggleRedLetters() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                settings: Settings(showRedLetters: true)
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.toggleRedLetters) {
            $0.settings.showRedLetters = false
        }
        
        await store.send(.toggleRedLetters) {
            $0.settings.showRedLetters = true
        }
    }
    
    // MARK: - Notification Settings Tests
    
    func testToggleDailyVerseNotification() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
                $0.notificationService = .mock
            }
        )
        
        await store.send(.toggleDailyVerse) {
            $0.settings.notifications.dailyVerse = true
        }
        
        await store.send(.toggleDailyVerse) {
            $0.settings.notifications.dailyVerse = false
        }
    }
    
    func testDailyVerseTimeChange() async {
        let newTime = Date()
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
                $0.notificationService = .mock
            }
        )
        
        await store.send(.dailyVerseTimeChanged(newTime)) {
            $0.settings.notifications.dailyVerseTime = newTime
        }
    }
    
    func testToggleReadingReminders() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
                $0.notificationService = .mock
            }
        )
        
        await store.send(.toggleReadingReminders) {
            $0.settings.notifications.readingReminders = true
        }
        
        await store.send(.toggleReadingReminders) {
            $0.settings.notifications.readingReminders = false
        }
    }
    
    // MARK: - Audio Settings Tests
    
    func testAutoPlayNextChapterToggle() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.toggleAutoPlayNextChapter) {
            $0.settings.audioSettings.autoPlayNextChapter = true
        }
        
        await store.send(.toggleAutoPlayNextChapter) {
            $0.settings.audioSettings.autoPlayNextChapter = false
        }
    }
    
    func testDefaultPlaybackRateChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.defaultPlaybackRateChanged(1.5)) {
            $0.settings.audioSettings.defaultPlaybackRate = 1.5
        }
        
        await store.send(.defaultPlaybackRateChanged(0.75)) {
            $0.settings.audioSettings.defaultPlaybackRate = 0.75
        }
    }
    
    func testSleepTimerDefaultChange() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.sleepTimerDefaultChanged(30)) {
            $0.settings.audioSettings.sleepTimerDefault = 30
        }
        
        await store.send(.sleepTimerDefaultChanged(60)) {
            $0.settings.audioSettings.sleepTimerDefault = 60
        }
    }
    
    // MARK: - Data Management Tests
    
    func testClearCache() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.downloadClient = .mock
                $0.databaseClient = .mock
            }
        )
        
        await store.send(.clearCache) {
            $0.isClearingCache = true
        }
        
        await store.receive(\.clearCacheResponse.success) {
            $0.isClearingCache = false
            $0.alert = AlertState {
                TextState("Success")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Cache cleared successfully")
            }
        }
    }
    
    func testExportData() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.databaseClient = .mock
                $0.fileClient = .mock
            }
        )
        
        await store.send(.exportData) {
            $0.isExportingData = true
        }
        
        await store.receive(\.exportDataResponse.success) {
            $0.isExportingData = false
            XCTAssertNotNil($0.shareSheet)
        }
    }
    
    func testImportData() async {
        let testURL = URL(fileURLWithPath: "/test/data.json")
        let store = makeTestStore(
            initialState: SettingsReducer.State(),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.databaseClient = .mock
                $0.fileClient = .mock
            }
        )
        
        await store.send(.importData(testURL)) {
            $0.isImportingData = true
        }
        
        await store.receive(\.importDataResponse.success) {
            $0.isImportingData = false
            $0.alert = AlertState {
                TextState("Success")
            } actions: {
                ButtonState(role: .cancel) {
                    TextState("OK")
                }
            } message: {
                TextState("Data imported successfully")
            }
        }
    }
    
    // MARK: - Reset Settings Tests
    
    func testResetSettings() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                settings: Settings(
                    theme: .dark,
                    fontSize: .large,
                    fontFamily: .serif,
                    showVerseNumbers: false
                )
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.settingsService = .mock
            }
        )
        
        await store.send(.resetSettings) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Reset Settings")
            } actions: {
                ButtonState(role: .destructive, action: .confirmReset) {
                    TextState("Reset")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to reset all settings to default?")
            }
        }
        
        await store.send(.confirmReset) {
            $0.confirmationDialog = nil
            $0.settings = Settings()
        }
    }
    
    // MARK: - Account Management Tests
    
    func testLogout() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                isLoggedIn: true
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.authClient = .mock
                $0.databaseClient = .mock
            }
        )
        
        await store.send(.logout) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Log Out")
            } actions: {
                ButtonState(role: .destructive, action: .confirmLogout) {
                    TextState("Log Out")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("Are you sure you want to log out?")
            }
        }
        
        await store.send(.confirmLogout) {
            $0.confirmationDialog = nil
            $0.isLoggingOut = true
        }
        
        await store.receive(\.logoutResponse.success) {
            $0.isLoggingOut = false
            $0.isLoggedIn = false
        }
    }
    
    func testDeleteAccount() async {
        let store = makeTestStore(
            initialState: SettingsReducer.State(
                isLoggedIn: true
            ),
            reducer: SettingsReducer.init,
            dependencies: {
                $0.authClient = .mock
                $0.databaseClient = .mock
            }
        )
        
        await store.send(.deleteAccount) {
            $0.confirmationDialog = ConfirmationDialogState {
                TextState("Delete Account")
            } actions: {
                ButtonState(role: .destructive, action: .confirmDeleteAccount) {
                    TextState("Delete Account")
                }
                ButtonState(role: .cancel) {
                    TextState("Cancel")
                }
            } message: {
                TextState("This action cannot be undone. All your data will be permanently deleted.")
            }
        }
        
        await store.send(.confirmDeleteAccount) {
            $0.confirmationDialog = nil
            $0.isDeletingAccount = true
        }
        
        await store.receive(\.deleteAccountResponse.success) {
            $0.isDeletingAccount = false
            $0.isLoggedIn = false
        }
    }
}

// MARK: - Mock Dependencies
extension DependencyValues {
    var notificationService: NotificationService {
        get { self[NotificationService.self] }
        set { self[NotificationService.self] = newValue }
    }
    
    var fileClient: FileClient {
        get { self[FileClient.self] }
        set { self[FileClient.self] = newValue }
    }
    
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// Mock implementations for missing services
struct NotificationService {
    static let mock = Self()
}

struct FileClient {
    static let mock = Self()
}

struct AuthClient {
    static let mock = Self()
}