# Plane Testing Setup Guide

## Overview

This guide provides comprehensive instructions for setting up and configuring plane testing environments for the Leavn application. Plane testing allows us to test the application in various network conditions, including offline scenarios, to ensure robust performance and data synchronization.

## Environment Setup

### Prerequisites
- Xcode 26 or later
- macOS 26 or later
- Physical iOS devices (recommended for accurate testing)
- Charles Proxy or similar network debugging tool
- Access to TestFlight for beta testing

### Test Environment Configuration

#### 1. Network Conditioning
Configure network conditions to simulate various scenarios:

```bash
# Enable Network Link Conditioner on macOS
sudo systemsetup -setnetworkserviceenabled "Network Link Conditioner" on
```

**Preset Profiles:**
- **Airplane Mode**: No connectivity
- **Poor Connection**: 100% packet loss periodically
- **Edge Network**: 50 Kbps bandwidth
- **3G Network**: 780 Kbps bandwidth
- **Lossy Network**: 10% packet loss

#### 2. Device Configuration

**iOS Devices:**
1. Enable Developer Mode: Settings → Privacy & Security → Developer Mode
2. Install network debugging profiles
3. Configure proxy settings for Charles/Proxyman

**Simulator Setup:**
```bash
# Set up simulator for offline testing
xcrun simctl shutdown all
xcrun simctl erase all
xcrun simctl boot "iPhone 15 Pro"
```

### CloudKit Testing Environment

#### Development Container
```swift
// Config/CloudKitConfig.swift
struct CloudKitConfig {
    static let container: CKContainer = {
        #if DEBUG
        return CKContainer(identifier: "iCloud.com.leavn.development")
        #else
        return CKContainer(identifier: "iCloud.com.leavn.production")
        #endif
    }()
}
```

#### Test Data Seeding
```swift
// TestData/CloudKitSeeder.swift
class CloudKitSeeder {
    static func seedTestData() async throws {
        let employees = createTestEmployees()
        let leaves = createTestLeaves()
        
        for employee in employees {
            try await CloudKitService.shared.save(employee)
        }
        
        for leave in leaves {
            try await CloudKitService.shared.save(leave)
        }
    }
    
    private static func createTestEmployees() -> [Employee] {
        return [
            Employee(id: "emp001", name: "John Doe", department: "Engineering"),
            Employee(id: "emp002", name: "Jane Smith", department: "Design"),
            Employee(id: "emp003", name: "Bob Johnson", department: "HR")
        ]
    }
    
    private static func createTestLeaves() -> [Leave] {
        return [
            Leave(employeeId: "emp001", type: .annual, startDate: Date(), endDate: Date().addingDays(5)),
            Leave(employeeId: "emp002", type: .sick, startDate: Date(), endDate: Date().addingDays(2)),
            Leave(employeeId: "emp003", type: .personal, startDate: Date(), endDate: Date().addingDays(1))
        ]
    }
}
```

## Plane Testing Configuration

### 1. Offline Mode Testing

#### Enable Airplane Mode Simulation
```swift
// Services/NetworkManager.swift
class NetworkManager: ObservableObject {
    @Published var isOffline = false
    
    #if DEBUG
    func simulateAirplaneMode() {
        isOffline = true
        // Disable all network requests
        URLSession.shared.configuration.urlCache?.removeAllCachedResponses()
    }
    #endif
}
```

#### Local Data Persistence
```swift
// Services/OfflineDataService.swift
class OfflineDataService {
    private let localStore = UserDefaults.standard
    private let coreDataStack = CoreDataStack.shared
    
    func cacheForOffline<T: Codable>(_ data: T, key: String) {
        if let encoded = try? JSONEncoder().encode(data) {
            localStore.set(encoded, forKey: "offline_\(key)")
        }
    }
    
    func retrieveOfflineData<T: Codable>(_ type: T.Type, key: String) -> T? {
        guard let data = localStore.data(forKey: "offline_\(key)") else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
```

### 2. Sync Testing Setup

#### Conflict Resolution Testing
```swift
// Tests/SyncTests.swift
class SyncConflictTests: XCTestCase {
    func testConflictingLeaveRequests() async throws {
        // Create conflicting changes on two devices
        let device1Change = Leave(id: "leave001", status: .approved)
        let device2Change = Leave(id: "leave001", status: .rejected)
        
        // Test conflict resolution
        let resolved = try await SyncService.resolveConflict(device1Change, device2Change)
        XCTAssertEqual(resolved.status, .approved) // Last write wins
    }
}
```

#### Multi-Device Sync Testing
```bash
# Script to test multi-device sync
#!/bin/bash

# Launch multiple simulators
xcrun simctl boot "iPhone 15 Pro"
xcrun simctl boot "iPad Pro (12.9-inch)"

# Install app on both
xcrun simctl install "iPhone 15 Pro" path/to/Leavn.app
xcrun simctl install "iPad Pro (12.9-inch)" path/to/Leavn.app

# Launch apps
xcrun simctl launch "iPhone 15 Pro" com.leavn.app
xcrun simctl launch "iPad Pro (12.9-inch)" com.leavn.app
```

