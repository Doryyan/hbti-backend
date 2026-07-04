import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let userDefaults = UserDefaults.standard
    /// 内存缓存，避免重复解码 UserDefaults
    private var cachedResults: [TestResult]?
    private var cachedResultsTimestamp: Date?
    private let resultsKey = "hbti_test_results"
    private let profileKey = "hbti_user_profile"
    private let unlockedProductsKey = "hbti_unlocked_products"
    private let privacyConsentKey = "hbti_privacy_consent"
    private let consentShownKey = "hbti_consent_shown"
    
    private init() {}
    
    func saveTestResult(_ result: TestResult) {
        // 直接从缓存或解码获取现有数据
        var results: [TestResult]
        if let cached = cachedResults {
            results = cached
        } else {
            results = decodeResultsFromUserDefaults()
        }
        results.append(result)
        let sortedResults = results.sorted { $0.timestamp > $1.timestamp }
        // 先写入持久化，再更新内存缓存
        if let data = try? JSONEncoder().encode(sortedResults) {
            userDefaults.set(data, forKey: resultsKey)
        }
        cachedResults = sortedResults
    }
    
    func getTestResults() -> [TestResult] {
        // 命中内存缓存直接返回
        if let cached = cachedResults { return cached }
        // 缓存未命中则从 UserDefaults 解码
        return decodeResultsFromUserDefaults()
    }
    
    /// 从 UserDefaults 解码并更新缓存
    private func decodeResultsFromUserDefaults() -> [TestResult] {
        guard let data = userDefaults.data(forKey: resultsKey),
              let results = try? JSONDecoder().decode([TestResult].self, from: data) else {
            cachedResults = []
            return []
        }
        let sorted = results.sorted { $0.timestamp > $1.timestamp }
        cachedResults = sorted
        return sorted
    }
    
    func deleteTestResult(_ id: UUID) {
        var results = getTestResults()
        results.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(results) {
            userDefaults.set(data, forKey: resultsKey)
        }
        // 同步更新缓存
        cachedResults = results.sorted { $0.timestamp > $1.timestamp }
    }
    
    func getUserProfile() -> UserProfile {
        guard let data = userDefaults.data(forKey: profileKey),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return UserProfile(username: "", lastTestDate: nil, totalTestsCompleted: 0, unlockedProducts: [])
        }
        return profile
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        if let data = try? JSONEncoder().encode(profile) {
            userDefaults.set(data, forKey: profileKey)
        }
    }
    
    func isProductUnlocked(_ productID: String) -> Bool {
        let products = userDefaults.stringArray(forKey: unlockedProductsKey) ?? []
        return products.contains(productID)
    }
    
    func unlockProduct(_ productID: String) {
        var products = userDefaults.stringArray(forKey: unlockedProductsKey) ?? []
        if !products.contains(productID) {
            products.append(productID)
            userDefaults.set(products, forKey: unlockedProductsKey)
        }
    }
    
    // MARK: - Privacy Consent
    
    func hasShownPrivacyConsent() -> Bool {
        return userDefaults.bool(forKey: consentShownKey)
    }
    
    func savePrivacyConsent(analytics: Bool, crashReports: Bool) {
        let consent = PrivacyConsent(
            analyticsEnabled: analytics,
            crashReportsEnabled: crashReports,
            timestamp: Date()
        )
        if let data = try? JSONEncoder().encode(consent) {
            userDefaults.set(data, forKey: privacyConsentKey)
        }
        userDefaults.set(true, forKey: consentShownKey)
    }
    
    func getPrivacyConsent() -> PrivacyConsent {
        guard let data = userDefaults.data(forKey: privacyConsentKey),
              let consent = try? JSONDecoder().decode(PrivacyConsent.self, from: data) else {
            return PrivacyConsent(analyticsEnabled: false, crashReportsEnabled: false, timestamp: nil)
        }
        return consent
    }
    
    func isAnalyticsEnabled() -> Bool {
        return getPrivacyConsent().analyticsEnabled
    }
    
    func isCrashReportingEnabled() -> Bool {
        return getPrivacyConsent().crashReportsEnabled
    }
}

struct PrivacyConsent: Codable {
    let analyticsEnabled: Bool
    let crashReportsEnabled: Bool
    let timestamp: Date?
}
