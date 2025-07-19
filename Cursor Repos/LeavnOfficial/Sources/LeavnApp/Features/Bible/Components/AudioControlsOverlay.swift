import SwiftUI
import ComposableArchitecture

struct AudioControlsOverlay: View {
    @Bindable var store: StoreOf<BibleReducer>
    @State private var isDragging = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Handle for dragging
            Capsule()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 12)
            
            // Audio Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(store.currentBook.name)
                        .font(.headline)
                    Text("Chapter \(store.currentChapter)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Speed Control
                Menu {
                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0], id: \.self) { speed in
                        Button(action: { store.send(.setPlaybackSpeed(speed)) }) {
                            HStack {
                                Text("\(speed, specifier: "%.2f")x")
                                if store.playbackSpeed == speed {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "gauge")
                        Text("\(store.playbackSpeed, specifier: "%.2f")x")
                            .font(.callout)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            // Progress Bar
            AudioProgressBar(
                progress: store.audioProgress,
                duration: store.audioDuration,
                isDragging: $isDragging,
                onSeek: { progress in
                    store.send(.seekAudio(progress))
                }
            )
            .padding(.horizontal)
            .padding(.vertical, 16)
            
            // Playback Controls
            HStack(spacing: 32) {
                // Previous Chapter
                Button(action: { store.send(.previousChapterTapped) }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                .disabled(!store.canGoPrevious)
                
                // Skip Backward
                Button(action: { store.send(.skipBackward) }) {
                    Image(systemName: "gobackward.15")
                        .font(.title2)
                }
                
                // Play/Pause
                Button(action: { 
                    store.send(store.isAudioPlaying ? .pauseAudioTapped : .playAudioTapped)
                }) {
                    Image(systemName: store.isAudioPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.leavnPrimary)
                }
                
                // Skip Forward
                Button(action: { store.send(.skipForward) }) {
                    Image(systemName: "goforward.30")
                        .font(.title2)
                }
                
                // Next Chapter
                Button(action: { store.send(.nextChapterTapped) }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                .disabled(!store.canGoNext)
            }
            .foregroundColor(.leavnLabel)
            .padding(.bottom, 20)
            
            // Additional Controls
            HStack {
                // Sleep Timer
                Button(action: { store.send(.toggleSleepTimer) }) {
                    HStack {
                        Image(systemName: store.sleepTimerActive ? "moon.fill" : "moon")
                        if let remaining = store.sleepTimerRemaining {
                            Text(formatTime(remaining))
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
                
                // Voice Selection
                Menu {
                    ForEach(store.availableVoices, id: \.id) { voice in
                        Button(action: { store.send(.selectVoice(voice)) }) {
                            HStack {
                                Text(voice.name)
                                if voice.id == store.selectedVoice?.id {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "person.wave.2")
                        Text(store.selectedVoice?.name ?? "Voice")
                            .font(.callout)
                    }
                }
            }
            .font(.callout)
            .foregroundColor(.secondary)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.bottom, 20)
        .background(
            VisualEffectBlur(style: .systemMaterial)
                .ignoresSafeArea()
        )
        .cornerRadius(20, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, y: -5)
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct AudioProgressBar: View {
    let progress: Double
    let duration: TimeInterval
    @Binding var isDragging: Bool
    let onSeek: (Double) -> Void
    
    @State private var dragProgress: Double?
    
    var displayProgress: Double {
        dragProgress ?? progress
    }
    
    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    // Progress
                    Capsule()
                        .fill(Color.leavnPrimary)
                        .frame(width: geometry.size.width * displayProgress, height: 4)
                    
                    // Scrubber
                    Circle()
                        .fill(Color.leavnPrimary)
                        .frame(width: 16, height: 16)
                        .offset(x: geometry.size.width * displayProgress - 8)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    isDragging = true
                                    let progress = max(0, min(1, value.location.x / geometry.size.width))
                                    dragProgress = progress
                                }
                                .onEnded { _ in
                                    if let progress = dragProgress {
                                        onSeek(progress)
                                    }
                                    dragProgress = nil
                                    isDragging = false
                                }
                        )
                }
            }
            .frame(height: 16)
            
            // Time Labels
            HStack {
                Text(formatTime(duration * displayProgress))
                    .font(.caption)
                    .monospacedDigit()
                
                Spacer()
                
                Text("-\(formatTime(duration * (1 - displayProgress)))")
                    .font(.caption)
                    .monospacedDigit()
            }
            .foregroundColor(.secondary)
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Visual Effect Blur Helper
struct VisualEffectBlur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

// Corner Radius Extension
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// Mock Voice model
struct Voice: Identifiable {
    let id: String
    let name: String
}