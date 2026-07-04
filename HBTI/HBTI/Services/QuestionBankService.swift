import Foundation

class QuestionBankService {
    static let shared = QuestionBankService()
    
    private var questionBanks: [TestVersion: [Question]] = [:]
    
    private init() {
        loadAllQuestionBanks()
    }
    
    private func loadAllQuestionBanks() {
        for version in TestVersion.allCases {
            if let questions = loadQuestionBank(for: version) {
                questionBanks[version] = questions
            }
        }
    }
    
    private func loadQuestionBank(for version: TestVersion) -> [Question]? {
        let filename: String
        switch version {
        case .short:
            filename = "questions_28"
        case .standard:
            filename = "questions_48"
        case .full:
            filename = "questions_93"
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let bank = try decoder.decode(QuestionBank.self, from: data)
            return bank.questions
        } catch {
            print("Failed to load question bank: \(error)")
            return nil
        }
    }
    
    func getQuestions(for version: TestVersion, shuffled: Bool = true) -> [Question] {
        guard let questions = questionBanks[version] else {
            return []
        }
        return shuffled ? questions.shuffled() : questions
    }
    
    func getQuestionCount(for version: TestVersion) -> Int {
        return questionBanks[version]?.count ?? 0
    }
}

struct QuestionBank: Codable {
    let version: String
    let description: String
    let questions: [Question]
}
