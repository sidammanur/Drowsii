import Foundation

struct SleepRecommendation: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let soundSuggestion: String
    let timestamp: Date
    
    init(title: String, content: String, soundSuggestion: String) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.soundSuggestion = soundSuggestion
        self.timestamp = Date()
    }
}

class RecommendationsManager: ObservableObject {
    @Published var recommendations: [SleepRecommendation] = []
    @Published var currentRecommendation: SleepRecommendation?
    
    init() {
        loadRecommendations()
    }
    
    func addRecommendation(title: String, content: String, soundSuggestion: String) {
        let recommendation = SleepRecommendation(
            title: title,
            content: content,
            soundSuggestion: soundSuggestion
        )
        recommendations.append(recommendation)
        currentRecommendation = recommendation
        saveRecommendations()
    }
    
    func getRecommendationForQuizAnswers(_ answers: [Int]) -> SleepRecommendation? {
        // For now, return the most recent recommendation
        // In a real app, you could implement logic to match recommendations to quiz patterns
        return recommendations.last
    }
    
    private func saveRecommendations() {
        if let encoded = try? JSONEncoder().encode(recommendations) {
            UserDefaults.standard.set(encoded, forKey: "saved_recommendations")
        }
    }
    
    private func loadRecommendations() {
        if let data = UserDefaults.standard.data(forKey: "saved_recommendations"),
           let decoded = try? JSONDecoder().decode([SleepRecommendation].self, from: data) {
            recommendations = decoded
        }
    }
    
    func clearRecommendations() {
        recommendations.removeAll()
        currentRecommendation = nil
        UserDefaults.standard.removeObject(forKey: "saved_recommendations")
    }
} 