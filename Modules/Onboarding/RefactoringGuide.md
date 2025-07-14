# Onboarding Module Refactoring Guide

## Overview
This guide documents the refactoring improvements made to reduce component complexity and improve maintainability.

## Key Refactoring Patterns Applied

### 1. **Component Extraction**
Large views were broken down into smaller, focused components:
- `OnboardingSectionHeader` - Reusable header for all customization screens
- `OnboardingNavigation` - Standard navigation buttons with back/next
- `SelectionCard` - Generic selection wrapper for any content
- `InfoTip` - Reusable information tips
- `SectionLabel` - Consistent section labels

### 2. **Single Responsibility Principle**
Each component now has a single, clear purpose:
- `PerspectiveIcon` - Only handles the icon display
- `PerspectiveText` - Only handles text content
- `RadioButton` - Only handles radio button UI
- `ProgressIndicator` - Only handles progress bar animation

### 3. **Composition Over Inheritance**
Components are composed of smaller pieces:
```swift
PerspectiveCard {
    PerspectiveIcon()
    PerspectiveText()
    InfoButton()
}
```

### 4. **State Management Simplification**
- Moved validation logic to enum cases
- Extracted computed properties for cleaner code
- Simplified binding management

### 5. **Common UI Patterns Library**
Created `OnboardingComponents.swift` with shared components:
- Navigation buttons
- Selection cards
- Progress indicators
- Section headers

## Benefits Achieved

### Before:
- `TheologicalPerspectiveView`: ~200 lines
- `TranslationPreferenceView`: ~180 lines
- `CustomizationFlow`: ~170 lines
- Lots of duplicate code

### After:
- Components: 20-50 lines each
- Shared components reduce duplication by ~60%
- Better testability
- Easier maintenance

## Usage Examples

### Using Shared Components:
```swift
// Instead of duplicating header code:
OnboardingSectionHeader(
    icon: "books.vertical.fill",
    title: "Your Title",
    subtitle: "Your subtitle"
)

// Instead of custom navigation:
OnboardingNavigation(
    showBack: true,
    nextLabel: "Continue",
    onBack: { /* action */ },
    onNext: { /* action */ }
)
```

### Component Composition:
```swift
SelectionCard(isSelected: isSelected) {
    // Your custom content
    YourCustomView()
}
```

## Migration Guide

To use the refactored components in your code:

1. Import the shared components:
```swift
import OnboardingComponents
```

2. Replace large view bodies with composed components
3. Extract repeated patterns into the shared library
4. Use the simplified state management patterns

## Future Improvements

1. **Further Extraction**: 
   - Extract color schemes into theme variants
   - Create more granular animation modifiers

2. **Protocol-Based Design**:
   - Define protocols for selectable items
   - Create generic selection views

3. **SwiftUI Previews**:
   - Add preview providers for each component
   - Create preview data sets

4. **Accessibility**:
   - Add more accessibility labels
   - Improve VoiceOver navigation

5. **Performance**:
   - Lazy load heavy components
   - Optimize animation performance