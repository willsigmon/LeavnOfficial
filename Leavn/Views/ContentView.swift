import SwiftUI
import LeavnCore

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        MainTabView()
    }
}
