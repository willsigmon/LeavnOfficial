import SwiftUI

struct NotificationCenterView: View {
    @State private var notifications: [NotificationItem] = [
        NotificationItem(id: "1", title: "New Prayer Request", message: "John needs prayer for healing", timestamp: Date(), isRead: false),
        NotificationItem(id: "2", title: "Group Invitation", message: "You've been invited to join Bible Study", timestamp: Date().addingTimeInterval(-3600), isRead: false),
        NotificationItem(id: "3", title: "New Comment", message: "Jane commented on your post", timestamp: Date().addingTimeInterval(-7200), isRead: true)
    ]
    
    var body: some View {
        List {
            ForEach(notifications) { notification in
                NotificationRow(notification: notification)
                    .onTapGesture {
                        markAsRead(notification)
                    }
            }
            .onDelete(perform: deleteNotifications)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Clear All") {
                    notifications.removeAll()
                }
            }
        }
    }
    
    func markAsRead(_ notification: NotificationItem) {
        if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
            notifications[index].isRead = true
        }
    }
    
    func deleteNotifications(at offsets: IndexSet) {
        notifications.remove(atOffsets: offsets)
    }
}

struct NotificationItem: Identifiable {
    let id: String
    let title: String
    let message: String
    let timestamp: Date
    var isRead: Bool
}

struct NotificationRow: View {
    let notification: NotificationItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundColor(notification.isRead ? .secondary : .primary)
                    
                    if !notification.isRead {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(notification.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        NotificationCenterView()
    }
}