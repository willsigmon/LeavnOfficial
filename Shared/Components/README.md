# Reusable Components Library

This library provides a comprehensive set of reusable UI components designed to ensure consistency across the Leavn app while reducing code duplication.

## Components Overview

### Base Components (`BaseComponents.swift`)

#### BaseCard
A flexible card component that can be used throughout the app for consistent styling.

```swift
BaseCard(
    style: .elevated,
    shadowStyle: .medium,
    tapAction: { /* handle tap */ }
) {
    VStack(alignment: .leading, spacing: 8) {
        Text("Card Title")
            .font(.headline)
        Text("Card content...")
            .foregroundColor(.secondary)
    }
}
```

**Styles:**
- `.elevated` - Standard elevated card with shadow
- `.filled` - Filled background card
- `.outlined` - Card with border only
- `.minimal` - Minimal styling

**Shadow Styles:**
- `.none` - No shadow
- `.light` - Light shadow
- `.medium` - Medium shadow (default)
- `.heavy` - Heavy shadow

#### BaseActionButton
Consistent button styling with various styles and sizes.

```swift
BaseActionButton(
    title: "Continue",
    icon: "arrow.right",
    style: .primary,
    size: .medium,
    isLoading: false,
    action: { /* handle action */ }
)
```

**Styles:**
- `.primary` - Primary action button
- `.secondary` - Secondary action button
- `.outline` - Outlined button
- `.ghost` - Ghost button (no background)
- `.destructive` - Destructive action button

**Sizes:**
- `.small` - Small button
- `.medium` - Medium button (default)
- `.large` - Large button

#### BaseIconButton
Icon-only buttons for actions like bookmark, share, etc.

```swift
BaseIconButton(
    icon: "heart.fill",
    style: .filled,
    size: .medium,
    action: { /* handle action */ }
)
```

#### BaseListItem
Consistent list item styling with optional disclosure indicator.

```swift
BaseListItem(
    showDisclosureIndicator: true,
    action: { /* handle tap */ }
) {
    HStack {
        Image(systemName: "gear")
        Text("Settings")
    }
}
```

#### BaseLoadingView
Consistent loading states across the app.

```swift
BaseLoadingView(
    message: "Loading...",
    style: .standard
)
```

#### BaseErrorView & BaseEmptyStateView
Consistent error and empty state presentations.

```swift
BaseErrorView(
    title: "Error",
    message: "Something went wrong",
    icon: "exclamationmark.triangle",
    retryAction: { /* retry */ }
)

BaseEmptyStateView(
    title: "No Data",
    message: "There's nothing to display",
    icon: "tray",
    actionTitle: "Refresh",
    action: { /* refresh */ }
)
```

### Bible-Specific Components (`BibleComponents.swift`)

#### BibleVerseCard
Specialized card for displaying Bible verses with actions.

```swift
BibleVerseCard(
    verse: bibleVerse,
    isHighlighted: true,
    isBookmarked: false,
    onHighlight: { /* handle highlight */ },
    onBookmark: { /* handle bookmark */ },
    onShare: { /* handle share */ },
    onNote: { /* handle note */ }
)
```

#### ReadingPlanCard
Card for displaying reading plan progress.

```swift
ReadingPlanCard(
    plan: ReadingPlanCard.ReadingPlan(
        title: "One Year Bible",
        description: "Read through the entire Bible in 365 days",
        currentDay: 127,
        totalDays: 365,
        todaysReading: ["Genesis 8-10", "Matthew 4"]
    ),
    onTap: { /* view plan */ },
    onContinue: { /* continue reading */ }
)
```

#### LifeSituationCard
Card for displaying life situation categories.

```swift
LifeSituationCard(
    situation: LifeSituationCard.LifeSituation(
        title: "Anxiety",
        description: "Find peace and comfort",
        icon: "heart.fill",
        accentColor: .blue,
        verseCount: 25
    ),
    onTap: { /* handle tap */ }
)
```

#### BookSelectionCard
Card for selecting Bible books.

```swift
BookSelectionCard(
    book: BookSelectionCard.BibleBook(
        name: "Genesis",
        testament: .old,
        chapterCount: 50,
        summary: "The book of beginnings"
    ),
    isSelected: true,
    onTap: { /* handle selection */ }
)
```

### Error Handling (`ErrorHandling.swift`)

