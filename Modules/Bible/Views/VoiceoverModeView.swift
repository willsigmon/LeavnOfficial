import SwiftUI

import AVFoundation

public struct VoiceoverModeView: View {
    let verses: [BibleVerse]
    let book: BibleBook?
    let chapter: Int
    
    @State private var isPlaying = false
    @State private var currentPosition: TimeInterval = 0
    @State private var totalDuration: TimeInterval = 0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isLoading = false
    @State private var playbackSpeed: Float = 1.0
    @State private var selectedVoice = "Rachel" // Default Eleven Labs voice
    @State private var errorMessage: String?
    @State private var downloadProgress: Double = 0.0
    @State private var audioDelegate: AudioPlayerDelegate?
    @State private var playbackTimer: Timer?
    @State private var currentVerseIndex = 0
    
    @Environment(\.dismiss) private var dismiss
    
    private let availableVoices = [
        ("Rachel", "Warm, expressive female voice - Perfect for V3 emotional reading"),
        ("Drew", "Deep, authoritative male voice - Excellent for proclamations"),
        ("Clyde", "Gentle, middle-aged male voice - Ideal for narrative passages"),
        ("Bella", "Clear, pleasant female voice - Great for psalms and wisdom"),
        ("Josh", "Young, energetic male voice - Perfect for joyful passages"),
        ("Arnold", "Crisp, professional male voice - Excellent for teaching"),
        ("Adam", "Deep, resonant male voice - Ideal for dramatic readings"),
        ("Sam", "Mature, wise male voice - Perfect for meditative passages")
    ]
    
    // Speed options with 0.1 precision
    private let speedOptions: [Float] = [
        0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0
    ]
    
    public init(verses: [BibleVerse], book: BibleBook?, chapter: Int) {
        self.verses = verses
        self.book = book
        self.chapter = chapter
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with book info
                headerSection
                
                // Voice controls
                voiceControlsSection
                
                // Progress and timing
                progressSection
                
                // Speed controls with 0.1 precision
                speedControlsSection
                
                // Playback controls
                playbackControlsSection
                
                // Chapter display with current verse highlight
                chapterDisplaySection
                
                Spacer()
            }
            .navigationTitle("Audio Bible")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        stopPlayback()
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            stopPlayback()
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(book?.name ?? "Bible")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Chapter \(chapter)")
                .font(.title3)
                .foregroundColor(.secondary)
            
