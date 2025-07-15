import SwiftUI

@main
struct LeavnApp: App {
    // Initialize the DI container
    let diContainer = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, diContainer)
        }
    }
}