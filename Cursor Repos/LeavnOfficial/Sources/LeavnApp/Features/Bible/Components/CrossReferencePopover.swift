import SwiftUI

struct CrossReferencePopover: View {
    let reference: CrossReference
    let onDismiss: () -> Void
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cross References")
                        .font(.headline)
                    Text(reference.mainReference)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color.leavnSecondaryBackground)
            
            Divider()
            
            // References List
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(reference.references) { ref in
                        CrossReferenceRow(reference: ref)
                        
                        if ref.id != reference.references.last?.id {
                            Divider()
                                .padding(.leading, 60)
                        }
                    }
                }
            }
            .frame(maxHeight: 400)
        }
        .background(Color.leavnSecondaryBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.2), radius: 20)
        .padding()
        .transition(.scale.combined(with: .opacity))
    }
}

struct CrossReferenceRow: View {
    let reference: Reference
    @State private var isLoading = false
    @State private var verseText: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: loadVerse) {
                HStack(alignment: .top, spacing: 12) {
                    // Icon
                    Image(systemName: "link")
                        .font(.body)
                        .foregroundColor(.leavnPrimary)
                        .frame(width: 24, height: 24)
                        .background(Color.leavnPrimary.opacity(0.1))
                        .cornerRadius(6)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        // Reference
                        Text(reference.displayText)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        // Context or Preview
                        if let verseText = verseText {
                            Text(verseText)
                                .font(.callout)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        } else if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                        } else {
                            Text(reference.context)
                                .font(.caption)
                                .foregroundColor(.tertiaryLabel)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.tertiaryLabel)
                }
            }
            .buttonStyle(.plain)
        }
        .padding()
    }
    
    private func loadVerse() {
        guard verseText == nil else { return }
        
        isLoading = true
        // Simulate loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            verseText = "For God so loved the world that he gave his one and only Son..."
            isLoading = false
        }
    }
}

// Mock CrossReference model
struct CrossReference: Identifiable {
    let id = UUID()
    let mainReference: String
    let references: [Reference]
}

struct Reference: Identifiable {
    let id = UUID()
    let book: String
    let chapter: Int
    let verse: Int
    let context: String
    
    var displayText: String {
        "\(book) \(chapter):\(verse)"
    }
}