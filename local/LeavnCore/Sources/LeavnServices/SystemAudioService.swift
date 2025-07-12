import Foundation
import AVFoundation
import LeavnCore

/// Fallback audio service using system Text-to-Speech
@MainActor
public final class SystemAudioService: AudioServiceProtocol {
    
    // MARK: - Properties
    
    private let synthesizer = AVSpeechSynthesizer()
    private var isNarrating = false
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - ServiceProtocol
    
    public func initialize() async throws {
        // Configure audio session
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
        try AVAudioSession.sharedInstance().setActive(true)
    }
    
    // MARK: - AudioServiceProtocol
    
    public func narrate(_ verse: BibleVerse, configuration: AudioConfiguration) async throws -> AudioNarration {
        let utterance = AVSpeechUtterance(string: verse.text)
        utterance.rate = Float(configuration.speed * 0.5) // AVSpeech rate is 0-1, where 0.5 is normal
        utterance.pitchMultiplier = Float(configuration.pitch)
        utterance.volume = Float(configuration.volume)
        
        // Use system voice
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        isNarrating = true
        synthesizer.speak(utterance)
        
        return AudioNarration(
            verse: verse,
            configuration: configuration
        )
    }
    
    public func narrateChapter(_ chapter: BibleChapter, configuration: AudioConfiguration) async throws -> [AudioNarration] {
        var narrations: [AudioNarration] = []
        
        // Create combined text for the chapter
        let chapterText = chapter.verses
            .sorted { $0.verse < $1.verse }
            .map { "Verse \($0.verse). \($0.text)" }
            .joined(separator: " ")
        
        let utterance = AVSpeechUtterance(string: chapterText)
        utterance.rate = Float(configuration.speed * 0.5)
        utterance.pitchMultiplier = Float(configuration.pitch)
        utterance.volume = Float(configuration.volume)
        
        if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        isNarrating = true
        synthesizer.speak(utterance)
        
        // Create narration objects for each verse
        for verse in chapter.verses {
            narrations.append(AudioNarration(
                verse: verse,
                configuration: configuration
            ))
        }
        
        return narrations
    }
    
    public func getAvailableVoices() async throws -> [ElevenLabsVoice] {
        // Return system voices as ElevenLabsVoice format
        let systemVoices = AVSpeechSynthesisVoice.speechVoices()
            .filter { $0.language.hasPrefix("en") }
            .map { voice in
                ElevenLabsVoice(
                    voiceId: voice.identifier,
                    name: voice.name,
                    category: "system",
                    labels: [
                        "language": voice.language,
                        "quality": voice.quality == .enhanced ? "enhanced" : "default"
                    ]
                )
            }
        
        return systemVoices
    }
    
    public func preloadAudio(for verses: [BibleVerse], configuration: AudioConfiguration) async {
        // System TTS doesn't support preloading
    }
    
    public func stopNarration() async {
        synthesizer.stopSpeaking(at: .immediate)
        isNarrating = false
    }
    
    public func pauseNarration() async {
        synthesizer.pauseSpeaking(at: .immediate)
    }
    
    public func resumeNarration() async {
        synthesizer.continueSpeaking()
    }
    
    public func setEmotionalContext(_ context: EmotionalState) async {
        // System TTS doesn't support emotional context
    }
    
    nonisolated public func generateSSML(for text: String, style: VoiceStyle) -> String {
        // System TTS doesn't support SSML, return plain text
        return text
    }
}