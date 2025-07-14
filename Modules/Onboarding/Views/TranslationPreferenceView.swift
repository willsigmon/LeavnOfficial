import SwiftUI

struct TranslationPreferenceView: View {
    @Binding var primaryTranslation: String
    @Binding var additionalTranslations: Set<String>
    @State private var showAllTranslations = false
    @State private var showRecommendations = true
    @State private var animateCards = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Enhanced Header with Animation
            VStack(spacing: 20) {
                ZStack {
                    // Background glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [LeavnTheme.Colors.accent.opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .scaleEffect(animateCards ? 1.2 : 1.0)
                    
                    Image(systemName: "text.book.closed.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(LeavnTheme.Colors.primaryGradient)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(animateCards ? 1.0 : 0.9)
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: animateCards)
                
                Text("Choose Your Bible Translation")
                    .font(LeavnTheme.Typography.displayMedium)
                    .multilineTextAlignment(.center)
                
                Text("Select your primary translation and any additional versions for comparison")
                    .font(LeavnTheme.Typography.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Smart recommendation badge
                if showRecommendations {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("Recommended based on your preferences")
                            .font(LeavnTheme.Typography.caption)
                    }
                    .foregroundColor(LeavnTheme.Colors.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(LeavnTheme.Colors.accent.opacity(0.1))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Primary Translation Section
            VStack(alignment: .leading, spacing: 12) {
                Text("PRIMARY TRANSLATION")
                    .font(LeavnTheme.Typography.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        // Show recommended translations first
                        let recommendations = getRecommendedTranslations()
                        if showRecommendations && !recommendations.isEmpty {
                            ForEach(recommendations, id: \.translation.id) { recommendation in
                                TranslationCard(
                                    translation: recommendation.translation,
                                    isPrimary: primaryTranslation == recommendation.translation.id,
                                    isAdditional: additionalTranslations.contains(recommendation.translation.id),
                                    recommendationReason: recommendation.reason,
                                    onTap: {
                                        selectPrimaryTranslation(recommendation.translation.id)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                            
                            Divider()
                                .padding(.vertical, 8)
                        }
                        
                        // Show all translations
                        ForEach(UserPreferencesData.onboardingTranslations.filter { translation in
                            !recommendations.contains(where: { $0.translation.id == translation.id })
                        }, id: \.id) { translation in
                            TranslationCard(
                                translation: translation,
                                isPrimary: primaryTranslation == translation.id,
                                isAdditional: additionalTranslations.contains(translation.id),
                                onTap: {
                                    selectPrimaryTranslation(translation.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Additional Translations
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("COMPARISON TRANSLATIONS")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(additionalTranslations.count) selected")
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(LeavnTheme.Colors.accent)
                }
                .padding(.horizontal, 20)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(UserPreferencesData.onboardingTranslations.filter { $0.id != primaryTranslation }, id: \.id) { translation in
                            ComparisonChip(
                                translation: translation,
                                isSelected: additionalTranslations.contains(translation.id),
                                onTap: {
                                    toggleAdditionalTranslation(translation.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                animateCards = true
            }
        }
    }
    
    private func toggleAdditionalTranslation(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if additionalTranslations.contains(id) {
                additionalTranslations.remove(id)
            } else {
                additionalTranslations.insert(id)
            }
        }
    }
    
    private func selectPrimaryTranslation(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            primaryTranslation = id
            additionalTranslations.remove(id)
        }
    }
    
    private func getRecommendedTranslations() -> [TranslationRecommendation] {
        var recommendations: [TranslationRecommendation] = []
        
        // Always recommend NIV as a balanced choice
        if let niv = UserPreferencesData.onboardingTranslations.first(where: { $0.id == "NIV" }) {
            recommendations.append(
                TranslationRecommendation(
                    translation: niv,
                    reason: "Most popular & balanced",
                    score: 1.0
                )
            )
        }
        
        // Recommend ESV for literal study
        if let esv = UserPreferencesData.onboardingTranslations.first(where: { $0.id == "ESV" }) {
            recommendations.append(
                TranslationRecommendation(
                    translation: esv,
                    reason: "Great for deep study",
                    score: 0.9
                )
            )
        }
        
        // Recommend NLT for easy reading
        if let nlt = UserPreferencesData.onboardingTranslations.first(where: { $0.id == "NLT" }) {
            recommendations.append(
                TranslationRecommendation(
                    translation: nlt,
                    reason: "Easy to understand",
                    score: 0.8
                )
            )
        }
        
        return recommendations
    }
}

// MARK: - Translation Card
struct TranslationCard: View {
    let translation: BibleTranslation
    let isPrimary: Bool
    let isAdditional: Bool
    var recommendationReason: String? = nil
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Radio button
            ZStack {
                Circle()
                    .stroke(isPrimary ? LeavnTheme.Colors.accent : Color.gray.opacity(0.3), lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isPrimary {
                    Circle()
                        .fill(LeavnTheme.Colors.accent)
                        .frame(width: 16, height: 16)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPrimary)
            
            // Translation info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(translation.abbreviation)
                        .font(LeavnTheme.Typography.headline)
                        .foregroundColor(.primary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(translation.name)
                        .font(LeavnTheme.Typography.body)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                if let description = translation.description {
                    Text(description)
                        .font(LeavnTheme.Typography.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Recommendation badge
            if let reason = recommendationReason {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text(reason)
                        .font(LeavnTheme.Typography.micro)
                }
                .foregroundColor(LeavnTheme.Colors.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(LeavnTheme.Colors.accent.opacity(0.1))
                )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isPrimary ? LeavnTheme.Colors.accent.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isPrimary ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture(perform: onTap)
        .scaleEffect(isPrimary ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPrimary)
    }
}

// MARK: - Comparison Chip
struct ComparisonChip: View {
    let translation: BibleTranslation
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .transition(.scale.combined(with: .opacity))
            }
            
            Text(translation.abbreviation)
                .font(LeavnTheme.Typography.headline)
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(isSelected ? LeavnTheme.Colors.accent : Color(.systemGray5))
        )
        .overlay(
            Capsule()
                .stroke(isSelected ? LeavnTheme.Colors.accent : Color.clear, lineWidth: 1)
        )
        .onTapGesture(perform: onTap)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}