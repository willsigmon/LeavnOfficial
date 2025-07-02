import SwiftUI
import LeavnCore
import DesignSystem

// A helper enum for theme selection
public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    public var id: String { self.rawValue }
}

public struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showSignOutAlert = false
    @State private var selectedTheme: AppTheme = .system // Assuming this is managed locally or via viewmodel
    @State private var showAbout = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                settingsHeader
                
                ScrollView {
                    VStack(spacing: 30) {
                        profileSection
                        appearanceSection
                        bibleSection
                        notificationsSection
                        aboutSection
                        signOutButton
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
            }
        }
        .alert("Sign Out", isPresented: $showSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task {
                    await viewModel.signOut()
                }
            }
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }

    }
    
    private var settingsHeader: some View {
        HStack {
            Text("Settings")
                .font(LeavnTheme.Typography.displayMedium) // FIX 1
                .foregroundStyle(LeavnTheme.Colors.primaryGradient)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
    
    private var profileSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(LeavnTheme.Colors.primaryGradient)
                        .frame(width: 60, height: 60)
                    
                    Text(viewModel.user?.name.prefix(1).uppercased() ?? "?") // FIX 2
                        .font(LeavnTheme.Typography.titleMedium)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading) {
                    Text(viewModel.user?.name ?? "Guest")
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text(viewModel.user?.email ?? "Not signed in")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            HStack(spacing: 16) {
                StatCard(value: "\(viewModel.readingStreak)", label: "Day Streak", icon: "flame.fill", color: LeavnTheme.Colors.error)
                StatCard(value: "\(viewModel.versesRead)", label: "Verses Read", icon: "book.fill", color: LeavnTheme.Colors.info)
                StatCard(value: "\(viewModel.timeInWord)", label: "Time In Word", icon: "clock.fill", color: LeavnTheme.Colors.success)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
    }
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Appearance", icon: "paintbrush.fill")
            
            VStack(spacing: 0) {
                SettingRow(icon: "paintbrush", title: "Theme", value: viewModel.selectedTheme) {
                    // Action to change theme
                }
            }
            .padding(.vertical, 8)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    private var bibleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Bible Reading", icon: "book.fill")
            
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Font Size")
                        Spacer()
                        Text("\(Int(viewModel.fontSize))pt")
                    }
                    Slider(value: $viewModel.fontSize, in: 12...32, step: 1)
                        .tint(LeavnTheme.Colors.accent)
                }
                .padding()
                
                Divider().padding(.horizontal)
                
                SettingRow(icon: "globe", title: "Default Translation", value: viewModel.readingTranslation.name) { // FIX 3 (using .name for display)
                    // Show translation picker
                }
                
                Divider().padding(.horizontal)
                
                SettingToggle(icon: "text.book.closed.fill", title: "Show Red Letter Words", isOn: $viewModel.showRedLetterWords)
                
                Divider().padding(.horizontal)
                
                SettingToggle(icon: "list.number", title: "Show Verse Numbers", isOn: $viewModel.showVerseNumbers)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Notifications", icon: "bell.fill")
            
            VStack(spacing: 0) {
                SettingToggle(icon: "sun.max.fill", title: "Daily Verse", isOn: $viewModel.dailyVerseEnabled)
                Divider().padding(.horizontal)
                SettingToggle(icon: "bell.badge.fill", title: "Reading Reminders", isOn: $viewModel.readingRemindersEnabled)
                Divider().padding(.horizontal)
                SettingToggle(icon: "person.2.fill", title: "Community Updates", isOn: $viewModel.communityUpdatesEnabled) // FIX 4
                Divider().padding(.horizontal)
                SettingToggle(icon: "star.fill", title: "Achievement Alerts", isOn: $viewModel.achievementAlertsEnabled)
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "About", icon: "info.circle.fill")
            
            VStack(spacing: 0) {
                SettingRow(icon: "questionmark.circle.fill", title: "Help & Support") { }
                Divider().padding(.horizontal)
                SettingRow(icon: "lock.shield.fill", title: "Privacy Policy") { }
                Divider().padding(.horizontal)
                SettingRow(icon: "doc.text.fill", title: "Terms of Service") { }
                Divider().padding(.horizontal)
                SettingRow(icon: "sparkles", title: "About Leavn", value: "v1.0.0") {
                    showAbout = true
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    private var signOutButton: some View {
        Button(action: { showSignOutAlert = true }) {
            HStack {
                Spacer()
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Sign Out")
                Spacer()
            }
            .font(LeavnTheme.Typography.headline)
            .foregroundColor(.white)
            .padding()
            .background(LeavnTheme.Colors.error)
            .cornerRadius(16)
        }
    }
}


// MARK: - Supporting Views

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(LeavnTheme.Colors.accent)
            Text(title)
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.primary)
            Spacer()
        }
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text(value)
                .font(LeavnTheme.Typography.titleMedium)
                .fontWeight(.bold)
            Text(label)
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingRow: View {
    let icon: String
    let title: String
    var value: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 24)
                    .foregroundColor(LeavnTheme.Colors.accent)
                
                Text(title)
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if let value = value {
                    Text(value)
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary.opacity(0.5))
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        }
    }
}


struct SettingToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .frame(width: 24)
                    .foregroundColor(LeavnTheme.Colors.accent)
                
                Text(title)
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.primary)
            }
        }
        .tint(LeavnTheme.Colors.accent)
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}

struct ThemeOption: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(theme.rawValue)
                    .font(LeavnTheme.Typography.caption)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? LeavnTheme.Colors.accent.opacity(0.2) : Color(UIColor.tertiarySystemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}


// MARK: - About View (Sheet)

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showDeveloper = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Image("LeavnIcon") // Make sure this asset exists
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        
                        Text("Leavn")
                            .font(LeavnTheme.Typography.titleLarge)
                            .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                        
                        Text("Version 1.0.0 (Build 1)")
                            .font(LeavnTheme.Typography.body)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            FeatureRow(
                                icon: "icloud.fill",
                                title: "Sync Everywhere",
                                description: "Your data syncs across all devices",
                                color: LeavnTheme.Colors.success, delay: 0.1) // FIX 5
                            
                            FeatureRow(
                                icon: "person.2.fill",
                                title: "Community",
                                description: "Connect with fellow believers",
                                color: LeavnTheme.Colors.warning, delay: 0.2) // FIX 5
                                
                            FeatureRow(
                                icon: "book.fill",
                                title: "Multiple Translations",
                                description: "Access various Bible translations",
                                color: LeavnTheme.Colors.info, delay: 0.3) // FIX 5
                        }
                        .padding(.horizontal, 20)
                        
                        VStack(spacing: 8) {
                            Text("Made with ❤️ for the glory of God")
                                .font(LeavnTheme.Typography.body)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showDeveloper = true }) {
                                Text("By the Leavn Team")
                                    .font(LeavnTheme.Typography.caption)
                                    .foregroundColor(LeavnTheme.Colors.accent)
                            }
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .alert("Developer", isPresented: $showDeveloper) {
            Button("OK") {}
        } message: {
            Text("Developed with SwiftUI and love. Thank you for using Leavn!")
        }
    }
}

// Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
