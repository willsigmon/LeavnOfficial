import SwiftUI
import LeavnCore
import LeavnServices
import DesignSystem

public struct NotificationCenterView: View {
    @StateObject private var notificationService = NotificationService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showClearAllAlert = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Background
                LeavnTheme.Colors.darkBackground.ignoresSafeArea()
                
                if notificationService.notifications.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(notificationService.notifications) { notification in
                                NotificationRow(notification: notification) {
                                    handleNotificationTap(notification)
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !notificationService.notifications.isEmpty {
                        Menu {
                            Button(action: {
                                notificationService.markAllAsRead()
                            }) {
                                Label("Mark All Read", systemImage: "checkmark.circle")
                            }
                            
                            Button(role: .destructive, action: {
                                showClearAllAlert = true
                            }) {
                                Label("Clear All", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                    }
                }
            }
            .alert("Clear All Notifications", isPresented: $showClearAllAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Clear All", role: .destructive) {
                    notificationService.clearAll()
                }
            } message: {
                Text("Are you sure you want to clear all notifications?")
            }
        }
    }
    
    private var emptyState: some View {
        PlayfulEmptyState(
            icon: "bell.slash",
            title: "No Notifications",
            message: "When you receive notifications, they'll appear here",
            buttonTitle: "Got it",
            action: { dismiss() }
        )
    }
    
    private func handleNotificationTap(_ notification: AppNotification) {
        notificationService.markAsRead(notification.id)
        
        // Navigate based on notification type
        switch notification.type {
        case .newReply, .newLike:
            if let postId = notification.postId {
                // Navigate to post
                NotificationCenter.default.post(
                    name: .navigateToPost,
                    object: nil,
                    userInfo: ["postId": postId]
                )
            }
        case .newFollower:
            if let userId = notification.userId {
                // Navigate to user profile
                NotificationCenter.default.post(
                    name: .navigateToProfile,
                    object: nil,
                    userInfo: ["userId": userId]
                )
            }
        case .groupInvite:
            // Navigate to groups
            NotificationCenter.default.post(name: .navigateToGroups, object: nil)
        }
        
        dismiss()
    }
}

// MARK: - Notification Row
struct NotificationRow: View {
    let notification: AppNotification
    let onTap: () -> Void
    
    @State private var appear = false
    
    private var icon: String {
        switch notification.type {
        case .newReply: return "bubble.left.fill"
        case .newLike: return "heart.fill"
        case .newFollower: return "person.badge.plus.fill"
        case .groupInvite: return "person.3.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.type {
        case .newReply: return LeavnTheme.Colors.info
        case .newLike: return LeavnTheme.Colors.error
        case .newFollower: return LeavnTheme.Colors.success
        case .groupInvite: return LeavnTheme.Colors.warning
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconColor)
                }
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(LeavnTheme.Typography.titleMedium)
                        .foregroundColor(.primary)
                    
                    Text(notification.body)
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    Text(notification.timestamp, style: .relative)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(LeavnTheme.Colors.accent)
                        .frame(width: 8, height: 8)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(notification.isRead ?
                          LeavnTheme.Colors.darkSecondary :
                          LeavnTheme.Colors.darkSecondary.opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(!notification.isRead ? 
                                   LeavnTheme.Colors.accent.opacity(0.3) : 
                                   Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            LeavnTheme.Motion.smoothSpring,
            value: appear
        )
        .onAppear {
            appear = true
        }
    }
}


