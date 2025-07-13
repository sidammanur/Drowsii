import SwiftUI

struct SleepQuizView: View {
    @StateObject private var viewModel = SleepQuizViewModel()
    @Environment(\.dismiss) private var dismiss
    var onQuizComplete: (([Int]) -> Void)? = nil
    @State private var pressedIndex: Int? = nil
    @State private var didFireCompletion = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("Drowsii Sounds & Chat Background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
            
            // Dreamy icons overlay
                Group {
                    Image(systemName: "moon.stars.fill")
                        .resizable()
                        .frame(width: 120, height: 120)
                        .foregroundColor(Color.white.opacity(0.07))
                        .offset(x: -120, y: -200)
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 90, height: 60)
                        .foregroundColor(Color.white.opacity(0.09))
                        .offset(x: 120, y: -160)
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 60, height: 40)
                        .foregroundColor(Color.white.opacity(0.06))
                        .offset(x: -100, y: 100)
                    Image(systemName: "cloud.fill")
                        .resizable()
                        .frame(width: 70, height: 50)
                        .foregroundColor(Color.white.opacity(0.05))
                        .offset(x: 100, y: 200)
                    Image(systemName: "sparkles")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color.white.opacity(0.05))
                        .offset(x: 80, y: 180)
                    Image(systemName: "zzz")
                        .resizable()
                        .frame(width: 70, height: 40)
                        .foregroundColor(Color.white.opacity(0.06))
                        .offset(x: -100, y: 120)
                }
                .allowsHitTesting(false)
            
            VStack(spacing: 24) {
                if !viewModel.hasCompletedQuiz {
                    VStack(spacing: 0) {
                    Text(viewModel.currentQuestion.question)
                        .font(.custom("OpenSans-Bold", size: 26))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .id(viewModel.currentQuestionIndex)
                    ProgressView(value: Double(viewModel.currentQuestionIndex), total: Double(viewModel.questions.count))
                        .accentColor(Color("PastelBlue"))
                        .scaleEffect(1.2)
                        .padding(.bottom, 8)
                        .animation(.easeInOut, value: viewModel.currentQuestionIndex)
                    VStack(spacing: 16) {
                        ForEach(0..<viewModel.currentQuestion.options.count, id: \.self) { index in
                            Button(action: {
                                pressedIndex = index
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    viewModel.answerQuestion(index)
                                }
                                if viewModel.hasCompletedQuiz && !didFireCompletion {
                                    didFireCompletion = true
                                    onQuizComplete?(viewModel.answers)
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    pressedIndex = nil
                                }
                            }) {
                                Text(viewModel.currentQuestion.options[index])
                                    .font(.custom("OpenSans-SemiBold", size: 20))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background((pressedIndex == index) ? Color("PastelBlue").opacity(0.25) : Color.white.opacity(0.08))
                                    .cornerRadius(22)
                                    .shadow(color: Color("PastelBlue").opacity(0.08), radius: 8, x: 0, y: 4)
                                    .scaleEffect(pressedIndex == index ? 0.97 : 1.0)
                                    .animation(.spring(), value: pressedIndex)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                    }
                } else {
                    VStack(spacing: 28) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Color("PastelBlue"))
                            .shadow(color: Color("PastelBlue").opacity(0.18), radius: 10, x: 0, y: 6)
                            .transition(.scale.combined(with: .opacity))
                        Text("Quiz Completed!")
                            .font(.custom("OpenSans-Bold", size: 36))
                            .foregroundColor(.white)
                            .minimumScaleFactor(0.7)
                        Text("Thank you for completing the sleep assessment. We'll use this information to provide personalized recommendations.")
                            .font(.custom("OpenSans-Regular", size: 20))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("PastelBlue")))
                            .scaleEffect(1.5)
                            .padding(.top, 12)
                    }
                    .padding(.top, 60)
                    .transition(.opacity.combined(with: .scale))
                }
            }
            .padding(.top, 80)
            .padding(.bottom, 40)
            .animation(.easeInOut, value: viewModel.currentQuestionIndex)
            .padding(.horizontal, 16)
            .offset(y: 40)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
} 
