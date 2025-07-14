# Leavn Accessibility & Theme Guide

## Overview
The Leavn app implements comprehensive accessibility features to ensure WCAG 2.1 AA compliance and excellent user experience for all users, including those with disabilities.

## Key Features

### 1. WCAG 2.1 AA Compliance
- All color combinations meet minimum contrast ratios:
  - Normal text: 4.5:1
  - Large text: 3.0:1
  - UI components: 3.0:1
- Proper focus indicators for keyboard navigation
- Sufficient touch targets (minimum 44x44 points)

### 2. Dynamic Type Support
- All text scales with system Dynamic Type settings
- Maximum scaling limited to Accessibility3 to prevent layout issues
- Automatic line height and spacing adjustments

### 3. High Contrast Mode
- Automatic detection of system high contrast preference
- Enhanced colors with stronger contrast ratios
- Reduced visual complexity (solid colors instead of gradients)
- Stronger borders and separators

### 4. Dark Mode Support
- Full dark mode implementation with proper contrast
- Separate color sets for light/dark/high contrast modes
- Smooth transitions between modes

### 5. Reduce Motion
- Respects system reduce motion preference
- Disables non-essential animations
- Maintains functional feedback

## Usage Guide

### Accessible Text Components

```swift
// Basic text with automatic scaling
AccessibleText("Hello World", style: .body)

// Custom colored text with proper contrast checking
AccessibleText("Important", style: .headline, color: .red)

// Section headers with proper accessibility traits
AccessibleSectionHeader(
    title: "Settings",
    subtitle: "Manage your preferences"
)
```

### Accessible Buttons

```swift
// Primary button with full accessibility
AccessibleLeavnButton(
    "Sign In",
    style: .primary,
    accessibilityHint: "Double tap to sign in to your account"
) {
    // Action
}

// Icon button with proper labeling
AccessibleIconButton(
    icon: "gear",
    accessibilityLabel: "Settings",
    accessibilityHint: "Double tap to open settings"
) {
    // Action
}
```

### Accessible Cards and Containers

```swift
// Card with automatic high contrast borders
AccessibleCard(style: .elevated) {
    // Content
}

// List item with proper touch targets
AccessibleListItem(
    accessibilityLabel: "Profile Settings"
) {
    // Content
}
```

### Color Usage

```swift
// Use semantic colors that adapt to theme/contrast
Text("Error")
    .foregroundColor(Color.LeavnColors.error.current)

// Check contrast before using custom colors
let result = ContrastChecker.checkContrast(
    foreground: customColor,
    background: backgroundColor
)
if result.passesAA {
    // Safe to use
}
```

### Theme Validation

```swift
// Validate entire theme
let results = ThemeValidator.validateTheme()
for result in results where !result.passesAA {
    print(result.description)
}

// Use validation view in debug builds
#if DEBUG
ThemeValidationView()
#endif
```

## Best Practices

### 1. Always Use Semantic Colors
- Don't hardcode colors - use the design system
- Semantic colors automatically adapt to theme/contrast settings

### 2. Provide Accessibility Labels
- Always add meaningful labels to interactive elements
- Include hints for complex interactions
- Use `.accessibilityElement(children: .combine)` for grouped content

### 3. Test with Accessibility Settings
- Enable Dynamic Type (Settings > Display & Brightness > Text Size)
- Test with Larger Accessibility Sizes
- Enable Increase Contrast (Settings > Accessibility > Display & Text Size)
- Test with VoiceOver enabled
- Test keyboard navigation on iPad/Mac

### 4. Minimum Touch Targets
- Interactive elements must be at least 44x44 points
- Add padding if needed to meet minimum size
- Group related actions when appropriate

### 5. Focus Management
- Ensure logical focus order
- Provide clear focus indicators
- Use `.accessibilityFocused()` to guide focus when needed

## Color Palette

### Primary Colors
- **Light Mode**: #007AFF (Blue)
- **Dark Mode**: #4DA1FF (Light Blue)
- **High Contrast Light**: #0066CC (Dark Blue)
- **High Contrast Dark**: #66B3FF (Bright Blue)

### Semantic Colors
- **Success**: Green shades with proper contrast
- **Warning**: Yellow/Orange with dark text for contrast
- **Error**: Red shades with white text
- **Info**: Blue shades matching primary

### Text Colors
- **Primary**: Pure black/white in high contrast
- **Secondary**: 60% opacity with minimum contrast
- **Tertiary**: 30% opacity for less important text
- **Disabled**: Reduced contrast but still readable

## Testing Checklist

- [ ] All text meets WCAG contrast requirements
- [ ] Interactive elements have 44x44pt touch targets
- [ ] Focus indicators are clearly visible
- [ ] VoiceOver reads all content correctly
- [ ] Dynamic Type scales appropriately
- [ ] High contrast mode enhances visibility
- [ ] Reduce motion disables animations
- [ ] Dark mode maintains proper contrast
- [ ] Keyboard navigation works logically
- [ ] Color is not the only indicator of state

## Troubleshooting

### Common Issues

1. **Text not scaling with Dynamic Type**
   - Use `.scaledFont()` modifier or system text styles
   - Avoid fixed font sizes

2. **Poor contrast in dark mode**
   - Use ColorSet with proper dark variants
   - Test with ThemeValidator

3. **Missing focus indicators**
   - Use `.accessibleFocus()` modifier
   - Ensure interactive elements are focusable

4. **VoiceOver reading incorrectly**
   - Add proper accessibility labels
   - Use `.accessibilityElement(children: .combine)`

5. **Animations not respecting reduce motion**
   - Use DesignSystem animations
   - Check `themeManager.reduceMotion` before animating