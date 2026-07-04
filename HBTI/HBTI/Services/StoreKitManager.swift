import Foundation
import StoreKit

@Observable
class StoreKitManager {
    static let shared = StoreKitManager()
    
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    
    private init() {}
    
    func loadProducts() async {
        isLoading = true
        do {
            let productIDs = ["hbti_report_48", "hbti_report_93"]
            products = try await Product.products(for: productIDs)
            await checkPurchaseStatus()
        } catch {
            errorMessage = "加载产品信息失败: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await handleSuccessfulPurchase(transaction)
                    isLoading = false
                    return true
                case .unverified(_, let error):
                    errorMessage = "交易验证失败: \(error.localizedDescription)"
                    isLoading = false
                    return false
                }
            case .userCancelled:
                isLoading = false
                return false
            case .pending:
                errorMessage = "交易正在处理中，请稍后查看"
                isLoading = false
                return false
            @unknown default:
                errorMessage = "未知的购买结果"
                isLoading = false
                return false
            }
        } catch {
            errorMessage = "购买失败: \(error.localizedDescription)"
            isLoading = false
            return false
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        do {
            for await result in Transaction.currentEntitlements {
                switch result {
                case .verified(let transaction):
                    await handleSuccessfulPurchase(transaction)
                case .unverified(_, _):
                    break
                }
            }
        }
        isLoading = false
    }
    
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                await handleSuccessfulPurchase(transaction)
            case .unverified(_, _):
                break
            }
        }
    }
    
    private func handleSuccessfulPurchase(_ transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
        PersistenceManager.shared.unlockProduct(transaction.productID)
        await transaction.finish()
    }
    
    func isProductPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID) || PersistenceManager.shared.isProductUnlocked(productID)
    }
}
