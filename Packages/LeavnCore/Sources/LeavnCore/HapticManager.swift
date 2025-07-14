#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

/// Centralized haptic feedback manager for consistent tactile experiences
@MainActor
public final class HapticManager {
    public static let shared = HapticManager()
    
    #if canImport(UIKit)
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selectionGenerator = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()
    #endif
    
    private init() {
        #if canImport(UIKit)
        // Prepare generators for immediate feedback
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selectionGenerator.prepare()
        notification.prepare()
        #endif
    }
    
    // MARK: - Impact Haptics
    
    /// Light impact for subtle interactions (regular button taps)
    #if canImport(UIKit)
    public func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        default:
            impactLight.impactOccurred()
        }
    }
    #else
    public func impact(_ style: Int = 0) {
        // No-op on platforms without UIKit
    }
    #endif
    
    /// Selection feedback for toggles, switches, and selections
    public func selectionFeedback() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Success feedback for completed operations
    public func success() {
        #if canImport(UIKit)
        notification.notificationOccurred(.success)
        #endif
    }
    
    /// Warning feedback for destructive actions
    public func warning() {
        #if canImport(UIKit)
        notification.notificationOccurred(.warning)
        #endif
    }
    
    /// Error feedback for failed operations
    public func error() {
        #if canImport(UIKit)
        notification.notificationOccurred(.error)
        #endif
    }
    
    // MARK: - Contextual Haptics
    
    /// Tab selection haptic
    public func tabSelected() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Button tap haptic
    public func buttonTap() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        #endif
    }
    
    /// Navigation push/pop haptic
    public func navigationTransition() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        #endif
    }
    
    /// Toggle switch haptic
    public func toggleChanged() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Slider value changed haptic
    public func sliderChanged() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Sheet/Modal presentation haptic
    public func sheetPresented() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Alert presentation haptic
    public func alertPresented() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Swipe action haptic
    public func swipeAction() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Long press haptic
    public func longPress() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Refresh triggered haptic
    public func refreshTriggered() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Destructive action haptic
    public func destructiveAction() {
        warning()
    }
    
    /// Chapter navigation haptic
    public func chapterNavigation() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        #endif
    }
    
    /// Verse selection haptic
    public func verseSelected() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Bookmark toggle haptic
    public func bookmarkToggled() {
        #if canImport(UIKit)
        impactMedium.impactOccurred()
        #endif
    }
    
    /// Settings changed haptic
    public func settingChanged() {
        #if canImport(UIKit)
        selectionGenerator.selectionChanged()
        #endif
    }
    
    /// Create/Save action haptic
    public func createAction() {
        success()
    }
    
    /// Cancel action haptic
    public func cancelAction() {
        #if canImport(UIKit)
        impactLight.impactOccurred()
        #endif
    }
}

// MARK: - SwiftUI View Extensions

#if canImport(SwiftUI)
public extension View {
    /// Adds haptic feedback on tap
    func hapticTap(_ type: HapticType = .light) -> some View {
        self.onTapGesture {
            switch type {
            case .light:
                #if canImport(UIKit)
                HapticManager.shared.impact(.light)
                #else
                HapticManager.shared.impact(0)
                #endif
            case .medium:
                #if canImport(UIKit)
                HapticManager.shared.impact(.medium)
                #else
                HapticManager.shared.impact(1)
                #endif
            case .heavy:
                #if canImport(UIKit)
                HapticManager.shared.impact(.heavy)
                #else
                HapticManager.shared.impact(2)
                #endif
            case .selection:
                HapticManager.shared.selectionFeedback()
            case .success:
                HapticManager.shared.success()
            case .warning:
                HapticManager.shared.warning()
            case .failure:
                HapticManager.shared.error()
            }
        }
    }
    
    /// Adds haptic feedback on appear
    func hapticOnAppear(_ type: HapticType = .light) -> some View {
        self.onAppear {
            switch type {
            case .light:
                #if canImport(UIKit)
                HapticManager.shared.impact(.light)
                #else
                HapticManager.shared.impact(0)
                #endif
            case .medium:
                #if canImport(UIKit)
                HapticManager.shared.impact(.medium)
                #else
                HapticManager.shared.impact(1)
                #endif
            case .heavy:
                #if canImport(UIKit)
                HapticManager.shared.impact(.heavy)
                #else
                HapticManager.shared.impact(2)
                #endif
            case .selection:
                HapticManager.shared.selectionFeedback()
            case .success:
                HapticManager.shared.success()
            case .warning:
                HapticManager.shared.warning()
            case .failure:
                HapticManager.shared.error()
            }
        }
    }
}
#endif

public enum HapticType {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case failure
}