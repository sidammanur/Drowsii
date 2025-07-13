import Foundation
import GoogleGenerativeAI

class GeminiService: ObservableObject {
    private var model: GenerativeModel?
    
    // WARNING: It is strongly advised not to hardcode API keys in your application.
    // This is done here for demonstration purposes only.
    // Consider using a more secure method for storing and accessing your API key.
    private let apiKey = "AIzaSyD6GmeAX0gP2MgrzXobadt8bF-t33vM-GY"

    init() {
        // Correctly configure the model for JSON output directly in the initializer.
        model = GenerativeModel(
            name: "gemini-1.5-flash-latest",
            apiKey: apiKey,
            generationConfig: GenerationConfig(responseMIMEType: "application/json"),
            safetySettings: [] // Consider adjusting safety settings for production
        )
    }
    
    // Updated function to return a structured AIResponse
    func getRecommendations(quiz: SleepQuizViewModel, answers: [Int], retries: Int = 3) async throws -> AIResponse {
        guard let model = model else {
            throw NSError(domain: "GeminiServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }
        
        let prompt = createDetailedPrompt(quiz: quiz, answers: answers)

        var lastError: Error?
        for attempt in 0..<retries {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text, let jsonData = text.data(using: .utf8) {
                    let decoder = JSONDecoder()
                    let aiResponse = try decoder.decode(AIResponse.self, from: jsonData)
                    return aiResponse
                } else {
                    throw NSError(domain: "GeminiServiceError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Empty response from API"])
                }
            } catch {
                lastError = error
                print("Gemini API call failed (attempt \(attempt + 1)/\(retries)): \(error)")
                if attempt < retries - 1 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
            }
        }
        
        throw lastError ?? NSError(domain: "GeminiServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get recommendations after multiple retries."])
    }

    // General chat function for chat view
    func generateChatResponse(prompt: String, retries: Int = 3) async throws -> String {
        guard let model = model else {
            throw NSError(domain: "GeminiServiceError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not initialized"])
        }
        var lastError: Error?
        for attempt in 0..<retries {
            do {
                let response = try await model.generateContent(prompt)
                if let text = response.text, !text.isEmpty {
                    return text.trimmingCharacters(in: .whitespacesAndNewlines)
                } else {
                    throw NSError(domain: "GeminiServiceError", code: -3, userInfo: [NSLocalizedDescriptionKey: "Empty response from API"])
                }
            } catch {
                lastError = error
                print("Gemini API call failed (attempt \(attempt + 1)/\(retries)): \(error)")
                if attempt < retries - 1 {
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                }
            }
        }
        throw lastError ?? NSError(domain: "GeminiServiceError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Failed to get chat response after multiple retries."])
    }

    private func createDetailedPrompt(quiz: SleepQuizViewModel, answers: [Int]) -> String {
        var questionAndAnswers = ""
        for (index, question) in quiz.questions.enumerated() {
            if index < answers.count {
                let answerIndex = answers[index]
                if answerIndex < question.options.count {
                    let answerText = question.options[answerIndex]
                    questionAndAnswers += "Question: \(question.question)\nAnswer: \(answerText)\n\n"
                }
            }
        }

        // Improved prompt for more variety and better structure
        return """
        You are a supportive sleep science expert for the Drowsii app.
        Based *only* on the user's quiz answers provided below, generate personalized sleep recommendations.

        User's answers:
        \(questionAndAnswers)

        For the recommended sleep sound:
        - Recommend a main sound category (e.g., "Pink Noise", "Brown Noise", "White Noise", "Nature Sounds", etc.).
        - In a subcategory, list 3-5 example sounds that fit that category (e.g., for Pink Noise: "rain, wind, gentle static").
        - Do NOT always recommend rain or waves. Vary your suggestions and use the full range of sleep sounds (e.g., fan, wind, forest, static, fireplace, crickets, etc.).
        - The reason should explain why this category is recommended based on their answers.

        Your response MUST be a valid JSON object with the following structure, and nothing else:
        {
          "recommendedSound": {
            "soundCategory": "string",
            "exampleSounds": ["string", "string", ...],
            "reason": "string"
          },
          "additionalTips": [
            {
              "tip": "string",
              "category": "string"
            }
          ]
        }

        - The `additionalTips` should be highly relevant to their specific answers. Provide at least four detailed tips.
        - `category` should be a single word like "Routine", "Environment", "Mindfulness", or "Diet".
        """
    }
} 