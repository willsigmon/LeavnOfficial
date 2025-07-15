import SwiftUI

// MARK: - Component Usage Examples
// This file demonstrates how to use the new reusable components

struct ComponentUsageExamples: View {
    @State private var isLoading = false
    @State private var error: AppError?
    @State private var showAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Base Cards
                section(title: "Base Cards") {
                    // Basic card
                    BaseCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Basic Card")
                                .font(.headline)
                            Text("This is a basic card with default styling.")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Elevated card with tap action
                    BaseCard(
                        style: .elevated,
                        shadowStyle: .heavy,
                        tapAction: { print("Card tapped") }
                    ) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text("Tappable Card")
                                    .font(.headline)
                                Text("Tap me!")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
                
                // MARK: - Buttons
                section(title: "Buttons") {
                    VStack(spacing: 12) {
                        // Primary button
                        BaseActionButton(
                            title: "Primary Button",
                            icon: "star.fill",
                            style: .primary,
                            action: { print("Primary button tapped") }
                        )
                        
                        // Secondary button
                        BaseActionButton(
                            title: "Secondary Button",
                            style: .secondary,
                            action: { print("Secondary button tapped") }
                        )
                        
                        // Outline button
                        BaseActionButton(
                            title: "Outline Button",
                            style: .outline,
                            action: { print("Outline button tapped") }
                        )
                        
                        // Loading button
                        BaseActionButton(
                            title: "Loading...",
                            style: .primary,
                            isLoading: true,
                            action: {}
                        )
                        
                        // Icon buttons
                        HStack(spacing: 16) {
                            BaseIconButton(
                                icon: "heart.fill",
                                style: .filled,
                                action: { print("Heart tapped") }
                            )
                            
                            BaseIconButton(
                                icon: "bookmark",
                                style: .outlined,
                                action: { print("Bookmark tapped") }
                            )
                            
                            BaseIconButton(
                                icon: "share",
                                style: .plain,
                                action: { print("Share tapped") }
                            )
                        }
                    }
                }
                
                // MARK: - Bible Components
                section(title: "Bible Components") {
                    // Bible verse card
                    BibleVerseCard(
                        verse: BibleVerse(
                            id: "john-3-16",
                            bookId: "JOH",
                            bookName: "John",
                            chapter: 3,
                            verse: 16,
                            text: "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.",
                            translation: "NIV"
                        ),
                        isHighlighted: true,
                        isBookmarked: false,
                        onHighlight: { print("Highlighted") },
                        onBookmark: { print("Bookmarked") },
                        onShare: { print("Shared") },
                        onNote: { print("Note added") }
                    )
                    
                    // Life situation card
                    LifeSituationCard(
                        situation: LifeSituationCard.LifeSituation(
                            title: "Anxiety",
                            description: "Find peace and comfort in God's promises",
                            icon: "heart.fill",
                            accentColor: .blue,
                            verseCount: 25
                        ),
                        onTap: { print("Life situation tapped") }
                    )
                    
                    // Reading plan card
                    ReadingPlanCard(
                        plan: ReadingPlanCard.ReadingPlan(
                            title: "One Year Bible",
                            description: "Read through the entire Bible in 365 days",
                            currentDay: 127,
                            totalDays: 365,
                            todaysReading: ["Genesis 8-10", "Matthew 4", "Psalm 15"]
                        ),
                        onTap: { print("Reading plan tapped") },
                        onContinue: { print("Continue reading") }
                    )
                }
                
                // MARK: - Loading States
                section(title: "Loading States") {
                    VStack(spacing: 16) {
                        BaseLoadingView(message: "Loading data...")
                        
                        BaseLoadingView(style: .compact)
                        
                        BaseLoadingView(style: .minimal)
                    }
                }
                
                // MARK: - Error States
                section(title: "Error States") {
                    VStack(spacing: 16) {
                        ErrorView(
                            error: .networkError("Unable to connect to server"),
                            onRetry: { print("Retry tapped") },
                            onDismiss: { print("Dismissed") }
                        )
                        
                        InlineErrorView(
                            message: "Failed to load data",
                            onRetry: { print("Retry tapped") }
                        )
                        
                        ErrorBanner(
                            error: .authenticationError("Session expired"),
                            onRetry: { print("Retry tapped") },
                            onDismiss: { print("Dismissed") }
                        )
                    }
                }
                
                // MARK: - Empty States
                section(title: "Empty States") {
                    BaseEmptyStateView(
                        title: "No Bookmarks",
                        message: "You haven't bookmarked any verses yet. Start reading to bookmark your favorites.",
                        icon: "bookmark",
                        actionTitle: "Start Reading",
                        action: { print("Start reading") }
                    )
                }
                
                // MARK: - List Items
                section(title: "List Items") {
                    VStack(spacing: 0) {
                        BaseListItem(
                            showDisclosureIndicator: true,
                            action: { print("List item 1 tapped") }
                        ) {
                            HStack {
                                Image(systemName: "gear")
                                    .foregroundColor(.secondary)
                                Text("Settings")
                                    .font(.body)
                            }
                        }
                        
                        BaseListItem(
                            showDisclosureIndicator: true,
                            action: { print("List item 2 tapped") }
                        ) {
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .foregroundColor(.secondary)
                                Text("Help & Support")
                                    .font(.body)
                            }
                        }
                        
                        BaseListItem(
                            showDisclosureIndicator: false,
                            showDivider: false
                        ) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.secondary)
                                Text("About")
                                    .font(.body)
                            }
                        }
                    }
                    .cardStyle()
                }
                
                // MARK: - Loading State Handler
                section(title: "Loading State Handler") {
                    LoadingStateView(
                        isLoading: isLoading,
                        error: error,
                        isEmpty: false,
                        emptyTitle: "No Data",
                        emptyMessage: "There's nothing to display",
                        emptyIcon: "tray",
                        onRetry: { 
                            error = nil
                            isLoading = true
                            // Simulate loading
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isLoading = false
                            }
                        }
                    ) {
                        VStack(spacing: 16) {
                            Text("Content loaded successfully!")
                                .font(.headline)
                            
                            BaseActionButton(
                                title: "Simulate Error",
                                style: .destructive,
                                action: {
                                    error = .networkError("Simulated network error")
                                }
                            )
                            
                            BaseActionButton(
                                title: "Simulate Loading",
                                style: .secondary,
                                action: {
                                    isLoading = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isLoading = false
                                    }
                                }
                            )
                        }
                        .padding()
                        .cardStyle()
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Component Examples")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            content()
        }
    }
}

