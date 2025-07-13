import Foundation

struct SleepQuestion: Identifiable {
    let id = UUID()
    let question: String
    let options: [String]
    let correctAnswer: Int
}

class SleepQuizViewModel: ObservableObject {
    @Published var questions: [SleepQuestion] = [
        SleepQuestion(
            question: "How many hours of sleep do you typically get per night?",
            options: ["Less than 6 hours", "6-7 hours", "7-8 hours", "More than 8 hours"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How long does it usually take you to fall asleep?",
            options: ["Less than 15 minutes", "15-30 minutes", "30-60 minutes", "More than 60 minutes"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How often do you wake up during the night?",
            options: ["Never", "Once", "2-3 times", "More than 3 times"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you feel refreshed when you wake up?",
            options: ["Always", "Usually", "Sometimes", "Rarely"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How would you rate your sleep quality?",
            options: ["Excellent", "Good", "Fair", "Poor"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you use electronic devices before bed?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you consume caffeine after 2 PM?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you exercise regularly?",
            options: ["Daily", "3-4 times per week", "1-2 times per week", "Never"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you have a consistent sleep schedule?",
            options: ["Always", "Usually", "Sometimes", "Rarely"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How would you describe your stress levels?",
            options: ["Very low", "Low", "Moderate", "High"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you take naps during the day?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you use sleep aids or supplements?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How would you describe your bedroom environment?",
            options: ["Very comfortable", "Comfortable", "Uncomfortable", "Very uncomfortable"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you experience sleep paralysis?",
            options: ["Never", "Rarely", "Sometimes", "Often"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you snore?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you experience nightmares?",
            options: ["Never", "Rarely", "Sometimes", "Often"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How would you rate your daytime energy levels?",
            options: ["Very high", "High", "Moderate", "Low"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you work night shifts?",
            options: ["Never", "Sometimes", "Often", "Always"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "Do you have trouble staying awake while driving?",
            options: ["Never", "Rarely", "Sometimes", "Often"],
            correctAnswer: 0
        ),
        SleepQuestion(
            question: "How would you rate your overall sleep satisfaction?",
            options: ["Very satisfied", "Satisfied", "Dissatisfied", "Very dissatisfied"],
            correctAnswer: 0
        )
    ]
    
    @Published var currentQuestionIndex = 0
    @Published var answers: [Int] = []
    @Published var hasCompletedQuiz = false
    
    var currentQuestion: SleepQuestion {
        questions[currentQuestionIndex]
    }
    
    func answerQuestion(_ answerIndex: Int) {
        answers.append(answerIndex)
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            hasCompletedQuiz = true
        }
    }
    
    func resetQuiz() {
        currentQuestionIndex = 0
        answers = []
        hasCompletedQuiz = false
    }
} 