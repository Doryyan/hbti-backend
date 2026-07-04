import UIKit
import Foundation

/// 匿名化测试数据上传服务
/// 支持 Firebase / 自建后端 / 第三方分析平台
/// 所有上传数据均经匿名化处理，不含用户真实身份信息
final class AnalyticsService {
    static let shared = AnalyticsService()
    
    private let session: URLSession
    private var baseURL: String
    private let anonymousID: String
    
    private init() {
        self.session = URLSession(configuration: .default)
        // 从 UserDefaults 读取服务器地址，默认本地开发地址
        if let configuredURL = UserDefaults.standard.string(forKey: "hbti_server_url") {
            self.baseURL = configuredURL
        } else {
            self.baseURL = "https://hbti-api.onrender.com/api"
        }
        
        // 生成稳定的匿名设备标识（非IDFA，非广告标识符）
        if let storedID = UserDefaults.standard.string(forKey: "hbti_anonymous_id") {
            self.anonymousID = storedID
        } else {
            let newID = UUID().uuidString.prefix(8).lowercased()
            UserDefaults.standard.set(String(newID), forKey: "hbti_anonymous_id")
            self.anonymousID = String(newID)
        }
    }
    
    /// 在生产环境中调用此方法配置实际的服务器地址（在 App 启动时调用）
    func configure(serverURL: String) {
        self.baseURL = serverURL
        UserDefaults.standard.set(serverURL, forKey: "hbti_server_url")
    }
    
    // MARK: - 上传测试完成数据
    
    func uploadTestResult(
        result: TestResult,
        answers: [Int: Double],
        questions: [Question],
        completion: ((Bool) -> Void)? = nil
    ) {
        guard PersistenceManager.shared.isAnalyticsEnabled() else {
            completion?(false)
            return
        }
        
        let payload = buildTestPayload(
            result: result,
            answers: answers,
            questions: questions
        )
        
        send(endpoint: "/test-results", payload: payload, completion: completion)
    }
    
    // MARK: - 上传测试进度事件
    
    func trackEvent(_ event: AnalyticsEvent) {
        guard PersistenceManager.shared.isAnalyticsEnabled() else { return }
        
        let payload: [String: Any] = [
            "anonymousID": anonymousID,
            "event": event.rawValue,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "buildVersion": Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        ]
        
        send(endpoint: "/events", payload: payload, completion: nil)
    }
    
    // MARK: - 删除云端匿名数据
    
    func deleteCloudData(completion: ((Bool) -> Void)? = nil) {
        let payload: [String: Any] = [
            "anonymousID": anonymousID,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        var request = URLRequest(url: URL(string: baseURL + "/delete-data")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        session.dataTask(with: request) { _, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion?(success) }
        }.resume()
    }
    
    // MARK: - Private
    
    private func buildTestPayload(
        result: TestResult,
        answers: [Int: Double],
        questions: [Question]
    ) -> [String: Any] {
        // 构建答案映射（题号:维度:方向:得分）
        let answerRecords: [[String: Any]] = questions.compactMap { question in
            guard let score = answers[question.id] else { return nil }
            return [
                "questionID": question.id,
                "dimension": question.dimension.rawValue,
                "direction": question.direction.rawValue,
                "score": score,
                "category": question.category.rawValue
            ]
        }
        
        // 四维得分摘要
        let dimensionSummary: [[String: Any]] = result.dimensionScores.map { score in
            [
                "dimension": score.dimension.rawValue,
                "leftPercentage": score.leftPercentage,
                "rightPercentage": score.rightPercentage,
                "dominantSide": score.dominantSide.rawValue
            ]
        }
        
        return [
            "anonymousID": anonymousID,
            "timestamp": ISO8601DateFormatter().string(from: result.timestamp),
            "testVersion": result.testVersion.rawValue,
            "typeCode": result.typeCode,
            "dimensionScores": dimensionSummary,
            "answers": answerRecords,
            "questionCount": questions.count,
            "deviceInfo": [
                "model": UIDevice.current.model,
                "systemVersion": UIDevice.current.systemVersion,
                "screenScale": UIScreen.main.scale
            ]
        ]
    }
    
    private func send(
        endpoint: String,
        payload: [String: Any],
        completion: ((Bool) -> Void)?
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion?(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 15
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            completion?(false)
            return
        }
        
        session.dataTask(with: request) { data, response, error in
            let success = error == nil && (response as? HTTPURLResponse)?.statusCode == 200
            #if DEBUG
            if let error = error {
                print("[Analytics] Upload failed: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                print("[Analytics] Upload status: \(response.statusCode)")
            }
            #endif
            DispatchQueue.main.async { completion?(success) }
        }.resume()
    }
}

// MARK: - Analytics Events

enum AnalyticsEvent: String {
    case appLaunch = "app_launch"
    case welcomeScreenViewed = "welcome_viewed"
    case testStarted = "test_started"
    case testCompleted = "test_completed"
    case resultViewed = "result_viewed"
    case paywallShown = "paywall_shown"
    case purchaseInitiated = "purchase_initiated"
    case purchaseCompleted = "purchase_completed"
    case shareResult = "share_result"
    case viewHistory = "view_history"
    case viewPDFReport = "view_pdf_report"
    case deleteDataRequested = "delete_data_requested"
}
