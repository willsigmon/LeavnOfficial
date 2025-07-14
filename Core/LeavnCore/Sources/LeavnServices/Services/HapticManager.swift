import Foundation
import SwiftUI

// MARK: - Haptic Feedback Types
public enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
    case selection
}

// MARK: - Haptic Manager Protocol
public protocol HapticManager {
    func triggerFeedback(_ type: HapticFeedbackType)
    func configure(isEnabled: Bool)
    var isEnabled: Bool { get }
}

// MARK: - Default Haptic Manager Implementation
public final class DefaultHapticManager: HapticManager, ObservableObject {
    @Published public private(set) var isEnabled: Bool = true
    
    private var lightImpact: UIImpactFeedbackGenerator
    private var mediumImpact: UIImpactFeedbackGenerator
    private var heavyImpact: UIImpactFeedbackGenerator
    private var notificationFeedback: UINotificationFeedbackGenerator
    private var selectionFeedback: UISelectionFeedbackGenerator
    
    public init() {
        self.lightImpact = UIImpactFeedbackGenerator(style: .light)
        self.mediumImpact = UIImpactFeedbackGenerator(style: .medium)
        self.heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
        self.notificationFeedback = UINotificationFeedbackGenerator()
        self.selectionFeedback = UISelectionFeedbackGenerator()
        
        // Prepare generators for better performance
        prepareGenerators()
    }
    
    public func configure(isEnabled: Bool) {
        self.isEnabled = isEnabled
        if isEnabled {
            prepareGenerators()
        }
    }
    
    public func triggerFeedback(_ type: HapticFeedbackType) {
        guard isEnabled else { return }
        
        switch type {
        case .light:
            lightImpact.impactOccurred()
            
        case .medium:
            mediumImpact.impactOccurred()
            
        case .heavy:
            heavyImpact.impactOccurred()
            
        case .success:
            notificationFeedback.notificationOccurred(.success)
            
        case .warning:
            notificationFeedback.notificationOccurred(.warning)
            
        case .error:
            notificationFeedback.notificationOccurred(.error)
            
        case .selection:
            selectionFeedback.selectionChanged()
        }
        
        // Re-prepare generators for next use
        Task {
            await MainActor.run {
                prepareGenerators()
            }
        }
    }
    
    private func prepareGenerators() {
        guard isEnabled else { return }
        
        lightImpact.prepare()
        mediumImpact.prepare()
        heavyImpact.prepare()
        notificationFeedback.prepare()
        selectionFeedback.prepare()
    }
}

// MARK: - Mock Haptic Manager (for testing/previews)
public final class MockHapticManager: HapticManager, ObservableObject {
    @Published public private(set) var isEnabled: Bool = true
    private var feedbackLog: [HapticFeedbackType] = []
    
    public init() {}
    
    public func configure(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
    
    public func triggerFeedback(_ type: HapticFeedbackType) {
        guard isEnabled else { return }
        feedbackLog.append(type)
        print("Mock Haptic Feedback: \(type)")
    }
    
    public func getLastFeedbacks(count: Int = 5) -> [HapticFeedbackType] {
        return Array(feedbackLog.suffix(count))
    }
    
    public func clearLog() {
        feedbackLog.removeAll()
    }
}

// MARK: - Haptic Manager with Settings Integration
public final class SettingsAwareHapticManager: HapticManager, ObservableObject {
    @Published public private(set) var isEnabled: Bool = true
    
    private let hapticManager: HapticManager
    private let settingsViewModel: SettingsViewModel
    
    public init(hapticManager: HapticManager, settingsViewModel: SettingsViewModel) {
        self.hapticManager = hapticManager
        self.settingsViewModel = settingsViewModel
        
        // Initial configuration
        updateHapticState()
        
        // Listen for settings changes
        setupSettingsObserver()
    }
    
    public func configure(isEnabled: Bool) {
        self.isEnabled = isEnabled
        hapticManager.configure(isEnabled: isEnabled)
    }
    
    public func triggerFeedback(_ type: HapticFeedbackType) {
        guard isEnabled else { return }
        hapticManager.triggerFeedback(type)
    }
    
    private func setupSettingsObserver() {
        // Observe settings changes
        Task { @MainActor in
            for await settings in settingsViewModel.$appSettings.values {
                updateHapticState(from: settings)
            }
        }
    }
    
    private func updateHapticState(from settings: AppSettings? = nil) {
        let settings = settings ?? settingsViewModel.appSettings
        let hapticEnabled = settings.general.hapticFeedback
        configure(isEnabled: hapticEnabled)
    }
}

// MARK: - SwiftUI Environment Key
public struct HapticManagerKey: EnvironmentKey {
    public static let defaultValue: HapticManager = MockHapticManager()
}

public extension EnvironmentValues {
    var hapticManager: HapticManager {
        get { self[HapticManagerKey.self] }
        set { self[HapticManagerKey.self] = newValue }
    }
}

// MARK: - View Modifier for Haptic Feedback
public struct HapticFeedbackModifier: ViewModifier {
    let type: HapticFeedbackType
    @Environment(\.hapticManager) private var hapticManager
    
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                hapticManager.triggerFeedback(type)
            }
    }
}

public extension View {
    func hapticFeedback(_ type: HapticFeedbackType) -> some View {
        modifier(HapticFeedbackModifier(type: type))
    }
}

// MARK: - Haptic Feedback Action Helper
public struct HapticAction {
    private let hapticManager: HapticManager
    
    public init(hapticManager: HapticManager) {
        self.hapticManager = hapticManager
    }
    
    public func trigger(_ type: HapticFeedbackType) {
        hapticManager.triggerFeedback(type)
    }
    
    // Convenience methods for common UI actions
    public func bookmark() {
        hapticManager.triggerFeedback(.light)
    }
    
    public func highlight() {
        hapticManager.triggerFeedback(.light)
    }
    
    public func navigate() {
        hapticManager.triggerFeedback(.medium)
    }
    
    public func complete() {
        hapticManager.triggerFeedback(.success)
    }
    
    public func error() {
        hapticManager.triggerFeedback(.error)
    }
    
    public func playPause() {
        hapticManager.triggerFeedback(.medium)
    }
    
    public func tabSwitch() {
        hapticManager.triggerFeedback(.selection)
    }
    
    public func progressUpdate() {
        hapticManager.triggerFeedback(.light)
    }
}