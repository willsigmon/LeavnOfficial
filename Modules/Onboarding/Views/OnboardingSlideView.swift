import SwiftUI

struct OnboardingSlideView: View {
    let slide: OnboardingSlide
    let isCurrentSlide: Bool
    var hasAppeared: Bool = false
    
    @State private var showContent = false
    @State private var imageScale: CGFloat = 0.8
    @State private var particlesVisible = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Enhanced animated icon with particles
            ZStack {
                // Particle effects
                if particlesVisible {
                    ForEach(0..<8, id: \.self) { index in
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 4, height: 4)
                            .offset(
                                x: showContent ? CGFloat.random(in: -100...100) : 0,
                                y: showContent ? CGFloat.random(in: -100...100) : 0
                            )
                            .blur(radius: showContent ? 2 : 0)
                            .opacity(showContent ? 0 : 1)
                            .animation(
                                .spring(response: 2, dampingFraction: 0.5)
                                .delay(Double(index) * 0.1),
                                value: showContent
                            )
                    }
                }
                
                // Glow layers
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white.opacity(0.3), .white.opacity(0)],
                            center: .center,
                            startRadius: 0,
                            endRadius: 100
                        )
                    )
                    .frame(width: 250, height: 250)
                    .blur(radius: 20)
                    .scaleEffect(showContent ? 1.3 : 0.8)
                    .opacity(showContent ? 1 : 0.5)
                
                Circle()
                    .fill(.white.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 15)
                    .scaleEffect(showContent ? 1.1 : 0.7)
                
                // Icon container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: slide.imageName)
                        .font(.system(size: 60, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .symbolRenderingMode(.hierarchical)
                        .scaleEffect(imageScale)
                        .rotationEffect(.degrees(isCurrentSlide ? 0 : -10))
                        .shadow(color: .white.opacity(0.5), radius: 10)
                }
                .overlay(
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.white.opacity(0.6), .white.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(showContent ? 1.05 : 0.95)
                )
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showContent)
            .animation(.spring(response: 0.8, dampingFraction: 0.5), value: imageScale)
                
                // Enhanced content with better typography
                VStack(spacing: 24) {
                    // Subtitle badge
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(.white.opacity(0.6))
                            .frame(width: showContent ? 30 : 0, height: 2)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showContent)
                        
                        Text(slide.subtitle)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .textCase(.uppercase)
                            .tracking(3)
                            .foregroundColor(.white)
                            .opacity(showContent ? 1 : 0)
                            .shadow(color: slide.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                        
                        Rectangle()
                            .fill(.white.opacity(0.6))
                            .frame(width: showContent ? 30 : 0, height: 2)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2), value: showContent)
                    }
                    .offset(y: showContent ? 0 : 20)
                    
                    // Title with gradient
                    Text(slide.title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 30)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .scaleEffect(showContent ? 1 : 0.9)
                    
                    // Description with fade
                    Text(slide.description)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.95))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .lineLimit(4)
                        .padding(.horizontal, 32)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 40)
                        .blur(radius: showContent ? 0 : 2)
                    
                    // Call to action hint
                    if isCurrentSlide && showContent {
                        HStack(spacing: 4) {
                            Image(systemName: "hand.draw")
                                .font(.caption)
                            Text("Swipe to continue")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.6))
                        .offset(y: 10)
                        .opacity(showContent ? 1 : 0)
                        .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: showContent)
                    }
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1), value: showContent)
            
            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(slide.backgroundColor.ignoresSafeArea())
        .onAppear {
            if isCurrentSlide && hasAppeared {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        showContent = true
                        imageScale = 1.0
                    }
                    
                    withAnimation(.spring(response: 1.2, dampingFraction: 0.5).delay(0.3)) {
                        particlesVisible = true
                    }
                }
            }
        }
        .onChange(of: isCurrentSlide) { _, isCurrent in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showContent = isCurrent
                imageScale = isCurrent ? 1.0 : 0.8
                
                if isCurrent {
                    withAnimation(.spring(response: 1.2, dampingFraction: 0.5).delay(0.3)) {
                        particlesVisible = true
                    }
                } else {
                    particlesVisible = false
                }
            }
        }
    }
}