// MARK: - View Modifier Usage Examples
struct ViewModifierExamples: View {
    @State private var isPressed = false
    @State private var isVisible = true
    @State private var error: AppError?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Card Modifiers
                section(title: "Card Modifiers") {
                    VStack(spacing: 16) {
                        Text("Standard Card")
                            .padding()
                            .cardStyle()
                        
                        Text("Minimal Card")
                            .padding()
                            .minimalCardStyle()
                        
                        Text("Elevated Card")
                            .padding()
                            .elevatedCardStyle()
                    }
                }
                
                // MARK: - Button Modifiers
                section(title: "Button Modifiers") {
                    VStack(spacing: 12) {
                        Button("Primary Button") {}
                            .primaryButtonStyle()
                        
                        Button("Secondary Button") {}
                            .secondaryButtonStyle()
                        
                        Button("Outline Button") {}
                            .outlineButtonStyle()
                        
                        Button("Destructive Button") {}
                            .destructiveButtonStyle()
                    }
                }
                
                // MARK: - Animation Modifiers
                section(title: "Animation Modifiers") {
                    VStack(spacing: 16) {
                        Text("Bounce Animation")
                            .padding()
                            .cardStyle()
                            .bounceAnimation(trigger: isPressed)
                            .onTapGesture {
                                isPressed.toggle()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    isPressed = false
                                }
                            }
                        
                        Text("Fade Animation")
                            .padding()
                            .cardStyle()
                            .fadeAnimation(isVisible: isVisible)
                            .onTapGesture {
                                isVisible.toggle()
                            }
                        
                        Text("Slide Animation")
                            .padding()
                            .cardStyle()
                            .slideAnimation(isVisible: isVisible)
                            .onTapGesture {
                                isVisible.toggle()
                            }
                    }
                }
                
                // MARK: - Accessibility
                section(title: "Accessibility") {
                    VStack(spacing: 16) {
                        Text("Accessible Card")
                            .padding()
                            .cardStyle()
                            .accessibleCard(
                                label: "Information card",
                                hint: "Double tap to open"
                            )
                        
                        Button("Accessible Button") {}
                            .primaryButtonStyle()
                            .accessibleButton(
                                label: "Action button",
                                hint: "Double tap to perform action"
                            )
                        
                        Text("Accessible Header")
                            .font(.headline)
                            .accessibleText(
                                label: "Section header",
                                isHeader: true
                            )
                    }
                }
                
                // MARK: - Error Handling
                section(title: "Error Handling") {
                    VStack(spacing: 16) {
                        Text("Content with error handling")
                            .padding()
                            .cardStyle()
                            .errorHandling(error: $error) {
                                error = nil
                            }
                        
                        BaseActionButton(
                            title: "Trigger Error",
                            style: .destructive,
                            action: {
                                error = .networkError("Example error message")
                            }
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("View Modifiers")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Helper
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            content()
        }
    }
}

// MARK: - Preview
struct ComponentUsageExamples_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ComponentUsageExamples()
        }
        
        NavigationView {
            ViewModifierExamples()
        }
    }
}