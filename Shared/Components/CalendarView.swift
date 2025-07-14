import SwiftUI

/// A shared calendar component that works across all platforms
/// Displays a month view with customizable date marking
public struct CalendarView: View {
    @Binding var selectedDate: Date
    let markedDates: Set<Date>
    let accentColor: Color
    
    @State private var displayedMonth: Date
    
    public init(
        selectedDate: Binding<Date>,
        markedDates: Set<Date> = [],
        accentColor: Color = .blue
    ) {
        self._selectedDate = selectedDate
        self.markedDates = markedDates
        self.accentColor = accentColor
        self._displayedMonth = State(initialValue: selectedDate.wrappedValue)
    }
    
    private var calendar: Calendar {
        Calendar.current
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    private var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols
    }
    
    private var daysInMonth: [Date?] {
        guard let monthRange = calendar.range(of: .day, in: .month, for: displayedMonth),
              let firstOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstOfMonth) - 1
        let daysInMonth = monthRange.count
        
        var days: [Date?] = Array(repeating: nil, count: firstWeekday)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) {
                days.append(date)
            }
        }
        
        // Fill remaining days to complete the last week
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Month navigation header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: displayedMonth))
                    .font(.headline)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(accentColor)
                }
            }
            .padding()
            
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { weekday in
                    Text(weekday)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(Array(daysInMonth.enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isMarked: markedDates.contains(where: { calendar.isDate($0, inSameDayAs: date) }),
                            isToday: calendar.isDateInToday(date),
                            accentColor: accentColor
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func previousMonth() {
        withAnimation {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }
    
    private func nextMonth() {
        withAnimation {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
}

private struct DayView: View {
    let date: Date
    let isSelected: Bool
    let isMarked: Bool
    let isToday: Bool
    let accentColor: Color
    let action: () -> Void
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Background
                if isSelected {
                    Circle()
                        .fill(accentColor)
                } else if isToday {
                    Circle()
                        .stroke(accentColor, lineWidth: 2)
                }
                
                // Day number
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 16))
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundColor(isSelected ? .white : .primary)
                
                // Marked indicator
                if isMarked && !isSelected {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 6, height: 6)
                        .offset(y: 14)
                }
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var selectedDate = Date()
        private let markedDates: Set<Date> = {
            let calendar = Calendar.current
            let today = Date()
            return Set([
                calendar.date(byAdding: .day, value: 2, to: today)!,
                calendar.date(byAdding: .day, value: 5, to: today)!,
                calendar.date(byAdding: .day, value: 10, to: today)!
            ])
        }()
        
        var body: some View {
            CalendarView(
                selectedDate: $selectedDate,
                markedDates: markedDates,
                accentColor: .blue
            )
            .padding()
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
    }
}