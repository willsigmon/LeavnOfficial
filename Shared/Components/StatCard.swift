import SwiftUI

/// A reusable statistics card component for dashboards
/// Displays a metric with an icon, value, and trend indicator
public struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let trend: Trend?
    let accentColor: Color
    
    public enum Trend {
        case up(Double)
        case down(Double)
        case neutral
        
        var icon: String {
            switch self {
            case .up:
                return "arrow.up.right"
            case .down:
                return "arrow.down.right"
            case .neutral:
                return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up:
                return .green
            case .down:
                return .red
            case .neutral:
                return .gray
            }
        }
        
        var text: String {
            switch self {
            case .up(let value):
                return "+\(Int(value))%"
            case .down(let value):
                return "-\(Int(value))%"
            case .neutral:
                return "0%"
            }
        }
    }
    
    public init(
        title: String,
        value: String,
        icon: String,
        trend: Trend? = nil,
        accentColor: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.trend = trend
        self.accentColor = accentColor
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon and title
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(accentColor)
                    .frame(width: 40, height: 40)
                    .background(accentColor.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
                
                if let trend = trend {
                    HStack(spacing: 4) {
                        Image(systemName: trend.icon)
                            .font(.caption)
                        Text(trend.text)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(trend.color)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

/// A variant of StatCard optimized for compact spaces
public struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let accentColor: Color
    
    public init(
        title: String,
        value: String,
        icon: String,
        accentColor: Color = .blue
    ) {
        self.title = title
        self.value = value
        self.icon = icon
        self.accentColor = accentColor
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(accentColor)
                .frame(width: 36, height: 36)
                .background(accentColor.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Preview
struct StatCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(
                    title: "Total Employees",
                    value: "142",
                    icon: "person.3.fill",
                    trend: .up(12),
                    accentColor: .blue
                )
                
                StatCard(
                    title: "On Leave",
                    value: "8",
                    icon: "airplane",
                    trend: .down(5),
                    accentColor: .orange
                )
            }
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Pending Requests",
                    value: "23",
                    icon: "clock.fill",
                    trend: .neutral,
                    accentColor: .purple
                )
                
                StatCard(
                    title: "Leave Balance",
                    value: "18.5 days",
                    icon: "calendar",
                    accentColor: .green
                )
            }
            
            // Compact variants
            VStack(spacing: 8) {
                CompactStatCard(
                    title: "Team Size",
                    value: "12",
                    icon: "person.2.fill",
                    accentColor: .indigo
                )
                
                CompactStatCard(
                    title: "Available Today",
                    value: "10",
                    icon: "checkmark.circle.fill",
                    accentColor: .green
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
}