import SwiftUI

// MARK: - Card Styling
public extension View {
    /// Apply standard card styling with shadow
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 5,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 2
            )
    }
    
    /// Apply compact card styling
    func compactCardStyle() -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(
                color: Color.black.opacity(0.05),
                radius: 3,
                x: 0,
                y: 1
            )
    }
}

// MARK: - Loading States
public extension View {
    /// Show loading overlay
    func loadingOverlay(isLoading: Bool, message: String? = nil) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        LoadingView(message: message, style: .standard)
                    }
                }
            }
        )
    }
    
    /// Redacted placeholder while loading
    func redactedShimmer(isLoading: Bool) -> some View {
        self
            .redacted(reason: isLoading ? .placeholder : [])
            .shimmering(active: isLoading)
    }
}

// MARK: - Conditional Modifiers
public extension View {
    /// Apply modifier conditionally
    @ViewBuilder
    func `if`<Transform: View>(
        _ condition: Bool,
        transform: (Self) -> Transform
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Apply modifier based on optional value
    @ViewBuilder
    func ifLet<Value, Transform: View>(
        _ value: Value?,
        transform: (Self, Value) -> Transform
    ) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Platform Adaptive Modifiers
public extension View {
    /// Apply different modifiers based on platform
    func adaptive<iOS: View, macOS: View, watchOS: View, visionOS: View>(
        iOS: (Self) -> iOS,
        macOS: (Self) -> macOS,
        watchOS: (Self) -> watchOS,
        visionOS: (Self) -> visionOS
    ) -> some View {
        #if os(iOS)
        return iOS(self)
        #elseif os(macOS)
        return macOS(self)
        #elseif os(watchOS)
        return watchOS(self)
        #elseif os(visionOS)
        return visionOS(self)
        #else
        return self
        #endif
    }
    
    /// Navigation title that adapts to platform
    func adaptiveNavigationTitle(_ title: String) -> some View {
        #if os(iOS) || os(visionOS)
        return self.navigationTitle(title)
            .navigationBarTitleDisplayMode(.large)
        #elseif os(macOS)
        return self.navigationTitle(title)
        #elseif os(watchOS)
        return self.navigationTitle(title)
        #else
        return self
        #endif
    }
}

// MARK: - Keyboard Handling
public extension View {
    /// Hide keyboard when tapped
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            #if os(iOS)
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
            #endif
        }
    }
    
    /// Add toolbar with Done button to dismiss keyboard
    func keyboardDoneButton() -> some View {
        self.toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil,
                        from: nil,
                        for: nil
                    )
                }
            }
            #endif
        }
    }
}

// MARK: - Animation Helpers
public extension View {
    /// Animate view appearance
    func animateAppearance(
        animation: Animation = .easeInOut(duration: 0.3),
        delay: Double = 0
    ) -> some View {
        self.modifier(AnimateAppearanceModifier(animation: animation, delay: delay))
    }
    
    /// Add spring animation to tap
    func springyTap(scale: CGFloat = 0.95) -> some View {
        self.modifier(SpringyTapModifier(scale: scale))
    }
}

// MARK: - Error Handling
public extension View {
    /// Show error alert
    func errorAlert(
        error: Binding<Error?>,
        buttonTitle: String = "OK"
    ) -> some View {
        self.alert(
            "Error",
            isPresented: .constant(error.wrappedValue != nil),
            presenting: error.wrappedValue
        ) { _ in
            Button(buttonTitle) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}

// MARK: - Accessibility
public extension View {
    /// Add accessibility label and hint
    func accessibilityElement(
        label: String,
        hint: String? = nil,
        traits: AccessibilityTraits = []
    ) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(traits)
    }
    
    /// Mark as decorative element
    func decorative() -> some View {
        self.accessibilityHidden(true)
    }
}

// MARK: - Layout Helpers
public extension View {
    /// Center view in available space
    func centered() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    /// Add consistent padding
    func standardPadding() -> some View {
        self.padding(16)
    }
    
    /// Add section spacing
    func sectionSpacing() -> some View {
        self.padding(.vertical, 24)
    }
}

// MARK: - Supporting Types

private struct AnimateAppearanceModifier: ViewModifier {
    let animation: Animation
    let delay: Double
    @State private var isVisible = false
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.9)
            .onAppear {
                withAnimation(animation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

private struct SpringyTapModifier: ViewModifier {
    let scale: CGFloat
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1)
            .onLongPressGesture(
                minimumDuration: 0,
                maximumDistance: .infinity,
                pressing: { pressing in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isPressed = pressing
                    }
                },
                perform: {}
            )
    }
}

// MARK: - Shimmer Effect
private struct ShimmeringModifier: ViewModifier {
    let active: Bool
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(active ? 0.5 : 0),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase * 400 - 200)
                .mask(content)
                .animation(
                    active ? Animation.linear(duration: 1.5).repeatForever(autoreverses: false) : .default,
                    value: phase
                )
            )
            .onAppear {
                if active {
                    phase = 1
                }
            }
            .onChange(of: active) { newValue in
                phase = newValue ? 1 : 0
            }
    }
}

extension View {
    func shimmering(active: Bool) -> some View {
        self.modifier(ShimmeringModifier(active: active))
    }
}

// MARK: - Badge Modifier
public extension View {
    /// Add a badge to the view
    func badgeOverlay(
        _ text: String,
        color: Color = .red,
        position: BadgePosition = .topTrailing
    ) -> some View {
        self.overlay(
            Text(text)
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color)
                .clipShape(Capsule())
                .alignmentGuide(.top) { _ in
                    position == .topTrailing || position == .topLeading ? -8 : 0
                }
                .alignmentGuide(.bottom) { _ in
                    position == .bottomTrailing || position == .bottomLeading ? 8 : 0
                }
                .alignmentGuide(.leading) { _ in
                    position == .topLeading || position == .bottomLeading ? -8 : 0
                }
                .alignmentGuide(.trailing) { _ in
                    position == .topTrailing || position == .bottomTrailing ? 8 : 0
                },
            alignment: position.alignment
        )
    }
}

public enum BadgePosition {
    case topTrailing
    case topLeading
    case bottomTrailing
    case bottomLeading
    
    var alignment: Alignment {
        switch self {
        case .topTrailing:
            return .topTrailing
        case .topLeading:
            return .topLeading
        case .bottomTrailing:
            return .bottomTrailing
        case .bottomLeading:
            return .bottomLeading
        }
    }
}