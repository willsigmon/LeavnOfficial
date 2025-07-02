import SwiftUI
import LeavnCore

struct ShareVerseSheet: View {
    let verse: BibleVerse
    let verseText: String
    @State private var includeReference = true
    @State private var shareFormat = ShareFormat.plain
    @Environment(\.dismiss) private var dismiss
    
    enum ShareFormat: String, CaseIterable {
        case plain = "Plain Text"
        case formatted = "Formatted"
        case image = "Image"
        
        var icon: String {
            switch self {
            case .plain: return "text.alignleft"
            case .formatted: return "text.badge.star"
            case .image: return "photo"
            }
        }
    }
    
    var shareText: String {
        let reference = "\(verse.bookName) \(verse.chapter):\(verse.verse)"
        if includeReference {
            return "\(verseText)\n\n— \(reference)"
        } else {
            return verseText
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Share Options") {
                    Picker("Format", selection: $shareFormat) {
                        ForEach(ShareFormat.allCases, id: \.self) { format in
                            Label(format.rawValue, systemImage: format.icon)
                        }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityLabel("Share Format Picker")
                    
                    Toggle("Include Reference", isOn: $includeReference)
                        .accessibilityLabel("Include Reference Toggle")
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(verseText)
                            .font(.body)
                        
                        if includeReference {
                            Text("— \(verse.bookName) \(verse.chapter):\(verse.verse)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .accessibilityLabel("Share Preview")
                
                Section {
                    Button(action: shareVerse) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .accessibilityLabel("Share Verse")
                    .accessibilityHint("Share this verse using your selected format.")
                }
            }
            .navigationTitle("Share Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityLabel("Dismiss Share Sheet")
                }
            }
        }
    }
    
    private func shareVerse() {
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

