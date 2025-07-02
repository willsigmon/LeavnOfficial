import SwiftUI
import LeavnCore

struct ReaderSettingsView: View {
    @AppStorage("bibleReaderFontSize") private var fontSize: Double = 17.0
    @AppStorage("bibleReaderLineSpacing") private var lineSpacing: Double = 6.0
    @AppStorage("showVerseNumbers") private var showVerseNumbers: Bool = true
    @AppStorage("showRedLetters") private var showRedLetters: Bool = true
    @AppStorage("nightMode") private var nightMode: Bool = false
    @AppStorage("fontName") private var fontName: String = "System"
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Form {
            Section("Text Display") {
                VStack(alignment: .leading) {
                    Text("Font Size")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("A")
                            .font(.caption)
                        
                        Slider(value: $fontSize, in: 12...32, step: 1)
                        
                        Text("A")
                            .font(.title3)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Line Spacing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: $lineSpacing, in: 0...20, step: 1)
                }
                
                Picker("Font", selection: $fontName) {
                    Text("System").tag("System")
                    Text("Georgia").tag("Georgia")
                    Text("Palatino").tag("Palatino")
                    Text("Times New Roman").tag("Times New Roman")
                    Text("Helvetica").tag("Helvetica")
                }
            }
            
            Section("Display Options") {
                Toggle("Show Verse Numbers", isOn: $showVerseNumbers)
                Toggle("Show Red Letters", isOn: $showRedLetters)
                Toggle("Night Mode", isOn: $nightMode)
            }
            
            Section("Preview") {
                VStack(alignment: .leading, spacing: CGFloat(lineSpacing)) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        if showVerseNumbers {
                            Text("16")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 30, alignment: .trailing)
                        }
                        
                        Text("For God so loved the world that he gave his one and only Son,")
                            .font(.custom(fontName == "System" ? "System" : fontName, size: fontSize))
                            .foregroundColor(showRedLetters ? .red : (nightMode ? .white : .primary))
                    }
                }
                .padding()
                .background(nightMode ? Color.black : Color(.systemBackground))
                .cornerRadius(8)
            }
            
            Section {
                Button("Reset to Defaults") {
                    fontSize = 17.0
                    lineSpacing = 6.0
                    fontName = "System"
                    showVerseNumbers = true
                    showRedLetters = true
                    nightMode = false
                }
                .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    NavigationView {
        ReaderSettingsView()
            .navigationTitle("Reader Settings")
            .navigationBarTitleDisplayMode(.inline)
    }
} 