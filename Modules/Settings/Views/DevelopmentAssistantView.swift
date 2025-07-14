import SwiftUI

public struct DevelopmentAssistantView: View {
    @StateObject private var assistant = DevelopmentAssistantViewModel()
    @State private var inputPrompt = ""
    @State private var isAnalyzing = false
    @State private var selectedTab = 0
    
    public init() {}
    
    public var body: some View {
        ZStack {
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                TabView(selection: $selectedTab) {
                    codeAnalysisTab
                        .tag(0)
                    
                    suggestionsTab
                        .tag(1)
                    
                    metricsTab
                        .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                
                promptInputView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 24))
                    .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                
                Text("Development Assistant")
                    .font(LeavnTheme.Typography.titleLarge)
                    .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                
                Spacer()
            }
            
            Text("AI-powered code analysis and suggestions")
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private var codeAnalysisTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let analysis = assistant.lastAnalysis {
                    ForEach(analysis.issues, id: \.description) { issue in
                        IssueCard(issue: issue)
                    }
                } else {
                    EmptyStateView(
                        icon: "doc.text.magnifyingglass",
                        title: "No Analysis Yet",
                        description: "Enter a prompt below to analyze your codebase"
                    )
                }
            }
            .padding()
        }
    }
    
    private var suggestionsTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !assistant.suggestions.isEmpty {
                    ForEach(assistant.suggestions, id: \.self) { suggestion in
                        SuggestionCard(suggestion: suggestion)
                    }
                } else {
                    EmptyStateView(
                        icon: "lightbulb.fill",
                        title: "No Suggestions",
                        description: "Analyze your code to get improvement suggestions"
                    )
                }
            }
            .padding()
        }
    }
    
    private var metricsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let analysis = assistant.lastAnalysis {
                    MetricsGrid(analysis: analysis)
                } else {
                    EmptyStateView(
                        icon: "chart.bar.fill",
                        title: "No Metrics",
                        description: "Run analysis to see code quality metrics"
                    )
                }
            }
            .padding()
        }
    }
    
    private var promptInputView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                TextField("Ask about your code...", text: $inputPrompt)
                    .textFieldStyle(.roundedBorder)
                    .submitLabel(.go)
                    .onSubmit {
                        analyzeCode()
                    }
                
                Button(action: analyzeCode) {
                    if isAnalyzing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                }
                .frame(width: 44, height: 44)
                .background(LeavnTheme.Colors.accent)
                .clipShape(Circle())
                .disabled(inputPrompt.isEmpty || isAnalyzing)
            }
            
            HStack(spacing: 8) {
                ForEach(quickPrompts, id: \.self) { prompt in
                    Button(action: { inputPrompt = prompt }) {
                        Text(prompt)
                            .font(LeavnTheme.Typography.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(LeavnTheme.Colors.accent.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
    }
    
    private var quickPrompts: [String] {
        [
            "Find bugs",
            "Optimize performance",
            "Check security"
        ]
    }
    
    private func analyzeCode() {
        guard !inputPrompt.isEmpty else { return }
        
        isAnalyzing = true
        
        Task {
            await assistant.analyzeCode(prompt: inputPrompt)
            await MainActor.run {
                isAnalyzing = false
                inputPrompt = ""
            }
        }
    }
}

// MARK: - Supporting Views

struct IssueCard: View {
    let issue: CodeAnalysis.Issue
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconForSeverity(issue.severity))
                .foregroundColor(colorForSeverity(issue.severity))
                .font(.system(size: 20))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(issue.description)
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.primary)
                
                if let file = issue.file {
                    HStack {
                        Image(systemName: "doc.text")
                            .font(.caption)
                        Text("\(file):\(issue.line ?? 0)")
                            .font(LeavnTheme.Typography.caption)
                    }
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(12)
    }
    
    func iconForSeverity(_ severity: CodeAnalysis.Issue.Severity) -> String {
        switch severity {
        case .error: return "xmark.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    func colorForSeverity(_ severity: CodeAnalysis.Issue.Severity) -> Color {
        switch severity {
        case .error: return LeavnTheme.Colors.error
        case .warning: return LeavnTheme.Colors.warning
        case .info: return LeavnTheme.Colors.info
        }
    }
}

struct SuggestionCard: View {
    let suggestion: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(LeavnTheme.Colors.warning)
                .font(.system(size: 20))
            
            Text(suggestion)
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(LeavnTheme.Colors.warning.opacity(0.1))
        .cornerRadius(12)
    }
}

struct MetricsGrid: View {
    let analysis: CodeAnalysis
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            MetricCard(
                title: "Issues Found",
                value: "\(analysis.issues.count)",
                icon: "exclamationmark.triangle",
                color: LeavnTheme.Colors.error
            )
            
            MetricCard(
                title: "Files Analyzed",
                value: "\(Set(analysis.issues.compactMap { $0.file }).count)",
                icon: "doc.text",
                color: LeavnTheme.Colors.info
            )
            
            MetricCard(
                title: "Errors",
                value: "\(analysis.issues.filter { $0.severity == .error }.count)",
                icon: "xmark.circle",
                color: LeavnTheme.Colors.error
            )
            
            MetricCard(
                title: "Warnings",
                value: "\(analysis.issues.filter { $0.severity == .warning }.count)",
                icon: "exclamationmark.triangle",
                color: LeavnTheme.Colors.warning
            )
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(color)
            
            Text(value)
                .font(LeavnTheme.Typography.titleLarge)
                .fontWeight(.bold)
            
            Text(title)
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(16)
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text(title)
                .font(LeavnTheme.Typography.headline)
                .foregroundColor(.secondary)
            
            Text(description)
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    NavigationView {
        DevelopmentAssistantView()
    }
}