import Foundation

import Combine

@MainActor
public class DevelopmentAssistantViewModel: ObservableObject {
    @Published var lastAnalysis: CodeAnalysis?
    @Published var suggestions: [String] = []
    @Published var isAnalyzing = false
    
    public init() {}
    
    public func analyzeCode(prompt: String) async {
        isAnalyzing = true
        
        // Simulate analysis
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        // Create mock analysis
        let issues = [
            CodeAnalysis.Issue(
                severity: .warning,
                description: "Consider using @MainActor for UI updates",
                file: "ContentView.swift",
                line: 42
            ),
            CodeAnalysis.Issue(
                severity: .info,
                description: "This function could be simplified",
                file: "ViewModel.swift", 
                line: 15
            )
        ]
        
        lastAnalysis = CodeAnalysis(
            timestamp: Date(),
            issues: issues,
            suggestions: [
                "Consider extracting this logic into a separate function",
                "Add error handling for network requests",
                "This view could benefit from composition"
            ]
        )
        
        suggestions = lastAnalysis?.suggestions ?? []
        isAnalyzing = false
    }
}

// MARK: - Code Analysis Model
public struct CodeAnalysis {
    public let timestamp: Date
    public let issues: [Issue]
    public let suggestions: [String]
    
    public struct Issue {
        public enum Severity {
            case error, warning, info
        }
        
        public let severity: Severity
        public let description: String
        public let file: String?
        public let line: Int?
    }
}