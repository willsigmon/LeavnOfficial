// PlatformExtensions.swift: Platform detection and adaptive UI helpers.

import SwiftUI

// MARK: - Platform Detection

/// Provides information about the current platform the code is running on.
public struct Platform {
    /// Returns the current platform name as a string.
    public static var current: String {
        if isIOS {
            return "iOS"
        } else if isMac {
            return "macOS"
        } else if isWatch {
            return "watchOS"
        } else if isVision {
            return "visionOS"
        } else if isTV {
            return "tvOS"
        } else {
            return "unknown"
        }
    }
    
    /// Returns `true` if the current platform is iOS.
    public static var isIOS: Bool {
        #if os(iOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current platform is macOS.
    public static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current platform is watchOS.
    public static var isWatch: Bool {
        #if os(watchOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current platform is visionOS.
    public static var isVision: Bool {
        #if os(visionOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current platform is tvOS.
    public static var isTV: Bool {
        #if os(tvOS)
        return true
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current device is an iPad.
    @MainActor
    public static var isIPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }
    
    /// Returns `true` if the current environment is Mac Catalyst.
    public static var isCatalyst: Bool {
        #if targetEnvironment(macCatalyst)
        return true
        #else
        return false
        #endif
    }
}

// MARK: - Platform-Specific View Modifiers

public extension View {
    /// Applies a view modifier conditionally based on the given platform boolean.
    ///
    /// - Parameters:
    ///   - platform: Boolean indicating whether to apply the transform.
    ///   - transform: A closure that takes the view as input and returns a modified view.
    ///
    /// - Returns: Either the original view or the transformed view depending on the platform condition.
    @ViewBuilder
    func ifPlatform<Content: View>(
        _ platform: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if platform {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies adaptive frame adjustments depending on the platform and device type.
    ///
    /// - Returns: A view with platform-specific frame constraints applied.
    func adaptiveFrame() -> some View {
        self.modifier(AdaptiveFrameModifier())
    }
}

/// A view modifier that adjusts frame sizes adaptively for different platforms.
struct AdaptiveFrameModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .frame(maxWidth: Platform.isIPad ? 800 : .infinity)
        #elseif os(macOS)
        content
            .frame(minWidth: 600, maxWidth: 1200, minHeight: 400, maxHeight: .infinity)
        #elseif os(watchOS)
        content
        #elseif os(visionOS)
        content
            .frame(maxWidth: 1000)
        #else
        content
        #endif
    }
}

// MARK: - Navigation Adaptations

public extension View {
    /// Wraps the view in a platform-appropriate navigation container.
    ///
    /// - Returns: A view embedded in `NavigationStack`, `NavigationSplitView`, `NavigationView`, or unchanged depending on the platform.
    @ViewBuilder
    func adaptiveNavigation() -> some View {
        #if os(iOS) || os(visionOS)
        NavigationStack {
            self
        }
        #elseif os(macOS)
        NavigationSplitView {
            self
        } detail: {
            Text("Select an item")
        }
        #elseif os(watchOS)
        NavigationView {
            self
        }
        #else
        self
        #endif
    }
}
