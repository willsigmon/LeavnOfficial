//
//  ContentView.swift
//  Leavn (visionOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var showingNewRequest = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedTab: $selectedTab)
                .navigationTitle("Leavn")
        } detail: {
            DetailContainerView(selectedTab: selectedTab)
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            HStack(spacing: 20) {
                Button(action: { showingNewRequest = true }) {
                    Label("New Request", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                
                Toggle("3D View", isOn: $appModel.is3DMode)
                    .toggleStyle(.button)
                    .buttonStyle(.bordered)
                    .buttonBorderShape(.capsule)
                    .onChange(of: appModel.is3DMode) { _, newValue in
                        Task {
                            if newValue {
                                await openImmersiveSpace(id: "LeaveCalendarSpace")
                            } else {
                                await dismissImmersiveSpace()
                            }
                        }
                    }
            }
            .padding()
            .glassBackgroundEffect()
        }
        .sheet(isPresented: $showingNewRequest) {
            NewRequestView()
                .frame(width: 600, height: 500)
        }
    }
}

struct SidebarView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        List {
            NavigationLink(tag: 0, selection: $selectedTab) {
                Label("Dashboard", systemImage: "square.grid.3x3.fill")
            } destination: {
                DashboardView()
            }
            
            NavigationLink(tag: 1, selection: $selectedTab) {
                Label("Calendar", systemImage: "calendar")
            } destination: {
                CalendarView()
            }
            
            NavigationLink(tag: 2, selection: $selectedTab) {
                Label("My Requests", systemImage: "doc.text.fill")
            } destination: {
                MyRequestsView()
            }
            
            NavigationLink(tag: 3, selection: $selectedTab) {
                Label("Team", systemImage: "person.3.fill")
            } destination: {
                TeamView()
            }
            
            NavigationLink(tag: 4, selection: $selectedTab) {
                Label("Analytics", systemImage: "chart.pie.fill")
            } destination: {
                AnalyticsView()
            }
        }
        .navigationTitle("Menu")
    }
}

struct DetailContainerView: View {
    let selectedTab: Int
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                DashboardView()
            case 1:
                CalendarView()
            case 2:
                MyRequestsView()
            case 3:
                TeamView()
            case 4:
                AnalyticsView()
            default:
                DashboardView()
            }
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 30) {
                Text("Dashboard")
                    .font(.extraLargeTitle)
                    .bold()
                
                // Stats Cards
                HStack(spacing: 20) {
                    StatCard3D(
                        title: "Available Days",
                        value: "15",
                        icon: "calendar.badge.plus",
                        color: .green
                    )
                    
                    StatCard3D(
                        title: "Pending",
                        value: "2",
                        icon: "clock.fill",
                        color: .orange
                    )
                    
                    StatCard3D(
                        title: "Used Days",
                        value: "10",
                        icon: "checkmark.circle.fill",
                        color: .blue
                    )
                }
                
                // Recent Activity
                VStack(alignment: .leading, spacing: 15) {
                    Text("Recent Activity")
                        .font(.title)
                        .bold()
                    
                    ForEach(appModel.leaveRequests) { request in
                        LeaveRequestCard(request: request)
                    }
                }
                
                Spacer()
            }
            .padding(40)
        }
    }
}

struct StatCard3D: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundStyle(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        .padding(25)
        .frame(maxWidth: .infinity)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: isHovered ? 15 : 5)
        .scaleEffect(isHovered ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct LeaveRequestCard: View {
    let request: LeaveRequest
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Circle()
                .fill(request.type.color)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(request.type.name)
                    .font(.headline)
                
                Text(formatDateRange(start: request.startDate, end: request.endDate))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: request.status.icon)
                .font(.title2)
                .foregroundStyle(statusColor(for: request.status))
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: isHovered ? 8 : 2)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    func formatDateRange(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if Calendar.current.isDate(start, inSameDayAs: end) {
            return formatter.string(from: start)
        } else {
            return "\(formatter.string(from: start)) - \(formatter.string(from: end))"
        }
    }
    
    func statusColor(for status: LeaveRequest.RequestStatus) -> Color {
        switch status {
        case .pending: return .orange
        case .approved: return .green
        case .rejected: return .red
        }
    }
}

struct CalendarView: View {
    @EnvironmentObject var appModel: AppModel
    
    var body: some View {
        VStack {
            Text("Calendar View")
                .font(.extraLargeTitle)
                .padding()
            
            Text("Enable 3D View to see immersive calendar")
                .font(.title2)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MyRequestsView: View {
    var body: some View {
        VStack {
            Text("My Requests")
                .font(.extraLargeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct TeamView: View {
    var body: some View {
        VStack {
            Text("Team View")
                .font(.extraLargeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct AnalyticsView: View {
    var body: some View {
        VStack {
            Text("Analytics")
                .font(.extraLargeTitle)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct NewRequestView: View {
    @Environment(\.dismiss) var dismiss
    @State private var leaveType = "Annual Leave"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var reason = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Leave Details") {
                    Picker("Leave Type", selection: $leaveType) {
                        Text("Annual Leave").tag("Annual Leave")
                        Text("Sick Leave").tag("Sick Leave")
                        Text("Personal Leave").tag("Personal Leave")
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
                
                Section("Additional Information") {
                    TextField("Reason", text: $reason, axis: .vertical)
                        .lineLimit(4...6)
                }
            }
            .navigationTitle("New Leave Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        // Submit logic
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
    }
}