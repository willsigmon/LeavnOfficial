import SwiftUI

struct DevotionReaderView: View {
    let devotionTitle: String
    let devotionContent: String
    
    init(devotionTitle: String = "Daily Devotion", devotionContent: String = "Today's devotional content...") {
        self.devotionTitle = devotionTitle
        self.devotionContent = devotionContent
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(devotionTitle)
                    .font(.largeTitle)
                    .bold()
                
                Text(Date(), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(devotionContent)
                    .font(.body)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reflection")
                        .font(.headline)
                    
                    Text("Take a moment to reflect on today's message...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Devotion")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        DevotionReaderView()
    }
}