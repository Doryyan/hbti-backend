import Foundation

struct UserProfile: Codable {
    var username: String
    var lastTestDate: Date?
    var totalTestsCompleted: Int
    var unlockedProducts: [String]
}
