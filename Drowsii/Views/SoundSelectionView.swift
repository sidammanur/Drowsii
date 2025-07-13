import SwiftUI
import AVFoundation

struct SoundSelectionView: View {
    @Binding var selectedSounds: [SleepSound]
    var selectedCategory: SoundCategory
    var onBack: () -> Void
    var onNext: () -> Void
    
    @State private var currentCategory: SoundCategory = .white
    @State private var showFileImporter = false
    @State private var pressedSound: SleepSound? = nil
    @State private var pressedCustom: Bool = false
    @State private var selectedTab: Int = 0 // 0: Default, 1: My Sounds
    @State private var mySounds: [URL] = []
    @State private var showDeleteAlert = false
    @State private var soundToDelete: URL?
    @State private var showRenameAlert = false
    @State private var soundToRename: URL?
    @State private var newSoundName: String = ""
    
    var sounds: [SleepSound] {
        switch currentCategory {
        case .white: return [.whiteNoise, .fan, .airConditioner, .staticNoise, .shower, .waterfall]
        case .pink: return [.pinkNoise, .rain, .ocean, .stream, .bubbles, .wind]
        case .brown: return [.brownNoise, .thunder, .fireplace, .drum, .heartbeat, .engine]
        case .nature: return [.forest, .birds, .crickets, .waves, .leaves, .campfire]
        }
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Back button
            HStack {
                Button(action: onBack) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(Color("PastelBlue"))
                        Text("Back")
                            .font(.custom("OpenSans-SemiBold", size: 20))
                            .foregroundColor(Color("PastelBlue"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 8)
                    }
                    .padding(12)
                }
                .background(Color.white.opacity(0.07))
                .cornerRadius(22)
                .shadow(color: Color("PastelBlue").opacity(0.10), radius: 8, x: 0, y: 4)
                .scaleEffect(0.97)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.leading, 8)
            .padding(.horizontal, 16)
            
            Picker("Sound Source", selection: $selectedTab) {
                Text("Default Sounds").tag(0)
                Text("My Sounds").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, 16)
            .onChange(of: selectedTab) { _ in
                if selectedTab == 1 { loadMySounds() }
            }
            
            if selectedTab == 0 {
                // Selected sounds area
                VStack(alignment: .leading, spacing: 16) {
                    Text("Selected Sounds:")
                        .font(.title).bold()
                        .foregroundColor(Color("PastelBlue"))
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(selectedSounds, id: \ .self) { sound in
                                HStack(spacing: 4) {
                                    Image(systemName: icon(for: sound))
                                        .foregroundColor(Color("PastelBlue"))
                                    Text(sound.rawValue)
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, 8)
                                    Button(action: {
                                        if let idx = selectedSounds.firstIndex(of: sound) {
                                            selectedSounds.remove(at: idx)
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                            }
                            Button(action: { showFileImporter = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle")
                                    Text("Add Sound")
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, 8)
                                }
                                .font(.custom("OpenSans-SemiBold", size: 16))
                                .foregroundColor(Color("PastelBlue"))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.08))
                                .cornerRadius(14)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
                
                // Category picker
                Picker("Category", selection: $currentCategory) {
                    ForEach(SoundCategory.allCases) { category in
                        Text(category.rawValue).tag(category)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 8)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .accentColor(.white)
                .tint(.white)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
                
                // Replace List with grid-based sound selection
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(sounds, id: \ .self) { sound in
                        Button(action: {
                            pressedSound = sound
                            if selectedSounds.contains(sound) {
                                selectedSounds.removeAll { $0 == sound }
                            } else {
                                selectedSounds.append(sound)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                pressedSound = nil
                            }
                        }) {
                            VStack(spacing: 8) {
                                Image(systemName: icon(for: sound))
                                    .font(.system(size: 28))
                                    .foregroundColor(selectedSounds.contains(sound) ? Color("PastelBlue") : .white)
                                Text(sound.rawValue)
                                    .font(.custom("OpenSans-SemiBold", size: 14))
                                    .foregroundColor(selectedSounds.contains(sound) ? Color("PastelBlue") : .white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                    .padding(.horizontal, 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background((pressedSound == sound || selectedSounds.contains(sound)) ? Color("PastelBlue").opacity(0.28) : Color.white.opacity(0.07))
                            .cornerRadius(22)
                            .shadow(color: Color("PastelBlue").opacity(0.10), radius: 8, x: 0, y: 4)
                            .scaleEffect(pressedSound == sound ? 0.97 : 1.0)
                            .animation(.spring(), value: pressedSound)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
                
                // Add Custom Sound button
                Button(action: { 
                    pressedCustom = true
                    showFileImporter = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { pressedCustom = false }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.square.on.square")
                        Text("Add Custom Sound")
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 8)
                    }
                    .font(.custom("OpenSans-SemiBold", size: 16))
                    .foregroundColor(Color("MidnightBlue"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(pressedCustom ? Color("MidnightBlue").opacity(0.18) : Color.white.opacity(0.10))
                    .cornerRadius(14)
                    .scaleEffect(pressedCustom ? 0.97 : 1.0)
                    .animation(.spring(), value: pressedCustom)
                }
                .buttonStyle(.plain)
                .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.audio], allowsMultipleSelection: false) { result in
                    // Handle file selection here (e.g., store URL or play custom sound)
                }
                .padding(.horizontal, 20)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(mySounds, id: \ .self) { url in
                            HStack {
                                Text(url.lastPathComponent)
                                    .foregroundColor(.white)
                                Spacer()
                                Button(action: { playMySound(url: url) }) {
                                    Image(systemName: "play.circle.fill")
                                        .foregroundColor(Color("PastelBlue"))
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(14)
                            .onLongPressGesture {
                                soundToDelete = url
                                showDeleteAlert = true
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            // Next button
            Button(action: onNext) {
                Text("Continue")
                    .font(.custom("OpenSans-Bold", size: 16))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color("PastelBlue").opacity(0.18))
                    )
                    .foregroundColor(Color("PastelBlue"))
                    .shadow(color: Color("PastelBlue").opacity(0.12), radius: 8, x: 0, y: 4)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 8)
            }
            .padding(.top, 16)
            .disabled(selectedSounds.isEmpty)
            .padding(.horizontal, 16)
            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color("MidnightBlue"), Color("DeepBlue")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
        )
        .alert(isPresented: $showDeleteAlert) {
            Alert(title: Text("Delete Sound?"), message: Text("Are you sure you want to delete this sound?"), primaryButton: .destructive(Text("Delete")) {
                if let url = soundToDelete { deleteMySound(url: url) }
            }, secondaryButton: .cancel())
        }
    }
    
    private func loadMySounds() {
        let soundsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Sounds")
        if let files = try? FileManager.default.contentsOfDirectory(at: soundsDir, includingPropertiesForKeys: nil) {
            mySounds = files.filter { $0.pathExtension == "mp3" }
        }
    }
    private func playMySound(url: URL) {
        // Use AVAudioPlayer or SoundPlayerService
    }
    private func deleteMySound(url: URL) {
        try? FileManager.default.removeItem(at: url)
        loadMySounds()
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
}

struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color("PastelBlue").opacity(0.28) : Color.white.opacity(0.07))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(), value: configuration.isPressed)
    }
}
