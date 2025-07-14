import Foundation

// MARK: - Date Range
public struct DateRange: Codable, Sendable {
    public let startDate: Date
    public let endDate: Date
    
    public init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
}

// MARK: - Sort Order
public enum SortOrder: String, Codable, CaseIterable {
    case ascending
    case descending
    
    public var displayName: String {
        switch self {
        case .ascending:
            return "Ascending"
        case .descending:
            return "Descending"
        }
    }
}