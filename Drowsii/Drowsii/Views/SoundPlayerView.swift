import SwiftUI

struct SoundPlayerView: View {
    @StateObject private var soundPlayer = SoundPlayerService()
    @State private var selectedDuration: TimeInterval = 3600 // 1 hour default
    @State private var showingDurationPicker = false
    @State private var showingSettings = false
    @State private var selectedTab = 0
    
    let durations: [(String, TimeInterval)] = [
        ("30 minutes", 1800),
        ("1 hour", 3600),
        ("2 hours", 7200),
        ("4 hours", 14400),
        ("8 hours", 28800)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            VStack(spacing: 20) {
                // Timer display
                Text(soundPlayer.formatTime(soundPlayer.remainingTime))
                    .font(.custom("OpenSans-Bold", size: 60))
                    .monospacedDigit()
                    .foregroundColor(.white)
                
                // Duration picker
                Button(action: {
                    showingDurationPicker = true
                }) {
                    HStack {
                        Image(systemName: "clock")
                        Text("Set Duration")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                }
                .sheet(isPresented: $showingDurationPicker) {
                    NavigationView {
                        List {
                            ForEach(durations, id: \.1) { duration in
                                Button(action: {
                                    selectedDuration = duration.1
                                    showingDurationPicker = false
                                }) {
                                    Text(duration.0)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .navigationTitle("Select Duration")
                        .navigationBarItems(trailing: Button("Cancel") {
                            showingDurationPicker = false
                        })
                    }
                    .preferredColorScheme(.dark)
                }
                
                // Info for new multi-track UI
                VStack(spacing: 12) {
                    Text("Multi-track sound selection and per-track volume control is now available in the main Sleep Sound Setup experience.")
                        .font(.custom("OpenSans-SemiBold", size: 16))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color("PastelBlue").opacity(0.12))
                        .cornerRadius(16)
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 32)
            
            // Bottom tab bar
            HStack(spacing: 0) {
                ForEach(0..<4, id: \.self) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: getTabIcon(index))
                                .font(.system(size: 20))
                            Text(getTabTitle(index))
                                .font(.caption)
                        }
                        .foregroundColor(selectedTab == index ? Color("PastelBlue") : Color("White").opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color("MidnightBlue").opacity(0.95))
            .overlay(
                Rectangle()
                    .frame(height: 0.5)
                    .foregroundColor(Color("White").opacity(0.15)),
                alignment: .top
            )
        }
        .background(Color("MidnightBlue").background(.ultraThinMaterial).ignoresSafeArea())
        .navigationTitle("Sleep Sounds")
        .navigationBarItems(trailing: Button(action: {
            showingSettings = true
        }) {
            Image(systemName: "gear")
        })
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .alert("Error", isPresented: $soundPlayer.showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(soundPlayer.errorMessage)
        }
        .preferredColorScheme(.dark)
    }
    
    private func getTabIcon(_ index: Int) -> String {
        switch index {
        case 0: return "waveform"
        case 1: return "waveform.path"
        case 2: return "waveform.path.ecg"
        case 3: return "leaf"
        default: return "waveform"
        }
    }
    
    private func getTabTitle(_ index: Int) -> String {
        switch index {
        case 0: return "White"
        case 1: return "Pink"
        case 2: return "Brown"
        case 3: return "Nature"
        default: return "White"
        }
    }
    
    private func getSoundsForTab(_ tabIndex: Int) -> [SleepSound] {
        switch tabIndex {
        case 0: // White Noise
            return [.whiteNoise, .fan, .airConditioner, .staticNoise, .shower, .waterfall]
        case 1: // Pink Noise
            return [.pinkNoise, .rain, .ocean, .stream, .bubbles, .wind]
        case 2: // Brown Noise
            return [.brownNoise, .thunder, .fireplace, .drum, .heartbeat, .engine]
        case 3: // Nature
            return [.forest, .birds, .crickets, .waves, .leaves, .campfire]
        default:
            return [.whiteNoise]
        }
    }
    
    private func getIconForSound(_ sound: SleepSound) -> String {
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
} 