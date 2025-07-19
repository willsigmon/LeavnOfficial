import SwiftUI
import ComposableArchitecture

struct BibleSettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        Form {
            // Default Translation
            Section("Default Translation") {
                Picker("Translation", selection: $store.settings.defaultTranslation) {
                    ForEach(BibleTranslation.allCases) { translation in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(translation.abbreviation)
                                    .font(.headline)
                                Text(translation.fullName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tag(translation)
                    }
                }
                .pickerStyle(.inline)
            }
            
            // Reading Preferences
            Section("Reading Preferences") {
                Toggle("Auto-scroll while reading", isOn: $store.settings.autoScroll)
                
                if store.settings.autoScroll {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Scroll Speed")
                            Spacer()
                            Text("\(Int(store.settings.scrollSpeed))%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $store.settings.scrollSpeed,
                            in: 25...200,
                            step: 25
                        )
                    }
                }
                
                Toggle("Continuous scrolling", isOn: $store.settings.continuousScrolling)
                
                Toggle("Show chapter transitions", isOn: $store.settings.showChapterTransitions)
            }
            
            // Gestures
            Section("Gestures") {
                Picker("Swipe Left", selection: $store.settings.swipeLeftAction) {
                    ForEach(SwipeAction.allCases) { action in
                        Text(action.displayName).tag(action)
                    }
                }
                
                Picker("Swipe Right", selection: $store.settings.swipeRightAction) {
                    ForEach(SwipeAction.allCases) { action in
                        Text(action.displayName).tag(action)
                    }
                }
                
                Toggle("Tap to show/hide controls", isOn: $store.settings.tapToToggleControls)
                
                Toggle("Pinch to zoom", isOn: $store.settings.pinchToZoom)
            }
            