            if !verses.isEmpty {
                VStack(spacing: 4) {
                    Text("Complete chapter • \(verses.count) verses")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // V3 indicator
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundColor(.purple)
                        Text("Enhanced with ElevenLabs V3 emotional AI")
                            .font(.caption2)
                            .foregroundColor(.purple)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.purple.opacity(0.1))
                    )
                }
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private var voiceControlsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Voice Selection")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableVoices, id: \.0) { voice in
                        VoiceSelectionCard(
                            name: voice.0,
                            description: voice.1,
                            isSelected: selectedVoice == voice.0
                        ) {
                            selectedVoice = voice.0
                            HapticManager.shared.buttonTap()
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    private var progressSection: some View {
        VStack(spacing: 12) {
            if isLoading {
                VStack(spacing: 8) {
                    ProgressView(value: downloadProgress, total: 1.0)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    VStack(spacing: 4) {
                        Text("Generating emotional chapter audio with ElevenLabs V3...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Applying contextual emotion tags for Biblical reading")
                            .font(.caption2)
                            .foregroundColor(.purple)
                            .opacity(0.8)
                    }
                }
                .padding(.horizontal)
            } else if totalDuration > 0 {
                VStack(spacing: 8) {
                    ProgressView(value: currentPosition, total: totalDuration)
                        .progressViewStyle(LinearProgressViewStyle())
                    
                    HStack {
                        Text(formatTime(currentPosition))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        if !verses.isEmpty && currentVerseIndex < verses.count {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption2)
                                    .foregroundColor(.purple)
                                Text("Verse \(currentVerseIndex + 1)")
                                    .font(.caption)
                                    .foregroundColor(.accentColor)
                            }
                        }
                        
                        Spacer()
                        
                        Text(formatTime(totalDuration))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
            }
            
            if let error = errorMessage {
                VStack(spacing: 4) {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if error.contains("V3") {
                        Text("Automatically falling back to V2 for compatibility")
                            .font(.caption2)
                            .foregroundColor(.orange)
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }
        .padding(.vertical)
    }
    
    private var speedControlsSection: some View {
        SpeedControlSection(
            playbackSpeed: $playbackSpeed,
            speedOptions: speedOptions,
            increaseSpeed: increaseSpeed,
            decreaseSpeed: decreaseSpeed
        )
    }
    
    private var playbackControlsSection: some View {
        VStack(spacing: 20) {
            // Main play/pause button
            Button(action: togglePlayback) {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
            }
            .frame(minWidth: 80, minHeight: 80)
            .contentShape(Rectangle())
            .disabled(verses.isEmpty || isLoading)
            
            // Chapter navigation controls
            HStack(spacing: 40) {
                // Restart chapter
                Button(action: restartChapter) {
                    VStack(spacing: 4) {
                        Image(systemName: "gobackward")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text("Restart")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .disabled(isLoading)
                
                // Skip forward 30 seconds
                Button(action: skipForward) {
                    VStack(spacing: 4) {
                        Image(systemName: "goforward.30")
                            .font(.title2)
                            .foregroundColor(.primary)
                        Text("30s")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(minWidth: 44, minHeight: 44)
                .contentShape(Rectangle())
                .disabled(isLoading || totalDuration == 0)
            }
        }
        .padding(.vertical)
    }
    
    private var chapterDisplaySection: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(verses.enumerated()), id: \.element.id) { index, verse in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                // Verse number
                                Text("\(verse.verse)")
                                    .font(.caption.bold())
                                    .foregroundColor(index == currentVerseIndex ? .white : .secondary)
                                    .frame(width: 30, alignment: .leading)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(index == currentVerseIndex ? Color.accentColor : Color.clear)
                                    )
                                
                                Spacer()
                                
                                // Playing indicator
                                if index == currentVerseIndex && isPlaying {
                                    Image(systemName: "speaker.wave.2.fill")
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                        .opacity(0.8)
                                }
                            }
                            
                            // Verse text
                            Text(verse.text)
                                .font(.body)
                                .lineSpacing(6)
                                .foregroundColor(index == currentVerseIndex ? .primary : .secondary)
                                .opacity(index == currentVerseIndex ? 1.0 : 0.7)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(index == currentVerseIndex ? Color(.secondarySystemBackground) : Color.clear)
                        )
                        .id(verse.id)
                        .animation(.easeInOut(duration: 0.3), value: currentVerseIndex)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 34)
            }
            .onChange(of: currentVerseIndex) { _, newIndex in
                if newIndex < verses.count {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(verses[newIndex].id, anchor: .center)
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func togglePlayback() {
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
    }
    
    private func startPlayback() {
        guard !verses.isEmpty else { return }
        
        if audioPlayer == nil {
            // Generate new audio for entire chapter
            Task {
                await generateAndPlayChapterAudio()
            }
        } else {
            // Resume existing audio
            audioPlayer?.play()
            isPlaying = true
            startPlaybackTimer()
            HapticManager.shared.buttonTap()
        }
    }
    
    private func pausePlayback() {
        isPlaying = false
        audioPlayer?.pause()
        stopPlaybackTimer()
        HapticManager.shared.buttonTap()
    }
    
    private func stopPlayback() {
        isPlaying = false
        audioPlayer?.stop()
        audioPlayer = nil
        stopPlaybackTimer()
        currentPosition = 0
        totalDuration = 0
    }
    
    private func restartChapter() {
        audioPlayer?.currentTime = 0
        currentPosition = 0
        currentVerseIndex = 0
        HapticManager.shared.buttonTap()
    }
    
    private func skipForward() {
        guard let player = audioPlayer else { return }
        let newTime = min(player.currentTime + 30, player.duration)
        player.currentTime = newTime
        currentPosition = newTime
        updateCurrentVerse()
        HapticManager.shared.buttonTap()
    }
    
    private func increaseSpeed() {
        if let currentIndex = speedOptions.firstIndex(of: playbackSpeed),
           currentIndex < speedOptions.count - 1 {
            playbackSpeed = speedOptions[currentIndex + 1]
            audioPlayer?.rate = playbackSpeed
            HapticManager.shared.buttonTap()
        }
    }
    
    private func decreaseSpeed() {
        if let currentIndex = speedOptions.firstIndex(of: playbackSpeed),
           currentIndex > 0 {
            playbackSpeed = speedOptions[currentIndex - 1]
            audioPlayer?.rate = playbackSpeed
            HapticManager.shared.buttonTap()
        }
    }
    
    // MARK: - Audio Generation
    
    private func generateAndPlayChapterAudio() async {
        guard !verses.isEmpty else { return }
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            downloadProgress = 0.0
        }
        
        do {
            // Create emotionally formatted text for V3 with Biblical context
            let formattedText = formatChapterForV3Reading(verses: verses, book: book, chapter: chapter)
            
            // Generate audio using ElevenLabs V3 with audio tags
            let audioData = try await generateElevenLabsV3Audio(
                text: formattedText,
                voice: selectedVoice
            )
            
            await MainActor.run {
                do {
                    self.audioPlayer = try AVAudioPlayer(data: audioData)
                    self.audioPlayer?.enableRate = true
                    self.audioPlayer?.rate = self.playbackSpeed
                    self.totalDuration = self.audioPlayer?.duration ?? 0
                    
                    // Create and store delegate
                    self.audioDelegate = AudioPlayerDelegate {
                        DispatchQueue.main.async {
                            self.handleAudioFinished()
                        }
                    }
                    self.audioPlayer?.delegate = self.audioDelegate
                    
                    if self.audioPlayer?.play() == true {
                        self.isPlaying = true
                        self.isLoading = false
                        self.startPlaybackTimer()
                        HapticManager.shared.buttonTap()
                    } else {
                        throw NSError(domain: "AudioPlayback", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to start audio playback"])
                    }
                } catch {
                    self.errorMessage = "Failed to play audio: \(error.localizedDescription)"
                    self.isLoading = false
                    self.isPlaying = false
                }
            }
            
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to generate audio: \(error.localizedDescription)"
                self.isLoading = false
                self.isPlaying = false
            }
        }
    }
    
    // MARK: - V3 Text Formatting for Biblical Reading
    
    private func formatChapterForV3Reading(verses: [BibleVerse], book: BibleBook?, chapter: Int) -> String {
        var formattedText = ""
        
        // Opening with reverent tone
        if let bookName = book?.name {
            formattedText += "[reverent] From the book of \(bookName), chapter \(chapter). [pause] "
        }
        
        // Process each verse with appropriate emotional context
        for (index, verse) in verses.enumerated() {
            let verseText = verse.text.trimmingCharacters(in: .whitespacesAndNewlines)
            let emotionalContext = determineEmotionalContext(for: verseText, book: book)
            
            // Add verse number with slight pause
            formattedText += "Verse \(verse.verse). [pause] "
            
            // Apply emotional formatting based on content
            formattedText += applyEmotionalFormatting(text: verseText, context: emotionalContext)
            
            // Add natural pause between verses
            if index < verses.count - 1 {
                formattedText += " [pause] "
            }
        }
        
        // Closing with peaceful tone
        formattedText += " [pause] [peaceful] This concludes chapter \(chapter)."
        
        return formattedText
    }
    
    private func determineEmotionalContext(for text: String, book: BibleBook?) -> EmotionalContext {
        let lowercaseText = text.lowercased()
        
        // Determine emotional context based on content and book
        if lowercaseText.contains("fear not") || lowercaseText.contains("do not fear") || lowercaseText.contains("be not afraid") {
            return .comforting
        } else if lowercaseText.contains("rejoice") || lowercaseText.contains("joy") || lowercaseText.contains("celebrate") {
            return .joyful
        } else if lowercaseText.contains("woe") || lowercaseText.contains("judgment") || lowercaseText.contains("anger of the lord") {
            return .warning
        } else if lowercaseText.contains("love") || lowercaseText.contains("beloved") || lowercaseText.contains("mercy") {
            return .loving
        } else if lowercaseText.contains("pray") || lowercaseText.contains("worship") || lowercaseText.contains("holy") {
            return .reverent
        } else if lowercaseText.contains("!") || lowercaseText.contains("behold") {
            return .proclamation
        } else if lowercaseText.contains("?") {
            return .questioning
        } else if book?.name.contains("Psalm") == true {
            return .meditative
        } else if book?.name.contains("Proverbs") == true {
            return .wise
        } else {
            return .narrative
        }
    }
    
    private func applyEmotionalFormatting(text: String, context: EmotionalContext) -> String {
        switch context {
        case .comforting:
            return "[gentle] [warm] \(text)"
        case .joyful:
            return "[excited] [uplifting] \(text)"
        case .warning:
            return "[serious] [authoritative] \(text)"
        case .loving:
            return "[warm] [tender] \(text)"
        case .reverent:
            return "[reverent] [whispers] \(text)"
        case .proclamation:
            return "[confident] [clear] \(text)"
        case .questioning:
            return "[curious] [thoughtful] \(text)"
        case .meditative:
            return "[peaceful] [contemplative] \(text)"
        case .wise:
            return "[wise] [measured] \(text)"
        case .narrative:
            return "[clear] [storytelling] \(text)"
        }
    }
    
    // MARK: - ElevenLabs V3 API Integration
    
    private func generateElevenLabsV3Audio(text: String, voice: String) async throws -> Data {
        guard let apiKey = getElevenLabsAPIKey() else {
            throw NSError(domain: "ElevenLabs", code: 1, userInfo: [NSLocalizedDescriptionKey: "Eleven Labs API key not configured"])
        }
        
        let voiceId = getVoiceId(for: voice)
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        // V3 optimized settings for Biblical reading
        let requestBody: [String: Any] = [
            "text": text,
            "model_id": "eleven_v3_alpha", // Try V3 alpha model first
            "voice_settings": [
                "stability": 0.3,  // Creative setting for better emotional expression
                "similarity_boost": 0.75,
                "style": 0.2,      // Subtle style variation
                "use_speaker_boost": true
            ],
            "apply_text_normalization": "auto",
            "seed": 12345 // For consistent generation
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Realistic progress updates for V3 generation (slower due to quality)
        for step in 1...30 {
            await MainActor.run {
                downloadProgress = Double(step) / 30.0
            }
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 second for V3 processing
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "ElevenLabs", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        // Handle V3 specific responses
        if httpResponse.statusCode == 402 || httpResponse.statusCode == 403 || httpResponse.statusCode == 400 {
            // V3 not available or model not accessible, fallback to V2
            print("V3 Alpha not available (status: \(httpResponse.statusCode)), falling back to V2")
            return try await generateElevenLabsV2FallbackAudio(text: text, voice: voice)
        } else if httpResponse.statusCode != 200 {
            // Try V2 fallback for any non-200 response
            print("V3 API request failed with status \(httpResponse.statusCode), trying V2 fallback")
            return try await generateElevenLabsV2FallbackAudio(text: text, voice: voice)
        }
        
        return data
    }
    
    // Fallback to V2 if V3 is not available
    private func generateElevenLabsV2FallbackAudio(text: String, voice: String) async throws -> Data {
        let voiceId = getVoiceId(for: voice)
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voiceId)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(getElevenLabsAPIKey()!, forHTTPHeaderField: "xi-api-key")
        
        // Clean text for V2 (remove V3 audio tags)
        let cleanText = text.replacingOccurrences(of: "\\[[^\\]]+\\]", with: "", options: .regularExpression)
            .replacingOccurrences(of: "  +", with: " ", options: .regularExpression) // Clean up extra spaces
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        let requestBody: [String: Any] = [
            "text": cleanText,
            "model_id": "eleven_multilingual_v2", // Better quality fallback model
            "voice_settings": [
                "stability": 0.4,  // Slightly more variation for expressiveness
                "similarity_boost": 0.75,
                "style": 0.3,  // Add some style variation even in V2
                "use_speaker_boost": true
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "ElevenLabs", code: 2, userInfo: [NSLocalizedDescriptionKey: "V2 fallback API request failed"])
        }
        
        return data
    }
    
    // MARK: - Emotional Context Enum
    
    private enum EmotionalContext {
        case comforting, joyful, warning, loving, reverent, proclamation, questioning, meditative, wise, narrative
    }
    
    // MARK: - Helper Functions
    
    private func getElevenLabsAPIKey() -> String? {
        // Return the Eleven Labs API key
        return "sk_2e744d6fb26fe8fd3abd1704e4115350fc6071f19003a665"
    }
    
    private func getVoiceId(for voiceName: String) -> String {
        // Map voice names to Eleven Labs voice IDs (optimized for V3)
        let voiceMap = [
            "Rachel": "21m00Tcm4TlvDq8ikWAM",
            "Drew": "29vD33N1CtxCmqQRPOHJ",
            "Clyde": "2EiwWnXFnvU5JabPnv8n",
            "Bella": "EXAVITQu4vr4xnSDxMaL",
            "Josh": "TxGEqnHWrfWFTfGW9XjX",
            "Arnold": "VR6AewLTigWG4xSOukaG",
            "Adam": "pNInz6obpgDQGcFmaJgB",
            "Sam": "yoZ06aMxZJJ28mfd3POQ"
        ]
        
        return voiceMap[voiceName] ?? voiceMap["Rachel"]!
    }
    
    // MARK: - Timer and Progress Management
    
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            DispatchQueue.main.async {
                guard let player = self.audioPlayer,
                      self.isPlaying else { return }
                
                self.currentPosition = player.currentTime
                self.updateCurrentVerse()
            }
        }
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    private func updateCurrentVerse() {
        guard totalDuration > 0, !verses.isEmpty else { return }
        
        // Estimate current verse based on playback position
        let progress = currentPosition / totalDuration
        let estimatedVerseIndex = Int(progress * Double(verses.count))
        let newIndex = min(max(estimatedVerseIndex, 0), verses.count - 1)
        
        if newIndex != currentVerseIndex {
            currentVerseIndex = newIndex
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    @MainActor
    private func handleAudioFinished() {
        isPlaying = false
        stopPlaybackTimer()
        currentPosition = totalDuration
        currentVerseIndex = verses.count - 1
    }
}

 