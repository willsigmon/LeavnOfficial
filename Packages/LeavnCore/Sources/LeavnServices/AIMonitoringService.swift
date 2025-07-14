import Foundation

import OSLog

/// Service for monitoring and reporting AI quality metrics
public actor AIMonitoringService {
    
    // MARK: - Types
    
    public struct AIMetrics {
        public let totalRequests: Int
        public let successfulResponses: Int
        public let validationFailures: Int
        public let fallbacksUsed: Int
        public let averageResponseTime: TimeInterval
        public let errorRate: Double
        public let validationPassRate: Double
        public let contentTypes: [ContentType: Int]
        public let issuesByType: [ContentIssue.IssueType: Int]
        public let lastUpdated: Date
    }
    
    public struct AIEvent {
        public let id: String
        public let timestamp: Date
        public let eventType: EventType
        public let contentType: ContentType
        public let success: Bool
        public let validationResult: AIValidationResult?
        public let responseTime: TimeInterval
        public let fallbackUsed: Bool
        public let issues: [ContentIssue]
        public let metadata: [String: String]
        
        public enum EventType {
            case request
            case response
            case validation
            case fallback
            case error
        }
    }
    
    public struct AlertRule: Sendable {
        public let id: String
        public let name: String
        public let condition: AlertCondition
        public let threshold: Double
        public let windowMinutes: Int
        public let isActive: Bool
        
        public enum AlertCondition: Sendable {
            case errorRateExceeds
            case validationFailureRateExceeds
            case fallbackRateExceeds
            case responseTimeExceeds
            case consecutiveFailures
        }
    }
    
    // MARK: - ContentIssue (moved to file top for visibility)
    public struct ContentIssue: Sendable {
        public let type: IssueType
        public let description: String
        public let location: String?
        public let severity: FilterResult.Severity
        public enum IssueType: Sendable {
            case theological
            case factual
            case reverence
            case inappropriate
            case scriptureAccuracy
            case denominational
        }
    }
    
    // MARK: - Properties
    
    private let logger = Logger(subsystem: "com.leavn3", category: "AIMonitoring")
    private var events: [AIEvent] = []
    private var alerts: [AlertRule] = []
    private let maxEventHistory = 10000
    private let metricsUpdateInterval: TimeInterval = 60 // 1 minute
    
    // Real-time counters
    private var requestCount = 0
    private var successCount = 0
    private var validationFailureCount = 0
    private var fallbackCount = 0
    private var totalResponseTime: TimeInterval = 0
    private var contentTypeCounters: [ContentType: Int] = [:]
    private var issueTypeCounters: [ContentIssue.IssueType: Int] = [:]
    
    // Alert tracking
    private var activeAlerts: Set<String> = []
    private var lastAlertCheck = Date()
    
    // MARK: - Initialization
    
    public init() {
        Task { [weak self] in
            await self?.setupDefaultAlerts()
            await self?.startPeriodicCleanup()
        }
    }
    
    // MARK: - Public Methods
    
    /// Record an AI request event
    public func recordRequest(
        contentType: ContentType,
        metadata: [String: String] = [:]
    ) -> String {
        let eventId = UUID().uuidString
        requestCount += 1
        
        contentTypeCounters[contentType, default: 0] += 1
        
        let event = AIEvent(
            id: eventId,
            timestamp: Date(),
            eventType: .request,
            contentType: contentType,
            success: false, // Will be updated on response
            validationResult: nil,
            responseTime: 0,
            fallbackUsed: false,
            issues: [],
            metadata: metadata
        )
        
        addEvent(event)
        return eventId
    }
    
    /// Record an AI response event
    public func recordResponse(
        eventId: String,
        success: Bool,
        responseTime: TimeInterval,
        validationResult: AIValidationResult? = nil,
        fallbackUsed: Bool = false,
        issues: [ContentIssue] = []
    ) {
        if success {
            successCount += 1
        }
        
        if let validation = validationResult, !validation.isValid {
            validationFailureCount += 1
        }
        
        if fallbackUsed {
            fallbackCount += 1
        }
        
        totalResponseTime += responseTime
        
        // Track issues by type
        for issue in issues {
            issueTypeCounters[issue.type, default: 0] += 1
        }
        
        // Update the original event if found
        if let index = events.firstIndex(where: { $0.id == eventId }) {
            let event = events[index]
            let updatedEvent = AIEvent(
                id: event.id,
                timestamp: event.timestamp,
                eventType: .response,
                contentType: event.contentType,
                success: success,
                validationResult: validationResult,
                responseTime: responseTime,
                fallbackUsed: fallbackUsed,
                issues: issues,
                metadata: event.metadata
            )
            events[index] = updatedEvent
        }
        
        // Check alerts
        Task {
            await checkAlerts()
        }
    }
    
    /// Record a validation event
    public func recordValidation(
        contentType: ContentType,
        result: AIValidationResult,
        issues: [ContentIssue] = []
    ) {
        let event = AIEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            eventType: .validation,
            contentType: contentType,
            success: result.isValid,
            validationResult: result,
            responseTime: 0,
            fallbackUsed: false,
            issues: issues,
            metadata: [:]
        )
        
        addEvent(event)
        
        if !result.isValid {
            validationFailureCount += 1
            logWarning("Validation failed for \(contentType): \(result.failureReason ?? "Unknown")", category: .analytics)
        }
    }
    
    /// Record an error event
    public func recordError(
        contentType: ContentType,
        error: Error,
        metadata: [String: String] = [:]
    ) {
        var updatedMetadata = metadata
        updatedMetadata["error"] = error.localizedDescription
        
        let event = AIEvent(
            id: UUID().uuidString,
            timestamp: Date(),
            eventType: .error,
            contentType: contentType,
            success: false,
            validationResult: nil,
            responseTime: 0,
            fallbackUsed: false,
            issues: [],
            metadata: updatedMetadata
        )
        
        addEvent(event)
        logError("AI error for \(contentType): \(error)", category: .analytics)
    }
    
    /// Get current metrics
    public func getMetrics() -> AIMetrics {
        let errorRate = Double(requestCount - successCount) / Double(max(requestCount, 1))
        let validationPassRate = Double(requestCount - validationFailureCount) / Double(max(requestCount, 1))
        let avgResponseTime = totalResponseTime / Double(max(requestCount, 1))
        
        return AIMetrics(
            totalRequests: requestCount,
            successfulResponses: successCount,
            validationFailures: validationFailureCount,
            fallbacksUsed: fallbackCount,
            averageResponseTime: avgResponseTime,
            errorRate: errorRate,
            validationPassRate: validationPassRate,
            contentTypes: contentTypeCounters,
            issuesByType: issueTypeCounters,
            lastUpdated: Date()
        )
    }
    
    /// Get recent events
    public func getRecentEvents(limit: Int = 100) -> [AIEvent] {
        return Array(events.suffix(limit))
    }
    
    /// Get events with issues
    public func getProblematicEvents(limit: Int = 50) -> [AIEvent] {
        return events
            .filter { !$0.success || !$0.issues.isEmpty || $0.fallbackUsed }
            .suffix(limit)
    }
    
    /// Export metrics for analysis
    public func exportMetrics() -> Data? {
        let metrics = getMetrics()
        let exportData: [String: Any] = [
            "metrics": [
                "totalRequests": metrics.totalRequests,
                "successfulResponses": metrics.successfulResponses,
                "validationFailures": metrics.validationFailures,
                "fallbacksUsed": metrics.fallbacksUsed,
                "averageResponseTime": metrics.averageResponseTime,
                "errorRate": metrics.errorRate,
                "validationPassRate": metrics.validationPassRate
            ],
            "contentTypes": metrics.contentTypes.map { ["type": $0.key, "count": $0.value] },
            "issues": metrics.issuesByType.map { ["type": "\($0.key)", "count": $0.value] },
            "timestamp": ISO8601DateFormatter().string(from: metrics.lastUpdated)
        ]
        
        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
    
    /// Generate health report
    public func generateHealthReport() -> String {
        let metrics = getMetrics()
        
        return """
        📊 AI Service Health Report
        Generated: \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))
        
        ✅ Performance Metrics:
        • Total Requests: \(metrics.totalRequests)
        • Success Rate: \(String(format: "%.1f%%", (1 - metrics.errorRate) * 100))
        • Validation Pass Rate: \(String(format: "%.1f%%", metrics.validationPassRate * 100))
        • Average Response Time: \(String(format: "%.2fs", metrics.averageResponseTime))
        • Fallbacks Used: \(metrics.fallbacksUsed) (\(String(format: "%.1f%%", Double(metrics.fallbacksUsed) / Double(max(metrics.totalRequests, 1)) * 100)))
        
        📈 Content Type Distribution:
        \(metrics.contentTypes.map { "• \($0.key): \($0.value)" }.joined(separator: "\n"))
        
        ⚠️ Issues Detected:
        \(metrics.issuesByType.isEmpty ? "• No issues detected" : metrics.issuesByType.map { "• \($0.key): \($0.value)" }.joined(separator: "\n"))
        
        🚨 Active Alerts: \(activeAlerts.count)
        \(activeAlerts.isEmpty ? "• All systems normal" : activeAlerts.map { "• \($0)" }.joined(separator: "\n"))
        """
    }
    
    // MARK: - Alert Management
    
    /// Add a custom alert rule
    public func addAlertRule(_ rule: AlertRule) {
        alerts.append(rule)
        logger.info("Added alert rule: \(rule.name)")
    }
    
    /// Remove an alert rule
    public func removeAlertRule(id: String) {
        alerts.removeAll { $0.id == id }
        activeAlerts.remove(id)
    }
    
    /// Get active alerts
    public func getActiveAlerts() -> Set<String> {
        return activeAlerts
    }
    
    // MARK: - Private Methods
    
    private func addEvent(_ event: AIEvent) {
        events.append(event)
        
        // Trim old events if needed
        if events.count > maxEventHistory {
            events.removeFirst(events.count - maxEventHistory)
        }
    }
    
    private func setupDefaultAlerts() {
        alerts = [
            AlertRule(
                id: "high-error-rate",
                name: "High Error Rate",
                condition: .errorRateExceeds,
                threshold: 0.1, // 10%
                windowMinutes: 5,
                isActive: true
            ),
            AlertRule(
                id: "high-validation-failures",
                name: "High Validation Failure Rate",
                condition: .validationFailureRateExceeds,
                threshold: 0.2, // 20%
                windowMinutes: 5,
                isActive: true
            ),
            AlertRule(
                id: "excessive-fallbacks",
                name: "Excessive Fallback Usage",
                condition: .fallbackRateExceeds,
                threshold: 0.3, // 30%
                windowMinutes: 10,
                isActive: true
            ),
            AlertRule(
                id: "slow-response",
                name: "Slow Response Time",
                condition: .responseTimeExceeds,
                threshold: 5.0, // 5 seconds
                windowMinutes: 5,
                isActive: true
            )
        ]
    }
    
    private func checkAlerts() async {
        let now = Date()
        
        // Only check alerts every minute
        guard now.timeIntervalSince(lastAlertCheck) >= 60 else { return }
        lastAlertCheck = now
        
        for rule in alerts where rule.isActive {
            let shouldAlert = await evaluateAlertCondition(rule)
            
            if shouldAlert && !activeAlerts.contains(rule.id) {
                activeAlerts.insert(rule.id)
                logger.warning("🚨 Alert triggered: \(rule.name)")
                
                // In production, send notification to monitoring service
                await notifyAlert(rule)
            } else if !shouldAlert && activeAlerts.contains(rule.id) {
                activeAlerts.remove(rule.id)
                logger.info("✅ Alert resolved: \(rule.name)")
            }
        }
    }
    
    private func evaluateAlertCondition(_ rule: AlertRule) async -> Bool {
        let windowStart = Date().addingTimeInterval(-Double(rule.windowMinutes * 60))
        let recentEvents = events.filter { $0.timestamp >= windowStart }
        
        guard !recentEvents.isEmpty else { return false }
        
        switch rule.condition {
        case .errorRateExceeds:
            let errorCount = recentEvents.filter { !$0.success }.count
            let errorRate = Double(errorCount) / Double(recentEvents.count)
            return errorRate > rule.threshold
            
        case .validationFailureRateExceeds:
            let failureCount = recentEvents.filter { 
                $0.validationResult?.isValid == false 
            }.count
            let failureRate = Double(failureCount) / Double(recentEvents.count)
            return failureRate > rule.threshold
            
        case .fallbackRateExceeds:
            let fallbackCount = recentEvents.filter { $0.fallbackUsed }.count
            let fallbackRate = Double(fallbackCount) / Double(recentEvents.count)
            return fallbackRate > rule.threshold
            
        case .responseTimeExceeds:
            let avgTime = recentEvents.map(\.responseTime).reduce(0, +) / Double(recentEvents.count)
            return avgTime > rule.threshold
            
        case .consecutiveFailures:
            let consecutiveFailures = recentEvents.suffix(Int(rule.threshold))
                .allSatisfy { !$0.success }
            return consecutiveFailures && recentEvents.count >= Int(rule.threshold)
        }
    }
    
    private func notifyAlert(_ rule: AlertRule) async {
        // In production, this would send to:
        // - Monitoring dashboard
        // - Email/SMS notifications
        // - Slack/Teams channels
        // - PagerDuty for critical alerts
        
        logError("🚨 ALERT: \(rule.name) | Condition: \(rule.condition) | Threshold: \(rule.threshold) | Window: \(rule.windowMinutes) min", category: .analytics)
    }
    
    // MARK: - Periodic Cleanup
    
    private func startPeriodicCleanup() {
        Task {
            while true {
                try? await Task.sleep(nanoseconds: 3600_000_000_000) // 1 hour
                await cleanupOldEvents()
            }
        }
    }
    
    private func cleanupOldEvents() async {
        let cutoffDate = Date().addingTimeInterval(-86400 * 7) // Keep 7 days of events
        let oldEventCount = events.count
        events.removeAll { $0.timestamp < cutoffDate }
        let removedCount = oldEventCount - events.count
        
        if removedCount > 0 {
            logger.info("🧹 Cleaned up \(removedCount) old monitoring events")
        }
    }
}