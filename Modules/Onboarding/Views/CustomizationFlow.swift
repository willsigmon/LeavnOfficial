import SwiftUI

struct CustomizationFlow: View {
    @Binding var preferences: UserPreferencesData
    @State private var currentStep = 0
    let onComplete: () -> Void
    
    private let steps = ["Perspectives", "Translations", "Reading Goals", "Summary"]
    
    var body: some View {
        ZStack {
            // Background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                CustomizationProgressBar(
                    currentStep: currentStep,
                    totalSteps: steps.count
                )
                .padding(.top, 60)
                .padding(.horizontal, 24)
                
                // Content
                TabView(selection: $currentStep) {
                    TheologicalPerspectiveView(
                        selectedPerspectives: $preferences.theologicalPerspectives
                    )
                    .tag(0)
                    
                    TranslationPreferenceView(
                        primaryTranslation: $preferences.primaryTranslation,
                        additionalTranslations: $preferences.additionalTranslations
                    )
                    .tag(1)
                    
                    ReadingGoalsView(
                        selectedGoal: $preferences.readingGoal,
                        notificationTime: $preferences.dailyNotificationTime
                    )
                    .tag(2)
                    
                    PreferencesSummaryView(
                        preferences: preferences
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: { previousStep() }) {
                            Text("Back")
                                .font(.headline)
                                .frame(maxWidth: 120, minHeight: 48)
                                .padding(.horizontal, 16)
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        Button(action: { nextAction() }) {
                            Text(currentStep == steps.count - 1 ? "Finish Setup" : "Continue")
                                .font(.headline)
                                .frame(maxWidth: 120, minHeight: 48)
                                .padding(.horizontal, 16)
                                .background(isStepValid ? Color.accentColor : Color(.systemGray4))
                                .foregroundColor(.white)
                                .clipShape(Capsule())
                                .shadow(radius: 2)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(!isStepValid)
                        .animation(.easeInOut(duration: 0.2), value: isStepValid)
                        
                        if !isStepValid {
                            Text(validationHint)
                                .font(LeavnTheme.Typography.micro)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom)
            }
        }
    }
    
    private var isStepValid: Bool {
        switch currentStep {
        case 0:
            return !preferences.theologicalPerspectives.isEmpty
        case 1:
            return !preferences.primaryTranslation.isEmpty
        case 2:
            return true // Reading goals have defaults
        default:
            return true
        }
    }
    
    private func previousStep() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            currentStep = max(0, currentStep - 1)
        }
    }
    
    private func nextAction() {
        if currentStep == steps.count - 1 {
            onComplete()
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep = min(steps.count - 1, currentStep + 1)
            }
        }
    }
    
    private var validationHint: String {
        switch currentStep {
        case 0:
            return "Please select at least one theological perspective."
        case 1:
            return "Please select a primary translation."
        case 2:
            return "Reading goals are set to default values."
        default:
            return ""
        }
    }
}

// MARK: - Progress Bar
struct CustomizationProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Labels
            HStack {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Text(stepLabel(for: index))
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(index <= currentStep ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color(.systemGray5))
                        .frame(height: 4)
                    
                    // Progress
                    Capsule()
                        .fill(LeavnTheme.Colors.accent)
                        .frame(
                            width: geometry.size.width * CGFloat(currentStep + 1) / CGFloat(totalSteps),
                            height: 4
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentStep)
                }
            }
            .frame(height: 4)
        }
    }
    
    private func stepLabel(for index: Int) -> String {
        switch index {
        case 0: return "Perspectives"
        case 1: return "Translations"
        case 2: return "Goals"
        case 3: return "Summary"
        default: return ""
        }
    }
}