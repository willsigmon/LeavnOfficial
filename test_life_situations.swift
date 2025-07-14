import SwiftUI

// Test app to verify Life Situations integration
@main
struct TestLifeSituationsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TestHomeView()
            }
        }
    }
}

struct TestHomeView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("Leavn Home")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top)
                
                // Test the Life Situations section
                LifeSituationsHomeSection()
                    .padding(.horizontal)
                
                Spacer(minLength: 100)
            }
        }
        .navigationTitle("Home")
        .navigationBarHidden(true)
    }
}

// Preview
#Preview {
    TestHomeView()
}