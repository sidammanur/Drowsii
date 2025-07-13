import Foundation
import AVFoundation

enum SleepSound: String, CaseIterable {
    // White Noise variants
    case whiteNoise = "White Noise"
    case fan = "Fan"
    case airConditioner = "Air Conditioner"
    case staticNoise = "Static"
    case shower = "Shower"
    case waterfall = "Waterfall"
    
    // Pink Noise variants
    case pinkNoise = "Pink Noise"
    case rain = "Rain"
    case ocean = "Ocean"
    case stream = "Stream"
    case bubbles = "Bubbles"
    case wind = "Wind"
    
    // Brown Noise variants
    case brownNoise = "Brown Noise"
    case thunder = "Thunder"
    case fireplace = "Fireplace"
    case drum = "Drum"
    case heartbeat = "Heartbeat"
    case engine = "Engine"
    
    // Nature sounds
    case forest = "Forest"
    case birds = "Birds"
    case crickets = "Crickets"
    case waves = "Waves"
    case leaves = "Leaves"
    case campfire = "Campfire"
    
    var filename: String {
        switch self {
        case .whiteNoise: return "white_noise"
        case .pinkNoise: return "pink_noise"
        case .brownNoise: return "brown_noise"
        case .rain: return "rain"
        case .ocean: return "ocean"
        case .forest: return "forest"
        case .fan: return "fan"
        case .airConditioner: return "air_conditioner"
        case .staticNoise: return "static"
        case .shower: return "shower"
        case .waterfall: return "waterfall"
        case .stream: return "stream"
        case .bubbles: return "bubbles"
        case .wind: return "wind"
        case .thunder: return "thunder"
        case .fireplace: return "fireplace"
        case .drum: return "drum"
        case .heartbeat: return "heartbeat"
        case .engine: return "engine"
        case .birds: return "birds"
        case .crickets: return "crickets"
        case .waves: return "waves"
        case .leaves: return "leaves"
        case .campfire: return "campfire"
        }
    }
    
    var frequency: Double {
        switch self {
        // White Noise variants (higher frequencies)
        case .whiteNoise: return 1000
        case .fan: return 800
        case .airConditioner: return 1200
        case .staticNoise: return 1500
        case .shower: return 900
        case .waterfall: return 1100
        
        // Pink Noise variants (mid frequencies)
        case .pinkNoise: return 750
        case .rain: return 600
        case .ocean: return 500
        case .stream: return 650
        case .bubbles: return 700
        case .wind: return 550
        
        // Brown Noise variants (lower frequencies)
        case .brownNoise: return 400
        case .thunder: return 200
        case .fireplace: return 300
        case .drum: return 250
        case .heartbeat: return 150
        case .engine: return 350
        
        // Nature sounds (varied frequencies)
        case .forest: return 450
        case .birds: return 800
        case .crickets: return 300
        case .waves: return 400
        case .leaves: return 350
        case .campfire: return 280
        }
    }
    
    var fileExtension: String {
        switch self {
        case .birds, .forest, .crickets:
            return "mp3"
        default:
            return "wav" // Default or generated
        }
    }
}

class SoundPlayerService: ObservableObject {
    private var audioPlayers: [SleepSound: AVAudioPlayer] = [:]
    private var timer: Timer?
    
    @Published var isPlaying = false
    @Published var volumes: [SleepSound: Float] = [:] // Per-sound volume
    @Published var remainingTime: TimeInterval = 0
    @Published var showError = false
    @Published var errorMessage = ""
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }
    
    func play(sounds: [SleepSound], duration: TimeInterval, volumes: [SleepSound: Float]) {
        stop() // Stop any existing playback
        var didPlayAny = false
        for sound in sounds {
            let volume = volumes[sound, default: 0.5]
            if let url = Bundle.main.url(forResource: sound.filename.capitalized, withExtension: sound.fileExtension) ??
                Bundle.main.url(forResource: sound.filename.capitalized, withExtension: sound.fileExtension, subdirectory: "Sounds") {
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.numberOfLoops = -1
                    player.volume = volume
                    player.play()
                    audioPlayers[sound] = player
                    didPlayAny = true
                } catch {
                    print("Failed to play bundled audio for \(sound): \(error)")
                    showError = true
                    errorMessage = "Unable to play \(sound.rawValue)."
                }
            } else {
                // Fallback to generated tone
                if let player = createSimpleTonePlayer(for: sound, volume: volume) {
                    player.play()
                    audioPlayers[sound] = player
                    didPlayAny = true
                }
            }
        }
        if didPlayAny {
            isPlaying = true
            remainingTime = duration
            startTimer()
        }
    }
    
    private func createSimpleTonePlayer(for sound: SleepSound, volume: Float) -> AVAudioPlayer? {
        let sampleRate: Double = 44100
        let frequency = sound.frequency
        let frameCount = Int(sampleRate * 1.0)
        var audioData = [Float](repeating: 0, count: frameCount)
        for i in 0..<frameCount {
            let time = Double(i) / sampleRate
            audioData[i] = Float(sin(2.0 * .pi * frequency * time) * 0.3)
        }
        let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: AVAudioFrameCount(frameCount))!
        audioBuffer.frameLength = AVAudioFrameCount(frameCount)
        let channelData = audioBuffer.floatChannelData![0]
        for i in 0..<frameCount {
            channelData[i] = audioData[i]
        }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let audioURL = documentsPath.appendingPathComponent("\(sound.filename).wav")
        do {
            let audioFile = try AVAudioFile(forWriting: audioURL, settings: audioFormat.settings)
            try audioFile.write(from: audioBuffer)
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.numberOfLoops = -1
            player.volume = volume
            return player
        } catch {
            print("Failed to create or play audio: \(error)")
            showError = true
            errorMessage = "Unable to play sound. Please try again."
            return nil
        }
    }
    
    func setVolume(for sound: SleepSound, volume: Float) {
        volumes[sound] = volume
        audioPlayers[sound]?.volume = volume
    }
    
    func stop() {
        for player in audioPlayers.values {
            player.stop()
        }
        audioPlayers.removeAll()
        timer?.invalidate()
        timer = nil
        isPlaying = false
        remainingTime = 0
    }
    
    func pause() {
        for player in audioPlayers.values {
            player.pause()
        }
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    func resume() {
        for player in audioPlayers.values {
            player.play()
        }
        isPlaying = true
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stop()
            }
        }
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) / 60 % 60
        let seconds = Int(timeInterval) % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
} 
