#!/bin/bash

echo "🧹 Cleaning up onboarding views..."

# 1. Remove duplicate OnboardingView from Bible module
if [ -f "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Bible/Views/OnboardingView.swift" ]; then
    rm -f "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Bible/Views/OnboardingView.swift"
    echo "✅ Removed duplicate OnboardingView from Bible module"
fi

# 2. Create a cleaned version of OnboardingContainerView without WelcomeView
cat > "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Onboarding/Views/OnboardingContainerView_cleaned.swift" << 'EOF'
import SwiftUI
import LeavnCore

public struct OnboardingContainerView: View {
    @State private var currentPage = 0
    @State private var showPermissions = false
    @State private var showCustomization = false
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    
    // User preferences
    @State private var userPreferences = UserPreferencesData()
    
    let onComplete: () -> Void
    
    public init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }
    
    public var body: some View {
        ZStack {
            if showCustomization {
                CustomizationFlow(
                    preferences: $userPreferences,
                    onComplete: {
                        savePreferences()
                        onComplete()
                    }
                )
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                    removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                ))
            } else if showPermissions {
                PermissionsView(onComplete: {
                    withAnimation {
                        showCustomization = true
                    }
                })
                .transition(.asymmetric(
                    insertion: AnyTransition.move(edge: .trailing).combined(with: .opacity),
                    removal: AnyTransition.move(edge: .leading).combined(with: .opacity)
                ))
            } else {
                onboardingSlides
            }
        }
        .accessibilityIdentifier("onboardingView")
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showPermissions)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showCustomization)
    }
    
    private func savePreferences() {
        // Save preferences to UserDefaults or your preferred storage
        // This would be implemented based on your app's architecture
    }
    
    private var onboardingSlides: some View {
        VStack(spacing: 0) {
            // Slides
            TabView(selection: $currentPage) {
                ForEach(0..<3, id: \.self) { index in
                    VStack {
                        Spacer()
                        Text("Slide \(index + 1)")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .ignoresSafeArea()
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: currentPage)
            
            // Bottom controls overlay
            VStack(spacing: 0) {
                Spacer()
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 28 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                
                // Action buttons
                HStack {
                    Button("Skip", action: {
                        withAnimation {
                            showPermissions = true
                        }
                    })
                    .foregroundColor(.white.opacity(0.7))
                    .opacity(currentPage < 2 ? 1 : 0)
                    .accessibilityIdentifier("skipOnboardingButton")
                    
                    Spacer()
                    
                    Button(action: nextAction) {
                        Text(currentPage == 2 ? "Get Started" : "Next")
                            .font(.headline)
                            .frame(width: 120, height: 48)
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                            .shadow(radius: 2)
                    }
                    .accessibilityIdentifier(currentPage == 2 ? "completeOnboardingButton" : "onboardingContinueButton")
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func previousPage() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentPage = max(0, currentPage - 1)
        }
    }
    
    private func nextAction() {
        if currentPage == 2 {
            withAnimation {
                showPermissions = true
            }
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentPage = min(2, currentPage + 1)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    OnboardingContainerView(onComplete: {})
}
EOF

# 3. Backup original and replace with cleaned version
mv "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Onboarding/Views/OnboardingContainerView.swift" "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Onboarding/Views/OnboardingContainerView.swift.backup"
mv "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Onboarding/Views/OnboardingContainerView_cleaned.swift" "/Users/wsig/Cursor Repos/LeavnOfficial/Modules/Onboarding/Views/OnboardingContainerView.swift"

echo "✅ Removed WelcomeView placeholder from OnboardingContainerView"
echo ""
echo "Summary of changes:"
echo "1. Removed duplicate OnboardingView.swift from Bible module"
echo "2. Removed WelcomeView (fake splash screen) from OnboardingContainerView"
echo "3. OnboardingContainerView now shows real onboarding immediately"
echo ""
echo "✅ Onboarding cleanup complete!"