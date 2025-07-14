import SwiftUI

struct ReaderSettingsView: View {
    @Binding var fontSize: CGFloat
    @Binding var lineSpacing: CGFloat
    @Binding var theme: String
    
    init(fontSize: Binding<CGFloat> = .constant(16),
         lineSpacing: Binding<CGFloat> = .constant(1.5),
         theme: Binding<String> = .constant("Light")) {
        self._fontSize = fontSize
        self._lineSpacing = lineSpacing
        self._theme = theme
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Text Settings") {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Stepper("\(Int(fontSize))", value: $fontSize, in: 12...24)
                    }
                    
                    HStack {
                        Text("Line Spacing")
                        Spacer()
                        Picker("", selection: $lineSpacing) {
                            Text("Compact").tag(1.0)
                            Text("Regular").tag(1.5)
                            Text("Relaxed").tag(2.0)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section("Theme") {
                    Picker("Theme", selection: $theme) {
                        Text("Light").tag("Light")
                        Text("Dark").tag("Dark")
                        Text("Sepia").tag("Sepia")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section("Reading Preferences") {
                    Toggle("Show Verse Numbers", isOn: .constant(true))
                    Toggle("Show Chapter Headers", isOn: .constant(true))
                    Toggle("Show Cross References", isOn: .constant(false))
                }
            }
            .navigationTitle("Reader Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ReaderSettingsView()
}