import SwiftUI
import ComposableArchitecture

struct AudioSettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @State private var selectedVoice: Voice?
    @State private var isTestingVoice = false
    
    var body: some View {
        Form {
            // Voice Selection
            Section("Voice") {
                NavigationLink(destination: VoiceSelectionView(store: store)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Selected Voice")
                                .font(.headline)
                            Text(store.selectedVoice?.name ?? "Default Voice")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if let voice = store.selectedVoice {
                            VoicePreviewButton(voice: voice)
                        }
                    }
                }
            }
            
            // Playback Settings
            Section("Playback") {
                // Speed
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Playback Speed")
                        Spacer()
                        Text("\(store.settings.playbackSpeed, specifier: "%.2f")x")
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    
                    Slider(
                        value: $store.settings.playbackSpeed,
                        in: 0.5...2.0,
                        step: 0.25
                    )
                    
                    HStack {
                        Text("0.5x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("2.0x")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Auto-play
                Toggle("Auto-play next chapter", isOn: $store.settings.autoPlayNextChapter)
                
                // Skip silence
                Toggle("Skip silence", isOn: $store.settings.skipSilence)
                
                // Background playback
                Toggle("Continue in background", isOn: $store.settings.backgroundPlayback)
            }
            
            // Audio Quality
            Section("Quality") {
                Picker("Streaming Quality", selection: $store.settings.streamingQuality) {
                    ForEach(AudioQuality.allCases) { quality in
                        HStack {
                            Text(quality.displayName)
                            if let bitrate = quality.bitrate {
                                Text("(\(bitrate))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tag(quality)
                    }
                }
                
                Picker("Download Quality", selection: $store.settings.downloadQuality) {
                    ForEach(AudioQuality.allCases) { quality in
                        HStack {
                            Text(quality.displayName)
                            if let bitrate = quality.bitrate {
                                Text("(\(bitrate))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tag(quality)
                    }
                }
            }
            
            // Sleep Timer
            Section("Sleep Timer") {
                Toggle("Enable sleep timer", isOn: $store.settings.sleepTimerEnabled)
                
                if store.settings.sleepTimerEnabled {
                    Picker("Duration", selection: $store.settings.sleepTimerDuration) {
                        ForEach(SleepTimerDuration.allCases) { duration in
                            Text(duration.displayName).tag(duration)
                        }
                    }
                    
                    Toggle("Fade out audio", isOn: $store.settings.sleepTimerFadeOut)
                }
            }
            
            // Controls
            Section("Controls") {
                Picker("Skip forward", selection: $store.settings.skipForwardDuration) {
                    ForEach(SkipDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                
                Picker("Skip backward", selection: $store.settings.skipBackwardDuration) {
                    ForEach(SkipDuration.allCases) { duration in
                        Text(duration.displayName).tag(duration)
                    }
                }
                
                Toggle("Show audio visualizer", isOn: $store.settings.showAudioVisualizer)
            }
        }
        .navigationTitle("Audio Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VoiceSelectionView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @State private var selectedCategory: VoiceCategory = .all
    @State private var isLoadingVoices = false
    @State private var previewingVoice: Voice?
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(VoiceCategory.allCases) { category in
                        FilterPill(
                            title: category.displayName,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding()
            }
            
            if isLoadingVoices {
                LoadingView(message: "Loading voices...")
            } else {
                List {
                    ForEach(filteredVoices) { voice in
                        VoiceRow(
                            voice: voice,
                            isSelected: voice.id == store.selectedVoice?.id,
                            isPreviewing: voice.id == previewingVoice?.id
                        ) {
                            store.send(.selectVoice(voice))
                        } onPreview: {
                            previewVoice(voice)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Select Voice")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadVoices()
        }
    }
    
    private var filteredVoices: [Voice] {
        switch selectedCategory {
        case .all:
            return store.availableVoices
        case .male:
            return store.availableVoices.filter { $0.gender == .male }
        case .female:
            return store.availableVoices.filter { $0.gender == .female }
        case .premium:
            return store.availableVoices.filter { $0.isPremium }
        case .favorites:
            return store.favoriteVoices
        }
    }
    
    private func loadVoices() {
        isLoadingVoices = true
        store.send(.loadAvailableVoices)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isLoadingVoices = false
        }
    }
    
    private func previewVoice(_ voice: Voice) {
        previewingVoice = voice
        store.send(.previewVoice(voice))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            previewingVoice = nil
        }
    }
}

struct VoiceRow: View {
    let voice: Voice
    let isSelected: Bool
    let isPreviewing: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        HStack {
            // Voice Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(voice.name)
                        .font(.headline)
                    
                    if voice.isPremium {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                HStack(spacing: 8) {
                    Label(voice.language, systemImage: "globe")
                    
                    if let accent = voice.accent {
                        Text("•")
                            .foregroundColor(.secondary)
                        Text(accent)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(voice.gender.rawValue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                if let description = voice.description {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                // Preview Button
                Button(action: onPreview) {
                    if isPreviewing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "play.circle")
                            .font(.title2)
                            .foregroundColor(.leavnPrimary)
                    }
                }
                .buttonStyle(.plain)
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            onSelect()
        }
    }
}

struct VoicePreviewButton: View {
    let voice: Voice
    @State private var isPreviewing = false
    
    var body: some View {
        Button(action: {
            isPreviewing = true
            // Play preview
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                isPreviewing = false
            }
        }) {
            if isPreviewing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(0.6)
            } else {
                Image(systemName: "play.circle")
                    .foregroundColor(.leavnPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

// Enums
enum VoiceCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case male = "Male"
    case female = "Female"
    case premium = "Premium"
    case favorites = "Favorites"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum AudioQuality: String, CaseIterable, Identifiable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case veryHigh = "Very High"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var bitrate: String? {
        switch self {
        case .low: return "64 kbps"
        case .medium: return "128 kbps"
        case .high: return "256 kbps"
        case .veryHigh: return "320 kbps"
        }
    }
}

enum SleepTimerDuration: String, CaseIterable, Identifiable {
    case fiveMinutes = "5 minutes"
    case tenMinutes = "10 minutes"
    case fifteenMinutes = "15 minutes"
    case thirtyMinutes = "30 minutes"
    case oneHour = "1 hour"
    case endOfChapter = "End of chapter"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum SkipDuration: String, CaseIterable, Identifiable {
    case tenSeconds = "10 seconds"
    case fifteenSeconds = "15 seconds"
    case thirtySeconds = "30 seconds"
    case oneMinute = "1 minute"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

// Extended Voice model
extension Voice {
    enum Gender: String {
        case male = "Male"
        case female = "Female"
        case neutral = "Neutral"
    }
    
    var gender: Gender { .male } // Default implementation
    var language: String { "English" }
    var accent: String? { nil }
    var isPremium: Bool { false }
    var description: String? { nil }
}