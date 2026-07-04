import Foundation

struct DimensionScore: Codable, Identifiable {
    var id: String { "\(dimension.rawValue)" }
    let dimension: PersonalityDimension
    let leftScore: Double
    let rightScore: Double
    let leftPercentage: Double
    let rightPercentage: Double
    let dominantSide: DimensionDirection
    
    var dominantCode: String {
        dominantSide == .left ? dimension.leftCode : dimension.rightCode
    }
    
    var dominantLabel: String {
        dominantSide == .left ? dimension.leftLabel : dimension.rightLabel
    }
}
