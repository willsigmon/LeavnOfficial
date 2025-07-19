import Foundation
import AVFoundation

// MARK: - Concrete Audio Service Implementation

public actor AudioServiceImpl: AudioServiceProtocol {
    private let apiConfiguration: APIConfiguration
    private let session: URLSession
    private var audioPlayer: AVAudioPlayer?
    private var audioSession: AVAudioSession
    private var currentStreamTask: URLSessionDataTask?
    
    public init(
        apiConfiguration: APIConfiguration,
        session: URLSession = .shared
    ) {
        self.apiConfiguration = apiConfiguration
        self.session = session
        self.audioSession = AVAudioSession.sharedInstance()
    }
    
    public func streamAudio(for text: String, voice: Voice) async throws -> AsyncThrowingStream<Data, Error> {
        guard let apiKey = apiConfiguration.elevenLabsAPIKey else {
            throw AppError.apiKeyMissing("ElevenLabs")
        }
        
        // Cancel any existing stream
        currentStreamTask?.cancel()
        
        let url = URL(string: "https://api.elevenlabs.io/v1/text-to-speech/\(voice.id)/stream")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let body = ElevenLabsTTSRequest(
            text: text,
            modelId: "eleven_multilingual_v2",
            voiceSettings: .init(stability: 0.5, similarityBoost: 0.75)
        )
        request.httpBody = try JSONEncoder().encode(body)
        
        return AsyncThrowingStream { continuation in
            let task = self.session.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.finish(throwing: NetworkError.invalidURL)
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    if let data = data {
                        continuation.yield(data)
                    }
                    continuation.finish()
                case 401:
                    continuation.finish(throwing: NetworkError.unauthorized)
                case 429:
                    continuation.finish(throwing: NetworkError.rateLimited)
                default:
                    continuation.finish(throwing: NetworkError.serverError(httpResponse.statusCode, nil))
                }
            }
            
            task.resume()
            self.currentStreamTask = task
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
    
    public func downloadAudio(for verses: [Verse], voice: Voice) async throws -> URL {
        let text = verses.map { $0.text }.joined(separator: " ")
        
        var audioData = Data()
        for try await chunk in try await streamAudio(for: text, voice: voice) {
            audioData.append(chunk)
        }
        
        // Save to temporary file
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(UUID().uuidString).mp3"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        try audioData.write(to: fileURL)
        
        return fileURL
    }
    
    public func getAvailableVoices() async throws -> [Voice] {
        guard let apiKey = apiConfiguration.elevenLabsAPIKey else {
            throw AppError.apiKeyMissing("ElevenLabs")
        }
        
        let url = URL(string: "https://api.elevenlabs.io/v1/voices")!
        
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "xi-api-key")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidURL
        }
        
        switch httpResponse.statusCode {
        case 200:
            let voiceResponse = try JSONDecoder().decode(ElevenLabsVoiceResponse.self, from: data)
            return voiceResponse.voices.map { voice in
                Voice(
                    id: voice.voiceId,
                    name: voice.name,
                    language: "en",
                    gender: .neutral,
                    previewURL: voice.previewUrl.flatMap { URL(string: $0) },
                    isPremium: false
                )
            }
        case 401:
            throw NetworkError.unauthorized
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.serverError(httpResponse.statusCode, nil)
        }
    }
    
    // Audio playback control methods
    public func play(audioData: Data) async throws {
        try await configureAudioSession()
        
        audioPlayer = try AVAudioPlayer(data: audioData)
        audioPlayer?.prepareToPlay()
        audioPlayer?.play()
    }
    
    public func pause() async {
        audioPlayer?.pause()
    }
    
    public func resume() async {
        audioPlayer?.play()
    }
    
    public func stop() async {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    public func setPlaybackSpeed(_ speed: Double) async {
        audioPlayer?.rate = Float(speed)
    }
    
    private func configureAudioSession() async throws {
        try audioSession.setCategory(.playback, mode: .spokenAudio)
        try audioSession.setActive(true)
    }
}

// MARK: - Default Voice Presets

public extension Voice {
    static let defaultVoices: [Voice] = [
        Voice(
            id: "21m00Tcm4TlvDq8ikWAM",
            name: "Rachel",
            gender: .female,
            isPremium: false
        ),
        Voice(
            id: "AZnzlk1XvdvUeBnXmlld",
            name: "Domi",
            gender: .female,
            isPremium: false
        ),
        Voice(
            id: "EXAVITQu4vr4xnSDxMaL",
            name: "Bella",
            gender: .female,
            isPremium: false
        ),
        Voice(
            id: "ErXwobaYiN019PkySvjV",
            name: "Antoni",
            gender: .male,
            isPremium: false
        ),
        Voice(
            id: "VR6AewLTigWG4xSOukaG",
            name: "Arnold",
            gender: .male,
            isPremium: false
        )
    ]
}