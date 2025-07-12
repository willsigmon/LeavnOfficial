import SwiftUI

public extension View {
    /// Apply conditional modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply modifier for a specific platform
    @ViewBuilder
    func onPlatform<Transform: View>(
        iOS: ((Self) -> Transform)? = nil,
        macOS: ((Self) -> Transform)? = nil,
        tvOS: ((Self) -> Transform)? = nil,
        watchOS: ((Self) -> Transform)? = nil,
        visionOS: ((Self) -> Transform)? = nil
    ) -> some View {
        #if os(iOS)
        if let iOS = iOS {
            iOS(self)
        } else {
            self
        }
        #elseif os(macOS)
        if let macOS = macOS {
            macOS(self)
        } else {
            self
        }
        #elseif os(tvOS)
        if let tvOS = tvOS {
            tvOS(self)
        } else {
            self
        }
        #elseif os(watchOS)
        if let watchOS = watchOS {
            watchOS(self)
        } else {
            self
        }
        #elseif os(visionOS)
        if let visionOS = visionOS {
            visionOS(self)
        } else {
            self
        }
        #else
        self
        #endif
    }
    
    /// Hide keyboard
    func hideKeyboard() {
        #if os(iOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }
}