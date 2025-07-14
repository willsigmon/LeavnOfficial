import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showSignOutAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var showTheologicalPerspectivePicker = false
    
    var body: some View {
        NavigationView {
            Form {
                // Account Section
                Section("Account") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        
                        VStack(alignment: .leading) {
                            Text(viewModel.userName)
                                .font(.headline)
                            Text(viewModel.userEmail)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    
                    NavigationLink(destination: Text("Edit Profile")) {
                        Label("Edit Profile", systemImage: "pencil")
                    }
                }
                
                // Preferences Section
                Section("Preferences") {
                    Picker("Theme", selection: $viewModel.appTheme) {
                        ForEach(viewModel.themes, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    
                    Picker("Default Translation", selection: $viewModel.preferredTranslation) {
                        ForEach(viewModel.translations, id: \.self) { translation in
                            Text(translation).tag(translation)
                        }
                    }
                    
                    NavigationLink(destination: TheologicalPerspectivePickerView(selectedPerspectives: $viewModel.theologicalPerspectives)) {
                        HStack {
                            Text("Theological Perspectives")
                            Spacer()
                            if viewModel.theologicalPerspectives.isEmpty {
                                Text("None")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("\(viewModel.theologicalPerspectives.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    HStack {
                        Text("Font Size")
                        Slider(value: $viewModel.fontSize, in: 12...24, step: 1)
                        Text("\(Int(viewModel.fontSize))")
                            .foregroundColor(.secondary)
                    }
                }
                
                // Notifications Section
                Section("Notifications") {
                    Toggle("Push Notifications", isOn: $viewModel.notifications)
                    
                    Toggle("Daily Reminders", isOn: $viewModel.dailyReminders)
                    
                    if viewModel.dailyReminders {
                        DatePicker("Reminder Time", selection: $viewModel.reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                // Data Section
                Section("Data") {
                    Button(action: viewModel.exportData) {
                        Label("Export Data", systemImage: "square.and.arrow.up")
                    }
                    
                    Button(action: viewModel.clearCache) {
                        Label("Clear Cache", systemImage: "trash")
                    }
                }
                
                // Support Section
                Section("Support") {
                    NavigationLink(destination: Text("Help & Support")) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }
                    
                    NavigationLink(destination: Text("Terms of Service")) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                    
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }
                }
                
                // Sign Out Section
                Section {
                    Button(action: { showSignOutAlert = true }) {
                        Text("Sign Out")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: { showDeleteAccountAlert = true }) {
                        Text("Delete Account")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    viewModel.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
            .alert("Delete Account", isPresented: $showDeleteAccountAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                }
            } message: {
                Text("This action cannot be undone. All your data will be permanently deleted.")
            }
            .onChange(of: viewModel.theologicalPerspectives) { perspectives in
                viewModel.updateTheologicalPerspectives(perspectives)
            }
        }
    }
}

#Preview {
    SettingsView()
}