import SwiftUI

struct SoundSummaryView: View {
    let category: SoundCategory
    let sounds: [SleepSound]
    let duration: TimeInterval
    let alarm: String?
    var onEditSound: (() -> Void)? = nil
    var onEditDuration: (() -> Void)? = nil
    var onEditAlarm: (() -> Void)? = nil
    @StateObject private var soundPlayer = SoundPlayerService()
    @State private var isPlaying = false
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var volumes: [SleepSound: Float] = [:]
    
    var body: some View {
        VStack(spacing: 36) {
            Spacer().frame(height: 32)
            Text("Your Sleep Sound Setup")
                .font(.custom("OpenSans-Bold", size: 32))
                .foregroundColor(Color("PastelBlue"))
                .padding(.top, 40)
            Text("Selected Tracks:")
                .font(.custom("OpenSans-Bold", size: 24))
                .foregroundColor(Color("PastelBlue"))
                .padding(.top, 8)
            VStack(spacing: 16) {
                ForEach(sounds, id: \ .self) { sound in
                    HStack {
                        Image(systemName: icon(for: sound))
                            .font(.system(size: 22))
                            .foregroundColor(Color("PastelBlue"))
                        Text(sound.rawValue)
                            .font(.custom("OpenSans-SemiBold", size: 18))
                            .foregroundColor(.white)
                        Spacer()
                        Slider(value: Binding(
                            get: { volumes[sound, default: 0.5] },
                            set: { newValue in
                                volumes[sound] = newValue
                                soundPlayer.setVolume(for: sound, volume: newValue)
                            }
                        ), in: 0...1)
                        .frame(width: 120)
                        .accentColor(Color("PastelBlue"))
                    }
                }
                if let onEditSound = onEditSound {
                    Button(action: { onEditSound() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color("PastelBlue"))
                            Text("Edit Sounds")
                                .font(.custom("OpenSans-SemiBold", size: 18))
                                .foregroundColor(Color("PastelBlue"))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
            .background(Color.white.opacity(0.07))
            .cornerRadius(24)
            .shadow(color: Color("PastelBlue").opacity(0.08), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 18) {
                HStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.system(size: 32))
                        .foregroundColor(Color("PastelBlue"))
                    Text("\(formatTime(duration))")
                        .font(.custom("OpenSans-SemiBold", size: 24))
                        .foregroundColor(Color("PastelBlue"))
                    if let onEditDuration = onEditDuration {
                        Button(action: { onEditDuration() }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(Color("PastelBlue"))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                if let alarm = alarm, alarm != "No Alarm" {
                    HStack(spacing: 12) {
                        Image(systemName: "alarm")
                            .font(.system(size: 32))
                            .foregroundColor(Color("PastelBlue"))
                        Text(alarm)
                            .font(.custom("OpenSans-SemiBold", size: 24))
                            .foregroundColor(Color("PastelBlue"))
                        if let onEditAlarm = onEditAlarm {
                            Button(action: { onEditAlarm() }) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color("PastelBlue"))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.07))
            .cornerRadius(24)
            .shadow(color: Color("PastelBlue").opacity(0.08), radius: 8, x: 0, y: 4)
            
            // Playback controls
            VStack(spacing: 24) {
                Text(soundPlayer.formatTime(remainingTime))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.bottom, 8)
                HStack(spacing: 40) {
                    Button(action: {
                        if isPlaying {
                            soundPlayer.pause()
                            stopTimer()
                        } else {
                            soundPlayer.play(sounds: sounds, duration: remainingTime == 0 ? duration : remainingTime, volumes: volumes)
                            startTimer()
                        }
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .scaleEffect(isPlaying ? 1.1 : 1.0)
                            .animation(.spring(), value: isPlaying)
                    }
                    Button(action: {
                        soundPlayer.stop()
                        stopTimer()
                        remainingTime = duration
                        isPlaying = false
                    }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                }
            }
            .onAppear {
                remainingTime = duration
            }
            .onDisappear {
                soundPlayer.stop()
                stopTimer()
            }
            Spacer()
        }
        .padding(.bottom, 40)
        .background(
            Image("Drowsii Sounds & Chat Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
        )
    }
    
    func icon(for sound: SleepSound) -> String {
        switch sound {
        case .whiteNoise: return "waveform"
        case .pinkNoise: return "waveform.path"
        case .brownNoise: return "waveform.path.ecg"
        case .rain: return "cloud.rain"
        case .ocean: return "water.waves"
        case .forest: return "leaf"
        case .fan: return "fan"
        case .airConditioner: return "snowflake"
        case .staticNoise: return "radio"
        case .shower: return "drop"
        case .waterfall: return "water.waves.and.arrow.up"
        case .stream: return "water.waves.and.arrow.down"
        case .bubbles: return "bubble.left.and.bubble.right"
        case .wind: return "wind"
        case .thunder: return "cloud.bolt.rain"
        case .fireplace: return "flame"
        case .drum: return "music.note"
        case .heartbeat: return "heart"
        case .engine: return "gearshape"
        case .birds: return "bird"
        case .crickets: return "ant"
        case .waves: return "water.waves"
        case .leaves: return "leaf.arrow.circlepath"
        case .campfire: return "flame.fill"
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
    
    func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                soundPlayer.stop()
                stopTimer()
                isPlaying = false
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
} 