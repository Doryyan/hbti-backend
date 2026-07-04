import SwiftUI
import StoreKit

struct PaywallView: View {
    let result: TestResult
    @Environment(\.dismiss) private var dismiss
    @State private var storeKitManager = StoreKitManager.shared
    @State private var showSuccessAlert = false
    @State private var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            ColorPalette.adaptiveBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 头部
                    VStack(spacing: 12) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color.orange)
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .clipShape(Circle())
                        
                        Text("解锁详细报告")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("你已经完成了 \(result.testVersion.rawValue) 的测试\n现在可以解锁完整的深度分析报告")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // 报告内容预览
                    VStack(alignment: .leading, spacing: 16) {
                        Text("解锁后将获得")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ReportFeatureRow(icon: "doc.text.fill", title: "完整多维度解析", description: "每个维度的深度解读和日常表现分析")
                        ReportFeatureRow(icon: "briefcase.fill", title: "职业推荐", description: "最适合的职业方向和工作风格建议")
                        ReportFeatureRow(icon: "heart.fill", title: "人际关系分析", description: "友谊、恋爱、沟通风格的全面解析")
                        ReportFeatureRow(icon: "chart.line.uptrend.xyaxis", title: "发展建议", description: "压力管理、成长路径和具体提升方案")
                        ReportFeatureRow(icon: "person.2.fill", title: "类型兼容性", description: "与16种人格类型的匹配度分析")
                        ReportFeatureRow(icon: "square.and.arrow.up", title: "PDF导出", description: "生成精美PDF报告，支持保存和分享")
                    }
                    .padding()
                    .background(ColorPalette.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .padding(.horizontal)
                    
                    // 购买选项
                    VStack(spacing: 12) {
                        if let product = storeKitManager.products.first(where: { $0.id == result.testVersion.productID }) {
                            PurchaseButton(
                                product: product,
                                isLoading: storeKitManager.isLoading
                            ) {
                                Task {
                                    let success = await storeKitManager.purchase(product)
                                    if success {
                                        showSuccessAlert = true
                                    }
                                }
                            }
                        } else {
                            // 演示用的价格按钮
                            DemoPurchaseButton(
                                version: result.testVersion,
                                isLoading: storeKitManager.isLoading
                            ) {
                                // 模拟购买成功
                                if let productID = result.testVersion.productID {
                                    PersistenceManager.shared.unlockProduct(productID)
                                    showSuccessAlert = true
                                }
                            }
                        }
                        
                        Button {
                            Task {
                                await storeKitManager.restorePurchases()
                            }
                        } label: {
                            Text("恢复购买")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .disabled(storeKitManager.isLoading)
                    }
                    .padding(.horizontal)
                    
                    // 安全提示
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.shield.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("Apple App Store 安全支付 · 购买后永久有效")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .task {
            await storeKitManager.loadProducts()
        }
        .alert("解锁成功！", isPresented: $showSuccessAlert) {
            Button("查看报告") {
                dismiss()
            }
        } message: {
            Text("详细报告已解锁，现在可以查看完整的分析报告了。")
        }
        .overlay {
            if storeKitManager.isLoading {
                LoadingOverlay()
            }
        }
    }
}

struct ReportFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(ColorPalette.dimensionColor(.ei))
                .frame(width: 36, height: 36)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

struct PurchaseButton: View {
    let product: Product
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                
                VStack(spacing: 4) {
                    Text("解锁详细报告")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text(product.displayPrice)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(isLoading)
    }
}

struct DemoPurchaseButton: View {
    let version: TestVersion
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.trailing, 8)
                }
                
                VStack(spacing: 4) {
                    Text("解锁详细报告")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    if let price = version.price {
                        Text("¥\(String(format: "%.1f", price))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.orange, Color.red],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.orange.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(isLoading)
    }
}

struct LoadingOverlay: View {
    var body: some View {
        Color.black.opacity(0.3)
            .ignoresSafeArea()
            .overlay {
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Text("处理中...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .shadow(radius: 20)
            }
    }
}
