import Foundation

struct TestResult: Identifiable, Codable {
    let id: UUID
    let username: String
    let testVersion: TestVersion
    let typeCode: String
    let dimensionScores: [DimensionScore]
    let timestamp: Date
    let isDetailedReportUnlocked: Bool
    
    var personalityType: PersonalityType? {
        PersonalityType.allTypes.first { $0.id == typeCode }
    }
}
