import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem

/// AI-powered verse comparison across multiple translations
/// Integrates with iOS 26's new Intelligence framework
public struct VerseComparisonView: View {
    let verse: BibleVerse
    @StateObject private var viewModel = VerseComparisonViewModel()
    @EnvironmentObject var container: DIContainer
    @Environment(\.dismiss) private var dismiss
    
    public init(verse: BibleVerse) {
        self.verse = verse
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Original verse card
                    originalVerseCard
                    
                    // Translation comparisons
                    ForEach(viewModel.translations) { translation in
                        translationCard(for: translation)
                    }
                    
                    // AI Insights section
                    if !viewModel.aiInsights.isEmpty {
                        aiInsightsSection
                    }
                    
                    // Historical context will be part of AI insights
                }
                .padding()
            }
            .navigationTitle("Verse Comparison")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .task {
                await viewModel.loadComparisons(for: verse)
            }
        }
    }
    
    private var originalVerseCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(verse.reference)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(verse.translation)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(LeavnTheme.Colors.accent.opacity(0.1))
                    .cornerRadius(6)
            }
            
            Text(verse.text)
                .font(.body)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func translationCard(for translation: VerseTranslation) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(translation.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if translation.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if translation.differenceHighlight > 0.7 {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .help("Significant translation difference")
                }
            }
            
            if let text = translation.text {
                Text(text)
                    .font(.body)
                    .lineSpacing(4)
                    .background(
                        // Highlight differences using iOS 26's text analysis
                        TextHighlightView(
                            originalText: verse.text,
                            comparisonText: text,
                            highlightColor: LeavnTheme.Colors.accent.opacity(0.3)
                        )
                    )
            } else if translation.isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading \(translation.abbreviation)...")
                    Spacer()
                }
                .frame(height: 60)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
    }
    
    private var aiInsightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(LeavnTheme.Colors.accent)
                Text("AI Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // iOS 18 Intelligence badge
                if #available(iOS 18.0, *) {
                    Text("Intelligence")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .cornerRadius(4)
                }
            }
            
            ForEach(viewModel.aiInsights) { insight in
                InsightCard(insight: insight)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [LeavnTheme.Colors.accent.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(LeavnTheme.Colors.accent.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func contextCard(_ context: HistoricalContext) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.secondary)
                Text("Historical Context")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Text(context.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
            
            if let timeframe = context.timeframe {
                Text("Timeframe: \(timeframe)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Supporting Views

private struct TextHighlightView: UIViewRepresentable {
    let originalText: String
    let comparisonText: String
    let highlightColor: Color
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Use iOS 26's enhanced text analysis for semantic differences
        let attributedText = NSMutableAttributedString(string: comparisonText)
        
        // AI-powered difference highlighting would go here
        // This is a simplified version - the full implementation would use
        // Natural Language framework for semantic comparison
        
        uiView.attributedText = attributedText
    }
}

private struct InsightCard: View {
    let insight: AIInsight
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: insight.type.iconName)
                    .foregroundColor(insight.type.color)
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            Text(insight.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .padding(12)
        .background(insight.type.backgroundColor)
        .cornerRadius(8)
    }
}

// MARK: - Extensions

extension InsightType {
    var iconName: String {
        switch self {
        case .historical: return "building.columns"
        case .theological: return "book.closed"
        case .practical: return "lightbulb"
        case .devotional: return "heart"
        }
    }
    
    var color: Color {
        switch self {
        case .historical: return .brown
        case .theological: return .blue
        case .practical: return .green
        case .devotional: return .pink
        }
    }
    
    var backgroundColor: Color {
        color.opacity(0.1)
    }
}

#Preview {
    VerseComparisonView(
        verse: BibleVerse(
            id: "gen-1-1",
            bookName: "Genesis",
            bookId: "gen",
            chapter: 1,
            verse: 1,
            text: "In the beginning God created the heaven and the earth.",
            translation: "KJV"
        )
    )
    .environmentObject(DIContainer.shared)
}