import SwiftUI

struct SettingsView: View {
    @AppStorage("hasCompletedQuiz") private var hasCompletedQuiz = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("Drowsii Sounds & Chat Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                Form {
                    Section(header: Text("App Data")
                        .font(.custom("OpenSans-Bold", size: 18))
                        .foregroundColor(Color("PastelBlue"))) {
                        Button("Reset Quiz Progress") {
                            hasCompletedQuiz = false
                            showAlert = true
                            alertMessage = "Quiz progress has been reset. The quiz will appear on next app launch."
                        }
                        .foregroundColor(.red)
                        .font(.custom("OpenSans-Bold", size: 16))
                    }
                    .padding(.vertical, 12)
                    Section(header: Text("About")
                        .font(.custom("OpenSans-Bold", size: 18))
                        .foregroundColor(Color("PastelBlue"))) {
                        HStack {
                            Text("Version")
                                .font(.custom("OpenSans-Regular", size: 16))
                                .foregroundColor(.white)
                            Spacer()
                            Text("1.0.0")
                                .font(.custom("OpenSans-Regular", size: 16))
                                .foregroundColor(Color("PastelBlue").opacity(0.8))
                        }
                        HStack {
                            Text("AI Recommendations")
                                .font(.custom("OpenSans-Regular", size: 16))
                                .foregroundColor(.white)
                            Spacer()
                            Text("Powered by OpenAI")
                                .font(.custom("OpenSans-Regular", size: 16))
                                .foregroundColor(Color("PastelBlue").opacity(0.8))
                        }
                    }
                    .padding(.vertical, 12)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .navigationTitle("Settings")
            .alert("Settings", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
        .preferredColorScheme(.dark)
    }
} 