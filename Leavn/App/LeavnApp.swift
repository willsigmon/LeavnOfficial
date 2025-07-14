import SwiftUI

@main
struct LeavnApp: App {
    // Initialize the DI container
    let diContainer = DIContainer.shared
    
    init() {
        // Configure the container with production settings
        let configuration = LeavnConfiguration(
            apiKey: ProcessInfo.processInfo.environment["LEAVN_API_KEY"] ?? "",
            environment: .production,
            esvAPIKey: ProcessInfo.processInfo.environment["ESV_API_KEY"] ?? "",
            bibleComAPIKey: ProcessInfo.processInfo.environment["BIBLE_COM_API_KEY"] ?? "",
            elevenLabsAPIKey: ProcessInfo.processInfo.environment["ELEVENLABS_API_KEY"] ?? ""
        )
        diContainer.configure(with: configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.diContainer, diContainer)
        }
    }
}