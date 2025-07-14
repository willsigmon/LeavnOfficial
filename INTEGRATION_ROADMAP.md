# LeavniOS Integration Roadmap - Final 20%

## Build Status
- ✅ SyncManager.swift - Memory management fixed
- ✅ HapticManager.swift - Platform compatibility fixed  
- ⚠️ AnimatedGradientBackground - Possible stale build artifacts (run clean_build.sh)

## Clean Build Instructions
```bash
chmod +x clean_build.sh
./clean_build.sh
xcodebuild -scheme 'Leavn' -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max,OS=latest' build
```

## Critical Integration Tasks

### 1. 🔴 Community Features (HIGH PRIORITY)
**Files to modify:**
- `/Modules/Community/ViewModels/CommunityViewModel.swift`
- `/Packages/LeavnCore/Sources/LeavnServices/FirebaseService.swift`

**Tasks:**
```swift
// In CommunityViewModel.swift - Replace empty methods:
private func loadPosts() async throws -> [CommunityPost] {
    return try await firebaseService.getCommunityPosts(limit: 50)
}

// In FirebaseService.swift - Implement TODOs:
- getPrayerRequests() 
- createPrayerRequest()
- prayForRequest()
- leaveGroup()
```

### 2. 🟡 Firebase Service Completion
**Location:** `/Packages/LeavnCore/Sources/LeavnServices/FirebaseService.swift`

**Required implementations:**
- Line 384: Implement real Firestore fetch
- Line 390: Implement real Firestore create  
- Line 396, 415: Implement real Firestore update
- Add proper error handling instead of print statements

### 3. 🟡 AI Service Improvements
**Location:** `/Packages/LeavnCore/Sources/LeavnServices/IlluminateService.swift`

**Priority TODOs:**
1. Replace random cache eviction with LRU (line 7)
2. Add JSON parsing for AI outputs (line 10)
3. Add structured logging (line 11)
4. Implement dependency injection (line 14)

### 4. 🟢 Authentication Flow
**Verify these work end-to-end:**
- Sign in with Apple
- Passkey authentication
- Anonymous user upgrade
- Session persistence

### 5. 🟢 Offline Support
**Add offline fallbacks for:**
- Bible reading (already has OfflineBibleData)
- Library items
- Reading plans
- Recent searches

### 6. 🔵 UI/Service Connections
**Ensure real data flows:**
- Bible tab → GetBibleService ✓
- Library tab → ProductionLibraryService ✓
- Search tab → ProductionSearchService ✓
- Community tab → FirebaseService ❌
- Settings → UserDataManager ✓

### 7. 🔵 Error Handling & Loading States
**Add proper error handling:**
```swift
// Replace this pattern:
} catch {
    print("Error: \(error)")
}

// With this:
} catch {
    self.error = error
    self.showError = true
    // Log to analytics
}
```

### 8. 🟣 Configuration & Environment
**Files to update:**
- Set production API keys
- Configure Firebase
- Set GetBible API token
- Configure analytics endpoints

### 9. 🟣 Testing Integration Points
**Create integration tests for:**
- Service → Backend API
- ViewModel → Service
- Offline → Online sync
- Error scenarios

### 10. ⚪ Polish & Performance
- Add loading skeletons
- Implement image caching
- Add pull-to-refresh
- Optimize list performance
- Add haptic feedback

## Quick Wins (Can do in parallel)
1. Remove empty `MockCommunityService.swift`
2. Add loading states to all ViewModels
3. Replace print statements with Logger
4. Add @MainActor to UI-updating methods
5. Test offline mode thoroughly

## Validation Checklist
- [ ] Build completes without errors
- [ ] All tabs load real data
- [ ] Offline mode works
- [ ] Authentication flows work
- [ ] Community features connect to Firebase
- [ ] Search returns real results
- [ ] Settings persist across launches
- [ ] No placeholder/mock data visible

## Next Immediate Steps
1. Run `clean_build.sh` to clear stale artifacts
2. Verify build succeeds
3. Start with Community Firebase integration
4. Test each feature with real data
5. Add comprehensive error handling

The app structure is solid - just needs the final connections between UI and services!