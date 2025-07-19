import SwiftUI
import ComposableArchitecture

struct NotificationSettingsView: View {
    @Bindable var store: StoreOf<SettingsReducer>
    @State private var showingPermissionAlert = false
    
    var body: some View {
        Form {
            // Permission Status
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Notification Permission")
                            .font(.headline)
                        Text(store.notificationPermissionStatus)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if !store.hasNotificationPermission {
                        Button("Enable") {
                            store.send(.requestNotificationPermission)
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Daily Reminders
            Section("Daily Reminders") {
                Toggle("Daily Verse", isOn: $store.settings.notifications.dailyVerse)
                
                if store.settings.notifications.dailyVerse {
                    DatePicker(
                        "Time",
                        selection: $store.settings.notifications.dailyVerseTime,
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Toggle("Reading Reminder", isOn: $store.settings.notifications.readingReminder)
                
                if store.settings.notifications.readingReminder {
                    DatePicker(
                        "Time",
                        selection: $store.settings.notifications.readingReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    
                    Picker("Repeat", selection: $store.settings.notifications.readingReminderFrequency) {
                        Text("Daily").tag(ReminderFrequency.daily)
                        Text("Weekdays").tag(ReminderFrequency.weekdays)
                        Text("Custom").tag(ReminderFrequency.custom)
                    }
                    
                    if store.settings.notifications.readingReminderFrequency == .custom {
                        WeekdayPicker(selectedDays: $store.settings.notifications.customReminderDays)
                    }
                }
            }
            
            // Prayer Reminders
            Section("Prayer Reminders") {
                Toggle("Prayer Time Reminders", isOn: $store.settings.notifications.prayerReminders)
                
                if store.settings.notifications.prayerReminders {
                    ForEach(store.settings.notifications.prayerTimes) { prayerTime in
                        HStack {
                            Text(prayerTime.name)
                            Spacer()
                            DatePicker(
                                "",
                                selection: .constant(prayerTime.time),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                        }
                    }
                    
                    Button(action: { store.send(.addPrayerTime) }) {
                        Label("Add Prayer Time", systemImage: "plus.circle")
                    }
                }
                
                Toggle("Prayer Wall Updates", isOn: $store.settings.notifications.prayerWallUpdates)
            }
            
            // Reading Plan Notifications
            Section("Reading Plans") {
                Toggle("Plan Reminders", isOn: $store.settings.notifications.readingPlanReminders)
                
                Toggle("Streak Notifications", isOn: $store.settings.notifications.streakNotifications)
                
                if store.settings.notifications.streakNotifications {
                    Stepper(
                        "Notify after \(store.settings.notifications.streakThreshold) days",
                        value: $store.settings.notifications.streakThreshold,
                        in: 3...30
                    )
                }
                
                Toggle("Plan Completion", isOn: $store.settings.notifications.planCompletion)
            }
            
            // Community Notifications
            Section("Community") {
                Toggle("Group Updates", isOn: $store.settings.notifications.groupUpdates)
                
                Toggle("Prayer Responses", isOn: $store.settings.notifications.prayerResponses)
                
                Toggle("Mentions", isOn: $store.settings.notifications.mentions)
                
                Toggle("New Followers", isOn: $store.settings.notifications.newFollowers)
            }
            
            // Notification Style
            Section("Style") {
                Toggle("Show Preview", isOn: $store.settings.notifications.showPreview)
                
                Picker("Sound", selection: $store.settings.notifications.sound) {
                    ForEach(NotificationSound.allCases) { sound in
                        Text(sound.displayName).tag(sound)
                    }
                }
                
                if store.settings.notifications.sound != .none {
                    Button("Preview Sound") {
                        store.send(.previewNotificationSound)
                    }
                }
                
                Toggle("Vibration", isOn: $store.settings.notifications.vibration)
            }
            
            // Quiet Hours
            Section("Quiet Hours") {
                Toggle("Enable Quiet Hours", isOn: $store.settings.notifications.quietHoursEnabled)
                
                if store.settings.notifications.quietHoursEnabled {
                    DatePicker(
                        "Start",
                        selection: $store.settings.notifications.quietHoursStart,
                        displayedComponents: .hourAndMinute
                    )
                    
                    DatePicker(
                        "End",
                        selection: $store.settings.notifications.quietHoursEnd,
                        displayedComponents: .hourAndMinute
                    )
                    
                    Text("Notifications will be silenced during these hours")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Notification Permission Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable notifications in Settings to receive reminders and updates.")
        }
    }
}

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Weekday>
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Weekday.allCases) { day in
                WeekdayButton(
                    day: day,
                    isSelected: selectedDays.contains(day)
                ) {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                }
            }
        }
    }
}

struct WeekdayButton: View {
    let day: Weekday
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.initial)
                .font(.caption.bold())
                .foregroundColor(isSelected ? .white : .primary)
                .frame(width: 32, height: 32)
                .background(isSelected ? Color.leavnPrimary : Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}

// Enums
enum ReminderFrequency: String, CaseIterable {
    case daily = "Daily"
    case weekdays = "Weekdays"
    case custom = "Custom"
}

enum Weekday: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var initial: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

enum NotificationSound: String, CaseIterable, Identifiable {
    case none = "None"
    case default = "Default"
    case chime = "Chime"
    case bell = "Bell"
    case prayer = "Prayer Bell"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
}

struct PrayerTime: Identifiable {
    let id = UUID()
    var name: String
    var time: Date
}