import SwiftUI
import LeavnCore

struct ReadingModeView: View {
    let verses: [BibleVerse]
    @State private var isAutoScrolling = false
    @State private var scrollPosition: CGFloat = 0
    @AppStorage("autoScrollSpeed") private var autoScrollSpeed: Double = 1.0
    @AppStorage("fontSize") private var fontSize: Double = 16
    @AppStorage("lineSpacing") private var lineSpacing: Double = 8
    @AppStorage("fontName") private var fontName: String = "System"
    @AppStorage("showVerseNumbers") private var showVerseNumbers: Bool = true
    @AppStorage("nightMode") private var nightMode: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                (nightMode ? Color.black : Color(.systemBackground))
                    .ignoresSafeArea()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: CGFloat(lineSpacing)) {
                            ForEach(verses) { verse in
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    if showVerseNumbers {
                                        Text("\(verse.verse)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 30, alignment: .trailing)
                                    }
                                    
                                    Text(verse.text)
                                        .font(.custom(fontName == "System" ? "System" : fontName, size: fontSize))
                                        .foregroundColor(nightMode ? .white : .primary)
                                }
                                .id(verse.id)
                                .padding(.horizontal)
                            }
                            
                            // Bottom padding for auto-scroll
                            Color.clear
                                .frame(height: 200)
                        }
                        .padding(.vertical)
                    }
                }
                
                // Auto-scroll controls
                VStack {
                    Spacer()
                    
                    if isAutoScrolling {
                        HStack {
                            Button(action: {
                                autoScrollSpeed = max(0.5, autoScrollSpeed - 0.5)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Speed: \(autoScrollSpeed, specifier: "%.1f")x")
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            Button(action: {
                                autoScrollSpeed = min(3.0, autoScrollSpeed + 0.5)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(20)
                        .padding()
                    }
                }
            }
            .navigationTitle("Reading Mode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isAutoScrolling.toggle()
                    }) {
                        Image(systemName: isAutoScrolling ? "pause.fill" : "play.fill")
                    }
                }
            }
        }
    }
}
