import SwiftUI

struct DurationSelectionView: View {
    @Binding var selectedDuration: TimeInterval?
    var onNext: () -> Void
    
    let durations: [(String, TimeInterval)] = [
        ("30 minutes", 1800),
        ("1 hour", 3600),
        ("2 hours", 7200),
        ("4 hours", 14400),
        ("8 hours", 28800)
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            Text("How long do you want the sound to play?")
                .font(.custom("OpenSans-Bold", size: 28))
                .foregroundColor(.white)
                .padding(.top, 40)
            ForEach(durations, id: \.1) { duration in
                Button(action: {
                    selectedDuration = duration.1
                    onNext()
                }) {
                    Text(duration.0)
                        .font(.custom("OpenSans-SemiBold", size: 22))
                        .foregroundColor(.white)
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color("PastelBlue").opacity(0.18))
                        .cornerRadius(18)
                        .shadow(color: Color("PastelBlue").opacity(0.10), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 32)
            }
            Spacer()
        }
        .background(Color("MidnightBlue").background(.ultraThinMaterial).ignoresSafeArea())
    }
} 