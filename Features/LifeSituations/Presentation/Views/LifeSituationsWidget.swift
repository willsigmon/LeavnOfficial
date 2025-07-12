import SwiftUI
import LeavnCore

struct LifeSituationsWidget: View {
    @ObservedObject var viewModel: LifeSituationsViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("How are you feeling?")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Share what's on your heart")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !viewModel.emotionalJourney.isEmpty {
                    NavigationLink(destination: EmotionalJourneyView(viewModel: viewModel)) {
                        HStack(spacing: 4) {
                            Image(systemName: "heart.text.square")
                            Text("Journey")
                                .font(.caption)
                        }
                        .foregroundColor(.accentColor)
                    }
                }
            }
            
            // Input Area
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    TextField("I'm feeling...", text: $viewModel.lifeSituationText)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.regularMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                )
                        )
                        .focused($isTextFieldFocused)
                        .disabled(viewModel.isAnalyzingSituation)
                    
                    Button(action: {
                        isTextFieldFocused = false
                        viewModel.analyzeSituation()
                    }) {
                        if viewModel.isAnalyzingSituation {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .frame(width: 32, height: 32)
                    .disabled(viewModel.lifeSituationText.isEmpty || viewModel.isAnalyzingSituation)
                }
                
                // Emotion Tags (Quick Options)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Grateful 🙏", "Anxious 😟", "Joyful 😊", "Struggling 💔", "Peaceful 🕊️"], id: \.self) { emotion in
                            Button(action: {
                                viewModel.lifeSituationText = "I'm feeling \(emotion.components(separatedBy: " ").first?.lowercased() ?? "")"
                                viewModel.analyzeSituation()
                            }) {
                                Text(emotion)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        Capsule()
                                            .fill(.thinMaterial)
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                                            )
                                    )
                            }
                        }
                    }
                }
            }
            
            // Error Message
            if let error = viewModel.situationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
            // Analysis Results
            if let analyzed = viewModel.analyzedSituation {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                    
                    // Detected Emotions
                    HStack {
                        Image(systemName: "heart.circle")
                            .foregroundColor(.accentColor)
                        Text("We hear you")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        Button("Clear") {
                            withAnimation {
                                viewModel.clearAnalysis()
                            }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }
                    
                    Text(analyzed.guidancePrompt ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    // Suggested Verses
                    if !viewModel.suggestedVerses.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Verses for you")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            ForEach(viewModel.suggestedVerses.prefix(3)) { recommendation in
                                NavigationLink(destination: BibleReaderView(
                                    book: BibleBook(from: recommendation.verse.bookId),
                                    chapter: recommendation.verse.chapter
                                )) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(recommendation.verse.reference)
                                                .font(.caption2)
                                                .fontWeight(.medium)
                                                .foregroundColor(.accentColor)
                                            
                                            Text(recommendation.verse.text)
                                                .font(.caption)
                                                .foregroundColor(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.ultraThinMaterial)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                                            )
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding()
        .background(
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            }
        )
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .shadow(color: Color.black.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

