import SwiftUI

struct PreferencesSummaryView: View {
    let preferences: UserPreferencesData
    
    @State private var showCheckmark = false
    @State private var showContent = false
    @State private var particlesVisible = false
    @State private var personalizedMessage = ""
    @StateObject private var userDataManager = UserDataManager.shared
    
    var body: some View {
        ZStack {
            // Celebration particles
            if particlesVisible {
                ForEach(0..<20, id: \.self) { index in
                    ConfettiParticle(
                        color: [LeavnTheme.Colors.accent, .yellow, .green, .pink, .purple].randomElement()!,
                        delay: Double(index) * 0.05
                    )
                }
            }
            
            VStack(spacing: 24) {
                // Enhanced Header with Animation
                VStack(spacing: 20) {
                    ZStack {
                        // Success animation circles
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(LeavnTheme.Colors.success.opacity(0.3 - Double(index) * 0.1), lineWidth: 2)
                                .frame(width: 80 + CGFloat(index) * 30, height: 80 + CGFloat(index) * 30)
                                .scaleEffect(showCheckmark ? 1.0 : 0.5)
                                .opacity(showCheckmark ? 1.0 : 0)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.6)
                                    .delay(Double(index) * 0.1),
                                    value: showCheckmark
                                )
                        }
                        
                        // Central checkmark
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [LeavnTheme.Colors.success, LeavnTheme.Colors.success.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .shadow(color: LeavnTheme.Colors.success.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(showCheckmark ? 1.0 : 0.3)
                                .rotationEffect(.degrees(showCheckmark ? 0 : -30))
                        }
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .opacity(showCheckmark ? 1.0 : 0)
                    }
                    .frame(height: 110)
                    
                    VStack(spacing: 12) {
                        Text("Welcome, \(userDataManager.currentUser?.name ?? "Friend")!")
                            .font(LeavnTheme.Typography.displayMedium)
                            .multilineTextAlignment(.center)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        
                        Text(personalizedMessage)
                            .font(LeavnTheme.Typography.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                    }
                }
                .padding(.top, 20)
                
                // Preferences Summary with staggered animations
                ScrollView {
                    VStack(spacing: 20) {
                        // Theological Perspectives
                        if !preferences.theologicalPerspectives.isEmpty {
                            SummarySection(
                                title: "Your Faith Perspectives",
                                icon: "books.vertical.fill",
                                editPath: "Tap to explore",
                                animationDelay: 0.6
                            ) {
                                FlowLayout(spacing: 8) {
                                    ForEach(Array(preferences.theologicalPerspectives), id: \.self) { perspective in
                                        PerspectiveBadge(perspective: perspective)
                                    }
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        }
                        
                        // Bible Translations
                        SummarySection(
                            title: "Bible Translations",
                            icon: "text.book.closed.fill",
                            editPath: "Ready to read",
                            animationDelay: 0.8
                        ) {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Label("Primary", systemImage: "star.fill")
                                        .font(LeavnTheme.Typography.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(preferences.primaryTranslation)
                                        .font(LeavnTheme.Typography.headline)
                                        .foregroundColor(LeavnTheme.Colors.accent)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            Capsule()
                                                .fill(LeavnTheme.Colors.accent.opacity(0.1))
                                        )
                                }
                                
                                if !preferences.additionalTranslations.isEmpty {
                                    HStack {
                                        Label("Compare", systemImage: "doc.on.doc")
                                            .font(LeavnTheme.Typography.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            ForEach(Array(preferences.additionalTranslations), id: \.self) { translation in
                                                Text(translation)
                                                    .font(LeavnTheme.Typography.caption)
                                                    .foregroundColor(.primary)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 2)
                                                    .background(
                                                        Capsule()
                                                            .fill(Color(.systemGray5))
                                                    )
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        // Reading Goals
                        if let readingGoal = preferences.readingGoal {
                            SummarySection(
                                title: "Reading Journey",
                                icon: "target",
                                editPath: "Let's begin!",
                                animationDelay: 1.0
                            ) {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: getGoalIcon(for: readingGoal))
                                            .foregroundColor(LeavnTheme.Colors.accent)
                                            .font(.title3)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(readingGoal.rawValue)
                                                .font(LeavnTheme.Typography.headline)
                                            Text(getGoalDescription(for: readingGoal))
                                                .font(LeavnTheme.Typography.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    if let notificationTime = preferences.dailyNotificationTime {
                                        HStack {
                                            Image(systemName: "bell.badge")
                                                .font(.caption)
                                                .foregroundColor(LeavnTheme.Colors.warning)
                                            Text("Daily reminder at \(formatTime(notificationTime))")
                                                .font(LeavnTheme.Typography.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(LeavnTheme.Colors.warning.opacity(0.1))
                                        )
                                    }
                                }
                            }
                            .opacity(showContent ? 1 : 0)
                            .offset(y: showContent ? 0 : 20)
                        }
                        
                        // Motivational CTA
                        VStack(spacing: 16) {
                            Image(systemName: "sparkles")
                                .font(.title)
                                .foregroundColor(LeavnTheme.Colors.accent)
                                .symbolEffect(.pulse)
                            
                            Text("Your journey begins now")
                                .font(LeavnTheme.Typography.headline)
                            
                            Text("Everything is set up just the way you like it. Tap 'Start Reading' to dive into God's Word!")
                                .font(LeavnTheme.Typography.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            LeavnTheme.Colors.accent.opacity(0.1),
                                            LeavnTheme.Colors.accent.opacity(0.05)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(LeavnTheme.Colors.accent.opacity(0.2), lineWidth: 1)
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.2), value: showContent)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .onAppear {
            generatePersonalizedMessage()
            animateIn()
        }
    }
    
    private func animateIn() {
        // Checkmark animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
            showCheckmark = true
        }
        
        // Content animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            showContent = true
        }
        
        // Particles
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            particlesVisible = true
        }
    }
    
    private func generatePersonalizedMessage() {
        let messages = [
            "Your personalized Bible experience is ready to inspire",
            "Everything is set up for your spiritual journey",
            "Get ready to discover God's Word in a whole new way",
            "Your faith adventure begins now"
        ]
        personalizedMessage = messages.randomElement() ?? messages[0]
    }
    
    private func getGoalIcon(for goal: ReadingGoal) -> String {
        switch goal {
        case .daily: return "sun.max.fill"
        case .weekly: return "calendar.badge.plus"
        case .monthly: return "star.fill"
        case .yearly: return "crown.fill"
        case .custom: return "sparkles"
        }
    }
    
    private func getGoalDescription(for goal: ReadingGoal) -> String {
        switch goal {
        case .daily: return "One chapter every day"
        case .weekly: return "Complete a book each week"
        case .monthly: return "Monthly themed reading"
        case .yearly: return "Read the Bible in a year"
        case .custom: return "Your own pace"
        }
    }
    
    private func formatTime(_ time: NotificationTime) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = time.hour
        components.minute = time.minute
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - Enhanced Summary Section
struct SummarySection<Content: View>: View {
    let title: String
    let icon: String
    let editPath: String
    let animationDelay: Double
    @ViewBuilder let content: () -> Content
    
    @State private var appeared = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(LeavnTheme.Typography.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(editPath)
                        .font(LeavnTheme.Typography.micro)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                }
                .foregroundColor(LeavnTheme.Colors.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(LeavnTheme.Colors.accent.opacity(0.1))
                )
            }
            
            content()
                .padding(.leading, 28)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .scaleEffect(appeared ? 1.0 : 0.95)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(animationDelay)) {
                appeared = true
            }
        }
    }
}

// MARK: - Perspective Badge
struct PerspectiveBadge: View {
    let perspective: TheologicalPerspective
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: perspective.icon)
                .font(.caption)
            Text(perspective.rawValue)
                .font(LeavnTheme.Typography.caption)
                .lineLimit(1)
        }
        .foregroundColor(perspective.color)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(perspective.color.opacity(0.1))
        )
        .overlay(
            Capsule()
                .stroke(perspective.color.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Confetti Particle
struct ConfettiParticle: View {
    let color: Color
    let delay: Double
    
    @State private var position = CGPoint(x: UIScreen.main.bounds.width / 2, y: -20)
    @State private var opacity: Double = 1
    @State private var rotation: Double = 0
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(rotation))
            .position(position)
            .opacity(opacity)
            .onAppear {
                withAnimation(.linear(duration: 2.0).delay(delay)) {
                    position = CGPoint(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: UIScreen.main.bounds.height + 20
                    )
                    rotation = Double.random(in: 0...360)
                    opacity = 0
                }
            }
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: result.positions[index].x + bounds.minX,
                                     y: result.positions[index].y + bounds.minY),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var maxX: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                maxX = max(maxX, currentX)
                lineHeight = max(lineHeight, size.height)
            }
            
            self.size = CGSize(width: maxX - spacing, height: currentY + lineHeight)
        }
    }
}