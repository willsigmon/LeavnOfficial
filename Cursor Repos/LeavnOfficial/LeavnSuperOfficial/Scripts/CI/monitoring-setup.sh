#!/bin/bash
# Monitoring and Analytics Setup for LeavnSuperOfficial

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PLIST_PATH="$PROJECT_DIR/Info.plist"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to print colored output
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Setup Crashlytics
setup_crashlytics() {
    print_message $YELLOW "Setting up Crashlytics..."
    
    # Add Crashlytics run script phase
    local run_script='#!/bin/bash
# Crashlytics Run Script
"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run"'
    
    # Create script file
    echo "$run_script" > "$PROJECT_DIR/Scripts/crashlytics-run.sh"
    chmod +x "$PROJECT_DIR/Scripts/crashlytics-run.sh"
    
    # Add dSYM upload script
    cat > "$PROJECT_DIR/Scripts/upload-symbols.sh" << 'EOF'
#!/bin/bash
# Upload dSYMs to Crashlytics

if [ -z "$GOOGLE_APP_ID" ]; then
    echo "Error: GOOGLE_APP_ID not set"
    exit 1
fi

# Find and upload dSYM files
find "${DWARF_DSYM_FOLDER_PATH}" -name "*.dSYM" | while read -r dsym; do
    "${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/upload-symbols" \
        -gsp "${PROJECT_DIR}/GoogleService-Info.plist" \
        -p ios "${dsym}"
done
EOF
    
    chmod +x "$PROJECT_DIR/Scripts/upload-symbols.sh"
    
    print_message $GREEN "Crashlytics setup complete"
}

# Setup Analytics
setup_analytics() {
    print_message $YELLOW "Setting up Analytics..."
    
    # Create analytics configuration
    cat > "$PROJECT_DIR/Sources/LeavnApp/Analytics/AnalyticsConfiguration.swift" << 'EOF'
//
//  AnalyticsConfiguration.swift
//  LeavnSuperOfficial
//
//  Created by CI/CD Pipeline
//

import Foundation

struct AnalyticsConfiguration {
    static let shared = AnalyticsConfiguration()
    
    let firebaseEnabled = ProcessInfo.processInfo.environment["ENABLE_FIREBASE"] == "true"
    let amplitudeApiKey = ProcessInfo.processInfo.environment["AMPLITUDE_API_KEY"] ?? ""
    let mixpanelToken = ProcessInfo.processInfo.environment["MIXPANEL_TOKEN"] ?? ""
    
    var isAnalyticsEnabled: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.environment["ENABLE_ANALYTICS"] == "true"
        #else
        return true
        #endif
    }
    
    private init() {}
}
EOF
    
    print_message $GREEN "Analytics configuration created"
}

# Setup Performance Monitoring
setup_performance_monitoring() {
    print_message $YELLOW "Setting up Performance Monitoring..."
    
    # Create performance monitoring helper
    cat > "$PROJECT_DIR/Sources/LeavnApp/Performance/PerformanceMonitor.swift" << 'EOF'
//
//  PerformanceMonitor.swift
//  LeavnSuperOfficial
//
//  Created by CI/CD Pipeline
//

import Foundation
import os.log

final class PerformanceMonitor {
    static let shared = PerformanceMonitor()
    
    private let logger = Logger(subsystem: "com.leavn.superofficial", category: "Performance")
    private var metrics: [String: TimeInterval] = [:]
    
    private init() {}
    
    func startMeasuring(_ identifier: String) {
        metrics[identifier] = Date().timeIntervalSince1970
    }
    
    func stopMeasuring(_ identifier: String) {
        guard let startTime = metrics[identifier] else { return }
        
        let duration = Date().timeIntervalSince1970 - startTime
        metrics.removeValue(forKey: identifier)
        
        logger.info("Performance: \(identifier) took \(duration, format: .fixed(precision: 3))s")
        
        // Send to analytics if enabled
        if AnalyticsConfiguration.shared.isAnalyticsEnabled {
            // Analytics implementation
        }
    }
}
EOF
    
    print_message $GREEN "Performance monitoring setup complete"
}

