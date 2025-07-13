import SwiftUI

struct AlarmSelectionView: View {
    @Binding var selectedAlarm: String?
    var onNext: () -> Void
    
    @State private var bedtime: Date = defaultBedtime
    let alarms: [String] = [
        "No Alarm",
        "Gentle Chimes",
        "Birdsong",
        "Classic Bell",
        "Soft Piano",
        "Ocean Sunrise"
    ]
    
    var body: some View {
        VStack(spacing: 28) {
            Text("Set Your Bedtime & Alarm")
                .font(.system(size: 28, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 36)
                .minimumScaleFactor(0.7)
                .transition(.move(edge: .top).combined(with: .opacity))
            
            VStack(spacing: 12) {
                Text("What time do you want to go to bed?")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("PastelBlue"))
                DatePicker("Bedtime", selection: $bedtime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(16)
                    .padding(.horizontal, 16)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                Text("Choose an alarm sound:")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("PastelBlue"))
                ForEach(alarms, id: \.self) { alarm in
                    Button(action: {
                        selectedAlarm = alarm
                        onNext()
                    }) {
                        Text(alarm)
                            .font(.custom("OpenSans-SemiBold", size: 20))
                            .foregroundColor(.white)
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                            .background(Color("PastelBlue").opacity(0.18))
                            .cornerRadius(16)
                            .shadow(color: Color("PastelBlue").opacity(0.10), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 32)
                }
            }
            Spacer()
        }
        .background(Color("MidnightBlue").background(.ultraThinMaterial).ignoresSafeArea())
    }
}

private var defaultBedtime: Date {
    var components = DateComponents()
    components.hour = 22
    components.minute = 0
    return Calendar.current.date(from: components) ?? Date()
} 