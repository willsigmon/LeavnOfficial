import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isComplete: Bool
    
    init(isComplete: Binding<Bool> = .constant(false)) {
        self._isComplete = isComplete
    }
    
    var body: some View {
        VStack {
            TabView(selection: $currentPage) {
                OnboardingPageView(
                    title: "Welcome to Leavn",
                    description: "Your daily companion for Bible study and spiritual growth",
                    imageName: "book.fill"
                )
                .tag(0)
                
                OnboardingPageView(
                    title: "Read & Study",
                    description: "Access multiple Bible translations and study tools",
                    imageName: "text.book.closed.fill"
                )
                .tag(1)
                
                OnboardingPageView(
                    title: "Connect & Grow",
                    description: "Join a community of believers on their faith journey",
                    imageName: "person.3.fill"
                )
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle())
            
            Button(action: {
                if currentPage < 2 {
                    currentPage += 1
                } else {
                    isComplete = true
                }
            }) {
                Text(currentPage < 2 ? "Next" : "Get Started")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct OnboardingPageView: View {
    let title: String
    let description: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: imageName)
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            VStack(spacing: 10) {
                Text(title)
                    .font(.largeTitle)
                    .bold()
                
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
}