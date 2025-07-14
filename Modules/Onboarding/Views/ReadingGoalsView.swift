import SwiftUI

struct ReadingGoalsView: View {
    @Binding var selectedGoal: ReadingGoal?
    @Binding var notificationTime: NotificationTime?
    
    @State private var showTimeSelector = false
    @State private var selectedTime = Date()
    @State private var animateGoals = false
    @State private var pulseAnimation = false
    
    private let goals: [(ReadingGoal, icon: String, description: String, timeEstimate: String)] = [
        (.daily, "sun.max.fill", "Build a daily habit with one chapter", "5-10 min/day"),
        (.weekly, "calendar.badge.plus", "Complete a book each week", "20-30 min/day"),
        (.monthly, "star.fill", "Focus on monthly themes", "15-20 min/day"),
        (.yearly, "crown.fill", "Read the entire Bible in a year", "15-20 min/day"),
        (.custom, "sparkles", "Create your own reading rhythm", "You decide")
    ]
    
    private let notificationTimes = [
        NotificationTime(hour: 6, minute: 0, label: "Early Morning"),
        NotificationTime(hour: 8, minute: 0, label: "Morning"),
        NotificationTime(hour: 12, minute: 0, label: "Lunch"),
        NotificationTime(hour: 18, minute: 0, label: "Evening"),
        NotificationTime(hour: 21, minute: 0, label: "Before Bed")
    ]
    
    var body: some View {
        VStack(spacing: 24) {
            // Enhanced Header
            VStack(spacing: 20) {
                ZStack {
                    // Animated background
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        LeavnTheme.Colors.accent.opacity(0.3 - Double(index) * 0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 50
                                )
                            )
                            .frame(width: 100 + CGFloat(index) * 40, height: 100 + CGFloat(index) * 40)
                            .scaleEffect(pulseAnimation ? 1.1 : 0.9)
                            .animation(
                                .easeInOut(duration: 2.0 + Double(index) * 0.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                                value: pulseAnimation
                            )
                    }
                    
                    Image(systemName: "target")
                        .font(.system(size: 60))
                        .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(animateGoals ? 1.0 : 0.8)
                }
                .frame(height: 120)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateGoals)
                
                Text("Set Your Reading Goal")
                    .font(LeavnTheme.Typography.displayMedium)
                    .multilineTextAlignment(.center)
                
                Text("Start small and build momentum. You can always adjust later!")
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Progress visualization
                HStack(spacing: 16) {
                    ForEach(["🌱", "🌿", "🌳"], id: \.self) { emoji in
                        VStack(spacing: 4) {
                            Text(emoji)
                                .font(.title2)
                            Text(emoji == "🌱" ? "Start" : emoji == "🌿" ? "Grow" : "Thrive")
                                .font(LeavnTheme.Typography.micro)
                                .foregroundColor(.secondary)
                        }
                        .opacity(animateGoals ? 1 : 0)
                        .offset(y: animateGoals ? 0 : 10)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(emoji == "🌱" ? 0.2 : emoji == "🌿" ? 0.4 : 0.6),
                            value: animateGoals
                        )
                    }
                }
            }
            
            // Reading Goals
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(goals, id: \.0) { goal, icon, description, timeEstimate in
                        ReadingGoalCard(
                            goal: goal,
                            icon: icon,
                            description: description,
                            timeEstimate: timeEstimate,
                            isSelected: selectedGoal == goal,
                            animationDelay: Double(goals.firstIndex(where: { $0.0 == goal }) ?? 0) * 0.1,
                            onTap: {
                                selectGoal(goal)
                            }
                        )
                    }
                    
                    // Notification Time Section
                    if selectedGoal != nil {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(LeavnTheme.Colors.accent)
                                Text("DAILY REMINDER")
                                    .font(LeavnTheme.Typography.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.top, 8)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(notificationTimes, id: \.hour) { time in
                                        TimeChip(
                                            time: time,
                                            isSelected: notificationTime?.hour == time.hour,
                                            onTap: {
                                                selectNotificationTime(time)
                                            }
                                        )
                                    }
                                    
                                    // Custom time option
                                    Button(action: { showTimeSelector = true }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "clock")
                                            Text("Custom")
                                        }
                                        .font(LeavnTheme.Typography.headline)
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(.systemGray5))
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.top, 8)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
            
            // Motivational quote
            if selectedGoal != nil {
                VStack(spacing: 8) {
                    Text("\"Your word is a lamp for my feet, a light on my path.\"")
                        .font(LeavnTheme.Typography.body)
                        .italic()
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    Text("Psalm 119:105")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 40)
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                animateGoals = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                pulseAnimation = true
            }
        }
        .sheet(isPresented: $showTimeSelector) {
            TimePickerSheet(
                selectedTime: $selectedTime,
                onSave: { time in
                    let components = Calendar.current.dateComponents([.hour, .minute], from: time)
                    notificationTime = NotificationTime(
                        hour: components.hour ?? 8,
                        minute: components.minute ?? 0,
                        label: "Custom Time"
                    )
                }
            )
        }
    }
    
    private func selectGoal(_ goal: ReadingGoal) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedGoal = goal
            
            // Auto-select a default notification time
            if notificationTime == nil {
                notificationTime = notificationTimes[1] // Default to morning
            }
        }
    }
    
    private func selectNotificationTime(_ time: NotificationTime) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            notificationTime = time
        }
    }
}

// MARK: - Reading Goal Card
struct ReadingGoalCard: View {
    let goal: ReadingGoal
    let icon: String
    let description: String
    let timeEstimate: String
    let isSelected: Bool
    let animationDelay: Double
    let onTap: () -> Void
    
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(isSelected ? LeavnTheme.Colors.accent : Color(.systemGray5))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? .white : .primary)
                    .symbolRenderingMode(.hierarchical)
            }
            .scaleEffect(isSelected ? 1.1 : 1.0)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.rawValue)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(timeEstimate)
                        .font(LeavnTheme.Typography.micro)
                }
                .foregroundColor(LeavnTheme.Colors.accent)
            }
            
            Spacer()
            
            // Selection indicator
            ZStack {
                Circle()
                    .stroke(isSelected ? LeavnTheme.Colors.accent : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(LeavnTheme.Colors.accent)
                        .frame(width: 16, height: 16)
                        .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isSelected ? LeavnTheme.Colors.accent.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
        .scaleEffect(appeared ? 1.0 : 0.9)
        .opacity(appeared ? 1.0 : 0)
        .offset(x: appeared ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(animationDelay)) {
                appeared = true
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Time Chip
struct TimeChip: View {
    let time: NotificationTime
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            Text(formatTime(hour: time.hour, minute: time.minute))
                .font(LeavnTheme.Typography.headline)
            Text(time.label)
                .font(LeavnTheme.Typography.micro)
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? LeavnTheme.Colors.accent : Color(.systemGray5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 1)
        )
        .onTapGesture(perform: onTap)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private func formatTime(hour: Int, minute: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    let onSave: (Date) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Choose Your Daily Reminder Time")
                    .font(LeavnTheme.Typography.titleMedium)
                    .padding(.top)
                
                DatePicker(
                    "",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Custom Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(selectedTime)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}