import SwiftUI

// MARK: - Card Modifiers
extension View {
    /// Applies a consistent card style with shadow and corner radius
    public func cardStyle(
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
    
    /// Applies a minimal card style without shadow
    public func minimalCardStyle(
        cornerRadius: CGFloat = 8,
        borderColor: Color = Color(.systemGray4),
        borderWidth: CGFloat = 1
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
    }
    
    /// Applies an elevated card style with stronger shadow
    public func elevatedCardStyle(
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 10,
        shadowOpacity: Double = 0.15
    ) -> some View {
        self
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(
                color: Color.black.opacity(shadowOpacity),
                radius: shadowRadius,
                x: 0,
                y: 4
            )
    }
}

// MARK: - Button Modifiers
extension View {
    /// Applies a primary button style
    public func primaryButtonStyle(
        cornerRadius: CGFloat = 8,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 12
    ) -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color.accentColor)
            .cornerRadius(cornerRadius)
    }
    
    /// Applies a secondary button style
    public func secondaryButtonStyle(
        cornerRadius: CGFloat = 8,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 12
    ) -> some View {
        self
            .foregroundColor(.accentColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color.accentColor.opacity(0.1))
            .cornerRadius(cornerRadius)
    }
    
    /// Applies an outline button style
    public func outlineButtonStyle(
        cornerRadius: CGFloat = 8,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 12,
        borderWidth: CGFloat = 1
    ) -> some View {
        self
            .foregroundColor(.accentColor)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color.clear)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.accentColor, lineWidth: borderWidth)
            )
    }
    
    /// Applies a destructive button style
    public func destructiveButtonStyle(
        cornerRadius: CGFloat = 8,
        horizontalPadding: CGFloat = 20,
        verticalPadding: CGFloat = 12
    ) -> some View {
        self
            .foregroundColor(.white)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
            .background(Color.red)
            .cornerRadius(cornerRadius)
    }
}

// MARK: - Loading Modifiers
extension View {
    /// Shows a loading overlay with progress indicator
    public func loadingOverlay(
        isLoading: Bool,
        message: String? = nil
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 12) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2)
                            
                            if let message = message {
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                    }
                }
            }
        )
    }
    
    /// Shows a skeleton loading effect
    public func skeletonLoading(
        isLoading: Bool,
        cornerRadius: CGFloat = 8
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color.gray.opacity(0.3))
                        .shimmerEffect()
                }
            }
        )
    }
}

// MARK: - Error Handling Modifiers
extension View {
    /// Shows an error alert with retry option
    public func errorAlert(
        error: Binding<Error?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        self.alert(
            "Error",
            isPresented: .constant(error.wrappedValue != nil),
            presenting: error.wrappedValue
        ) { _ in
            Button("Retry", action: retryAction)
            Button("Cancel", role: .cancel) {
                error.wrappedValue = nil
            }
        } message: { error in
            Text(error.localizedDescription)
        }
    }
    
    /// Shows an error banner at the top of the view
    public func errorBanner(
        error: Binding<Error?>,
        retryAction: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 0) {
            if let error = error.wrappedValue {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Button("Retry", action: retryAction)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    
                    Button("×") {
                        error.wrappedValue = nil
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
            
            self
        }
    }
}

// MARK: - Accessibility Modifiers
extension View {
    /// Applies accessibility improvements for cards
    public func accessibleCard(
        label: String? = nil,
        hint: String? = nil,
        isButton: Bool = false
    ) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(isButton ? [.isButton] : [])
    }
    
    /// Applies accessibility improvements for buttons
    public func accessibleButton(
        label: String? = nil,
        hint: String? = nil,
        isEnabled: Bool = true
    ) -> some View {
        self
            .accessibilityLabel(label ?? "")
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits([.isButton])
            .accessibilityRemoveTraits(isEnabled ? [] : [.isButton])
    }
    
    /// Applies accessibility improvements for text
    public func accessibleText(
        label: String? = nil,
        isHeader: Bool = false
    ) -> some View {
        self
            .accessibilityLabel(label ?? "")
            .accessibilityAddTraits(isHeader ? [.isHeader] : [])
    }
}

// MARK: - Animation Modifiers
extension View {
    /// Applies a bounce animation
    public func bounceAnimation(
        trigger: Bool,
        scale: CGFloat = 1.1,
        duration: Double = 0.3
    ) -> some View {
        self
            .scaleEffect(trigger ? scale : 1.0)
            .animation(.easeInOut(duration: duration), value: trigger)
    }
    
    /// Applies a fade animation
    public func fadeAnimation(
        isVisible: Bool,
        duration: Double = 0.3
    ) -> some View {
        self
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: duration), value: isVisible)
    }
    
    /// Applies a slide animation
    public func slideAnimation(
        isVisible: Bool,
        direction: Edge = .bottom,
        duration: Double = 0.3
    ) -> some View {
        self
            .offset(y: isVisible ? 0 : (direction == .bottom ? 100 : -100))
            .opacity(isVisible ? 1.0 : 0.0)
            .animation(.easeInOut(duration: duration), value: isVisible)
    }
}

// MARK: - Conditional Modifiers
extension View {
    /// Applies a modifier conditionally
    @ViewBuilder
    public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies a modifier conditionally with else clause
    @ViewBuilder
    public func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        if trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}

// MARK: - Shimmer Effect
private struct ShimmerEffect: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.white.opacity(0.5),
                        Color.clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: isAnimating ? 300 : -300)
                .mask(content)
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

extension View {
    /// Applies a shimmer effect
    public func shimmerEffect() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Gesture Modifiers
extension View {
    /// Adds a tap gesture with haptic feedback
    public func tapGesture(
        action: @escaping () -> Void,
        hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle = .medium
    ) -> some View {
        self.onTapGesture {
            UIImpactFeedbackGenerator(style: hapticFeedback).impactOccurred()
            action()
        }
    }
    
    /// Adds a long press gesture with haptic feedback
    public func longPressGesture(
        minimumDuration: Double = 0.5,
        action: @escaping () -> Void,
        hapticFeedback: UIImpactFeedbackGenerator.FeedbackStyle = .heavy
    ) -> some View {
        self.onLongPressGesture(minimumDuration: minimumDuration) {
            UIImpactFeedbackGenerator(style: hapticFeedback).impactOccurred()
            action()
        }
    }
}

// MARK: - Safe Area Modifiers
extension View {
    /// Applies safe area padding
    public func safeAreaPadding(
        _ edges: Edge.Set = .all,
        _ length: CGFloat? = nil
    ) -> some View {
        self.padding(edges, length)
    }
    
    /// Ignores safe area for specific edges
    public func ignoreSafeArea(
        _ regions: SafeAreaRegions = .all,
        edges: Edge.Set = .all
    ) -> some View {
        self.ignoresSafeArea(regions, edges: edges)
    }
}

// MARK: - Navigation Modifiers
extension View {
    /// Applies navigation bar styling
    public func navigationBarStyle(
        title: String? = nil,
        displayMode: NavigationBarItem.TitleDisplayMode = .automatic
    ) -> some View {
        self
            .navigationBarTitle(title ?? "", displayMode: displayMode)
            .navigationBarTitleDisplayMode(displayMode)
    }
    
    /// Hides navigation bar
    public func hideNavigationBar() -> some View {
        self.navigationBarHidden(true)
    }
}