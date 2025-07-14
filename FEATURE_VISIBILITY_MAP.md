# Leavn Feature Visibility Map
*Generated: December 2024*

## Overview
This document maps all implemented features in the Leavn codebase and their current UI visibility status.

## Feature Status Legend
- ✅ **Visible** - Feature is accessible through main UI
- 🚨 **Hidden** - Feature is implemented but not accessible
- ⚠️ **Partial** - Feature is partially exposed
- 🏗️ **In Progress** - Feature is being developed

## Core Features

### Bible Module
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Bible Reading | ✅ Visible | Bible Tab | Main reading interface |
| Verse Navigation | ✅ Visible | Bible Tab | Chapter/verse navigation |
| Parallel View | 🚨 Hidden | BibleView | Code exists, not exposed |
| Audio Bible | 🚨 Hidden | BibleView | Voiceover ready, not accessible |
| Verse Comparison | ⚠️ Partial | Bible Tab | Limited to current view |
| Study Notes | ✅ Visible | Bible Tab | Basic implementation |

### Community Module
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Community Feed | 🚨 Hidden | CommunityView | Fully implemented, disabled |
| Prayer Wall | 🚨 Hidden | PrayerWallView | Complete but inaccessible |
| Groups | 🚨 Hidden | GroupsView | Backend ready, no UI path |
| Challenges | 🚨 Hidden | ChallengesView | Gamification ready |
| Social Features | 🚨 Hidden | Throughout | Likes, comments, shares |

### Discovery Module
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Discover Tab | 🚨 Hidden | DiscoverView | Complete UI, not in tabs |
| Devotions | 🚨 Hidden | DevotionsView | Content exists |
| Reading Plans | ⚠️ Partial | Library Tab | Limited exposure |
| Topics Browse | 🚨 Hidden | TopicsView | Categorized content ready |

### Life Situations
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Life Situations Engine | 🚨 Hidden | Service only | No UI at all |
| Contextual Verses | 🚨 Hidden | Backend ready | Engine initialized |
| Situation Categories | 🚨 Hidden | Models exist | No interface |

### Maps & Atlas
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| Biblical Atlas | 🚨 Hidden | AncientMapView | Fully implemented |
| Journey Routes | 🚨 Hidden | MapRoutes | Paul's journeys, etc. |
| Location Details | 🚨 Hidden | LocationView | Historical context |

### AI Features
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| AI Search | ✅ Visible | Search Tab | Basic implementation |
| AI Guardrails | ⚠️ Partial | Backend | Limited UI exposure |
| AI Monitoring | ✅ Visible | Settings | Debug view only |
| Smart Insights | 🚨 Hidden | Service ready | No UI component |

### Platform Features
| Feature | Status | Location | Notes |
|---------|--------|----------|-------|
| iOS Widgets | 🚨 Hidden | Widget Extension | Not configured |
| watchOS App | 🚨 Hidden | Watch target | Components exist |
| visionOS Experience | 🚨 Hidden | Vision target | Immersive views ready |
| macOS App | ⚠️ Partial | Mac target | Basic window only |

## Quick Wins to Surface Features

### 1. Enable Community Tab (1 hour)
```swift
// In MainTabView.swift, uncomment:
.tabItem {
    Image(systemName: "person.3.fill")
    Text("Community")
}
```

### 2. Add Discover Tab (30 mins)
```swift
// Add to MainTabView tabs:
NavigationStack(path: bindingForTab(.discover)) {
    DiscoverView()
}
.tag(MainTab.discover)
.tabItem {
    Image(systemName: "sparkles")
    Text("Discover")
}
```

### 3. Surface Biblical Atlas (2 hours)
- Add button in Bible view toolbar
- Or add as Library section
- Link to AncientMapView

### 4. Create Life Situations UI (4 hours)
- Design simple category picker
- Connect to existing engine
- Add to Home or Discover tab

### 5. Enable Platform Features (per platform)
- Configure widget extension
- Enable watch/vision targets
- Test platform-specific views

## Recommended Tab Structure

```
1. Home (current)
2. Bible (current) 
3. Discover (add) - Devotions, Plans, Topics
4. Community (enable) - Feed, Prayer, Groups
5. Library (current)
6. Settings (current)
```

## Next Steps

1. **Immediate**: Enable Community and Discover tabs
2. **Week 1**: Surface Atlas and Life Situations
3. **Week 2**: Configure platform features
4. **Ongoing**: Add feature flags for gradual rollout

## Notes
- Most "hidden" features are 90-100% complete
- Primary issue is navigation/discoverability
- No technical blockers, just UI wiring needed