### 3. Performance Testing

#### Network Latency Simulation
```swift
// Tests/NetworkLatencyTests.swift
class NetworkLatencyTests: XCTestCase {
    func testHighLatencySync() async throws {
        // Configure high latency
        NetworkConditioner.shared.setLatency(1000) // 1 second
        
        let startTime = Date()
        try await SyncService.shared.performSync()
        let syncTime = Date().timeIntervalSince(startTime)
        
        XCTAssertLessThan(syncTime, 5.0) // Should complete within 5 seconds
    }
}
```

## Test Scenarios

### Scenario 1: Complete Offline Usage
1. Enable airplane mode
2. Create new leave request
3. Modify existing leave
4. Delete leave request
5. Disable airplane mode
6. Verify all changes sync correctly

### Scenario 2: Intermittent Connectivity
1. Start with good connection
2. Create leave request (should sync)
3. Enable airplane mode
4. Modify leave request
5. Re-enable connectivity
6. Verify changes merge correctly

### Scenario 3: Conflict Resolution
1. Setup two devices with same account
2. Enable airplane mode on both
3. Make conflicting changes
4. Re-enable connectivity
5. Verify conflict resolution works correctly

### Scenario 4: Large Data Sync
1. Create 1000+ leave records
2. Enable airplane mode
3. Make bulk modifications
4. Re-enable connectivity
5. Monitor sync performance

## Automated Testing Scripts

### Setup Script
```bash
#!/bin/bash
# setup_plane_testing.sh

echo "Setting up Plane Testing Environment..."

# Install dependencies
brew install charles
brew install proxyman

# Configure test data
echo "Seeding test data..."
swift run seed-test-data

# Setup network profiles
networksetup -createnetworkservice "Airplane Mode" "Wi-Fi"
networksetup -setnetworkserviceenabled "Airplane Mode" off

echo "Plane testing environment ready!"
```

### Test Runner Script
```bash
#!/bin/bash
# run_plane_tests.sh

# Run offline tests
echo "Running offline tests..."
xcodebuild test \
  -scheme Leavn \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:LeavnTests/OfflineTests

# Run sync tests
echo "Running sync tests..."
xcodebuild test \
  -scheme Leavn \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  -only-testing:LeavnTests/SyncTests

# Generate report
xcrun xcresulttool generate-report \
  --path TestResults.xcresult \
  --output-path TestReport.html
```

## Monitoring and Debugging

### CloudKit Dashboard
1. Log into CloudKit Dashboard
2. Select Development environment
3. Monitor:
   - Record changes
   - Sync operations
   - Error logs
   - Performance metrics

### Console Logging
```swift
// Utilities/DebugLogger.swift
class DebugLogger {
    static func logSyncOperation(_ operation: String, data: Any? = nil) {
        #if DEBUG
        print("🔄 SYNC: \(operation)")
        if let data = data {
            print("📦 DATA: \(data)")
        }
        #endif
    }
    
    static func logOfflineOperation(_ operation: String) {
        #if DEBUG
        print("✈️ OFFLINE: \(operation)")
        #endif
    }
}
```

### Network Debugging
```swift
// Configure URLSession for debugging
let config = URLSessionConfiguration.default
config.httpAdditionalHeaders = ["X-Debug-Mode": "true"]
config.timeoutIntervalForRequest = 30
config.waitsForConnectivity = true
```

## Troubleshooting

### Common Issues

**Issue: Sync not triggering after airplane mode**
```swift
// Solution: Force sync on network restoration
class NetworkMonitor {
    func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                Task {
                    try await SyncService.shared.performSync()
                }
            }
        }
    }
}
```

**Issue: Data conflicts not resolving**
```swift
// Solution: Implement proper conflict resolution
extension CKRecord {
    func resolveConflicts(with serverRecord: CKRecord) -> CKRecord {
        // Implement last-write-wins strategy
        if self.modificationDate! > serverRecord.modificationDate! {
            return self
        }
        return serverRecord
    }
}
```

**Issue: Performance degradation with large datasets**
```swift
// Solution: Implement batch processing
class BatchSyncService {
    func syncInBatches(records: [CKRecord]) async throws {
        for batch in records.chunked(into: 100) {
            try await cloudKit.save(batch)
            try await Task.sleep(nanoseconds: 100_000_000) // 100ms delay
        }
    }
}
```

## Best Practices

1. **Always test on real devices** for accurate network behavior
2. **Use TestFlight** for beta testing in real-world conditions
3. **Monitor CloudKit quotas** during heavy testing
4. **Implement proper error handling** for all network operations
5. **Test edge cases** like storage full, no iCloud account, etc.
6. **Document test results** for future reference
7. **Automate regression tests** for critical sync scenarios

## Conclusion

Proper plane testing setup ensures the Leavn app provides a seamless experience regardless of network conditions. Regular testing using these configurations helps identify and resolve sync issues before they impact users.