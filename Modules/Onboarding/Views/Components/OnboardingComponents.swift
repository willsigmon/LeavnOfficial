import SwiftUI

// MARK: - Section Header
public struct OnboardingSectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    var badge: String? = nil
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                .symbolRenderingMode(.hierarchical)
            
            Text(title)
                .font(LeavnTheme.Typography.displayMedium)
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(LeavnTheme.Typography.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let badge = badge {
                Text(badge)
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(LeavnTheme.Colors.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(LeavnTheme.Colors.accent.opacity(0.1))
                    )
            }
        }
    }
}

// MARK: - Navigation Buttons
public struct OnboardingNavigation: View {
    let showBack: Bool
    let nextLabel: String
    let nextIcon: String
    let isNextEnabled: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    
    public init(
        showBack: Bool = true,
        nextLabel: String = "Continue",
        nextIcon: String = "chevron.right",
        isNextEnabled: Bool = true,
        onBack: @escaping () -> Void,
        onNext: @escaping () -> Void
    ) {
        self.showBack = showBack
        self.nextLabel = nextLabel
        self.nextIcon = nextIcon
        self.isNextEnabled = isNextEnabled
        self.onBack = onBack
        self.onNext = onNext
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            if showBack {
                BackButton(action: onBack)
            }
            
            Spacer()
            
            NextButton(
                label: nextLabel,
                icon: nextIcon,
                isEnabled: isNextEnabled,
                action: onNext
            )
        }
        .padding(.horizontal, 24)
        .padding(.bottom)
    }
}

// MARK: - Back Button
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
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
        .accessibilityLabel("Go back to previous step")
        .accessibilityHint("Returns to the previous onboarding step")
    }
}

// MARK: - Next Button
struct NextButton: View {
    let label: String
    let icon: String
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: { action() }) {
            Text(label)
                .font(.headline)
                .frame(maxWidth: 120, minHeight: 48)
                .padding(.horizontal, 16)
                .background(isEnabled ? Color.accentColor : Color(.systemGray4))
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 2)
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
        .accessibilityLabel(label)
        .accessibilityHint(isEnabled ? "Proceeds to the next step" : "Complete current step to continue")
    }
}

// MARK: - Selection Card
public struct SelectionCard<Content: View>: View {
    let isSelected: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    
    public var body: some View {
        Button(action: action) {
            content()
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    isSelected ? LeavnTheme.Colors.accent : Color(.systemGray4),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        )
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Info Tip
public struct InfoTip: View {
    let text: String
    let icon: String = "lightbulb.fill"
    let color: Color = LeavnTheme.Colors.warning
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(text)
                .font(LeavnTheme.Typography.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
        .padding(.horizontal)
    }
}

// MARK: - Section Label
public struct SectionLabel: View {
    let text: String
    
    public var body: some View {
        Text(text)
            .font(LeavnTheme.Typography.caption)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .padding(.horizontal)
    }
}

// MARK: - Animated Check
public struct AnimatedCheckmark: View {
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    public var body: some View {
        ZStack {
            Circle()
                .fill(LeavnTheme.Colors.success)
                .frame(width: min(80, UIScreen.main.bounds.width * 0.2), height: min(80, UIScreen.main.bounds.width * 0.2))
            
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                scale = 1.1
                opacity = 1
            }
        }
    }
}