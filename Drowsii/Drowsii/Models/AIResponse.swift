import Foundation

struct AIResponse: Codable, Identifiable {
    var id = UUID()
    let recommendedSound: RecommendedSound
    let additionalTips: [AdditionalTip]

    enum CodingKeys: String, CodingKey {
        case recommendedSound, additionalTips
    }
}

struct RecommendedSound: Codable {
    let soundCategory: String
    let exampleSounds: [String]
    let reason: String
}

struct AdditionalTip: Codable, Identifiable {
    var id: String { tip }
    let tip: String
    let category: String
} 