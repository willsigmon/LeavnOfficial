import SwiftUI
import DesignSystem

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                // Welcome Page
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text("Welcome to Bible Study")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your personal Bible reading companion")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .tag(0)
                
                // Features Page 1
                VStack(spacing: 30) {
                    FeatureRow(
                        icon: "highlighter",
                        title: "Highlight & Bookmark",
                        description: "Mark important verses and save them for later",
                        color: .blue,
                        delay: 0.1
                    )
                    
                    FeatureRow(
                        icon: "note.text",
                        title: "Take Notes",
                        description: "Add personal insights and study notes",
                        color: .green,
                        delay: 0.2
                    )
                    
                    FeatureRow(
                        icon: "arrow.left.arrow.right",
                        title: "Multiple Translations",
                        description: "Compare different Bible translations",
                        color: .orange,
                        delay: 0.3
                    )
                }
                .tag(1)
                
                // Features Page 2
                VStack(spacing: 30) {
                    FeatureRow(
                        icon: "moon.stars.fill",
                        title: "Night Mode",
                        description: "Comfortable reading in any lighting",
                        color: .purple,
                        delay: 0.1
                    )
                    
                    FeatureRow(
                        icon: "textformat.size",
                        title: "Customizable Text",
                        description: "Adjust font size and style to your preference",
                        color: .indigo,
                        delay: 0.2
                    )
                    
                    FeatureRow(
                        icon: "square.and.arrow.up",
                        title: "Share Verses",
                        description: "Share meaningful verses with friends",
                        color: .teal,
                        delay: 0.3
                    )
                }
                .tag(2)
                
                // Get Started Page
                VStack(spacing: 30) {
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text("Let's Begin")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Start your Bible reading journey today")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button(action: {
                        showOnboarding = false
                    }) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.accentColor)
                            .cornerRadius(25)
                    }
                    .padding(.top)
                }
                .tag(3)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .padding()
            
            // Skip Button
            if currentPage < 3 {
                Button("Skip") {
                    showOnboarding = false
                }
                .foregroundColor(.secondary)
                .padding()
            }
        }
    }
}
