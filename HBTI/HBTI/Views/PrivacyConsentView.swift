import SwiftUI

struct PrivacyConsentView: View {
    @Binding var isPresented: Bool
    @State private var agreedToAnalytics = false
    @State private var agreedToCrashReports = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 图标
                ZStack {
                    Circle()
                        .fill(ColorPalette.primaryGradient.opacity(0.12))
                        .frame(width: 64, height: 64)
                    Image(systemName: "shield.checkered.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(ColorPalette.primaryGradient)
                }
                .padding(.top, 24)
                .padding(.bottom, 16)
                
                Text("数据使用说明")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("我们尊重您的隐私，以下是数据收集的详细说明")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                    .padding(.bottom, 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // 核心功能 - 不可关闭
                        consentCard(
                            icon: "checkmark.circle.fill",
                            iconColor: Color.green,
                            title: "测试结果计算",
                            description: "您的答题数据和计算结果仅保存在本地设备上，用于生成人格类型分析报告。这是核心功能，无法关闭。",
                            isRequired: true,
                            isOn: .constant(true)
                        )
                        
                        // 匿名分析数据 - 可选
                        consentCard(
                            icon: "chart.bar.fill",
                            iconColor: Color(hex: "#7B68EE"),
                            title: "匿名产品改进数据",
                            description: "上传匿名化的测试数据（不含您的名字），帮助我们分析题目质量、优化测试算法。数据无法追踪到您的个人身份。",
                            isRequired: false,
                            isOn: $agreedToAnalytics
                        )
                        
                        // 崩溃日志 - 可选
                        consentCard(
                            icon: "exclamationmark.triangle.fill",
                            iconColor: Color.orange,
                            title: "崩溃诊断信息",
                            description: "当 App 发生异常时，上传匿名技术日志帮助我们快速定位和修复问题。",
                            isRequired: false,
                            isOn: $agreedToCrashReports
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 280)
                
                // 隐私政策链接
                Button {
                    showPrivacyPolicy = true
                } label: {
                    Text("查看完整《隐私政策》")
                        .font(.footnote)
                        .foregroundColor(ColorPalette.dimensionColor(.ei))
                }
                .padding(.vertical, 12)
                
                // 底部按钮
                VStack(spacing: 12) {
                    Button {
                        saveConsentAndDismiss()
                    } label: {
                        Text("确认并继续")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorPalette.primaryGradient)
                            .cornerRadius(16)
                    }
                    
                    Button {
                        saveConsentAndDismiss()
                    } label: {
                        Text("暂不同意，仅使用基础功能")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
            .background(ColorPalette.cardBackground)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.2), radius: 40, x: 0, y: 20)
            .padding(.horizontal, 24)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicySheet()
        }
    }
    
    private func consentCard(
        icon: String,
        iconColor: Color,
        title: String,
        description: String,
        isRequired: Bool,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(iconColor)
                .frame(width: 28, height: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if isRequired {
                        Text("必需")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green)
                            .cornerRadius(4)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            if isRequired {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.green)
                    .frame(width: 24, height: 24)
            } else {
                Toggle("", isOn: isOn)
                    .toggleStyle(SwitchToggleStyle(tint: ColorPalette.dimensionColor(.ei)))
                    .frame(width: 48)
            }
        }
        .padding(14)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(14)
    }
    
    private func saveConsentAndDismiss() {
        PersistenceManager.shared.savePrivacyConsent(
            analytics: agreedToAnalytics,
            crashReports: agreedToCrashReports
        )
        isPresented = false
    }
}

// 隐私政策内嵌查看页
struct PrivacyPolicySheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("HBTI 16型人格测试 隐私政策")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("最后更新日期：2026年7月4日")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        policySection(title: "1. 我们收集哪些信息", content: [
                            "• 昵称/名字：用于在测试结果页面个性化展示，可填写化名或不填",
                            "• 测试答案：您在答题过程中对每道题的评分选择（1-5分）",
                            "• 测试结果：系统根据您的答案计算出的四维度得分和人格类型",
                            "• 匿名设备标识：用于统计去重，非 IDFA/广告标识符",
                            "• App 使用数据：如测试版本选择、是否完成测试等",
                            "• 崩溃日志：App 发生异常时的技术日志"
                        ])
                        
                        policySection(title: "2. 我们如何使用您的信息", content: [
                            "• 测试答案与结果：计算并展示人格类型分析报告（核心功能）",
                            "• 匿名测试数据：分析题目质量、优化测试算法（需您同意）",
                            "• 使用统计数据：了解各版本使用情况，优化功能设计（需您同意）",
                            "• 崩溃日志：定位并修复技术问题（需您同意）"
                        ])
                        
                        policySection(title: "3. 数据存储与安全", content: [
                            "• 所有数据传输均使用 HTTPS/TLS 加密",
                            "• 数据库访问受严格的权限控制保护",
                            "• 匿名分析数据保留 24 个月",
                            "• 崩溃日志保留 90 天"
                        ])
                        
                        policySection(title: "4. 您的权利", content: [
                            "• 知情权：了解我们收集哪些数据以及如何使用",
                            "• 选择权：可选择是否同意匿名数据收集",
                            "• 访问权：在测试历史中查看过往结果",
                            "• 删除权：随时要求删除所有云端匿名数据",
                            "• 撤回同意权：随时撤回对匿名数据收集的同意"
                        ])
                        
                        policySection(title: "5. 联系我们", content: [
                            "电子邮箱：support@hbti.app",
                            "反馈入口：App 内 设置 → 意见反馈"
                        ])
                    }
                }
                .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
    
    private func policySection(title: String, content: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            ForEach(content, id: \.self) { line in
                Text(line)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    PrivacyConsentView(isPresented: .constant(true))
}
