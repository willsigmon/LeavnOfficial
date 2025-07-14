//
//  LeavnApp.swift
//  Leavn (macOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI

@main
struct LeavnApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Leave Request") {
                    appState.showNewLeaveRequest = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("Leave") {
                Button("View Balance") {
                    appState.showLeaveBalance = true
                }
                .keyboardShortcut("b", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Sync Data") {
                    appState.syncData()
                }
                .keyboardShortcut("r", modifiers: .command)
            }
        }
        
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
    }
}

// App State for macOS
class AppState: ObservableObject {
    @Published var showNewLeaveRequest = false
    @Published var showLeaveBalance = false
    @Published var isSyncing = false
    
    func syncData() {
        isSyncing = true
        // Implement sync logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isSyncing = false
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            NotificationSettingsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
            
            AccountSettingsView()
                .tabItem {
                    Label("Account", systemImage: "person.circle")
                }
        }
        .frame(width: 450, height: 350)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("autoSync") private var autoSync = true
    @AppStorage("showInMenuBar") private var showInMenuBar = true
    
    var body: some View {
        Form {
            Toggle("Auto-sync leave data", isOn: $autoSync)
            Toggle("Show in menu bar", isOn: $showInMenuBar)
        }
        .padding()
    }
}

struct NotificationSettingsView: View {
    @AppStorage("enableNotifications") private var enableNotifications = true
    
    var body: some View {
        Form {
            Toggle("Enable notifications", isOn: $enableNotifications)
        }
        .padding()
    }
}

struct AccountSettingsView: View {
    var body: some View {
        VStack {
            Text("Account Settings")
                .font(.headline)
            Spacer()
        }
        .padding()
    }
}