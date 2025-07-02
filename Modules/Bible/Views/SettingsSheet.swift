import SwiftUI

struct SettingsSheet: View {
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("lineSpacing") private var lineSpacing: Double = 8
    @AppStorage("fontName") private var fontName: String = "System"
    @AppStorage("showVerseNumbers") private var showVerseNumbers: Bool = true
    @AppStorage("showRedLetters") private var showRedLetters: Bool = true
    @AppStorage("nightMode") private var nightMode: Bool = false
    @AppStorage("autoScrollSpeed") private var autoScrollSpeed: Double = 1.0
    
    @Environment(\.dismiss) private var dismiss
    
    let fonts = ["System", "Georgia", "Palatino", "Times New Roman", "Helvetica", "Avenir"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Text Display") {
                    VStack(alignment: .leading) {
                        Text("Font Size")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: $fontSize, in: 12...24, step: 1) {
                            Text("Font Size")
                        } minimumValueLabel: {
                            Text("A").font(.caption)
                        } maximumValueLabel: {
                            Text("A").font(.title3)
                        }
                        .accessibilityLabel("Font Size Slider")
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Line Spacing")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: $lineSpacing, in: 4...16, step: 2)
                            .accessibilityLabel("Line Spacing Slider")
                    }
                    
                    Picker("Font", selection: $fontName) {
                        ForEach(fonts, id: \.self) { font in
                            Text(font).tag(font)
                        }
                    }
                    .accessibilityLabel("Font Picker")
                }
                
                Section("Reading Options") {
                    Toggle("Show Verse Numbers", isOn: $showVerseNumbers)
                        .accessibilityLabel("Show Verse Numbers Toggle")
                    Toggle("Show Red Letters", isOn: $showRedLetters)
                        .accessibilityLabel("Show Red Letters Toggle")
                    Toggle("Night Mode", isOn: $nightMode)
                        .accessibilityLabel("Night Mode Toggle")
                }
                
                Section("Auto Scroll") {
                    VStack(alignment: .leading) {
                        Text("Scroll Speed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Slider(value: $autoScrollSpeed, in: 0.5...3.0, step: 0.5) {
                            Text("Speed")
                        } minimumValueLabel: {
                            Image(systemName: "tortoise")
                        } maximumValueLabel: {
                            Image(systemName: "hare")
                        }
                        .accessibilityLabel("Auto Scroll Speed Slider")
                    }
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: CGFloat(lineSpacing)) {
                        if showVerseNumbers {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text("16")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("For God so loved the world that he gave his one and only Son,")
                                    .font(.custom(fontName == "System" ? "System" : fontName, size: fontSize))
                            }
                        } else {
                            Text("For God so loved the world that he gave his one and only Son,")
                                .font(.custom(fontName == "System" ? "System" : fontName, size: fontSize))
                        }
                    }
                    .padding()
                    .background(nightMode ? Color.black : Color(.systemBackground))
                    .foregroundColor(nightMode ? Color.white : Color.primary)
                    .cornerRadius(8)
                }
                
                Section {
                    Button("Reset to Defaults") {
                        fontSize = 16
                        lineSpacing = 8
                        fontName = "System"
                        showVerseNumbers = true
                        showRedLetters = true
                        nightMode = false
                        autoScrollSpeed = 1.0
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Reset to Defaults")
                }
            }
            .navigationTitle("Reading Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Settings Sheet")
                }
            }
        }
        .accessibilityLabel("Settings Sheet")
    }
}
