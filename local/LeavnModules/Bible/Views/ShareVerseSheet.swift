import SwiftUI
import LeavnCore

struct ShareVerseSheet: View {
    let verse: BibleVerse
    let verseText: String
    var defaultFormat: ShareFormat = .plain  // New parameter
    
    @State private var shareFormat: ShareFormat = .plain
    @State private var includeReference = true
    @Environment(\.dismiss) private var dismiss
    
    init(verse: BibleVerse, verseText: String, defaultFormat: ShareFormat = .plain) {
        self.verse = verse
        self.verseText = verseText
        self.defaultFormat = defaultFormat
        _shareFormat = State(initialValue: defaultFormat)
    }
    
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
    
    var formattedShareText: String {
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
        let items: [Any]
        
        switch shareFormat {
        case .plain, .formatted:  // For now, treat formatted same as plain
            items = [formattedShareText]
        case .image:
            let image = generateShareImage()
            items = [image]
        }
        
        let activityVC = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private func generateShareImage() -> UIImage {
        let width: CGFloat = 800
        let height: CGFloat = 600
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        return renderer.image { ctx in
            // Background
            UIColor.white.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: width, height: height))
            
            // Verse text
            let verseParagraphStyle = NSMutableParagraphStyle()
            verseParagraphStyle.alignment = .center
            let verseAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .medium),
                .foregroundColor: UIColor.black,
                .paragraphStyle: verseParagraphStyle
            ]
            let verseRect = CGRect(x: 40, y: 100, width: width - 80, height: height - 200)
            verseText.draw(in: verseRect, withAttributes: verseAttributes)
            
            // Reference
            if includeReference {
                let reference = "— \(verse.bookName) \(verse.chapter):\(verse.verse)"
                let refParagraphStyle = NSMutableParagraphStyle()
                refParagraphStyle.alignment = .center
                let refAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18, weight: .regular),
                    .foregroundColor: UIColor.gray,
                    .paragraphStyle: refParagraphStyle
                ]
                let refRect = CGRect(x: 40, y: verseRect.maxY + 20, width: width - 80, height: 40)
                reference.draw(in: refRect, withAttributes: refAttributes)
            }
            
            // Watermark
            let watermark = "Shared via Leavn"
            let watermarkParagraphStyle = NSMutableParagraphStyle()
            watermarkParagraphStyle.alignment = .right
            let watermarkAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .light),
                .foregroundColor: UIColor.gray.withAlphaComponent(0.5),
                .paragraphStyle: watermarkParagraphStyle
            ]
            let watermarkRect = CGRect(x: 40, y: height - 60, width: width - 80, height: 40)
            watermark.draw(in: watermarkRect, withAttributes: watermarkAttributes)
        }
    }
}

