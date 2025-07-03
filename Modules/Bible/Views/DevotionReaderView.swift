import SwiftUI
import LeavnCore

struct DevotionReaderView: View {
    let devotion: Devotion
    @State private var progress: Double = 0
    @State private var isFavorited = false
    @State private var showShareSheet = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header Image
                    if let imageName = devotion.imageName {
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.clear, .black.opacity(0.3)]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Date
                        VStack(alignment: .leading, spacing: 8) {
                            Text(devotion.title)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            HStack {
                                Text(devotion.author ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(devotion.date, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Scripture Reference
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Scripture")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(devotion.scriptureReference ?? "")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text(devotion.scriptureText ?? "")
                                .font(.body)
                                .italic()
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                        }
                        
                        // Content
                        Text(devotion.content)
                            .font(.body)
                            .lineSpacing(8)
                        
                        // Reflection Questions
                        if let reflectionQuestions = devotion.reflectionQuestions, !reflectionQuestions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Reflection")
                                    .font(.headline)
                                
                                ForEach(reflectionQuestions, id: \.self) { question in
                                    HStack(alignment: .top) {
                                        Text("•")
                                            .fontWeight(.bold)
                                        Text(question)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        // Prayer
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Prayer")
                                .font(.headline)
                            
                            Text(devotion.prayer)
                                .italic()
                        }
                        .padding()
                        .background(Color(.systemBlue).opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: {
                            isFavorited.toggle()
                        }) {
                            Image(systemName: isFavorited ? "heart.fill" : "heart")
                                .foregroundColor(isFavorited ? .red : .primary)
                        }
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: ["\(devotion.title)\n\n\(devotion.content)\n\n\(devotion.prayer)\n\n- \(devotion.verse.reference)"])
        }
    }
}

// Using unified ShareSheet component from Components
