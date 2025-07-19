import ComposableArchitecture
import Foundation

@Reducer
public struct SettingsReducer {
    @ObservableState
    public struct State: Equatable {
        public var esvAPIKey: String = ""
        public var elevenLabsAPIKey: String = ""
        public var fontSize: Double = 16
        public var theme: AppTheme = .system
        public var autoPlayAudio: Bool = false
        public var downloadOverCellular: Bool = false
        public var isLoading: Bool = false
        public var error: String? = nil
        public var showingAPIKeyAlert: Bool = false
        public var apiKeyAlertType: APIKeyType? = nil
        public var voices: IdentifiedArrayOf<Voice> = []
        public var selectedVoiceId: String = "21m00Tcm4TlvDq8ikWAM" // Default Rachel
        public var showingVoicePicker: Bool = false
        
        public init() {}
        
        public enum APIKeyType {
            case esv
            case elevenLabs
        }
    }
    
    public enum Action {
        case onAppear
        case loadSettings
        case settingsLoaded
        case esvAPIKeyChanged(String)
        case elevenLabsAPIKeyChanged(String)
        case fontSizeChanged(Double)
        case themeChanged(AppTheme)
        case autoPlayAudioToggled
        case downloadOverCellularToggled
        case saveAPIKey(State.APIKeyType)
        case apiKeySaved
        case apiKeySaveFailed(Error)
        case showAPIKeyAlert(State.APIKeyType)
        case dismissAPIKeyAlert
        case loadVoices
        case voicesLoaded([Voice])
        case voicesLoadFailed(Error)
        case voiceSelected(String)
        case showVoicePicker
        case dismissVoicePicker
        case clearAllData
        case dataCleared
        case dataClearFailed(Error)
    }
    
    @Dependency(\.apiKeyManager) var apiKeyManager
    @Dependency(\.elevenLabsClient) var elevenLabsClient
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.downloadClient) var downloadClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadSettings)
                
            case .loadSettings:
                state.isLoading = true
                
                return .run { send in
                    do {
                        let esvKey = try await apiKeyManager.getESVKey() ?? ""
                        let elevenLabsKey = try await apiKeyManager.getElevenLabsKey() ?? ""
                        
                        await MainActor.run {
                            // Load other settings from UserDefaults
                            let fontSize = UserDefaults.standard.double(forKey: "fontSize")
                            let themeRaw = UserDefaults.standard.string(forKey: "theme") ?? "system"
                            let autoPlay = UserDefaults.standard.bool(forKey: "autoPlayAudio")
                            let downloadCellular = UserDefaults.standard.bool(forKey: "downloadOverCellular")
                            let voiceId = UserDefaults.standard.string(forKey: "elevenLabsVoiceId") ?? "21m00Tcm4TlvDq8ikWAM"
                            
                            Task {
                                await send(.settingsLoaded)
                            }
                        }
                    } catch {
                        await send(.apiKeySaveFailed(error))
                    }
                }
                
            case .settingsLoaded:
                state.isLoading = false
                
                // Load settings from UserDefaults
                state.fontSize = UserDefaults.standard.double(forKey: "fontSize") == 0 ? 16 : UserDefaults.standard.double(forKey: "fontSize")
                state.theme = AppTheme(rawValue: UserDefaults.standard.string(forKey: "theme") ?? "system") ?? .system
                state.autoPlayAudio = UserDefaults.standard.bool(forKey: "autoPlayAudio")
                state.downloadOverCellular = UserDefaults.standard.bool(forKey: "downloadOverCellular")
                state.selectedVoiceId = UserDefaults.standard.string(forKey: "elevenLabsVoiceId") ?? "21m00Tcm4TlvDq8ikWAM"
                
                return .run { send in
                    do {
                        let esvKey = try await apiKeyManager.getESVKey() ?? ""
                        let elevenLabsKey = try await apiKeyManager.getElevenLabsKey() ?? ""
                        
                        await MainActor.run {
                            Task {
                                // Note: In production, you'd want to show masked keys
                                // For now, we'll leave them empty for security
                            }
                        }
                    } catch {}
                }
                
            case let .esvAPIKeyChanged(key):
                state.esvAPIKey = key
                return .none
                
            case let .elevenLabsAPIKeyChanged(key):
                state.elevenLabsAPIKey = key
                return .none
                
            case let .fontSizeChanged(size):
                state.fontSize = size
                UserDefaults.standard.set(size, forKey: "fontSize")
                return .none
                
            case let .themeChanged(theme):
                state.theme = theme
                UserDefaults.standard.set(theme.rawValue, forKey: "theme")
                return .none
                
            case .autoPlayAudioToggled:
                state.autoPlayAudio.toggle()
                UserDefaults.standard.set(state.autoPlayAudio, forKey: "autoPlayAudio")
                return .none
                
            case .downloadOverCellularToggled:
                state.downloadOverCellular.toggle()
                UserDefaults.standard.set(state.downloadOverCellular, forKey: "downloadOverCellular")
                return .none
                
            case let .saveAPIKey(type):
                return .run { [state] send in
                    do {
                        switch type {
                        case .esv:
                            try await apiKeyManager.saveESVKey(state.esvAPIKey)
                        case .elevenLabs:
                            try await apiKeyManager.saveElevenLabsKey(state.elevenLabsAPIKey)
                        }
                        await send(.apiKeySaved)
                    } catch {
                        await send(.apiKeySaveFailed(error))
                    }
                }
                
            case .apiKeySaved:
                state.showingAPIKeyAlert = false
                state.apiKeyAlertType = nil
                return .none
                
            case let .apiKeySaveFailed(error):
                state.error = error.localizedDescription
                return .none
                
            case let .showAPIKeyAlert(type):
                state.showingAPIKeyAlert = true
                state.apiKeyAlertType = type
                return .none
                
            case .dismissAPIKeyAlert:
                state.showingAPIKeyAlert = false
                state.apiKeyAlertType = nil
                return .none
                
            case .loadVoices:
                return .run { send in
                    await send(
                        .voicesLoaded(
                            Result {
                                try await elevenLabsClient.getAvailableVoices()
                            }
                        )
                    )
                } catch: { error, send in
                    await send(.voicesLoadFailed(error))
                }
                
            case let .voicesLoaded(voices):
                state.voices = IdentifiedArray(uniqueElements: voices)
                return .none
                
            case let .voicesLoadFailed(error):
                state.error = error.localizedDescription
                return .none
                
            case let .voiceSelected(voiceId):
                state.selectedVoiceId = voiceId
                UserDefaults.standard.set(voiceId, forKey: "elevenLabsVoiceId")
                
                return .run { _ in
                    await elevenLabsClient.setVoice(voiceId)
                }
                
            case .showVoicePicker:
                state.showingVoicePicker = true
                return .send(.loadVoices)
                
            case .dismissVoicePicker:
                state.showingVoicePicker = false
                return .none
                
            case .clearAllData:
                return .run { send in
                    do {
                        try await apiKeyManager.deleteAllKeys()
                        try await databaseClient.clearCache()
                        
                        // Clear UserDefaults
                        let domain = Bundle.main.bundleIdentifier!
                        UserDefaults.standard.removePersistentDomain(forName: domain)
                        
                        await send(.dataCleared)
                    } catch {
                        await send(.dataClearFailed(error))
                    }
                }
                
            case .dataCleared:
                // Reset state to defaults
                state = State()
                return .none
                
            case let .dataClearFailed(error):
                state.error = error.localizedDescription
                return .none
            }
        }
    }
}

public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
}