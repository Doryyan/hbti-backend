import Foundation

struct Question: Identifiable, Codable {
    let id: Int
    let text: String
    let dimension: PersonalityDimension
    let direction: DimensionDirection
    let category: QuestionCategory
    let illustration: String
    let illustrationType: String
}

struct Answer: Codable {
    let questionID: Int
    let dimension: PersonalityDimension
    let score: Double
    let direction: DimensionDirection
}
