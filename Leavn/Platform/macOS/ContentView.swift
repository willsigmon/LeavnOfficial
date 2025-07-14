//
//  ContentView.swift
//  Leavn (macOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedView: SidebarItem? = .dashboard
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selectedView)
        } detail: {
            DetailView(selectedItem: selectedView)
        }
        .navigationTitle("Leavn")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { appState.showNewLeaveRequest = true }) {
                    Label("New Request", systemImage: "plus.circle.fill")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            ToolbarItem(placement: .automatic) {
                Button(action: { appState.syncData() }) {
                    Label("Sync", systemImage: "arrow.clockwise")
                }
                .disabled(appState.isSyncing)
                .animation(.easeInOut, value: appState.isSyncing)
            }
        }
        .sheet(isPresented: $appState.showNewLeaveRequest) {
            NewLeaveRequestView()
                .frame(width: 600, height: 500)
        }
        .sheet(isPresented: $appState.showLeaveBalance) {
            LeaveBalanceView()
                .frame(width: 500, height: 400)
        }
    }
}

enum SidebarItem: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case myRequests = "My Requests"
    case calendar = "Calendar"
    case team = "Team"
    case reports = "Reports"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .dashboard: return "square.grid.2x2"
        case .myRequests: return "doc.text"
        case .calendar: return "calendar"
        case .team: return "person.2"
        case .reports: return "chart.bar"
        }
    }
}

struct SidebarView: View {
    @Binding var selection: SidebarItem?
    
    var body: some View {
        List(SidebarItem.allCases, selection: $selection) { item in
            Label(item.rawValue, systemImage: item.iconName)
                .tag(item)
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
}

struct DetailView: View {
    let selectedItem: SidebarItem?
    
    var body: some View {
        Group {
            switch selectedItem {
            case .dashboard:
                DashboardView()
            case .myRequests:
                MyRequestsView()
            case .calendar:
                CalendarView()
            case .team:
                TeamView()
            case .reports:
                ReportsView()
            case .none:
                Text("Select an item from the sidebar")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Dashboard")
                    .font(.largeTitle)
                    .bold()
                
                HStack(spacing: 20) {
                    StatCard(title: "Available Days", value: "15", color: .green)
                    StatCard(title: "Pending Requests", value: "2", color: .orange)
                    StatCard(title: "Used Days", value: "10", color: .blue)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Recent Activity")
                        .font(.headline)
                    
                    ForEach(0..<5) { index in
                        ActivityRow(index: index)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}

struct ActivityRow: View {
    let index: Int
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            Text("Leave request \(index + 1) approved")
            Spacer()
            Text("2 days ago")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 5)
    }
}

struct MyRequestsView: View {
    var body: some View {
        VStack {
            Text("My Requests")
                .font(.largeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct CalendarView: View {
    var body: some View {
        VStack {
            Text("Calendar")
                .font(.largeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct TeamView: View {
    var body: some View {
        VStack {
            Text("Team")
                .font(.largeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct ReportsView: View {
    var body: some View {
        VStack {
            Text("Reports")
                .font(.largeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct NewLeaveRequestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var leaveType = "Annual Leave"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("New Leave Request")
                .font(.title)
                .bold()
            
            Form {
                Picker("Leave Type", selection: $leaveType) {
                    Text("Annual Leave").tag("Annual Leave")
                    Text("Sick Leave").tag("Sick Leave")
                    Text("Personal Leave").tag("Personal Leave")
                }
                
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                
                VStack(alignment: .leading) {
                    Text("Reason")
                    TextEditor(text: $reason)
                        .frame(height: 100)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Submit") {
                    // Submit logic
                    dismiss()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .padding()
    }
}

struct LeaveBalanceView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Leave Balance")
                .font(.title)
                .bold()
            
            VStack(spacing: 15) {
                BalanceRow(type: "Annual Leave", available: 15, used: 10, total: 25)
                BalanceRow(type: "Sick Leave", available: 5, used: 2, total: 7)
                BalanceRow(type: "Personal Leave", available: 3, used: 0, total: 3)
            }
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
    }
}

struct BalanceRow: View {
    let type: String
    let available: Int
    let used: Int
    let total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(type)
                .font(.headline)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * CGFloat(used) / CGFloat(total), height: 20)
                }
            }
            .frame(height: 20)
            
            HStack {
                Text("Used: \(used)")
                Spacer()
                Text("Available: \(available)")
                Spacer()
                Text("Total: \(total)")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(10)
    }
}