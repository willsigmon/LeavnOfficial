import SwiftUI
import ComposableArchitecture

struct LibraryStatsView: View {
    @Bindable var store: StoreOf<LibraryReducer>
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "book.fill",
                value: "\(store.totalVersesRead)",
                label: "Verses Read",
                color: .blue
            )
            
            StatCard(
                icon: "flame.fill",
                value: "\(store.currentStreak)",
                label: "Day Streak",
                color: .orange
            )
            
            StatCard(
                icon: "clock.fill",
                value: formatTime(store.totalReadingTime),
                label: "Total Time",
                color: .green
            )
        }
    }
    
    private func formatTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)m"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        }
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}