import Foundation

/// Analyzes code for Hick's Law compliance and cognitive load optimization
/// Enforces the 5-option limit for better user experience
public struct CognitiveLoadAnalyzer {
    
    /// Maximum recommended options for optimal cognitive load
    public static let maxRecommendedOptions = 5
    
    /// Violation severity levels
    public enum Severity: String {
        case critical = "Critical"   // >10 options
        case high = "High"          // 8-10 options
        case medium = "Medium"      // 6-7 options
        case low = "Low"           // Exactly 5 options (monitor)
        case compliant = "Compliant" // <5 options
        
        var emoji: String {
            switch self {
            case .critical: return "🚨"
            case .high: return "⚠️"
            case .medium: return "⚡"
            case .low: return "👀"
            case .compliant: return "✅"
            }
        }
    }
    
    /// Represents a cognitive load violation
    public struct Violation {
        let type: String
        let location: String
        let optionCount: Int
        let severity: Severity
        let suggestion: String
        
        var description: String {
            "\(severity.emoji) \(type) at \(location): \(optionCount) options (\(severity.rawValue))"
        }
    }
    
    /// Analyzes an enum's case count
    public static func analyzeEnum<T: CaseIterable>(
        _ enumType: T.Type,
        name: String,
        location: String
    ) -> Violation? {
        let count = enumType.allCases.count
        guard count > maxRecommendedOptions else { return nil }
        
        let severity = calculateSeverity(optionCount: count)
        let suggestion = generateSuggestion(for: count, type: "Enum")
        
        return Violation(
            type: "Enum \(name)",
            location: location,
            optionCount: count,
            severity: severity,
            suggestion: suggestion
        )
    }
    
    /// Analyzes an array of options
    public static func analyzeOptions<T>(
        _ options: [T],
        name: String,
        location: String
    ) -> Violation? {
        let count = options.count
        guard count > maxRecommendedOptions else { return nil }
        
        let severity = calculateSeverity(optionCount: count)
        let suggestion = generateSuggestion(for: count, type: "Options")
        
        return Violation(
            type: name,
            location: location,
            optionCount: count,
            severity: severity,
            suggestion: suggestion
        )
    }
    
    /// Calculate severity based on option count
    private static func calculateSeverity(optionCount: Int) -> Severity {
        switch optionCount {
        case 0..<5: return .compliant
        case 5: return .low
        case 6...7: return .medium
        case 8...10: return .high
        default: return .critical
        }
    }
    
    /// Generate contextual suggestions
    private static func generateSuggestion(for count: Int, type: String) -> String {
        let reduction = count - maxRecommendedOptions
        
        switch count {
        case 6...7:
            return "Consider combining \(reduction) related options or using progressive disclosure"
        case 8...10:
            return "Group into \(maxRecommendedOptions) categories with expandable subcategories"
        case 11...15:
            return "Implement hierarchical navigation with \(maxRecommendedOptions) top-level categories"
        default:
            return "Major refactoring needed: Create \(maxRecommendedOptions) primary categories with search functionality"
        }
    }
    
    /// Generates a compliance report
    public static func generateReport(violations: [Violation]) -> String {
        guard !violations.isEmpty else {
            return "✅ All interfaces are Hick's Law compliant!"
        }
        
        var report = "## Cognitive Load Analysis Report\n\n"
        report += "Found \(violations.count) violations:\n\n"
        
        // Group by severity
        let grouped = Dictionary(grouping: violations) { $0.severity }
        let severityOrder: [Severity] = [.critical, .high, .medium, .low]
        
        for severity in severityOrder {
            guard let items = grouped[severity], !items.isEmpty else { continue }
            
            report += "### \(severity.emoji) \(severity.rawValue) (\(items.count))\n"
            for violation in items {
                report += "- \(violation.description)\n"
                report += "  - Suggestion: \(violation.suggestion)\n"
            }
            report += "\n"
        }
        
        return report
    }
}

// MARK: - Development Time Assertions

#if DEBUG
/// Assert that an interface meets cognitive load requirements
public func assertCognitiveLoadCompliance<T: CaseIterable>(
    _ enumType: T.Type,
    file: String = #file,
    line: Int = #line
) {
    let count = enumType.allCases.count
    assert(
        count <= CognitiveLoadAnalyzer.maxRecommendedOptions,
        """
        Cognitive Load Violation: \(String(describing: enumType)) has \(count) cases (max: \(CognitiveLoadAnalyzer.maxRecommendedOptions))
        Location: \(file):\(line)
        """
    )
}

/// Assert that options array meets cognitive load requirements
public func assertCognitiveLoadCompliance<T>(
    options: [T],
    name: String,
    file: String = #file,
    line: Int = #line
) {
    let count = options.count
    assert(
        count <= CognitiveLoadAnalyzer.maxRecommendedOptions,
        """
        Cognitive Load Violation: \(name) has \(count) options (max: \(CognitiveLoadAnalyzer.maxRecommendedOptions))
        Location: \(file):\(line)
        """
    )
}
#endif