import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Accessibility Preview Helpers
#if DEBUG

public struct AccessibilityPreviewContainer<Content: View>: View {
    let content: () -> Content
    @State private var colorScheme: ColorScheme = .light
    @State private var sizeCategory: ContentSizeCategory = .medium
    @State private var isHighContrastEnabled = false
    
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Controls
            VStack(spacing: 12) {
                // Color Scheme
                Picker("Color Scheme", selection: $colorScheme) {
                    Text("Light").tag(ColorScheme.light)
                    Text("Dark").tag(ColorScheme.dark)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Text Size
                HStack {
                    Text("Text Size")
                    Spacer()
                    Picker("Size Category", selection: $sizeCategory) {
                        Text("XS").tag(ContentSizeCategory.extraSmall)
                        Text("S").tag(ContentSizeCategory.small)
                        Text("M").tag(ContentSizeCategory.medium)
                        Text("L").tag(ContentSizeCategory.large)
                        Text("XL").tag(ContentSizeCategory.extraLarge)
                        Text("XXL").tag(ContentSizeCategory.extraExtraLarge)
                        Text("XXXL").tag(ContentSizeCategory.extraExtraExtraLarge)
                        Text("A1").tag(ContentSizeCategory.accessibilityMedium)
                        Text("A2").tag(ContentSizeCategory.accessibilityLarge)
                        Text("A3").tag(ContentSizeCategory.accessibilityExtraLarge)
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                // High Contrast
                Toggle("High Contrast", isOn: $isHighContrastEnabled)
            }
            .padding()
            .background(
                #if canImport(UIKit)
                Color(UIColor.secondarySystemBackground)
                #else
                Color.LeavnBackgroundColors.secondary.current
                #endif
            )
            
            // Content
            ScrollView {
                content()
                    .padding()
            }
            .preferredColorScheme(colorScheme)
            .environment(\.sizeCategory, sizeCategory)
            .environment(\.colorSchemeContrast, isHighContrastEnabled ? .increased : .standard)
        }
        .onAppear {
            AccessibilityThemeManager.shared.isHighContrastEnabled = isHighContrastEnabled
        }
        .onChange(of: isHighContrastEnabled) { _, newValue in
            AccessibilityThemeManager.shared.isHighContrastEnabled = newValue
        }
    }
}

// MARK: - Component Gallery
public struct AccessibilityComponentGallery: View {
    public init() {}
    
    public var body: some View {
        AccessibilityPreviewContainer {
            VStack(spacing: 24) {
                // Text Styles
                textStylesSection
                
                // Buttons
                buttonsSection
                
                // Cards
                cardsSection
                
                // Colors
                colorsSection
                
                // Interactive Elements
                interactiveElementsSection
            }
        }
    }
    
    private var textStylesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AccessibleSectionHeader(title: "Text Styles")
            
            AccessibleText("Large Title", style: .largeTitle)
            AccessibleText("Title", style: .title)
            AccessibleText("Headline", style: .headline)
            AccessibleText("Body Text", style: .body)
            AccessibleText("Callout Text", style: .callout)
            AccessibleText("Caption Text", style: .caption)
            
            AccessibleDivider(style: .section)
        }
    }
    
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AccessibleSectionHeader(title: "Buttons")
            
            AccessibleLeavnButton("Primary Button", style: .primary) {}
            AccessibleLeavnButton("Secondary Button", style: .secondary) {}
            AccessibleLeavnButton("Tertiary Button", style: .tertiary) {}
            AccessibleLeavnButton("Destructive Button", style: .destructive) {}
            AccessibleLeavnButton("Loading Button", isLoading: true) {}
            AccessibleLeavnButton("Disabled Button", isEnabled: false) {}
            
            HStack(spacing: 16) {
                AccessibleIconButton(
                    icon: "heart.fill",
                    style: .primary,
                    accessibilityLabel: "Favorite"
                ) {}
                
                AccessibleIconButton(
                    icon: "share",
                    style: .secondary,
                    accessibilityLabel: "Share"
                ) {}
                
                AccessibleIconButton(
                    icon: "trash",
                    style: .destructive,
                    accessibilityLabel: "Delete"
                ) {}
            }
            
            AccessibleDivider(style: .section)
        }
    }
    
    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AccessibleSectionHeader(title: "Cards")
            
            AccessibleCard(style: .elevated) {
                VStack(alignment: .leading, spacing: 8) {
                    AccessibleText("Elevated Card", style: .headline)
                    AccessibleText("This card has a subtle shadow effect.", style: .body)
                }
            }
            
            AccessibleCard(style: .filled) {
                VStack(alignment: .leading, spacing: 8) {
                    AccessibleText("Filled Card", style: .headline)
                    AccessibleText("This card has a filled background.", style: .body)
                }
            }
            
            AccessibleCard(style: .outlined) {
                VStack(alignment: .leading, spacing: 8) {
                    AccessibleText("Outlined Card", style: .headline)
                    AccessibleText("This card has a visible border.", style: .body)
                }
            }
            
            AccessibleDivider(style: .section)
        }
    }
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AccessibleSectionHeader(title: "Semantic Colors")
            
            HStack(spacing: 16) {
                ColorSwatch(
                    color: Color.LeavnColors.primary.current,
                    label: "Primary"
                )
                ColorSwatch(
                    color: Color.LeavnColors.secondary.current,
                    label: "Secondary"
                )
                ColorSwatch(
                    color: Color.LeavnColors.accent.current,
                    label: "Accent"
                )
            }
            
            HStack(spacing: 16) {
                ColorSwatch(
                    color: Color.LeavnColors.success.current,
                    label: "Success"
                )
                ColorSwatch(
                    color: Color.LeavnColors.warning.current,
                    label: "Warning"
                )
                ColorSwatch(
                    color: Color.LeavnColors.error.current,
                    label: "Error"
                )
                ColorSwatch(
                    color: Color.LeavnColors.info.current,
                    label: "Info"
                )
            }
            
            AccessibleDivider(style: .section)
        }
    }
    
    private var interactiveElementsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            AccessibleSectionHeader(title: "Interactive Elements")
            
            AccessibleListItem {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(Color.LeavnColors.primary.current)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        AccessibleText("Profile Settings", style: .headline)
                        AccessibleText("Manage your account", style: .caption)
                    }
                }
            }
            
            AccessibleBadge("New", style: .primary)
            AccessibleBadge("Warning", style: .warning)
            AccessibleBadge("Error", style: .error)
            
            AccessibleEmptyState(
                icon: "doc.text.magnifyingglass",
                title: "No Results Found",
                message: "Try adjusting your search criteria",
                actionTitle: "Clear Filters"
            ) {
                print("Clear filters tapped")
            }
        }
    }
}

// MARK: - Color Swatch Helper
private struct ColorSwatch: View {
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.LeavnBorderColors.border.current, lineWidth: 1)
                )
            
            AccessibleText(label, style: .caption)
        }
    }
}

// MARK: - Preview Provider
struct AccessibilityComponentGallery_Previews: PreviewProvider {
    static var previews: some View {
        AccessibilityComponentGallery()
    }
}

#endif