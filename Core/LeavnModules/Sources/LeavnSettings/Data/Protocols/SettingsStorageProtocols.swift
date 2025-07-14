import Foundation
import LeavnCore

// MARK: - Settings Local Storage Protocol
public protocol SettingsLocalStorage {
    func loadAppSettings() async throws -> AppSettings?
    func saveAppSettings(_ settings: AppSettings) async throws
    func getSetting<T: Codable>(key: String, type: T.Type) async throws -> T?
    func setSetting<T: Codable>(key: String, value: T) async throws
    func removeSetting(key: String) async throws
    func getAllSettings() async throws -> [String: Any]
    func getSettingsHistory(limit: Int, offset: Int) async throws -> [SettingsChangeEvent]
    func getSettingChanges(for key: String, limit: Int) async throws -> [SettingsChangeEvent]
    func trackSettingChange(_ event: SettingsChangeEvent) async throws
    func saveBackup(_ backup: SettingsBackup) async throws
    func getBackups(limit: Int) async throws -> [SettingsBackup]
    func deleteBackup(_ backupId: String) async throws
    func getSettingsVersion() async throws -> String?
}

// MARK: - Settings Secure Storage Protocol
public protocol SettingsSecureStorage {
    func store<T: Codable>(_ value: T, forKey key: String) async throws
    func retrieve<T: Codable>(_ type: T.Type, forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
}

// MARK: - Settings Backup
public struct SettingsBackup: Codable, Identifiable {
    public let id: String
    public let name: String
    public let createdAt: Date
    public let settings: AppSettings
    public let version: String
    
    public init(
        id: String = UUID().uuidString,
        name: String,
        createdAt: Date = Date(),
        settings: AppSettings,
        version: String
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.settings = settings
        self.version = version
    }
}