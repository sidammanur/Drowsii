import SwiftUI

struct SoundTabBarView: View {
    @State private var selectedCategory: SoundCategory = .white
    @State private var selectedSounds: [SleepSound] = []
    @State private var isPicking: Bool = false
    @State private var selectedDuration: TimeInterval? = nil
    @State private var selectedAlarm: String? = nil
    @State private var step: SoundStep = .category
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("Drowsii Sounds & Chat Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        switch step {
                        case .category:
                            SoundCategoryGrid(selectedCategory: $selectedCategory, onNext: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    step = .sound
                                    isPicking = true
                                }
                            })
                        case .sound:
                            SoundSelectionView(
                                selectedSounds: $selectedSounds,
                                selectedCategory: selectedCategory,
                                onBack: { withAnimation(.spring()) { step = .category } },
                                onNext: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        step = .duration
                                    }
                                }
                            )
                        case .duration:
                            DurationSelectionView(selectedDuration: $selectedDuration, onNext: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { step = .alarm }
                            })
                        case .alarm:
                            AlarmSelectionView(selectedAlarm: $selectedAlarm, onNext: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { step = .summary }
                            })
                        case .summary:
                            SoundSummaryView(
                                category: selectedCategory,
                                sounds: selectedSounds,
                                duration: selectedDuration ?? 3600,
                                alarm: selectedAlarm,
                                onEditSound: { withAnimation(.spring()) { step = .sound; isPicking = true } },
                                onEditDuration: { withAnimation(.spring()) { step = .duration } },
                                onEditAlarm: { withAnimation(.spring()) { step = .alarm } }
                            )
                        }
                    }
                    .animation(.easeInOut, value: step)
                    .padding(.top, 32)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct SoundCategoryGrid: View {
    @Binding var selectedCategory: SoundCategory
    var onNext: () -> Void
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State private var pressedCategory: SoundCategory? = nil
    var body: some View {
        VStack {
            Spacer(minLength: 40)
            VStack(spacing: 36) {
                Text("Choose a Sound Category")
                    .font(.custom("OpenSans-Bold", size: 26))
                    .foregroundColor(.white)
                    .minimumScaleFactor(0.8)
                    .shadow(color: Color("MidnightBlue").opacity(0.15), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .multilineTextAlignment(.center)
                LazyVGrid(columns: columns, spacing: 28) {
                    ForEach(SoundCategory.allCases) { category in
                        Button(action: {
                            pressedCategory = category
                            selectedCategory = category
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) { onNext() }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) { pressedCategory = nil }
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: icon(for: category))
                                    .font(.system(size: 44))
                                    .foregroundColor(selectedCategory == category ? Color("PastelBlue") : .white)
                                    .shadow(color: Color("PastelBlue").opacity(0.18), radius: 10, x: 0, y: 6)
                                Text(category.rawValue)
                                    .font(.custom("OpenSans-SemiBold", size: 18))
                                    .foregroundColor(selectedCategory == category ? Color("PastelBlue") : .white)
                                    .minimumScaleFactor(0.8)
                                    .lineLimit(1)
                                    .padding(.horizontal, 8)
                            }
                            .frame(maxWidth: .infinity, minHeight: 90)
                            .background((pressedCategory == category || selectedCategory == category) ? Color("PastelBlue").opacity(0.18) : Color.white.opacity(0.07))
                            .cornerRadius(22)
                            .shadow(color: Color("PastelBlue").opacity(0.12), radius: 12, x: 0, y: 8)
                            .scaleEffect(pressedCategory == category ? 0.97 : 1.0)
                            .animation(.spring(), value: pressedCategory)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            Spacer(minLength: 40)
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .background(Color.clear)
    }
    func icon(for category: SoundCategory) -> String {
        switch category {
        case .white: return "waveform"
        case .pink: return "waveform.path"
        case .brown: return "waveform.path.ecg"
        case .nature: return "leaf"
        }
    }
} 