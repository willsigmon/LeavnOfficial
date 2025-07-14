import Foundation
import SwiftUI

// MARK: - Permission Types
public enum PermissionType: CaseIterable {
    case notifications
    case location
    case tracking
    case reminders
    
    var title: String {
        switch self {
        case .notifications:
            return "Daily Inspiration"
        case .location:
            return "Local Community"
        case .tracking:
            return "Personalized Journey"
        case .reminders:
            return "Reading Streaks"
        }
    }
    
    var description: String {
        switch self {
        case .notifications:
            return "Start each day with God's Word and timely prayer reminders"
        case .location:
            return "Find nearby Bible studies, churches, and fellowship groups"
        case .tracking:
            return "Get recommendations tailored to your spiritual growth"
        case .reminders:
            return "Build consistency with gentle nudges at your chosen time"
        }
    }
    
    var icon: String {
        switch self {
        case .notifications:
            return "bell.badge"
        case .location:
            return "location"
        case .tracking:
            return "chart.line.uptrend.xyaxis"
        case .reminders:
            return "calendar.badge.clock"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .notifications:
            return [Color(hex: "667EEA"), Color(hex: "764BA2")]
        case .location:
            return [Color(hex: "F093FB"), Color(hex: "F5576C")]
        case .tracking:
            return [Color(hex: "4FACFE"), Color(hex: "00F2FE")]
        case .reminders:
            return [Color(hex: "FA709A"), Color(hex: "FEE140")]
        }
    }
}

// MARK: - Onboarding Slide
public struct OnboardingSlide: Identifiable, Sendable {
    public let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: LinearGradient
    let accentColor: Color
    
    public init(
        title: String,
        subtitle: String,
        description: String,
        imageName: String,
        backgroundColor: LinearGradient,
        accentColor: Color
    ) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.imageName = imageName
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
    }
}

// MARK: - Onboarding Data
public struct OnboardingData {
    public static let slides = [
        OnboardingSlide(
            title: "Your Faith Journey Starts Here",
            subtitle: "Welcome to Leavn",
            description: "Join millions discovering God's Word in a whole new way. Every verse, every story, personalized just for you.",
            imageName: "book.fill",
            backgroundColor: LinearGradient(
                colors: [Color(red: 0.827, green: 0.827, blue: 1), Color(red: 0.71, green: 0.65, blue: 0.97)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            accentColor: Color(red: 0.64, green: 0.48, blue: 0.92)
        ),
        
        OnboardingSlide(
            title: "God's Word for Your World",
            subtitle: "Made Personal",
            description: "Whether you're facing joy or challenges, Leavn brings you verses that speak directly to your heart, exactly when you need them.",
            imageName: "heart.text.square.fill",
            backgroundColor: LinearGradient(
                colors: [Color(hex: "F093FB"), Color(hex: "F5576C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            accentColor: Color(hex: "F5576C")
        ),
        
        OnboardingSlide(
            title: "Walk Where Jesus Walked",
            subtitle: "Biblical Atlas",
            description: "Travel through time with interactive maps. Experience the Exodus, follow Paul's journeys, and see the Holy Land come alive.",
            imageName: "map.fill",
            backgroundColor: LinearGradient(
                colors: [Color(hex: "4FACFE"), Color(hex: "00F2FE")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            accentColor: Color(hex: "00F2FE")
        ),
        
        OnboardingSlide(
            title: "Faith Grows Together",
            subtitle: "Global Community",
            description: "Share insights, pray for one another, and celebrate God's work. You're never alone in your spiritual journey.",
            imageName: "person.3.fill",
            backgroundColor: LinearGradient(
                colors: [Color(hex: "FA709A"), Color(hex: "FEE140")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            accentColor: Color(hex: "FA709A")
        ),
        
        OnboardingSlide(
            title: "Unlock Deeper Meaning",
            subtitle: "AI Study Assistant",
            description: "From Greek origins to historical context, get instant insights that bring Scripture to life. It's like having a seminary in your pocket.",
            imageName: "sparkle",
            backgroundColor: LinearGradient(
                colors: [Color(hex: "A8EDEA"), Color(hex: "FED6E3")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            accentColor: Color(hex: "FED6E3")
        )
    ]
}

// MARK: - Onboarding Analytics Events
public enum OnboardingEvent: String {
    case started = "onboarding_started"
    case slideViewed = "onboarding_slide_viewed"
    case permissionGranted = "onboarding_permission_granted"
    case permissionDenied = "onboarding_permission_denied"
    case perspectiveSelected = "onboarding_perspective_selected"
    case translationSelected = "onboarding_translation_selected"
    case goalSelected = "onboarding_goal_selected"
    case completed = "onboarding_completed"
    case skipped = "onboarding_skipped"
}

// MARK: - Onboarding Progress
public struct OnboardingProgress: Codable {
    public var completedSteps: Set<String>
    public var currentStep: String
    public var startTime: Date
    public var lastInteractionTime: Date
    
    public init() {
        self.completedSteps = []
        self.currentStep = "welcome"
        self.startTime = Date()
        self.lastInteractionTime = Date()
    }
    
    public mutating func markStepCompleted(_ step: String) {
        completedSteps.insert(step)
        lastInteractionTime = Date()
    }
    
    public var completionPercentage: Double {
        let totalSteps = 5.0 // Welcome, Permissions, Perspectives, Translations, Goals
        return Double(completedSteps.count) / totalSteps
    }
}

// MARK: - Translation Recommendation
public struct TranslationRecommendation {
    let translation: BibleTranslation
    let reason: String
    let score: Double
    
    public init(translation: BibleTranslation, reason: String, score: Double) {
        self.translation = translation
        self.reason = reason
        self.score = score
    }
}