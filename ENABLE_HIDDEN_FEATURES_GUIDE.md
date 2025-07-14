# Guide to Enable Hidden Features in Leavn

This guide provides step-by-step instructions to surface all the hidden features discovered in the codebase audit.

## Quick Wins (Can be done immediately)

### 1. Enable Community Tab (15 minutes)

**Step 1**: Update MainTab enum in `MainTabView.swift`:
```swift
@MainActor
private enum MainTab: Int, CaseIterable {
    case home = 0, bible, search, discover, community, library, settings
}
```

**Step 2**: Add Community tab in TabView:
```swift
// After Search tab, before Library tab
NavigationStack(path: bindingForTab(.community)) {
    CommunityView()
        .navigationDestination(for: NavigationDestination.self) { destination in
            destinationView(for: destination)
        }
}
.tag(MainTab.community)
.tabItem {
    Image(systemName: "person.3.fill")
    Text("Community")
}
.accessibilityIdentifier("communityTab")
```

**Step 3**: Update helper functions:
```swift
// In icon(for:) function, add:
case .community: "person.3.fill"

// In title(for:) function, add:
case .community: "Community"

// In mapToAppTab() function, add:
case .community: return .community

// In mapFromAppTab() function, add:
case .community: return .community
```

**Step 4**: Import the module at top of file:
```swift
import LeavnCommunity
```

### 2. Enable Discover Tab (15 minutes)

Follow same pattern as Community:
- Add `.discover` to MainTab enum
- Add Discover NavigationStack with icon "sparkles"
- Update helper functions
- Import `LeavnDiscover`

### 3. Surface Biblical Atlas (30 minutes)

**Option A**: Add to Bible View toolbar
```swift
// In BibleView.swift toolbar:
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Button(action: { showAtlas = true }) {
            Image(systemName: "map.fill")
        }
    }
}
.sheet(isPresented: $showAtlas) {
    AncientMapView()
}
```

**Option B**: Add as Library section
```swift
// In LibraryView, add section:
Section("Biblical Resources") {
    NavigationLink(destination: AncientMapView()) {
        Label("Biblical Atlas", systemImage: "map.fill")
    }
}
```

### 4. Create Life Situations UI (2 hours)

Create a simple view to connect to the existing engine:

```swift
// New file: LifeSituationsView.swift
import SwiftUI
import LeavnServices

struct LifeSituationsView: View {
    @StateObject private var lifeSituationsEngine = DIContainer.shared.lifeSituationsEngine
    @State private var selectedCategory: String?
    
    let categories = [
        "Anxiety & Worry",
        "Grief & Loss", 
        "Relationships",
        "Work & Career",
        "Faith & Doubt",
        "Joy & Gratitude"
    ]
    
    var body: some View {
        NavigationView {
            List(categories, id: \.self) { category in
                NavigationLink(destination: SituationVersesView(category: category)) {
                    Label(category, systemImage: iconForCategory(category))
                }
            }
            .navigationTitle("Life Situations")
        }
    }
}
```

Add to Home view or as a card in Discover tab.

## Module Configuration Updates

### 1. Update Modules/Package.swift

Add these products:
```swift
.library(name: "LeavnCommunity", targets: ["LeavnCommunity"]),
.library(name: "LeavnDiscover", targets: ["LeavnDiscover"]),
```

Add these targets:
```swift
.target(
    name: "LeavnCommunity",
    dependencies: ["LeavnCore", "DesignSystem"],
    path: "Community"
),
.target(
    name: "LeavnDiscover", 
    dependencies: ["LeavnCore", "DesignSystem", "LeavnBible"],
    path: "Discover"
),
```

### 2. Update AppTab enum in NavigationCoordinator

Add cases:
```swift
public enum AppTab: Int, CaseIterable {
    case home, bible, search, discover, community, library, settings
}
```

### 3. Remove "disabled" message from CommunityView

In `CommunityView.swift`, remove or comment out:
```swift
// Remove this block:
Text("Community features temporarily disabled for build")
    .font(.caption)
    .foregroundColor(.secondary)
    .padding()
```

## Platform Features

### Enable iOS Widgets
1. Add Widget Extension target if not exists
2. Configure widget provider with daily verse
3. Add to App Extensions in project settings

### Enable watchOS App
1. Ensure watchOS target is active
2. Test WatchMainView and WatchBibleView
3. Configure complications if desired

### Enable visionOS Experience  
1. Activate visionOS target
2. Test VisionMainView and immersive spaces
3. Configure spatial interactions

## Feature Flags (Recommended)

Create a simple feature flag system:

```swift
// FeatureFlags.swift
struct FeatureFlags {
    static let isCommunityEnabled = true
    static let isDiscoverEnabled = true
    static let isLifeSituationsEnabled = false
    static let isBiblicalAtlasEnabled = true
}
```

Use in MainTabView:
```swift
if FeatureFlags.isCommunityEnabled {
    // Show Community tab
}
```

## Testing Checklist

After enabling features:
- [ ] Build succeeds without errors
- [ ] All new tabs appear and load correctly
- [ ] Navigation works between all tabs
- [ ] No crashes when accessing new features
- [ ] Performance remains smooth
- [ ] Memory usage is reasonable

## Rollback Plan

If issues arise:
1. Comment out new tabs in MainTabView
2. Keep imports but don't use views
3. Set feature flags to false
4. Focus on fixing one feature at a time

## Next Steps

1. **Week 1**: Enable Community and Discover tabs
2. **Week 2**: Add Biblical Atlas and Life Situations
3. **Week 3**: Platform-specific features
4. **Week 4**: Polish and optimize

Remember: Most of these features are 90-100% complete. The main work is just connecting them to the navigation!