import SwiftUI
import ComposableArchitecture

struct AppearanceSettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        Form {
            // Theme Section
            Section("Theme") {
                Picker("Appearance", selection: $store.settings.appearance.theme) {
                    ForEach(AppTheme.allCases) { theme in
                        Label(theme.displayName, systemImage: theme.icon)
                            .tag(theme)
                    }
                }
                .pickerStyle(.inline)
                
                if store.settings.appearance.theme == .system {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Theme follows your device settings")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Typography Section
            Section("Typography") {
                // Font Size
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(store.settings.appearance.fontSize))pt")
                            .foregroundColor(.secondary)
                            .monospacedDigit()
                    }
                    
                    Slider(
                        value: $store.settings.appearance.fontSize,
                        in: 12...30,
                        step: 1
                    )
                    
                    // Preview
                    Text("In the beginning God created the heavens and the earth.")
                        .font(.system(size: store.settings.appearance.fontSize))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Font Family
                Picker("Font", selection: $store.settings.appearance.fontFamily) {
                    ForEach(FontFamily.allCases) { font in
                        Text(font.displayName)
                            .font(font.font(size: 16))
                            .tag(font)
                    }
                }
                
                // Line Spacing
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Line Spacing")
                        Spacer()
                        Text(store.settings.appearance.lineSpacing.displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    Picker("Line Spacing", selection: $store.settings.appearance.lineSpacing) {
                        ForEach(LineSpacing.allCases) { spacing in
                            Text(spacing.displayName).tag(spacing)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            
            // Colors Section
            Section("Colors") {
                // Accent Color
                HStack {
                    Text("Accent Color")
                    Spacer()
                    ColorPicker("", selection: $store.settings.appearance.accentColor)
                        .labelsHidden()
                }
                
                // Highlight Colors
                VStack(alignment: .leading, spacing: 12) {
                    Text("Highlight Colors")
                        .font(.headline)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(HighlightColor.allCases, id: \.self) { color in
                            ColorOptionButton(
                                color: color,
                                isSelected: store.settings.appearance.enabledHighlightColors.contains(color)
                            ) {
                                store.send(.toggleHighlightColor(color))
                            }
                        }
                    }
                }
            }
            
            // Interface Section
            Section("Interface") {
                Toggle("Show Verse Numbers", isOn: $store.settings.appearance.showVerseNumbers)
                
                Toggle("Show Red Letters", isOn: $store.settings.appearance.showRedLetters)
                
                Toggle("Show Cross References", isOn: $store.settings.appearance.showCrossReferences)
                
                Toggle("Show Footnotes", isOn: $store.settings.appearance.showFootnotes)
            }
            
            // Reading Mode Section
            Section("Reading Mode") {
                Toggle("Full Screen Reading", isOn: $store.settings.appearance.fullScreenReading)
                
                Toggle("Hide Status Bar", isOn: $store.settings.appearance.hideStatusBar)
                    .disabled(!store.settings.appearance.fullScreenReading)
                
                Toggle("Keep Screen On", isOn: $store.settings.appearance.keepScreenOn)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ColorOptionButton: View {
    let color: HighlightColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(Color(color.uiColor))
                    .frame(width: 44, height: 44)
                    .overlay(
                        Circle()
                            .stroke(Color.primary, lineWidth: 2)
                            .opacity(isSelected ? 1 : 0)
                    )
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                            .opacity(isSelected ? 1 : 0)
                    )
                
                Text(color.name)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// Enums for appearance settings
enum FontFamily: String, CaseIterable, Identifiable {
    case system = "System"
    case georgia = "Georgia"
    case helvetica = "Helvetica"
    case times = "Times New Roman"
    case palatino = "Palatino"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    func font(size: CGFloat) -> Font {
        switch self {
        case .system:
            return .system(size: size)
        case .georgia:
            return .custom("Georgia", size: size)
        case .helvetica:
            return .custom("Helvetica Neue", size: size)
        case .times:
            return .custom("Times New Roman", size: size)
        case .palatino:
            return .custom("Palatino", size: size)
        }
    }
}

enum LineSpacing: String, CaseIterable, Identifiable {
    case compact = "Compact"
    case normal = "Normal"
    case relaxed = "Relaxed"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var value: CGFloat {
        switch self {
        case .compact: return 4
        case .normal: return 8
        case .relaxed: return 12
        }
    }
}