import SwiftUI

struct WelcomeView: View {
    @Environment(QuizViewModel.self) private var viewModel
    @State private var username: String = ""
    @State private var selectedVersion: TestVersion = .short
    @State private var showQuiz = false
    @State private var showDisclaimer = false
    @State private var showTerms = false
    @State private var showPrivacy = false
    @State private var agreedToTerms = false
    @State private var showPrivacyConsent = false
    
    var body: some View {
        ZStack {
            ColorPalette.adaptiveBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // Logo区域
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(ColorPalette.primaryGradient)
                            .frame(width: 120, height: 120)
                            .shadow(color: Color(hex: "#7B68EE").opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        Text("H")
                            .font(.system(size: 60, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                    
                    Text("HBTI")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(ColorPalette.primaryGradient)
                    
                    Text("16型人格测试")
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text("探索你的性格类型，发现真实的自己")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                
                // 输入区域
                VStack(spacing: 20) {
                    // 用户名输入
                    VStack(alignment: .leading, spacing: 8) {
                        Text("你的名字")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        TextField("请输入你的名字", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .padding()
                            .background(ColorPalette.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    }
                    
                    // 版本选择
                    VStack(alignment: .leading, spacing: 12) {
                        Text("选择测试版本")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ForEach(TestVersion.allCases, id: \.self) { version in
                            VersionCard(
                                version: version,
                                isSelected: selectedVersion == version
                            ) {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedVersion = version
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 开始按钮
                Button {
                    if !username.isEmpty && agreedToTerms {
                        viewModel.startQuiz(username: username, version: selectedVersion)
                        showQuiz = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("开始测试")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (username.isEmpty || !agreedToTerms) ? Color.gray : ColorPalette.primaryGradient
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "#7B68EE").opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .disabled(username.isEmpty || !agreedToTerms)
                .padding(.horizontal)
                
                // 服务条款与隐私政策勾选
                HStack(alignment: .top, spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            agreedToTerms.toggle()
                        }
                    } label: {
                        Image(systemName: agreedToTerms ? "checkmark.square.fill" : "square")
                            .font(.title3)
                            .foregroundStyle(agreedToTerms ? ColorPalette.dimensionColor(.ei) : Color.gray.opacity(0.4))
                    }
                    
                    Text("我已阅读并同意") + Text(" 《服务条款》").foregroundColor(ColorPalette.dimensionColor(.ei)).onTapGesture { showTerms = true } + Text(" 和 ") + Text(" 《隐私政策》").foregroundColor(ColorPalette.dimensionColor(.ei)).onTapGesture { showPrivacy = true }
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24)
                .padding(.top, 4)
                
                // 免责声明按钮
                Button("免责声明") {
                    showDisclaimer = true
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 8)
            }
            .padding()
            .padding(.bottom, 20)
            }
            }
        .navigationDestination(isPresented: $showQuiz) {
            QuizView()
                .environment(viewModel)
        }
        .sheet(isPresented: $showDisclaimer) {
            DisclaimerView()
        }
        .sheet(isPresented: $showTerms) {
            TermsOfServiceView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .onAppear {
            if !PersistenceManager.shared.hasShownPrivacyConsent() {
                showPrivacyConsent = true
            }
        }
        .overlay {
            if showPrivacyConsent {
                PrivacyConsentView(isPresented: $showPrivacyConsent)
                    .transition(.opacity.combined(with: .scale))
            }
        }
    }
}

// MARK: - 服务条款
struct TermsOfServiceView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("服务条款")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("最后更新日期：2026年7月4日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Section("1. 服务概述") {
                        Text("HBTI 16型人格测试（以下简称"本应用"）是由汇成家开发并运营的人格评估工具。本应用基于荣格心理类型理论，提供28题简版、48题通用版和93题完整版三种人格评估服务。使用本应用即表示您同意以下条款。")
                    }
                    
                    Section("2. 用户账号") {
                        Text("本应用仅要求用户输入昵称即可使用，不要求注册完整账号。用户应确保提供的昵称不侵犯他人权益，不包含违法或不当内容。我们有权对违规昵称进行修改或限制使用。")
                    }
                    
                    Section("3. 使用规范") {
                        Text("用户在使用本应用时，应遵守以下规范：\n• 不得将本应用用于任何违法或不当用途\n• 不得对本应用进行反向工程、反编译或其他技术破解\n• 不得干扰或破坏本应用的正常运行\n• 不得利用本应用进行商业活动或未经授权的数据采集\n• 不得冒充他人或提供虚假信息")
                    }
                    
                    Section("4. 知识产权") {
                        Text("本应用中的所有内容，包括但不限于文字、图形、图标、界面设计、代码、题库和报告模板，均为汇成家所有，受中华人民共和国知识产权法律保护。未经书面许可，不得以任何形式复制、修改、传播或商业使用本应用的任何内容。\n\n本应用基于荣格心理类型理论独立开发，与 The Myers-Briggs Company 的官方 MBTI 测评无关。")
                    }
                    
                    Section("5. 付费服务") {
                        Text("本应用提供部分付费内容（48题详细报告 ¥9.9、93题详细报告 ¥29.9），通过 Apple App Store 内购系统完成支付。付费内容一经解锁，用户可永久查看。\n\n退款政策遵循 Apple App Store 的标准退款流程，请通过 App Store 申请退款。")
                    }
                    
                    Section("6. 免责声明") {
                        Text("本应用提供的测试结果仅供娱乐和自我探索参考，不构成专业心理诊断、医疗建议或其他专业意见。测试结果不应作为任何医疗、教育、职业或人生重大决策的唯一依据。\n\n如果您有心理健康方面的困扰，请咨询专业的心理医生或心理咨询师。汇成家不对因使用本应用测试结果而做出的任何决策承担责任。")
                    }
                    
                    Section("7. 服务变更") {
                        Text("我们保留随时修改或终止本应用服务的权利，包括但不限于更改功能、调整价格、更新条款等。重大变更将通过应用内通知或更新日志告知用户。")
                    }
                    
                    Section("8. 争议解决") {
                        Text("本条款适用中华人民共和国法律。因本条款或本应用使用产生的任何争议，双方应首先协商解决；协商不成的，任何一方均可向汇成家所在地有管辖权的人民法院提起诉讼。")
                    }
                }
                .padding()
            }
            .navigationTitle("服务条款")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 隐私政策
struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("隐私政策")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("最后更新日期：2026年7月4日")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("汇成家深知个人信息对您的重要性，我们将按照法律法规的规定，保护您的个人信息及隐私安全。我们制定本隐私政策以帮助您了解我们如何收集、使用、存储和保护您的个人信息。请您在使用本应用前仔细阅读本隐私政策。")
                    
                    Section("1. 我们收集的信息") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("我们收集以下类型的信息：")
                                .fontWeight(.medium)
                            Text("• 用户昵称：您在应用中输入的显示名称")
                            Text("• 测试答案：您在答题过程中选择的答案数据")
                            Text("• 测试结果：系统根据您的答案生成的性格类型评估结果")
                            Text("• 购买记录：您通过 Apple IAP 购买的内容解锁记录")
                            Text("• 设备信息：系统版本、设备型号（仅用于性能优化）")
                        }
                    }
                    
                    Section("2. 我们如何使用信息") {
                        Text("我们收集的信息用于以下目的：\n• 生成您的人格类型评估结果和详细报告\n• 保存您的测试历史记录，方便您随时查看\n• 记录您的付费购买状态\n• 优化应用性能和用户体验\n• 遵守法律法规的要求")
                    }
                    
                    Section("3. 信息存储与上传") {
                        Text("您的核心测试数据（昵称、答案、测试结果）存储在您的 iOS 设备本地，您卸载本应用后将被自动清除。\n\n您可以选择是否允许我们上传匿名的测试数据（不含昵称和个人身份信息）用于产品改进分析。已上传的匿名数据可通过 App 内功能随时申请删除。")
                    }
                    
                    Section("4. 信息共享") {
                        Text("我们不会将您的个人信息出售、出租或以其他方式分享给任何第三方。但以下情况除外：\n• 法律法规要求或政府主管部门依法要求\n• 为保护汇成家的合法权益，在必要时向相关机构披露\n• 涉及人身安全的紧急情况")
                    }
                    
                    Section("5. 内购与第三方服务") {
                        Text("本应用的付费功能通过 Apple App Store 的内购系统（In-App Purchase）实现。Apple 会处理支付相关的事务，Apple 的隐私政策（https://www.apple.com/legal/privacy/）适用于支付过程中涉及的个人信息。\n\n本应用不集成任何第三方数据分析工具或广告SDK。")
                    }
                    
                    Section("6. 用户权利") {
                        Text("您对您的个人信息享有以下权利：\n• 查看权：您可以随时在应用内查看您的测试历史记录\n• 删除权：您可以随时删除单条或多条测试记录\n• 更正权：您可以修改您的昵称信息\n• 撤回同意：您可以卸载本应用以完全清除所有数据\n• 恢复购买：您可以随时使用"恢复购买"功能恢复已购买的内容")
                    }
                    
                    Section("7. 数据安全") {
                        Text("我们采取合理的安全措施保护您的个人信息，包括：\n• 核心测试数据仅存储在您的设备本地\n• 经您同意后上传的匿名数据使用 HTTPS/TLS 加密传输\n• 使用 iOS 系统级的安全存储机制\n\n但请注意，任何安全措施都无法做到万无一失。我们建议您妥善保管您的设备，使用设备密码和面容/指纹解锁功能。")
                    }
                    
                    Section("8. 未成年人保护") {
                        Text("本应用适合所有年龄段的用户使用。如果您是未满18周岁的未成年人，请在监护人的指导下阅读本隐私政策，并在取得监护人同意后使用本应用。")
                    }
                    
                    Section("9. 隐私政策的更新") {
                        Text("我们可能会不时更新本隐私政策。更新后的隐私政策将在本应用内公布，并更新"最后更新日期"。重大变更将通过应用更新或弹窗通知的方式告知您。继续使用本应用即表示您同意更新后的隐私政策。")
                    }
                    
                    Section("10. 联系我们") {
                        Text("如果您对本隐私政策或个人信息保护有任何疑问、意见或建议，请通过以下方式联系我们：\n\n邮箱：support@hcjworld.com\n\n我们将在收到您的反馈后尽快回复（通常不超过15个工作日）。")
                    }
                }
                .padding()
            }
            .navigationTitle("隐私政策")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct VersionCard: View {
    let version: TestVersion
    let isSelected: Bool
    let action: () -> Void
    
    var versionInfo: VersionDetailInfo {
        switch version {
        case .short:
            return VersionDetailInfo(
                icon: "bolt.fill",
                iconColor: Color.green,
                tagline: "快速初探，了解你的性格轮廓",
                features: [
                    "28道精选题目，约3分钟完成",
                    "四大维度基础评估",
                    "自动生成人格类型结果",
                    "免费查看基础分析报告",
                    "支持社交分享卡片"
                ],
                suitableFor: "适合首次体验、快速了解性格类型的人群",
                reportAccess: "基础报告 — 免费"
            )
        case .standard:
            return VersionDetailInfo(
                icon: "star.fill",
                iconColor: Color.orange,
                tagline: "标准评估，获得有深度的性格解读",
                features: [
                    "48道原创题目，约5分钟完成",
                    "每个维度覆盖12种场景",
                    "更精准的维度百分比计算",
                    "包含职业推荐与发展建议",
                    "解锁完整详细分析报告"
                ],
                suitableFor: "适合想要深入了解自己、需要职业或成长参考的人群",
                reportAccess: "基础免费 · 详细报告 ¥9.9"
            )
        case .full:
            return VersionDetailInfo(
                icon: "crown.fill",
                iconColor: Color(hex: "#7B68EE"),
                tagline: "全面深度评估，最详尽的人格画像",
                features: [
                    "93道完整题库，约10分钟完成",
                    "每个维度覆盖23种生活场景",
                    "最高精度的类型判定",
                    "全维度深度解析 + 职业规划",
                    "人际关系 + 压力管理 + 兼容性分析",
                    "支持导出精美PDF报告"
                ],
                suitableFor: "适合追求深度自我认知、需要全面分析报告的人群",
                reportAccess: "基础免费 · 详细报告 ¥29.9"
            )
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                // 第一行：图标+标签 + 标题 + 选中指示器（垂直居中对齐）
                HStack(alignment: .center, spacing: 10) {
                    // 图标 + 价格/免费标签
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(versionInfo.iconColor.opacity(0.12))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: versionInfo.icon)
                                .font(.title3)
                                .foregroundColor(versionInfo.iconColor)
                        }
                        
                        // 价格/标签显示在图标下方
                        if version.isFree {
                            Text("免费")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(Color.green)
                        } else {
                            Text("¥\(String(format: "%.1f", version.price!))")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(versionInfo.iconColor)
                        }
                    }
                    .frame(width: 44)
                    
                    // 标题
                    Text(version.rawValue)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                    
                    Spacer()
                    
                    // 选中指示器（与标题垂直居中）
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(ColorPalette.primaryGradient)
                            .font(.title2)
                    } else {
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                            .frame(width: 22, height: 22)
                    }
                }
                
                // 第二行：标语
                Text(versionInfo.tagline)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 54)
                    .fixedSize(horizontal: false, vertical: true)
                
                // 分割线（始终显示）
                Rectangle()
                    .fill(isSelected ? ColorPalette.dimensionColor(.ei).opacity(0.15) : Color.gray.opacity(0.08))
                    .frame(height: 1)

                // 功能亮点列表（始终完整展示）
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(versionInfo.features, id: \.self) { feature in
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(versionInfo.iconColor)
                                .frame(width: 16)

                            Text(feature)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    Divider()
                        .padding(.vertical, 4)

                    // 适合人群
                    HStack(spacing: 6) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(versionInfo.suitableFor)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    // 报告说明
                    HStack(spacing: 6) {
                        Image(systemName: "doc.text.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(versionInfo.reportAccess)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color(hex: "#F8F5FF") : ColorPalette.cardBackground)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color(hex: "#7B68EE") : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
            .shadow(color: .black.opacity(isSelected ? 0.08 : 0.04), radius: isSelected ? 12 : 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isSelected)
    }
}

// 版本详情信息模型
struct VersionDetailInfo {
    let icon: String
    let iconColor: Color
    let tagline: String
    let features: [String]
    let suitableFor: String
    let reportAccess: String
}

struct DisclaimerView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("免责声明")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("本测试基于荣格心理类型理论设计，仅供娱乐和自我探索参考，不构成专业心理诊断或医疗建议。测试结果不应作为任何医疗、教育或职业决策的唯一依据。")
                        .font(.body)
                    
                    Text("与 The Myers-Briggs Company 的官方 MBTI 测评无关。HBTI 是独立开发的原创人格评估工具。")
                        .font(.body)
                    
                    Text("如果您有心理健康方面的困扰，请咨询专业的心理医生或心理咨询师。")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}
