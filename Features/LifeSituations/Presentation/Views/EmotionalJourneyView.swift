import SwiftUI
import LeavnCore

// Emotional Journey View
struct EmotionalJourneyView: View {
    @ObservedObject var viewModel: LifeSituationsViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Emotional Journey")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.horizontal)
                
                if viewModel.emotionalJourney.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("No journey entries yet")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Share how you're feeling to start tracking your emotional journey with God")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    ForEach(viewModel.emotionalJourney) { situation in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text(situation.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    ForEach(situation.detectedEmotions, id: \.self) { emotion in
                                        Text(emotion)
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.accentColor.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                            
                            Text(situation.userInput)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            if let guidance = situation.guidancePrompt {
                                Text(guidance)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationTitle("Emotional Journey")
        .navigationBarTitleDisplayMode(.inline)
    }
} 