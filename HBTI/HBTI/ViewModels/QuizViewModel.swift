import Foundation
import SwiftUI

@Observable
class QuizViewModel {
    var username: String = ""
    var selectedVersion: TestVersion = .short
    var questions: [Question] = []
    var currentQuestionIndex: Int = 0
    var answers: [Int: Double] = [:]
    var isQuizCompleted: Bool = false
    var testResult: TestResult?
    
    var currentQuestion: Question? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard questions.count > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(questions.count)
    }
    
    var canGoBack: Bool {
        currentQuestionIndex > 0
    }
    
    func startQuiz(username: String, version: TestVersion) {
        self.username = username
        self.selectedVersion = version
        self.questions = QuestionBankService.shared.getQuestions(for: version, shuffled: true)
        self.currentQuestionIndex = 0
        self.answers = [:]
        self.isQuizCompleted = false
        self.testResult = nil
    }
    
    func submitAnswer(score: Double) {
        guard let question = currentQuestion else { return }
        answers[question.id] = score
        
        if currentQuestionIndex < questions.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentQuestionIndex += 1
            }
        } else {
            completeQuiz()
        }
    }
    
    func goBack() {
        guard canGoBack else { return }
        withAnimation(.easeInOut(duration: 0.3)) {
            currentQuestionIndex -= 1
        }
    }
    
    func getCurrentAnswer() -> Double? {
        guard let question = currentQuestion else { return nil }
        return answers[question.id]
    }
    
    private func completeQuiz() {
        let dimensionScores = calculateDimensionScores()
        let typeCode = determineTypeCode(from: dimensionScores)
        
        testResult = TestResult(
            id: UUID(),
            username: username,
            testVersion: selectedVersion,
            typeCode: typeCode,
            dimensionScores: dimensionScores,
            timestamp: Date(),
            isDetailedReportUnlocked: selectedVersion.isFree
        )
        
        isQuizCompleted = true
        saveResult()
        uploadAnalytics()
    }
    
    private func uploadAnalytics() {
        guard let result = testResult else { return }
        AnalyticsService.shared.trackEvent(.testCompleted)
        AnalyticsService.shared.uploadTestResult(
            result: result,
            answers: answers,
            questions: questions
        ) { success in
            #if DEBUG
            print("[QuizViewModel] Analytics upload: \(success ? "success" : "failed")")
            #endif
        }
    }
    
    private func calculateDimensionScores() -> [DimensionScore] {
        var scores: [PersonalityDimension: (left: Double, right: Double)] = [:]
        
        for dimension in PersonalityDimension.allCases {
            scores[dimension] = (left: 0, right: 0)
        }
        
        for question in questions {
            guard let answerScore = answers[question.id] else { continue }
            
            let score: Double
            if question.direction == .left {
                score = 1 - answerScore
            } else {
                score = answerScore
            }
            
            var currentScores = scores[question.dimension]!
            
            if score >= 0.5 {
                currentScores.right += score
            } else {
                currentScores.left += (1 - score)
            }
            
            scores[question.dimension] = currentScores
        }
        
        return scores.map { dimension, score in
            let total = score.left + score.right
            let leftPercentage = total > 0 ? (score.left / total) * 100 : 50
            let rightPercentage = total > 0 ? (score.right / total) * 100 : 50
            let dominantSide: DimensionDirection = score.right >= score.left ? .right : .left
            
            return DimensionScore(
                dimension: dimension,
                leftScore: score.left,
                rightScore: score.right,
                leftPercentage: leftPercentage,
                rightPercentage: rightPercentage,
                dominantSide: dominantSide
            )
        }.sorted { $0.dimension.rawValue < $1.dimension.rawValue }
    }
    
    private func determineTypeCode(from scores: [DimensionScore]) -> String {
        var typeCode = ""
        for score in scores.sorted(by: { $0.dimension.rawValue < $1.dimension.rawValue }) {
            typeCode += score.dominantCode
        }
        return typeCode
    }
    
    private func saveResult() {
        guard let result = testResult else { return }
        PersistenceManager.shared.saveTestResult(result)
    }
}
