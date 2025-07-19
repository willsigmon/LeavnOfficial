import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color
    let value: String?
    let badge: Int?
    
    init(
        icon: String,
        title: String,
        color: Color,
        value: String? = nil,
        badge: Int? = nil
    ) {
        self.icon = icon
        self.title = title
        self.color = color
        self.value = value
        self.badge = badge
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(color)
                .cornerRadius(6)
            
            // Title
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            // Value or Badge
            if let value = value {
                Text(value)
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            
            if let badge = badge, badge > 0 {
                Text("\(badge)")
                    .font(.caption.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 2)
    }
}

struct AccountRow: View {
    @Bindable var store: StoreOf<SettingsReducer>
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            if let avatarURL = store.userAvatarURL {
                AsyncImage(url: avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                ZStack {
                    Circle()
                        .fill(Color.leavnPrimary.opacity(0.2))
                    
                    Text(store.userInitials)
                        .font(.title3.bold())
                        .foregroundColor(.leavnPrimary)
                }
                .frame(width: 60, height: 60)
            }
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(store.userName ?? "Guest User")
                    .font(.headline)
                
                Text(store.userEmail ?? "Sign in to sync your data")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let plan = store.subscriptionPlan {
                    HStack(spacing: 4) {
                        Image(systemName: "crown.fill")
                            .font(.caption2)
                        Text(plan)
                            .font(.caption2.bold())
                    }
                    .foregroundColor(.leavnPrimary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.tertiaryLabel)
        }
        .padding(.vertical, 8)
    }
}