#### AppError
Standardized error types with recovery suggestions.

```swift
enum AppError: Error {
    case networkError(String)
    case dataLoadingError(String)
    case authenticationError(String)
    case validationError(String)
    case unknownError(String)
}
```

#### LoadingStateView
Handles loading, error, and empty states in one component.

```swift
LoadingStateView(
    isLoading: isLoading,
    error: error,
    isEmpty: isEmpty,
    emptyTitle: "No Data",
    emptyMessage: "Nothing to display",
    emptyIcon: "tray",
    onRetry: { /* retry action */ }
) {
    // Your content goes here
    ContentView()
}
```

### View Modifiers (`ViewModifiers.swift`)

#### Card Modifiers
```swift
// Standard card styling
.cardStyle()

// Minimal card styling
.minimalCardStyle()

// Elevated card styling
.elevatedCardStyle()
```

#### Button Modifiers
```swift
// Primary button
.primaryButtonStyle()

// Secondary button
.secondaryButtonStyle()

// Outline button
.outlineButtonStyle()

// Destructive button
.destructiveButtonStyle()
```

#### Loading Modifiers
```swift
// Loading overlay
.loadingOverlay(isLoading: isLoading, message: "Loading...")

// Skeleton loading
.skeletonLoading(isLoading: isLoading)
```

#### Error Handling Modifiers
```swift
// Error alert
.errorAlert(error: $error) { /* retry */ }

// Error banner
.errorBanner(error: $error) { /* retry */ }

// Error handling overlay
.errorHandling(error: $error) { /* retry */ }
```

#### Animation Modifiers
```swift
// Bounce animation
.bounceAnimation(trigger: isPressed)

// Fade animation
.fadeAnimation(isVisible: isVisible)

// Slide animation
.slideAnimation(isVisible: isVisible)
```

#### Accessibility Modifiers
```swift
// Accessible card
.accessibleCard(
    label: "Information card",
    hint: "Double tap to open"
)

// Accessible button
.accessibleButton(
    label: "Action button",
    hint: "Double tap to perform action"
)
```

## Usage Guidelines

### 1. Consistency
Always use the base components instead of creating custom UI elements. This ensures visual consistency across the app.

### 2. Theming
Components automatically adapt to the app's color scheme and accessibility settings.

### 3. Performance
Components are optimized for performance and include proper accessibility support.

### 4. Customization
While components provide sensible defaults, they can be customized through parameters and styling options.

## Migration Guide

### Replacing Existing Components

#### Before:
```swift
VStack {
    Text("Title")
        .font(.headline)
    Text("Content")
        .foregroundColor(.secondary)
}
.padding()
.background(Color(.systemBackground))
.cornerRadius(12)
.shadow(radius: 5)
```

#### After:
```swift
BaseCard {
    VStack(alignment: .leading, spacing: 8) {
        Text("Title")
            .font(.headline)
        Text("Content")
            .foregroundColor(.secondary)
    }
}
```

### Updating Button Styles

#### Before:
```swift
Button("Action") { /* action */ }
    .foregroundColor(.white)
    .padding()
    .background(Color.blue)
    .cornerRadius(8)
```

#### After:
```swift
BaseActionButton(
    title: "Action",
    style: .primary,
    action: { /* action */ }
)
```

### Updating Loading States

#### Before:
```swift
if isLoading {
    ProgressView("Loading...")
} else if let error = error {
    VStack {
        Text("Error")
        Button("Retry") { /* retry */ }
    }
} else {
    ContentView()
}
```

#### After:
```swift
LoadingStateView(
    isLoading: isLoading,
    error: error,
    onRetry: { /* retry */ }
) {
    ContentView()
}
```

## Best Practices

1. **Use the right component for the job** - Choose the most appropriate component for your use case
2. **Follow the design system** - Use consistent spacing, colors, and typography
3. **Test accessibility** - Ensure your usage works well with VoiceOver and other accessibility features
4. **Handle edge cases** - Consider loading, error, and empty states
5. **Keep it simple** - Don't over-customize components; trust the design system

## Examples

See `ComponentUsageExamples.swift` for comprehensive usage examples of all components and modifiers.

## Contributing

When adding new components:
1. Follow the existing naming conventions
2. Include accessibility support
3. Add comprehensive documentation
4. Provide usage examples
5. Test across different screen sizes and accessibility settings