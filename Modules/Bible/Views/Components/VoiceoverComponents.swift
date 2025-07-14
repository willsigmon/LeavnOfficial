import SwiftUI

import AVFoundation

// MARK: - Voice Selection Card

public struct VoiceSelectionCard: View {
    let name: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline.bold())
                .foregroundColor(isSelected ? .white : .primary)
            
            Text(description)
                .font(.caption)
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 140, height: 80)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Audio Player Delegate

public class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinished: () -> Void
    
    public init(onFinished: @escaping () -> Void) {
        self.onFinished = onFinished
    }
    
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinished()
    }
}

// MARK: - Speed Control Component

public struct SpeedControlSection: View {
    @Binding var playbackSpeed: Float
    let speedOptions: [Float]
    let increaseSpeed: () -> Void
    let decreaseSpeed: () -> Void
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("Playback Speed")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                // Decrease speed
                Button(action: decreaseSpeed) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .disabled(playbackSpeed <= speedOptions.first!)
                
                // Current speed display
                VStack(spacing: 4) {
                    Text("\(playbackSpeed, specifier: "%.1f")x")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                    
                    Text("Speed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(minWidth: 80)
                
                // Increase speed
                Button(action: increaseSpeed) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.accentColor)
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .disabled(playbackSpeed >= speedOptions.last!)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
} 