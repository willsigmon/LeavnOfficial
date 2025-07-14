import SwiftUI

import UserNotifications
import CoreLocation
import AppTrackingTransparency

public struct PermissionsView: View {
    @State private var notificationsEnabled = false
    @State private var locationEnabled = false
    @State private var trackingEnabled = false
    @State private var remindersEnabled = false
    @State private var allPermissionsHandled = false
    
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Header
            VStack(spacing: 16) {
                Image(systemName: "shield")
                    .font(.system(size: 60))
                    .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                    .symbolRenderingMode(.hierarchical)
                
                Text("Personalize Your Experience")
                    .font(LeavnTheme.Typography.displayMedium)
                    .multilineTextAlignment(.center)
                
                Text("Enable features to get the most out of Leavn")
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)
                
                // Permissions list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(PermissionType.allCases, id: \.self) { permission in
                            PermissionCard(
                                permission: permission,
                                isEnabled: binding(for: permission),
                                onToggle: { requestPermission(for: permission) }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 32)
                }
                
            Spacer()
            
            // Continue button
            VStack(spacing: 20) {
                ThemedButton("Continue", style: .primary) {
                    onComplete()
                }
                .frame(height: 48)
                .padding(.horizontal, 24)
                
                Button("Skip for now") {
                    onComplete()
                }
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
                
                HStack(spacing: 4) {
                    Text("\(enabledPermissionsCount) of \(PermissionType.allCases.count) features enabled")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    
                    if enabledPermissionsCount > 0 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(LeavnTheme.Colors.success)
                            .font(.caption)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AnimatedGradientBackground().ignoresSafeArea())
    }
    
    private var enabledPermissionsCount: Int {
        var count = 0
        if notificationsEnabled { count += 1 }
        if locationEnabled { count += 1 }
        if trackingEnabled { count += 1 }
        if remindersEnabled { count += 1 }
        return count
    }
    
    private func binding(for permission: PermissionType) -> Binding<Bool> {
        switch permission {
        case .notifications:
            return $notificationsEnabled
        case .location:
            return $locationEnabled
        case .tracking:
            return $trackingEnabled
        case .reminders:
            return $remindersEnabled
        }
    }
    
    private func requestPermission(for permission: PermissionType) {
        switch permission {
        case .notifications:
            requestNotificationPermission()
        case .location:
            requestLocationPermission()
        case .tracking:
            requestTrackingPermission()
        case .reminders:
            // Reminders use the same permission as notifications
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                self.remindersEnabled = granted
            }
        }
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        // Note: In a real app, you'd use a delegate to track the actual permission status
        DispatchQueue.main.async {
            self.locationEnabled = true
        }
    }
    
    private func requestTrackingPermission() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                self.trackingEnabled = status == .authorized
            }
        }
    }
}

// MARK: - Permission Card Component
struct PermissionCard: View {
    let permission: PermissionType
    @Binding var isEnabled: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with gradient background
            ZStack {
                LinearGradient(
                    colors: permission.gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(width: min(56, UIScreen.main.bounds.width * 0.15), height: min(56, UIScreen.main.bounds.width * 0.15))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Image(systemName: permission.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(permission.title)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(permission.description)
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Toggle
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: LeavnTheme.Colors.accent))
                .onChange(of: isEnabled) { _, newValue in
                    if newValue {
                        onToggle()
                    }
                }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}