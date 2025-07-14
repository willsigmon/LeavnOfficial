import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Springy Button Style
public struct SpringyButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.interactiveSpring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Scale Down Button Style
public struct ScaleDownButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Glass Card Button Style
public struct GlassCardButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(radius: configuration.isPressed ? 2 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Vibrant Button Style
public struct VibrantButtonStyle: ButtonStyle {
    let color: Color
    
    public init(color: Color = .accentColor) {
        self.color = color
    }
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(configuration.isPressed ? 0.3 : 0))
                    )
                    .shadow(color: color.opacity(0.3), radius: configuration.isPressed ? 2 : 8, y: configuration.isPressed ? 1 : 4)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Neumorphic Button Style
public struct NeumorphicButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: Color.black.opacity(0.2), radius: configuration.isPressed ? 2 : 8, x: configuration.isPressed ? -2 : -5, y: configuration.isPressed ? -2 : -5)
                    .shadow(color: Color.white.opacity(0.7), radius: configuration.isPressed ? 2 : 8, x: configuration.isPressed ? 2 : 5, y: configuration.isPressed ? 2 : 5)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Floating Action Button Style
public struct FloatingActionButtonStyle: ButtonStyle {
    public init() {}
    
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(
                Circle()
                    .fill(Color.accentColor)
                    .shadow(color: Color.accentColor.opacity(0.3), radius: configuration.isPressed ? 4 : 12, y: configuration.isPressed ? 2 : 6)
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Convenience Extensions
public extension ButtonStyle where Self == SpringyButtonStyle {
    static var springy: SpringyButtonStyle { SpringyButtonStyle() }
}

public extension ButtonStyle where Self == ScaleDownButtonStyle {
    static var scaleDown: ScaleDownButtonStyle { ScaleDownButtonStyle() }
}

public extension ButtonStyle where Self == GlassCardButtonStyle {
    static var glassCard: GlassCardButtonStyle { GlassCardButtonStyle() }
}

public extension ButtonStyle where Self == VibrantButtonStyle {
    static func vibrant(color: Color = .accentColor) -> VibrantButtonStyle {
        VibrantButtonStyle(color: color)
    }
}

public extension ButtonStyle where Self == NeumorphicButtonStyle {
    static var neumorphic: NeumorphicButtonStyle { NeumorphicButtonStyle() }
}

public extension ButtonStyle where Self == FloatingActionButtonStyle {
    static var floatingAction: FloatingActionButtonStyle { FloatingActionButtonStyle() }
}