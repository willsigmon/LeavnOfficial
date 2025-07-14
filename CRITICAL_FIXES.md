# Critical Fixes for LeavnOfficial

## 1. Fix Missing `await` in SettingsView.swift

**File**: `/Modules/Settings/Views/SettingsView.swift`
**Line**: 131

**Current Code**:
```swift
Task {
    viewModel.forceSyncWithiCloud()
}
```

**Fixed Code**:
```swift
Task {
    await viewModel.forceSyncWithiCloud()
}
```

## 2. Fix Missing Components in SearchView.swift

**File**: `/Modules/Search/Views/SearchView.swift`

### Option A: Uncomment the import
**Line 3**: Uncomment the DesignSystem import
```swift
import DesignSystem
```

### Option B: Create simple replacements
If DesignSystem is not available, replace the placeholder comments with actual views:

**Line 26**: Replace comment with actual background
```swift
Color(.systemBackground).ignoresSafeArea()
```

**Lines 35, 83**: Replace VibrantLoadingView placeholder
```swift
ProgressView("Loading Search...")
    .progressViewStyle(CircularProgressViewStyle())
```

## 3. Add Container Initialization Check in SearchView.swift

**File**: `/Modules/Search/Views/SearchView.swift`
**Line**: 328

**Current Code**:
```swift
guard let aiService = container.aiService else {
    aiResponse = "AI service is not available. Please try again later."
    return
}
```

**Fixed Code**:
```swift
guard container.isInitialized, let aiService = container.aiService else {
    aiResponse = "AI service is not available. Please try again later."
    return
}
```

## 4. Fix Debounce Task Memory Management

**File**: `/Modules/Search/Views/SearchView.swift`

Add onDisappear modifier after line 74:
```swift
.onDisappear {
    searchDebounceTask?.cancel()
}
```

## Testing After Fixes

Run these commands to verify the fixes:

```bash
# Clean build folder
xcodebuild clean -project Leavn.xcodeproj -scheme Leavn

# Build for simulator
xcodebuild build -project Leavn.xcodeproj -scheme Leavn -sdk iphonesimulator -configuration Debug

# Run tests
xcodebuild test -project Leavn.xcodeproj -scheme Leavn -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15'
```

These fixes should resolve the most critical build and runtime issues.