import Foundation

enum PersonalityDimension: String, Codable, CaseIterable {
    case ei = "EI"
    case sn = "SN"
    case tf = "TF"
    case jp = "JP"
    
    var leftLabel: String {
        switch self {
        case .ei: return "内向"
        case .sn: return "感觉"
        case .tf: return "情感"
        case .jp: return "知觉"
        }
    }
    
    var rightLabel: String {
        switch self {
        case .ei: return "外向"
        case .sn: return "直觉"
        case .tf: return "思考"
        case .jp: return "判断"
        }
    }
    
    var leftCode: String {
        switch self {
        case .ei: return "I"
        case .sn: return "S"
        case .tf: return "F"
        case .jp: return "P"
        }
    }
    
    var rightCode: String {
        switch self {
        case .ei: return "E"
        case .sn: return "N"
        case .tf: return "T"
        case .jp: return "J"
        }
    }
    
    var description: String {
        switch self {
        case .ei: return "精力来源"
        case .sn: return "认知方式"
        case .tf: return "决策方式"
        case .jp: return "生活态度"
        }
    }
    
    var colorHex: String {
        switch self {
        case .ei: return "#7B68EE"
        case .sn: return "#00BFA5"
        case .tf: return "#FF6B81"
        case .jp: return "#34C759"
        }
    }
}

enum DimensionDirection: String, Codable {
    case left
    case right
}

enum QuestionCategory: String, Codable {
    case social = "social"
    case work = "work"
    case leisure = "leisure"
    case decision = "decision"
    case stress = "stress"
    case learning = "learning"
    case communication = "communication"
    case planning = "planning"
}

enum TestVersion: String, Codable, CaseIterable {
    case short = "28题简版"
    case standard = "48题通用版"
    case full = "93题完整版"
    
    var questionCount: Int {
        switch self {
        case .short: return 28
        case .standard: return 48
        case .full: return 93
        }
    }
    
    var isFree: Bool {
        switch self {
        case .short: return true
        case .standard, .full: return false
        }
    }
    
    var price: Double? {
        switch self {
        case .short: return nil
        case .standard: return 9.9
        case .full: return 29.9
        }
    }
    
    var productID: String? {
        switch self {
        case .short: return nil
        case .standard: return "hbti_report_48"
        case .full: return "hbti_report_93"
        }
    }
}