            // Parallel Reading
            Section("Parallel Reading") {
                Toggle("Enable parallel translations", isOn: $store.settings.parallelReadingEnabled)
                
                if store.settings.parallelReadingEnabled {
                    NavigationLink(destination: ParallelTranslationsView(store: store)) {
                        HStack {
                            Text("Select Translations")
                            Spacer()
                            Text("\(store.settings.parallelTranslations.count) selected")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Picker("Layout", selection: $store.settings.parallelLayout) {
                        Text("Side by Side").tag(ParallelLayout.sideBySide)
                        Text("Verse by Verse").tag(ParallelLayout.verseByVerse)
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            // Copy & Share
            Section("Copy & Share") {
                Toggle("Include reference when copying", isOn: $store.settings.includeReferenceInCopy)
                
                Toggle("Include translation when sharing", isOn: $store.settings.includeTranslationInShare)
                
                Picker("Copy format", selection: $store.settings.copyFormat) {
                    ForEach(CopyFormat.allCases) { format in
                        Text(format.displayName).tag(format)
                    }
                }
            }
            
            // Study Tools
            Section("Study Tools") {
                Toggle("Show Strong's numbers", isOn: $store.settings.showStrongsNumbers)
                
                Toggle("Show morphology", isOn: $store.settings.showMorphology)
                
                Toggle("Show word meanings on tap", isOn: $store.settings.showWordMeanings)
            }
        }
        .navigationTitle("Bible Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ParallelTranslationsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        List {
            ForEach(BibleTranslation.allCases) { translation in
                HStack {
                    VStack(alignment: .leading) {
                        Text(translation.abbreviation)
                            .font(.headline)
                        Text(translation.fullName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if store.settings.parallelTranslations.contains(translation) {
                        Image(systemName: "checkmark")
                            .foregroundColor(.leavnPrimary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    store.send(.toggleParallelTranslation(translation))
                }
            }
        }
        .navigationTitle("Parallel Translations")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TranslationSettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @State private var showingAddTranslation = false
    
    var body: some View {
        List {
            // Downloaded Translations
            Section("Downloaded Translations") {
                ForEach(store.downloadedTranslations) { translation in
                    TranslationRow(
                        translation: translation,
                        isDefault: translation == store.settings.defaultTranslation,
                        isDownloaded: true
                    ) {
                        store.send(.setDefaultTranslation(translation))
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let translation = store.downloadedTranslations[index]
                        store.send(.deleteTranslation(translation))
                    }
                }
            }
            
            // Available Translations
            Section("Available Translations") {
                ForEach(store.availableTranslations) { translation in
                    TranslationRow(
                        translation: translation,
                        isDefault: false,
                        isDownloaded: false
                    ) {
                        store.send(.downloadTranslation(translation))
                    }
                }
            }
            
            // API Translations
            Section("Online Translations") {
                Button(action: { showingAddTranslation = true }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.leavnPrimary)
                        Text("Add Translation with API Key")
                    }
                }
            }
        }
        .navigationTitle("Bible Translations")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddTranslation) {
            AddTranslationView(store: store)
        }
    }
}

struct TranslationRow: View {
    let translation: BibleTranslation
    let isDefault: Bool
    let isDownloaded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(translation.abbreviation)
                            .font(.headline)
                        
                        if isDefault {
                            Text("DEFAULT")
                                .font(.caption2.bold())
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.leavnPrimary)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(translation.fullName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Label(translation.language, systemImage: "globe")
                        
                        if let year = translation.year {
                            Label(year, systemImage: "calendar")
                        }
                        
                        if translation.hasRedLetters {
                            Label("Red Letters", systemImage: "quote.bubble")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isDownloaded {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "arrow.down.circle")
                        .foregroundColor(.leavnPrimary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

struct AddTranslationView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @Environment(\.dismiss) var dismiss
    @State private var selectedProvider: TranslationProvider = .esv
    @State private var apiKey = ""
    
    enum TranslationProvider: String, CaseIterable {
        case esv = "ESV API"
        case nlt = "NLT API"
        case custom = "Custom API"
        
        var url: String {
            switch self {
            case .esv: return "api.esv.org"
            case .nlt: return "api.nlt.to"
            case .custom: return ""
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Provider") {
                    Picker("API Provider", selection: $selectedProvider) {
                        ForEach(TranslationProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    if !selectedProvider.url.isEmpty {
                        Link("Get API Key", destination: URL(string: "https://\(selectedProvider.url)")!)
                            .font(.caption)
                    }
                }
                
                Section("API Key") {
                    SecureField("Enter API Key", text: $apiKey)
                        .textContentType(.password)
                    
                    Text("Your API key will be stored securely in the keychain")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button("Add Translation") {
                        store.send(.addTranslationWithAPI(selectedProvider.rawValue, apiKey))
                        dismiss()
                    }
                    .disabled(apiKey.isEmpty)
                }
            }
            .navigationTitle("Add Translation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Enums
enum BibleTranslation: String, CaseIterable, Identifiable {
    case esv = "ESV"
    case niv = "NIV"
    case nlt = "NLT"
    case kjv = "KJV"
    case nkjv = "NKJV"
    case nasb = "NASB"
    case csb = "CSB"
    case amp = "AMP"
    case msg = "MSG"
    
    var id: String { rawValue }
    var abbreviation: String { rawValue }
    
    var fullName: String {
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
    
    var language: String { "English" }
    var year: String? {
        switch self {
        case .esv: return "2001"
        case .niv: return "2011"
        case .nlt: return "2015"
        case .kjv: return "1611"
        case .nkjv: return "1982"
        case .nasb: return "2020"
        case .csb: return "2017"
        case .amp: return "2015"
        case .msg: return "2002"
        }
    }
    var hasRedLetters: Bool { true }
}

enum SwipeAction: String, CaseIterable, Identifiable {
    case nextChapter = "Next Chapter"
    case previousChapter = "Previous Chapter"
    case bookmark = "Bookmark"
    case highlight = "Highlight"
    case none = "None"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

enum ParallelLayout: String, CaseIterable {
    case sideBySide = "Side by Side"
    case verseByVerse = "Verse by Verse"
}

enum CopyFormat: String, CaseIterable, Identifiable {
    case plain = "Plain Text"
    case markdown = "Markdown"
    case html = "HTML"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}