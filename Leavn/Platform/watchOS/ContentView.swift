//
//  ContentView.swift
//  Leavn (watchOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataModel: WatchDataModel
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "square.grid.2x2")
                }
            
            BalanceView()
                .tabItem {
                    Label("Balance", systemImage: "chart.pie.fill")
                }
            
            RequestView()
                .tabItem {
                    Label("Request", systemImage: "plus.circle.fill")
                }
            
            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "clock.fill")
                }
        }
    }
}

struct DashboardView: View {
    @EnvironmentObject var dataModel: WatchDataModel
    @State private var showingDetails = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                // Header
                HStack {
                    Text("Leavn")
                        .font(.title3)
                        .bold()
                    Spacer()
                    Image(systemName: "person.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                
                // Quick Stats
                HStack(spacing: 15) {
                    QuickStatView(
                        value: "\(dataModel.leaveBalance.annual.available)",
                        label: "Available",
                        color: .green
                    )
                    
                    QuickStatView(
                        value: "\(dataModel.upcomingLeave.count)",
                        label: "Upcoming",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                // Upcoming Leave
                if !dataModel.upcomingLeave.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Next Leave")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(dataModel.upcomingLeave.prefix(2)) { leave in
                            UpcomingLeaveRow(leave: leave)
                                .onTapGesture {
                                    showingDetails = true
                                }
                        }
                    }
                }
                
                // Recent Activity
                if !dataModel.recentActivity.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ForEach(dataModel.recentActivity.prefix(3)) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await dataModel.refresh()
        }
        .sheet(isPresented: $showingDetails) {
            LeaveDetailsView()
        }
    }
}

struct QuickStatView: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .bold()
                .foregroundColor(color)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(10)
    }
}

struct UpcomingLeaveRow: View {
    let leave: UpcomingLeave
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color.blue)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(leave.type)
                    .font(.footnote)
                    .bold()
                
                Text(leave.startDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(leave.days)d")
                .font(.caption)
                .foregroundColor(.blue)
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: activity.icon)
                .font(.caption)
                .foregroundColor(activity.color)
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(activity.description)
                    .font(.caption2)
                    .lineLimit(1)
                
                Text(activity.date, style: .relative)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}

struct BalanceView: View {
    @EnvironmentObject var dataModel: WatchDataModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Leave Balance")
                    .font(.title3)
                    .bold()
                    .padding(.bottom, 5)
                
                BalanceCardView(
                    title: "Annual",
                    balance: dataModel.leaveBalance.annual,
                    color: .blue
                )
                
                BalanceCardView(
                    title: "Sick",
                    balance: dataModel.leaveBalance.sick,
                    color: .orange
                )
                
                BalanceCardView(
                    title: "Personal",
                    balance: dataModel.leaveBalance.personal,
                    color: .purple
                )
            }
            .padding()
        }
    }
}

struct BalanceCardView: View {
    let title: String
    let balance: Balance
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("\(balance.available)")
                    .font(.title3)
                    .bold()
                    .foregroundColor(color)
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geometry.size.width * balance.percentage, height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Used: \(balance.used)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Total: \(balance.total)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}

struct RequestView: View {
    @State private var selectedType = "Annual"
    @State private var startDate = Date()
    @State private var numberOfDays = 1
    @State private var showingConfirmation = false
    
    let leaveTypes = ["Annual", "Sick", "Personal"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("New Request")
                    .font(.title3)
                    .bold()
                
                // Leave Type
                VStack(alignment: .leading, spacing: 5) {
                    Text("Type")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Leave Type", selection: $selectedType) {
                        ForEach(leaveTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.automatic)
                }
                
                // Start Date
                VStack(alignment: .leading, spacing: 5) {
                    Text("Start Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .labelsHidden()
                }
                
                // Number of Days
                VStack(alignment: .leading, spacing: 5) {
                    Text("Days: \(numberOfDays)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper("", value: $numberOfDays, in: 1...30)
                        .labelsHidden()
                }
                
                Button(action: {
                    showingConfirmation = true
                }) {
                    Text("Submit Request")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
            }
            .padding()
        }
        .alert("Request Submitted", isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text("Your \(selectedType.lowercased()) leave request for \(numberOfDays) day(s) has been submitted.")
        }
    }
}

struct ActivityView: View {
    @EnvironmentObject var dataModel: WatchDataModel
    
    var body: some View {
        List {
            Section {
                ForEach(dataModel.recentActivity) { activity in
                    HStack(spacing: 10) {
                        Image(systemName: activity.icon)
                            .foregroundColor(activity.color)
                            .frame(width: 25)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(activity.description)
                                .font(.footnote)
                            
                            Text(activity.date, style: .relative)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            } header: {
                Text("Recent Activity")
            }
        }
        .navigationTitle("Activity")
    }
}

struct LeaveDetailsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Leave Details")
                        .font(.headline)
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
                
                DetailRow(label: "Type", value: "Annual Leave")
                DetailRow(label: "Start", value: "July 20, 2025")
                DetailRow(label: "End", value: "July 22, 2025")
                DetailRow(label: "Duration", value: "3 days")
                DetailRow(label: "Status", value: "Approved", color: .green)
            }
            .padding()
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.footnote)
                .bold()
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}