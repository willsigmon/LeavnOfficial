import Foundation

// MARK: - Date Formatting Extensions
public extension Date {
    
    // MARK: - Common Formatters
    /// Returns date formatted as "Jan 15, 2024"
    var mediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns date formatted as "January 15, 2024"
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns date formatted as "1/15/24"
    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }
    
    /// Returns time formatted as "2:30 PM"
    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Returns date and time formatted as "Jan 15, 2:30 PM"
    var dateTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    // MARK: - Custom Formats
    /// Format date with custom format string
    func formatted(with format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Returns day of week as "Monday"
    var dayOfWeek: String {
        formatted(with: "EEEE")
    }
    
    /// Returns abbreviated day as "Mon"
    var abbreviatedDayOfWeek: String {
        formatted(with: "EEE")
    }
    
    /// Returns month name as "January"
    var monthName: String {
        formatted(with: "MMMM")
    }
    
    /// Returns abbreviated month as "Jan"
    var abbreviatedMonth: String {
        formatted(with: "MMM")
    }
    
    /// Returns year as "2024"
    var yearString: String {
        formatted(with: "yyyy")
    }
    
    /// Returns month and year as "January 2024"
    var monthYearString: String {
        formatted(with: "MMMM yyyy")
    }
    
    // MARK: - Relative Formatting
    /// Returns relative time string like "2 hours ago" or "in 3 days"
    var relativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns short relative time like "2h ago" or "in 3d"
    var shortRelativeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Returns time ago string
    var timeAgoString: String {
        let interval = Date().timeIntervalSince(self)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        } else {
            return mediumDateString
        }
    }
    
    // MARK: - Leave Specific Formatting
    /// Format for leave request display
    var leaveRequestDateString: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInTomorrow(self) {
            return "Tomorrow"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return formatted(with: "MMM d, yyyy")
        }
    }
    
    /// Format date range for leave display
    static func leaveRangeString(from startDate: Date, to endDate: Date) -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        
        // Same day
        if calendar.isDate(startDate, inSameDayAs: endDate) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: startDate)
        }
        
        // Same month and year
        if calendar.isDate(startDate, equalTo: endDate, toGranularity: .month) &&
           calendar.isDate(startDate, equalTo: endDate, toGranularity: .year) {
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startDate)
            formatter.dateFormat = "d, yyyy"
            let end = formatter.string(from: endDate)
            return "\(start) - \(end)"
        }
        
        // Same year
        if calendar.isDate(startDate, equalTo: endDate, toGranularity: .year) {
            formatter.dateFormat = "MMM d"
            let start = formatter.string(from: startDate)
            formatter.dateFormat = "MMM d, yyyy"
            let end = formatter.string(from: endDate)
            return "\(start) - \(end)"
        }
        
        // Different years
        formatter.dateFormat = "MMM d, yyyy"
        return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
    }
    
    // MARK: - Business Days Calculation
    /// Calculate business days between two dates
    static func businessDaysBetween(_ startDate: Date, and endDate: Date) -> Int {
        let calendar = Calendar.current
        var businessDays = 0
        var currentDate = startDate
        
        while currentDate <= endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday != 1 && weekday != 7 { // Not Sunday (1) or Saturday (7)
                businessDays += 1
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return businessDays
    }
    
    // MARK: - Date Components
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
    
    // MARK: - Date Manipulation
    /// Add or subtract days
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    /// Add or subtract months
    func addingMonths(_ months: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    /// Add or subtract years
    func addingYears(_ years: Int) -> Date {
        Calendar.current.date(byAdding: .year, value: years, to: self) ?? self
    }
    
    /// Start of day (00:00:00)
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    /// End of day (23:59:59)
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    /// Start of month
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: self)
        return Calendar.current.date(from: components) ?? self
    }
    
    /// End of month
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    // MARK: - Comparison Helpers
    /// Check if date is in the past
    var isInPast: Bool {
        self < Date()
    }
    
    /// Check if date is in the future
    var isInFuture: Bool {
        self > Date()
    }
    
    /// Check if date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    /// Check if date is tomorrow
    var isTomorrow: Bool {
        Calendar.current.isDateInTomorrow(self)
    }
    
    /// Check if date is yesterday
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    
    /// Check if date is in current week
    var isInCurrentWeek: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
    
    /// Check if date is in current month
    var isInCurrentMonth: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .month)
    }
    
    /// Check if date is in current year
    var isInCurrentYear: Bool {
        Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
}

// MARK: - ISO8601 Support
public extension Date {
    /// Initialize from ISO8601 string
    init?(iso8601: String) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: iso8601) {
            self = date
        } else {
            // Try without fractional seconds
            formatter.formatOptions = [.withInternetDateTime]
            if let date = formatter.date(from: iso8601) {
                self = date
            } else {
                return nil
            }
        }
    }
    
    /// Convert to ISO8601 string
    var iso8601String: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: self)
    }
}