import SwiftUI
import ComposableArchitecture

public struct SettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    public init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // API Keys Section
                Section("API Keys") {
                    Button("ESV API Key") {
                        store.send(.showAPIKeyAlert(.esv))
                    }
                    .foregroundColor(.primary)
                    
                    Button("ElevenLabs API Key") {
                        store.send(.showAPIKeyAlert(.elevenLabs))
                    }
                    .foregroundColor(.primary)
                }
                .headerProminence(.increased)
                
                // Reading Section
                Section("Reading") {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(store.fontSize))pt")
                            .foregroundColor(.secondary)
                    }
                    
                    Slider(
                        value: $store.fontSize.sending(\.fontSizeChanged),
                        in: 12...24,
                        step: 1
                    )
                    
                    Picker("Theme", selection: $store.theme.sending(\.themeChanged)) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                }
                .headerProminence(.increased)
                
                // Audio Section
                Section("Audio") {
                    Toggle("Auto-play Audio", isOn: $store.autoPlayAudio.sending(\.autoPlayAudioToggled))
                    
                    Button("Voice Selection") {
                        store.send(.showVoicePicker)
                    }
                    .foregroundColor(.primary)
                }
                .headerProminence(.increased)
                
                // Download Section
                Section("Downloads") {
                    Toggle("Download over Cellular", isOn: $store.downloadOverCellular.sending(\.downloadOverCellularToggled))
                }
                .headerProminence(.increased)
                
                // Data Section
                Section("Data") {
                    Button("Clear All Data") {
                        store.send(.clearAllData)
                    }
                    .foregroundColor(.red)
                }
                .headerProminence(.increased)
                
                // About Section
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link("Privacy Policy", destination: URL(string: "https://leavn.app/privacy")!)
                    Link("Terms of Service", destination: URL(string: "https://leavn.app/terms")!)
                    Link("Support", destination: URL(string: "https://leavn.app/support")!)
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                store.send(.onAppear)
            }
            .alert("ESV API Key", isPresented: $store.showingAPIKeyAlert) {
                if store.apiKeyAlertType == .esv {
                    TextField("Enter ESV API Key", text: $store.esvAPIKey.sending(\.esvAPIKeyChanged))
                    Button("Save") {
                        store.send(.saveAPIKey(.esv))
                    }
                    Button("Cancel", role: .cancel) {
                        store.send(.dismissAPIKeyAlert)
                    }
                } else {
                    TextField("Enter ElevenLabs API Key", text: $store.elevenLabsAPIKey.sending(\.elevenLabsAPIKeyChanged))
                    Button("Save") {
                        store.send(.saveAPIKey(.elevenLabs))
                    }
                    Button("Cancel", role: .cancel) {
                        store.send(.dismissAPIKeyAlert)
                    }
                }
            } message: {
                if store.apiKeyAlertType == .esv {
                    Text("Enter your ESV API key to access Bible text. Get one free at api.esv.org")
                } else {
                    Text("Enter your ElevenLabs API key for audio narration. Get one at elevenlabs.io")
                }
            }
            .sheet(isPresented: $store.showingVoicePicker) {
                VoicePickerView(
                    voices: store.voices,
                    selectedVoiceId: store.selectedVoiceId,
                    onVoiceSelected: { voiceId in
                        store.send(.voiceSelected(voiceId))
                        store.send(.dismissVoicePicker)
                    },
                    onDismiss: {
                        store.send(.dismissVoicePicker)
                    }
                )
            }
        }
    }
}

struct VoicePickerView: View {
    let voices: IdentifiedArrayOf<Voice>
    let selectedVoiceId: String
    let onVoiceSelected: (String) -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(voices) { voice in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(voice.name)
                                .font(.headline)
                            
                            Text(voice.category)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if voice.id == selectedVoiceId {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onVoiceSelected(voice.id)
                    }
                }
            }
            .navigationTitle("Select Voice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}