# Setup Notification Services
setup_notifications() {
    print_message $YELLOW "Setting up Notification Services..."
    
    # Create Slack notification script
    cat > "$PROJECT_DIR/Scripts/send-slack-notification.sh" << 'EOF'
#!/bin/bash
# Send Slack Notification

WEBHOOK_URL="${SLACK_WEBHOOK_URL}"
MESSAGE="$1"
COLOR="${2:-good}" # good, warning, danger
TITLE="${3:-LeavnSuperOfficial CI/CD}"

if [ -z "$WEBHOOK_URL" ]; then
    echo "Warning: SLACK_WEBHOOK_URL not set"
    exit 0
fi

payload=$(cat <<JSON
{
    "attachments": [
        {
            "fallback": "$MESSAGE",
            "color": "$COLOR",
            "title": "$TITLE",
            "text": "$MESSAGE",
            "footer": "LeavnSuperOfficial",
            "footer_icon": "https://leavn.app/icon.png",
            "ts": $(date +%s)
        }
    ]
}
JSON
)

curl -X POST -H 'Content-type: application/json' \
    --data "$payload" \
    "$WEBHOOK_URL"
EOF
    
    chmod +x "$PROJECT_DIR/Scripts/send-slack-notification.sh"
    
    # Create email notification template
    cat > "$PROJECT_DIR/Scripts/email-template.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #007AFF; color: white; padding: 20px; text-align: center; }
        .content { padding: 20px; background: #f5f5f5; }
        .footer { text-align: center; padding: 10px; color: #666; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>LeavnSuperOfficial Build {{BUILD_STATUS}}</h1>
        </div>
        <div class="content">
            <h2>Build Information</h2>
            <ul>
                <li><strong>Version:</strong> {{VERSION}}</li>
                <li><strong>Build:</strong> {{BUILD_NUMBER}}</li>
                <li><strong>Branch:</strong> {{BRANCH}}</li>
                <li><strong>Commit:</strong> {{COMMIT}}</li>
                <li><strong>Duration:</strong> {{DURATION}}</li>
            </ul>
            {{ADDITIONAL_INFO}}
        </div>
        <div class="footer">
            <p>LeavnSuperOfficial CI/CD Pipeline</p>
        </div>
    </div>
</body>
</html>
EOF
    
    print_message $GREEN "Notification services setup complete"
}

# Setup Build Metrics
setup_build_metrics() {
    print_message $YELLOW "Setting up Build Metrics..."
    
    # Create build metrics collector
    cat > "$PROJECT_DIR/Scripts/collect-build-metrics.sh" << 'EOF'
#!/bin/bash
# Collect Build Metrics

BUILD_START_TIME=${BUILD_START_TIME:-$(date +%s)}
BUILD_END_TIME=$(date +%s)
BUILD_DURATION=$((BUILD_END_TIME - BUILD_START_TIME))

# Get app size
if [ -f "*.ipa" ]; then
    APP_SIZE=$(stat -f%z *.ipa | head -1)
    APP_SIZE_MB=$((APP_SIZE / 1048576))
else
    APP_SIZE_MB="N/A"
fi

# Get test results
if [ -f "test_output/report.junit" ]; then
    TOTAL_TESTS=$(grep -o 'tests="[0-9]*"' test_output/report.junit | grep -o '[0-9]*' | head -1)
    FAILED_TESTS=$(grep -o 'failures="[0-9]*"' test_output/report.junit | grep -o '[0-9]*' | head -1)
    TEST_DURATION=$(grep -o 'time="[0-9.]*"' test_output/report.junit | grep -o '[0-9.]*' | head -1)
else
    TOTAL_TESTS="N/A"
    FAILED_TESTS="N/A"
    TEST_DURATION="N/A"
fi

# Get code coverage
if [ -f "coverage_report/index.html" ]; then
    COVERAGE=$(grep -o 'Total coverage: [0-9.]*%' coverage_report/index.html | grep -o '[0-9.]*' | head -1)
else
    COVERAGE="N/A"
fi

# Output metrics
cat << METRICS
Build Metrics Summary
====================
Build Duration: ${BUILD_DURATION}s
App Size: ${APP_SIZE_MB}MB
Total Tests: ${TOTAL_TESTS}
Failed Tests: ${FAILED_TESTS}
Test Duration: ${TEST_DURATION}s
Code Coverage: ${COVERAGE}%
METRICS

# Save to file
cat > build_metrics.json << JSON
{
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "build_duration": ${BUILD_DURATION},
    "app_size_mb": ${APP_SIZE_MB:-0},
    "total_tests": ${TOTAL_TESTS:-0},
    "failed_tests": ${FAILED_TESTS:-0},
    "test_duration": ${TEST_DURATION:-0},
    "code_coverage": ${COVERAGE:-0},
    "version": "$(agvtool what-marketing-version -terse1)",
    "build_number": "$(agvtool what-version -terse)",
    "branch": "${GITHUB_REF_NAME:-unknown}",
    "commit": "${GITHUB_SHA:-unknown}"
}
JSON
EOF
    
    chmod +x "$PROJECT_DIR/Scripts/collect-build-metrics.sh"
    
    print_message $GREEN "Build metrics collection setup complete"
}

# Main setup function
main() {
    print_message $BLUE "🚀 LeavnSuperOfficial Monitoring Setup"
    print_message $BLUE "====================================="
    echo ""
    
    case "${1:-all}" in
        crashlytics)
            setup_crashlytics
            ;;
        analytics)
            setup_analytics
            ;;
        performance)
            setup_performance_monitoring
            ;;
        notifications)
            setup_notifications
            ;;
        metrics)
            setup_build_metrics
            ;;
        all)
            setup_crashlytics
            setup_analytics
            setup_performance_monitoring
            setup_notifications
            setup_build_metrics
            ;;
        *)
            echo "Usage: $0 [all|crashlytics|analytics|performance|notifications|metrics]"
            exit 1
            ;;
    esac
    
    echo ""
    print_message $GREEN "✅ Monitoring setup complete!"
    print_message $YELLOW "Next steps:"
    print_message $YELLOW "1. Add GoogleService-Info.plist for Firebase"
    print_message $YELLOW "2. Configure analytics API keys in .env"
    print_message $YELLOW "3. Set up Slack webhook for notifications"
    print_message $YELLOW "4. Enable desired monitoring services"
}

# Run main function
main "$@"