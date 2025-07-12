import SwiftUI
import LeavnCore
import AVFoundation

struct AudioControlsView: View {
    let audioService: AudioServiceProtocol
    let currentChapter: BibleChapter?
    
    @State private var isExpanded = false
    @State private var isPlaying = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Collapsed View
            if !isExpanded {
                HStack(spacing: 16) {
                    // Play/Pause Button
                    Button(action: togglePlayback) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.accentColor)
                    }
                    .disabled(currentChapter == nil || isLoading)
                    
                    // Current Chapter Info
                    VStack(alignment: .leading, spacing: 2) {
                        if let chapter = currentChapter {
                            Text("\(chapter.bookName) \(chapter.chapterNumber)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        } else {
                            Text("Select a chapter")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        if isPlaying {
                            Text("Playing...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Expand Button
                    Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                        Image(systemName: "chevron.up")
                            .rotationEffect(.degrees(isExpanded ? 0 : 180))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            } else {
                // Expanded View
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            if let chapter = currentChapter {
                                Text("\(chapter.bookName) \(chapter.chapterNumber)")
                                    .font(.headline)
                            } else {
                                Text("Audio Player")
                                    .font(.headline)
                            }
                            
                            Text(isPlaying ? "Playing" : "Paused")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Button(action: { withAnimation(.spring()) { isExpanded.toggle() } }) {
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Playback Controls
                    HStack(spacing: 32) {
                        // Play/Pause
                        Button(action: togglePlayback) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                        .scaleEffect(1.5)
                                } else {
                                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 48))
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .disabled(currentChapter == nil || isLoading)
                        
                        // Stop
                        Button(action: stopPlayback) {
                            Image(systemName: "stop.circle")
                                .font(.title2)
                                .foregroundColor(.primary)
                        }
                        .disabled(!isPlaying)
                    }
                    
                    // Info Text
                    if isLoading {
                        Text("Generating audio...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
    }
    
    private func togglePlayback() {
        guard let chapter = currentChapter else { return }
        
        if isPlaying {
            Task {
                await audioService.pauseNarration()
                await MainActor.run {
                    isPlaying = false
                }
            }
        } else {
            isLoading = true
            Task {
                do {
                    // Create audio configuration
                    let config = AudioConfiguration(
                        voiceId: "default",
                        speed: 1.0,
                        pitch: 1.0,
                        volume: 1.0
                    )
                    
                    // Narrate the chapter
                    _ = try await audioService.narrateChapter(chapter, configuration: config)
                    
                    await MainActor.run {
                        isLoading = false
                        isPlaying = true
                    }
                } catch {
                    await MainActor.run {
                        isLoading = false
                        // Handle error - could show alert
                        print("Audio playback error: \(error)")
                    }
                }
            }
        }
    }
    
    private func stopPlayback() {
        Task {
            await audioService.stopNarration()
            await MainActor.run {
                isPlaying = false
            }
        }
    }
}