//
//  LeavnApp.swift
//  Leavn (watchOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI

@main
struct LeavnApp: App {
    @StateObject private var dataModel = WatchDataModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                ContentView()
            }
            .environmentObject(dataModel)
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "leaveUpdate")
    }
}

// Data Model for watchOS
class WatchDataModel: ObservableObject {
    @Published var leaveBalance: LeaveBalance
    @Published var upcomingLeave: [UpcomingLeave] = []
    @Published var recentActivity: [Activity] = []
    @Published var isLoading = false
    
    init() {
        // Initialize with sample data
        self.leaveBalance = LeaveBalance(
            annual: Balance(available: 15, used: 10, total: 25),
            sick: Balance(available: 5, used: 2, total: 7),
            personal: Balance(available: 3, used: 0, total: 3)
        )
        
        loadUpcomingLeave()
        loadRecentActivity()
    }
    
    func loadUpcomingLeave() {
        upcomingLeave = [
            UpcomingLeave(id: UUID(), type: "Annual", startDate: Date().addingTimeInterval(86400 * 7), days: 3),
            UpcomingLeave(id: UUID(), type: "Personal", startDate: Date().addingTimeInterval(86400 * 14), days: 1)
        ]
    }
    
    func loadRecentActivity() {
        recentActivity = [
            Activity(id: UUID(), description: "Annual leave approved", date: Date().addingTimeInterval(-86400), icon: "checkmark.circle.fill", color: .green),
            Activity(id: UUID(), description: "New leave request", date: Date().addingTimeInterval(-86400 * 2), icon: "doc.text.fill", color: .blue),
            Activity(id: UUID(), description: "Team member on leave", date: Date().addingTimeInterval(-86400 * 3), icon: "person.fill", color: .orange)
        ]
    }
    
    func refresh() async {
        isLoading = true
        // Simulate network request
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        loadUpcomingLeave()
        loadRecentActivity()
        isLoading = false
    }
}

struct LeaveBalance {
    let annual: Balance
    let sick: Balance
    let personal: Balance
}

struct Balance {
    let available: Int
    let used: Int
    let total: Int
    
    var percentage: Double {
        Double(used) / Double(total)
    }
}

struct UpcomingLeave: Identifiable {
    let id: UUID
    let type: String
    let startDate: Date
    let days: Int
}

struct Activity: Identifiable {
    let id: UUID
    let description: String
    let date: Date
    let icon: String
    let color: Color
}

// Notification Controller
class NotificationController: WKUserNotificationHostingController<NotificationView> {
    override var body: NotificationView {
        NotificationView()
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

struct NotificationView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Leave Update")
                .font(.headline)
                .foregroundColor(.blue)
            
            Text("Your annual leave request has been approved!")
                .font(.caption)
            
            Text("Starting: Tomorrow")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}