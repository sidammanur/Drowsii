import SwiftUI
import GoogleGenerativeAI

struct RecommendationsView: View {
    @StateObject private var geminiService = GeminiService()
    @StateObject private var quizViewModel = SleepQuizViewModel() // To access questions
    
    @AppStorage("lastQuizAnswersHash") private var lastQuizAnswersHash: Int = 0
    @AppStorage("cachedGeminiResponse") private var cachedGeminiResponseData: Data = Data()
    
    @State private var recommendationResponse: AIResponse?
    @State private var checkedTips: Set<String> = []
    
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    let quizAnswers: [Int]
    var saveQuizAnswers: ([Int]) -> Void
    
    var body: some View {
        ZStack {
            Color("MidnightBlue").background(.ultraThinMaterial).ignoresSafeArea()
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView("Generating personalized recommendations...")
                        .progressViewStyle(CircularProgressViewStyle(tint: Color("PastelBlue")))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 80)
                } else if showError {
                    VStack(spacing: 20) {
                        Text("Failed to get recommendations.")
                            .foregroundColor(.red)
                            .font(.title2)
                            .padding()
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.gray)
                        Button(action: { loadOrFetchRecommendations() }) {
                            Text("Retry")
                                .font(.custom("OpenSans-Bold", size: 18))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color("PastelBlue").opacity(0.18))
                                .foregroundColor(Color("PastelBlue"))
                                .cornerRadius(16)
                        }
                    }
                } else if let response = recommendationResponse {
                    // Main Title
                    Text(response.recommendedSound.soundCategory)
                        .font(.custom("OpenSans-Bold", size: 34))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                        .minimumScaleFactor(0.7)

                    // Example sounds subcategory
                    if !response.recommendedSound.exampleSounds.isEmpty {
                        Text(response.recommendedSound.exampleSounds.joined(separator: ", "))
                            .font(.custom("OpenSans-SemiBold", size: 18))
                            .foregroundColor(Color("PastelBlue"))
                            .padding(.bottom, 8)
                    }

                    // Reason
                    Text(response.recommendedSound.reason)
                        .font(.custom("OpenSans-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.85))
                        .lineSpacing(4)
                        .padding(.bottom, 16)

                    // Additional Tips Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADDITIONAL TIPS")
                            .font(.custom("OpenSans-SemiBold", size: 18))
                            .bold()
                            .foregroundColor(Color("PastelBlue"))
                        
                        ForEach(response.additionalTips) { tip in
                            Toggle(isOn: binding(for: tip.id)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(tip.tip)
                                        .font(.custom("OpenSans-Regular", size: 16))
                                        .foregroundColor(.white)
                                        .lineSpacing(4)
                                        .strikethrough(isChecked(tip.id), color: Color("PastelPurple"))
                                    Text(tip.category)
                                        .font(.custom("OpenSans-SemiBold", size: 13))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color("PastelPurple").opacity(0.2))
                                        .foregroundColor(Color("PastelPurple"))
                                        .cornerRadius(8)
                                }
                            }
                            .padding(10)
                            .toggleStyle(CheckboxToggleStyle())
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 40)
        .padding(.bottom, 60)
        .onAppear {
            loadOrFetchRecommendations()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // Helper function to create a binding for the toggle
    private func binding(for tipId: String) -> Binding<Bool> {
        Binding<Bool>(
            get: { self.checkedTips.contains(tipId) },
            set: { isChecked in
                if isChecked {
                    self.checkedTips.insert(tipId)
                } else {
                    self.checkedTips.remove(tipId)
                }
            }
        )
    }
    
    private func isChecked(_ tipId: String) -> Bool {
        self.checkedTips.contains(tipId)
    }
    
    private func hashAnswers(_ answers: [Int]) -> Int {
        var hasher = Hasher()
        for a in answers { hasher.combine(a) }
        return hasher.finalize()
    }
    
    private func loadOrFetchRecommendations() {
        let currentHash = hashAnswers(quizAnswers)
        if currentHash == lastQuizAnswersHash, let cached = try? JSONDecoder().decode(AIResponse.self, from: cachedGeminiResponseData) {
            self.recommendationResponse = cached
            self.isLoading = false
        } else {
            fetchRecommendations(currentHash: currentHash)
        }
    }
    
    private func fetchRecommendations(currentHash: Int) {
        isLoading = true
        showError = false
        Task {
            do {
                let result = try await geminiService.getRecommendations(quiz: quizViewModel, answers: quizAnswers)
                DispatchQueue.main.async {
                    self.recommendationResponse = result
                    self.isLoading = false
                    self.lastQuizAnswersHash = currentHash
                    if let data = try? JSONEncoder().encode(result) {
                        self.cachedGeminiResponseData = data
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to get AI recommendations: \(error.localizedDescription)"
                    self.showError = true
                    self.isLoading = false
                }
            }
        }
    }
}

// Custom ToggleStyle for a checkbox appearance
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Button(action: {
                configuration.isOn.toggle()
            }) {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(configuration.isOn ? Color("PastelPurple") : .gray)
            }
            configuration.label
                .padding(.leading, 8)
        }
    }
} 