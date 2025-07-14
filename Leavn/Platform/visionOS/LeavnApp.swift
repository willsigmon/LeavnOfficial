//
//  LeavnApp.swift
//  Leavn (visionOS)
//
//  Created by Leavn on 2025-07-13.
//

import SwiftUI

@main
struct LeavnApp: App {
    @StateObject private var appModel = AppModel()
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 0.8, depth: 0.5, in: .meters)
        
        ImmersiveSpace(id: "LeaveCalendarSpace") {
            ImmersiveCalendarView()
                .environmentObject(appModel)
        }
        .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
    }
}

// App Model for visionOS
class AppModel: ObservableObject {
    @Published var showImmersiveSpace = false
    @Published var selectedDate = Date()
    @Published var leaveRequests: [LeaveRequest] = []
    @Published var is3DMode = false
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        // Sample leave requests
        leaveRequests = [
            LeaveRequest(id: UUID(), type: .annual, startDate: Date(), endDate: Date().addingTimeInterval(86400 * 3), status: .approved),
            LeaveRequest(id: UUID(), type: .sick, startDate: Date().addingTimeInterval(86400 * 7), endDate: Date().addingTimeInterval(86400 * 8), status: .pending),
            LeaveRequest(id: UUID(), type: .personal, startDate: Date().addingTimeInterval(86400 * 14), endDate: Date().addingTimeInterval(86400 * 14), status: .pending)
        ]
    }
    
    func toggleImmersiveSpace() {
        showImmersiveSpace.toggle()
    }
}

struct LeaveRequest: Identifiable {
    let id: UUID
    let type: LeaveType
    let startDate: Date
    let endDate: Date
    let status: RequestStatus
    
    enum LeaveType {
        case annual, sick, personal
        
        var color: Color {
            switch self {
            case .annual: return .blue
            case .sick: return .orange
            case .personal: return .purple
            }
        }
        
        var name: String {
            switch self {
            case .annual: return "Annual Leave"
            case .sick: return "Sick Leave"
            case .personal: return "Personal Leave"
            }
        }
    }
    
    enum RequestStatus {
        case pending, approved, rejected
        
        var icon: String {
            switch self {
            case .pending: return "clock.fill"
            case .approved: return "checkmark.circle.fill"
            case .rejected: return "xmark.circle.fill"
            }
        }
    }
}

struct ImmersiveCalendarView: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        RealityKitCalendarView()
            .gesture(
                TapGesture()
                    .onEnded { _ in
                        openWindow(id: "main")
                    }
            )
    }
}

struct RealityKitCalendarView: View {
    var body: some View {
        // Placeholder for RealityKit 3D calendar
        // In a real implementation, this would use RealityKit to create
        // a 3D calendar with interactive leave request visualization
        ZStack {
            Color.clear
            
            VStack {
                Text("3D Calendar View")
                    .font(.extraLargeTitle)
                    .foregroundStyle(.white)
                    .padding()
                    .glassBackgroundEffect()
                
                Text("Tap anywhere to return")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}