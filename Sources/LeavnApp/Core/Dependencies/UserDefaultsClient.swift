import Dependencies
import Foundation

struct UserDefaultsClient {
    var isFirstLaunch: Bool
    var esvAPIKey: String?
    var elevenLabsAPIKey: String?
    var preferredTranslation: String
    var fontSize: Double
    var theme: String
    var autoPlayAudio: Bool
    var downloadOverCellular: Bool
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue = Self(
        isFirstLaunch: {
            UserDefaults.standard.object(forKey: "isFirstLaunch") == nil
        }(),
        esvAPIKey: {
            UserDefaults.standard.string(forKey: "esvAPIKey")
        }(),
        elevenLabsAPIKey: {
            UserDefaults.standard.string(forKey: "elevenLabsAPIKey")
        }(),
        preferredTranslation: {
            UserDefaults.standard.string(forKey: "preferredTranslation") ?? "ESV"
        }(),
        fontSize: {
            UserDefaults.standard.double(forKey: "fontSize") == 0 ? 16 : UserDefaults.standard.double(forKey: "fontSize")
        }(),
        theme: {
            UserDefaults.standard.string(forKey: "theme") ?? "system"
        }(),
        autoPlayAudio: {
            UserDefaults.standard.bool(forKey: "autoPlayAudio")
        }(),
        downloadOverCellular: {
            UserDefaults.standard.bool(forKey: "downloadOverCellular")
        }()
    )
}

extension DependencyValues {
    var userDefaults: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}