import SwiftUI

@main
struct DrowsiiApp: App {
    @AppStorage("hasCompletedQuiz") private var hasCompletedQuiz = false
    @AppStorage("quizAnswers") private var quizAnswersData: Data = Data()
    @State private var didStart = false
    @State private var selectedTab = 0
    
    var quizAnswers: [Int] {
        (try? JSONDecoder().decode([Int].self, from: quizAnswersData)) ?? []
    }
    
    func saveQuizAnswers(_ answers: [Int]) {
        if let data = try? JSONEncoder().encode(answers) {
            quizAnswersData = data
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if didStart {
                MainTabView(
                    hasCompletedQuiz: $hasCompletedQuiz,
                    quizAnswers: quizAnswers,
                    saveQuizAnswers: saveQuizAnswers,
                    selectedTab: $selectedTab
                )
            } else {
                StartScreenView(didStart: $didStart)
            }
        }
    }
}

struct MainTabView: View {
    @Binding var hasCompletedQuiz: Bool
    var quizAnswers: [Int]
    var saveQuizAnswers: ([Int]) -> Void
    @Binding var selectedTab: Int
    
    var shouldShowQuiz: Bool {
        !hasCompletedQuiz && quizAnswers.isEmpty
    }
    
    init(hasCompletedQuiz: Binding<Bool>, quizAnswers: [Int], saveQuizAnswers: @escaping ([Int]) -> Void, selectedTab: Binding<Int>) {
        self._hasCompletedQuiz = hasCompletedQuiz
        self.quizAnswers = quizAnswers
        self.saveQuizAnswers = saveQuizAnswers
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QuizTab(
                shouldShowQuiz: shouldShowQuiz,
                hasCompletedQuiz: $hasCompletedQuiz,
                quizAnswers: quizAnswers,
                saveQuizAnswers: saveQuizAnswers,
                selectedTab: $selectedTab
            )
            .tabItem {
                Label("Quiz", systemImage: "questionmark.circle")
            }
            .tag(0)
            ResultsTab(quizAnswers: quizAnswers, saveQuizAnswers: saveQuizAnswers)
                .tabItem {
                    Label("Results", systemImage: "chart.bar.xaxis")
                }
                .tag(1)
            SoundTabBarView()
                .tabItem {
                    Label("Sounds", systemImage: "speaker.wave.3.fill")
                }
                .tag(2)
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(3)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(Color("PastelBlue"))
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
            appearance.backgroundColor = .clear
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

struct QuizTab: View {
    var shouldShowQuiz: Bool
    @Binding var hasCompletedQuiz: Bool
    var quizAnswers: [Int]
    var saveQuizAnswers: ([Int]) -> Void
    @Binding var selectedTab: Int
    @State private var showWelcome = true
    
    var body: some View {
        ZStack {
            Image("Drowsii Sounds & Chat Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            if shouldShowQuiz && showWelcome {
                VStack(spacing: 32) {
                    Spacer()
                    Image(systemName: "moon.zzz.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(Color("PastelBlue").opacity(0.7))
                        .padding(.top, 60)
                    Text("Welcome!")
                        .font(.custom("OpenSans-Bold", size: 36))
                        .foregroundColor(Color("PastelBlue"))
                        .minimumScaleFactor(0.7)
                    Text("Please take this quiz so we can give you some recommendations on a healthy sleep life!")
                        .font(.custom("OpenSans-Regular", size: 20))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                    Button(action: { showWelcome = false }) {
                        Text("Start Quiz")
                            .font(.custom("OpenSans-Bold", size: 24))
                            .padding(.horizontal, 40)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 30)
                                    .fill(Color("PastelBlue").opacity(0.18))
                            )
                            .foregroundColor(Color("PastelBlue"))
                            .shadow(color: Color("PastelBlue").opacity(0.12), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 20)
                    Spacer()
                }
                .padding()
            } else if shouldShowQuiz {
                SleepQuizView(onQuizComplete: { answers in
                    saveQuizAnswers(answers)
                    hasCompletedQuiz = true
                    selectedTab = 1
                })
            } else {
                ScrollView {
                    VStack(spacing: 30) {
                        Image(systemName: "moon.zzz.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color("PastelBlue").opacity(0.7))
                            .padding(.top, 60)
                        Text("You've already completed the sleep quiz!")
                            .font(.custom("OpenSans-Bold", size: 32))
                            .foregroundColor(Color("PastelBlue"))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                        Button(action: {
                            hasCompletedQuiz = false
                            saveQuizAnswers([])
                            showWelcome = true
                        }) {
                            Text("Retake Quiz")
                                .font(.custom("OpenSans-Bold", size: 24))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color("PastelBlue").opacity(0.18))
                                )
                                .foregroundColor(Color("PastelBlue"))
                                .shadow(color: Color("PastelBlue").opacity(0.12), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

struct ResultsTab: View {
    var quizAnswers: [Int]
    var saveQuizAnswers: ([Int]) -> Void
    @State private var editingQuiz = false
    var body: some View {
        ZStack {
            Image("Drowsii Sounds & Chat Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            ScrollView {
                if quizAnswers.isEmpty {
                    VStack(spacing: 30) {
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color("PastelBlue").opacity(0.7))
                            .padding(.top, 60)
                        Text("No quiz results yet!")
                            .font(.custom("OpenSans-Bold", size: 32))
                            .foregroundColor(Color("PastelBlue"))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.7)
                        Spacer()
                    }
                    .padding()
                } else {
                    VStack(spacing: 0) {
                        RecommendationsView(quizAnswers: quizAnswers, saveQuizAnswers: saveQuizAnswers)
                        Button(action: { editingQuiz = true }) {
                            Text("Edit Answers")
                                .font(.custom("OpenSans-Bold", size: 22))
                                .padding(.horizontal, 32)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color("PastelBlue").opacity(0.18))
                                )
                                .foregroundColor(Color("PastelBlue"))
                                .shadow(color: Color("PastelBlue").opacity(0.12), radius: 8, x: 0, y: 4)
                        }
                        .padding(.top, 24)
                        .sheet(isPresented: $editingQuiz) {
                            SleepQuizView(onQuizComplete: { answers in
                                saveQuizAnswers(answers)
                                editingQuiz = false
                            })
                        }
                    }
                }
            }
        }
    }
} 