# HBTI 16型人格测试 — iOS App 实施计划

## 一、项目概述（Summary）

开发一款名为 **"HBTI 16型人格测试"** 的 iOS 原生应用，上架苹果 App Store。App 基于荣格心理类型理论（公共领域知识），自主设计原创题目，避免侵犯 The Myers-Briggs Company 的 MBTI 商标和版权。

**核心功能**：
- 三个版本测试：28题简版（完全免费）、48题通用版、93题完整版
- 滑动量表（5-7级 Likert 量表）答题交互
- 基础结果页免费展示，详细分析报告通过 Apple IAP 付费解锁
- 48题版付费 9.9 元解锁详细报告，93题版付费 29.9 元解锁详细报告
- 精美社交分享卡片生成
- 完整的多维度人格分析报告（含维度解析、职业推荐、发展建议、人际关系、压力分析等）
- **PDF 报告导出功能**：用户可将详细报告导出为精美 PDF 文件，支持保存到文件 App 或分享

**技术栈**：原生 SwiftUI + MVVM + @Observable + StoreKit 2 + SwiftData + WKWebView（报告展示）+ UIGraphicsPDFRenderer（PDF 导出）

**最低支持系统**：iOS 17

---

## 二、当前状态分析（Current State Analysis）

### 2.1 已确认信息
| 项目 | 状态 |
|------|------|
| App 名称 | HBTI 16型人格测试 |
| 开发技术 | 原生 SwiftUI |
| 答题交互 | 滑动量表（5-7级 Likert） |
| D-U-N-S 编码 | 已有 |
| 付费模式 | 一次性购买（Apple IAP） |
| 服务器 | 阿里云（现有公司网站运行中） |
| 目标上架 | 企业身份上架 App Store |

### 2.2 待完成事项
1. **注册 Apple Developer Program（公司/组织）**：需要 688 元/年，使用公司域名邮箱，D-U-N-S 编码验证，约 3-5 个工作日审核
2. **开发完整 iOS 应用**：从零开始创建 Xcode 项目
3. **自主创建原创题库**：28 + 48 + 93 共三套题目，每套完全原创
4. **编写 16 种人格类型的详细报告内容库**
5. **设计并实现内购系统**：StoreKit 2 配置与实现
6. **生成 App 图标和截图**：用于 App Store 提交
7. **准备隐私政策页面**：部署到阿里云服务器
8. **App Store 提交与审核**

### 2.3 风险与合规要点
- **法律风险**：不得使用 "MBTI" 商标，题目必须完全原创，需添加免责声明。16Personalities 是合法先例。
- **审核风险**：App 不得声称是医疗/心理诊断工具，必须声明"仅供娱乐参考"。付费功能必须通过 Apple IAP，不可引导至第三方支付。
- **抽成**：中国区 Apple IAP 抽成为 25%（2026年3月调整后），小型企业计划可降至 12%（年收入低于100万美元）。

---

## 三、项目目录结构

```
HBTI/
├── HBTI.xcodeproj                    # Xcode 项目
├── HBTI/
│   ├── App/
│   │   └── HBTIApp.swift             # App 入口
│   ├── Views/
│   │   ├── WelcomeView.swift         # 欢迎页（输入用户名）
│   │   ├── TestVersionSelectView.swift  # 测试版本选择
│   │   ├── QuizView.swift            # 答题主界面
│   │   ├── QuestionCardView.swift    # 题目卡片
│   │   ├── OptionSliderView.swift    # 滑动量表选项
│   │   ├── ProgressBarView.swift     # 进度条
│   │   ├── ResultView.swift          # 基础结果页（免费）
│   │   ├── PaywallView.swift         # 付费墙页面
│   │   ├── ReportView.swift          # 详细报告（WKWebView）
│   │   ├── PDFPreviewView.swift      # PDF 预览与导出界面
│   │   ├── ShareCardView.swift       # 社交分享卡片
│   │   └── HistoryView.swift         # 历史记录
│   ├── ViewModels/
│   │   ├── QuizViewModel.swift       # 答题状态管理、计分
│   │   ├── ResultViewModel.swift     # 结果计算与报告生成
│   │   └── StoreKitViewModel.swift   # 内购管理
│   ├── Models/
│   │   ├── Question.swift            # 题目数据模型
│   │   ├── Answer.swift              # 答案数据模型
│   │   ├── PersonalityType.swift     # 人格类型模型
│   │   ├── DimensionScore.swift      # 维度得分
│   │   ├── TestResult.swift          # 测试结果
│   │   └── UserProfile.swift         # 用户档案
│   ├── Services/
│   │   ├── QuestionBankService.swift # 题库加载（三套）
│   │   ├── ReportGenerator.swift     # 报告生成器
│   │   ├── PDFExportService.swift    # PDF 导出服务
│   │   ├── StoreKitManager.swift     # StoreKit 2 封装
│   │   └── PersistenceManager.swift  # SwiftData 持久化
│   ├── Resources/
│   │   ├── QuestionBanks/            # 三套题库 JSON
│   │   │   ├── questions_28.json
│   │   │   ├── questions_48.json
│   │   │   └── questions_93.json
│   │   ├── ReportTemplates/          # 16种类型报告模板 HTML
│   │   │   ├── INTJ.html
│   │   │   ├── INTP.html
│   │   │   └── ... (共16个)
│   │   ├── Illustrations/            # 题目情境插图（矢量插画）
│   │   │   ├── social_gathering.svg
│   │   │   ├── reading_alone.svg
│   │   │   ├── team_meeting.svg
│   │   │   └── ... (约30-40张)
│   │   ├── DimensionDescriptions.json  # 维度描述
│   │   ├── CareerRecommendations.json  # 职业推荐
│   │   └── DevelopmentAdvice.json      # 发展建议
│   ├── Utils/
│   │   ├── Constants.swift           # 常量定义
│   │   ├── Extensions.swift          # 扩展
│   │   └── ColorPalette.swift        # 配色方案
│   └── Assets.xcassets/              # 图标、图片资源
├── HBTITests/                         # 单元测试
├── HBTIUITests/                       # UI 测试
├── StoreKitTestConfiguration/         # StoreKit 测试配置
└── Assets/
    ├── AppIcon/                       # App 图标各尺寸
    ├── Screenshots/                   # App Store 截图
    └── Marketing/                     # 营销素材
```

---

## 四、详细实施步骤

### Phase 1: 环境与账号准备

#### 1.1 注册 Apple Developer Program（公司/组织）
**为什么**：上架 App Store 必须使用标准开发者计划（688元/年），企业计划（299美元/年）仅用于内部分发，不能上架。

**具体步骤**：
1. 使用公司域名邮箱（如 xxx@huichengjia.com）注册 Apple ID，开启双重认证
2. 访问 https://developer.apple.com/account，选择加入 Apple Developer Program
3. 填写公司英文名称、D-U-N-S 编码（已有）
4. 提交公司营业执照、申请人身份信息
5. 完成人脸识别认证
6. 支付 688 元/年（支持支付宝/微信）
7. 等待苹果人工审核（3-5个工作日）

#### 1.2 配置开发环境
- 安装最新 Xcode（需 macOS，Xcode 16+）
- 创建新的 iOS App 项目，选择 SwiftUI 界面
- 最低部署目标设为 iOS 17
- 配置 Bundle Identifier：`com.huichengjia.hbti`
- 添加 App Icon 和 Launch Screen

#### 1.3 配置 Apple Developer 后台
- 在 App Store Connect 创建新 App
- 填写 App 名称（HBTI 16型人格测试）、副标题、描述
- 配置 App 内购买项目（IAP）：
  - `hbti_report_48` — 48题详细报告解锁 — 9.9元
  - `hbti_report_93` — 93题详细报告解锁 — 29.9元
- 上传隐私政策 URL（需先部署到阿里云服务器）

---

### Phase 2: 数据层 — 题库与报告内容创建

#### 2.1 设计题目结构（JSON Schema）
每道题包含：
```json
{
  "id": 1,
  "text": "在社交场合中，你通常更倾向于...",
  "dimension": "EI",
  "positiveDirection": "E",
  "category": "social",
  "illustration": "social_gathering",
  "illustrationType": "vector"
}
```

**新增字段说明**：
- `illustration`：插图资源名称，对应 Assets.xcassets 中的图片资源
- `illustrationType`：插图类型，支持 `vector`（SF Symbols / SVG 矢量图标）或 `image`（插画图片）

**题目分配规则**：
| 版本 | 总题数 | 每维度题数 | 每维度正反题比例 |
|------|--------|-----------|---------------|
| 28题简版 | 28 | 7 | 正4反3 |
| 48题通用版 | 48 | 12 | 正6反6 |
| 93题完整版 | 93 | 23-24 | 正12反11 |

#### 2.2 原创题目设计原则
- **完全原创**：不复制任何官方 MBTI 量表题目或 16Personalities 原题
- **场景化描述**：每题描述具体行为场景（如"在团队会议中..."、"面对新任务时..."）
- **四个维度全覆盖**：
  - **E/I（外向/内向）**：社交偏好、精力来源、表达方式
  - **S/N（感觉/直觉）**：信息获取方式、关注现实 vs 可能性
  - **T/F（思考/情感）**：决策方式、逻辑 vs 价值观
  - **J/P（判断/知觉）**：生活态度、计划性 vs 灵活性
- **正反题搭配**：每个维度设计正反两种表述，防止作答偏差
- **文化本地化**：考虑中文语境下的行为描述，避免翻译腔

#### 2.3 评分机制
- 采用 Likert 5级或7级滑动量表
- 每题映射到一个维度（EI / SN / TF / JP）
- 选择偏向某一端时，该维度得分累加
- 最终每个维度比较两端得分，高者即为该维度类型
- 四维度组合成四字母类型（如 ENFP）

#### 2.4 报告内容库建设
为每种 16 型人格编写完整报告模板，包含以下模块：

**模块1：类型总览**
- 类型名称 + 中文代称（如"建筑师""辩论家"）
- 核心特征描述（200字精炼总结）
- 人群占比
- 类型关键词标签

**模块2：四维深度解析**
- 每个维度的得分百分比（如"外向 78% / 内向 22%"）
- 每个维度的日常行为表现
- 维度组合带来的独特性格特征

**模块3：职业倾向**
- 最适合的 5-8 个职业方向
- 工作风格描述（领导方式、问题解决、偏好环境）
- 适合的行业领域
- 团队合作中的角色定位

**模块4：人际关系**
- 友谊模式与社交偏好
- 恋爱关系中的表现与需求
- 沟通风格与冲突处理方式
- 亲子关系特点

**模块5：压力与发展**
- 常见压力触发因素
- 压力下的行为模式
- 具体可操作的成长建议（3-5条）
- 适合的放松与充电方式

**模块6：类型兼容性**
- 高兼容类型（3-5个）
- 需注意的互动类型
- 与不同类型相处的建议

---

### Phase 3: 核心功能开发

#### 3.1 数据模型层（Models/）

**Question.swift**
```swift
struct Question: Identifiable, Codable {
    let id: Int
    let text: String
    let dimension: PersonalityDimension
    let direction: DimensionDirection
    let category: QuestionCategory
}

enum PersonalityDimension: String, Codable {
    case ei, sn, tf, jp
}
```

**PersonalityType.swift**
```swift
struct PersonalityType: Identifiable {
    let id: String  // "INTJ"
    let name: String  // "建筑师"
    let group: TypeGroup  // Analyst / Diplomat / Sentinel / Explorer
    let description: String
    let strengths: [String]
    let weaknesses: [String]
}
```

**TestResult.swift**
```swift
struct TestResult: Identifiable, Codable {
    let id: UUID
    let username: String
    let testVersion: TestVersion
    let typeCode: String
    let dimensionScores: [DimensionScore]
    let timestamp: Date
}
```

#### 3.2 题库服务层（Services/QuestionBankService.swift）
- 从 Bundle 加载三套 JSON 题库
- 随机打乱题目顺序（每次测试不同顺序）
- 根据版本返回对应题数和维度分配
- 提供题目预加载和缓存

#### 3.3 答题界面（Views/QuizView.swift + QuestionCardView.swift）

**UI 设计要点**：
- 全屏卡片式布局，每题一张卡片
- 顶部显示用户名和进度条（"第 12/48 题"）
- **题目情境插图区**：每道题上方展示一张贴合题目内容的插图/图标，帮助用户快速理解题意
- 题目文字居中，大号字体，易读
- 底部滑动量表：从「非常不符合」到「非常符合」（5级或7级）
- 滑动时实时反馈，松手后自动进入下一题
- 支持左滑返回上一题修改答案
- 题目切换使用流畅的 `.transition(.slide)` 动画
- 背景使用品牌渐变配色

**题目情境插图设计**：

**插图类型与风格**：
- **优先使用 SF Symbols**：苹果原生矢量图标库，风格统一、系统适配、无需额外资源包
- **辅助使用原创插画**：对于无法用品达标的场景，使用统一风格的扁平插画（Illustration Set）
- **风格统一**：所有插图采用同一套配色（品牌色系），线条简洁、色块柔和，与 App 整体风格协调

**各维度插图示例**：

| 维度 | 题目场景示例 | 对应插图 |
|------|-------------|---------|
| **E/I（外向/内向）** | 参加聚会、独自阅读、团队讨论、独处充电 | `person.3.fill` / `book.fill` / `bubble.left.fill` / `moon.fill` |
| **S/N（感觉/直觉）** | 关注细节、想象未来、处理数据、头脑风暴 | `eye.fill` / `lightbulb.fill` / `chart.bar.fill` / `cloud.fill` |
| **T/F（思考/情感）** | 逻辑分析、关心他人、制定规则、调解冲突 | `brain.head.profile` / `heart.fill` / `list.bullet.clipboard` / `hands.sparkles.fill` |
| **J/P（判断/知觉）** | 制定计划、随性旅行、按时完成任务、灵活应变 | `calendar.badge.checkmark` / `airplane` / `checkmark.circle.fill` / `shuffle` |

**插图动态效果**：
- 题目切换时，插图使用 `.scaleEffect` + `.opacity` 淡入缩放动画
- 插图颜色根据当前题目所属维度动态变化（EI=紫色、SN=绿色、TF=蓝色、JP=黄色）
- 答题时插图轻微浮动动画，增加生动感

**插图尺寸与位置**：
- 位于题目文字上方，占据卡片顶部 30% 区域
- 尺寸：120x120 pt（SF Symbols 使用 `.font(.system(size: 80))`）
- 插图下方有柔和的品牌色渐变背景圆形底衬

**交互细节**：
- 滑动量表使用自定义 Slider 或自定义手势实现
- 每个选项点有触觉反馈（Haptic Feedback）
- 进度条使用动画填充
- 最后3题时进度条变高亮提示即将完成
- 插图区域可点击放大预览（使用 `.matchedGeometryEffect` 实现过渡动画）

#### 3.4 结果计算（ViewModels/QuizViewModel.swift）
- 收集所有答题结果
- 按维度统计得分
- 计算每个维度的百分比
- 确定四字母类型
- 生成基础结果数据

#### 3.5 基础结果页（Views/ResultView.swift）
**免费展示内容**：
- 大字显示四字母类型（如"ENFP"）和中文代称
- 类型卡片：配色区分四大族群（分析家=紫色，外交家=绿色，守护者=蓝色，探险家=黄色）
- 四个维度的百分比雷达图/条形图
- 一段简短的性格描述（约100字）
- 「查看详细报告」按钮（48/93题版引导付费）
- 「再测一次」按钮
- 「分享结果」按钮（生成社交卡片）

**动画效果**：
- 类型字母逐个弹出动画
- 维度条形图从0%动画增长到实际百分比
- 类型卡片缩放进入

#### 3.6 付费墙页面（Views/PaywallView.swift）
**设计要点**：
- 展示已解锁的基础结果
- 清晰说明付费后可获得的内容：
  - 完整多维度深度解析
  - 职业推荐与发展建议
  - 人际关系与恋爱分析
  - 压力管理与成长路径
  - 类型兼容性分析
- 显示价格（9.9元或29.9元）
- 「立即解锁」按钮调用 StoreKit 2 购买
- 「恢复购买」按钮（已购买用户）
- 底部小字：购买后永久有效

---

### Phase 4: 内购系统（StoreKit 2）

#### 4.1 StoreKit 配置
- 在 Xcode 中创建 `.storekit` 配置文件用于本地测试
- 在 App Store Connect 中配置真实产品：
  - `hbti_report_48` — 非消耗型 — 9.9元
  - `hbti_report_93` — 非消耗型 — 29.9元

#### 4.2 StoreKitManager 封装（Services/StoreKitManager.swift）
```swift
@Observable
class StoreKitManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    
    func loadProducts() async
    func purchase(_ product: Product) async -> Transaction?
    func restorePurchases() async
    func checkPurchaseStatus() async
}
```

**关键功能**：
- 应用启动时加载产品信息
- 购买流程：展示产品 → 用户确认 → Apple 支付 → 验证交易 → 解锁内容
- 交易验证使用 StoreKit 2 自动 JWS 签名验证
- 购买状态持久化（用户删了 App 重装也能恢复）
- 监听交易更新（Transaction.updates）

#### 4.3 购买状态管理
- 使用 SwiftData 保存已购买的报告版本
- 购买成功后更新本地状态
- 支持「恢复购买」功能

---

### Phase 5: 详细报告系统

#### 5.1 报告生成器（Services/ReportGenerator.swift）
- 根据人格类型代码加载对应 HTML 模板
- 将用户具体的维度百分比注入模板
- 生成个性化报告内容

#### 5.2 报告展示（Views/ReportView.swift）
**方案**：使用 WKWebView 加载 HTML 报告

**原因**：
- 报告内容复杂（图文混排、图表、多模块），HTML/CSS 最灵活
- 支持 CSS 动画、渐变色、响应式布局
- 可通过 JS 实现交互效果

**报告 HTML 模板结构**：
```html
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <style>
    /* 品牌配色、字体、动画 */
  </style>
</head>
<body>
  <section class="hero">类型总览</section>
  <section class="dimensions">四维解析</section>
  <section class="career">职业推荐</section>
  <section class="relationships">人际关系</section>
  <section class="development">发展建议</section>
  <section class="compatibility">类型兼容</section>
</body>
</html>
```

**交互功能**：
- 报告内嵌「分享」按钮，通过 messageHandler 调用原生分享
- 支持长按保存报告图片
- 报告内维度图表使用 CSS/SVG 动画

#### 5.3 社交分享卡片（Views/ShareCardView.swift）
- 使用 SwiftUI 原生 View 设计精美分享卡片
- 包含：用户名、类型代码、类型名称、维度百分比、关键特征词
- 使用 `ImageRenderer`（iOS 16+）将 View 转为 UIImage
- 支持分享到微信、微博、保存到相册

#### 5.4 PDF 报告导出（Services/PDFExportService.swift + Views/PDFPreviewView.swift）

**核心需求**：用户可将详细人格分析报告导出为精美 PDF 文件，支持保存到「文件」App、AirDrop 分享或发送给他人。

**技术方案**：使用 `UIGraphicsPDFRenderer`（iOS 原生 API）生成 PDF

**实现细节**：

**PDFExportService.swift**
```swift
class PDFExportService {
    static func generatePDF(from result: TestResult, type: PersonalityType) -> Data {
        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 595.2, height: 841.8)) // A4 尺寸 (72dpi)
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            // 绘制报告封面（类型代码 + 名称 + 品牌配色）
            // 绘制四维度分析图表
            // 绘制各模块内容（职业、关系、发展建议等）
        }
        return data
    }
}
```

**PDF 内容排版**：
- **封面页**：HBTI 品牌 Logo + 用户名称 + 测试日期 + 人格类型大字（如"ENFP — 竞选者"）+ 类型配色背景
- **第2页：四维解析**：每个维度的百分比条形图 + 文字解读
- **第3页：类型总览**：核心特征描述、优势与盲点
- **第4页：职业推荐**：推荐职业列表 + 工作风格分析
- **第5页：人际关系**：友谊模式、恋爱倾向、沟通风格
- **第6页：发展建议**：压力分析 + 成长路径 + 具体建议
- **第7页：类型兼容性**：高兼容类型图表
- **封底**：HBTI 品牌信息 + 免责声明

**PDF 样式**：
- 使用与 App 一致的品牌配色（根据类型族群动态切换主色）
- 中文字体：苹方 / PingFang SC（iOS 系统字体）
- 标题加粗，正文清晰易读
- 页眉显示类型代码，页脚显示页码

**用户交互流程**：
1. 在详细报告页（ReportView）底部添加「导出 PDF」按钮
2. 点击后弹出 PDF 预览界面（PDFPreviewView），使用 `PDFKit` 的 `PDFView` 展示生成的 PDF
3. 预览界面提供两个操作：
   - 「保存到文件」：调用 `UIDocumentPickerViewController` 保存到「文件」App
   - 「分享」：调用 `UIActivityViewController` 分享 PDF（微信、邮件、AirDrop 等）
4. 生成 PDF 时显示加载动画，完成后自动预览

**权限需求**：
- 需要 `UIFileSharingEnabled` 和 `LSSupportsOpeningDocumentsInPlace` 配置（如需支持文件 App 访问）
- 分享功能无需额外权限

---

### Phase 6: 数据持久化与历史记录

#### 6.1 SwiftData 数据模型
```swift
@Model
class TestRecord {
    var id: UUID
    var username: String
    var testVersion: String
    var typeCode: String
    var dimensionScores: [Double]
    var timestamp: Date
    var isDetailedReportUnlocked: Bool
}
```

#### 6.2 功能
- 自动保存每次测试结果
- 历史记录列表页，按时间倒序排列
- 可查看历史报告的详细内容（如已付费解锁）
- 支持删除单条记录

---

### Phase 7: UI/UX 设计与美化

#### 7.1 品牌配色方案
基于四大族群设计配色：

| 族群 | 主色 | 辅助色 | 适用类型 |
|------|------|--------|---------|
| 分析家（Analysts）| 深紫 #7B68EE | 浅紫 #E6E0FA | INTJ, INTP, ENTJ, ENTP |
| 外交家（Diplomats）| 翠绿 #3CB371 | 浅绿 #E0F5E9 | INFJ, INFP, ENFJ, ENFP |
| 守护者（Sentinels）| 藏蓝 #4169E1 | 浅蓝 #E0E8FA | ISTJ, ISFJ, ESTJ, ESFJ |
| 探险家（Explorers）| 金黄 #DAA520 | 浅黄 #FFF8DC | ISTP, ISFP, ESTP, ESFP |

全局背景使用微妙的渐变（品牌色到白色）。

#### 7.2 动画设计
- **欢迎页**：App Logo 淡入 + 标题打字机效果
- **答题页**：题目卡片滑动切换 + 选项选中缩放反馈
- **结果页**：类型字母逐个弹出 + 维度条形图动画增长
- **报告页**：章节滚动渐入
- **分享页**：卡片翻转效果

#### 7.3 字体与排版
- 标题：SF Pro Display Bold / 思源黑体 Bold
- 正文：SF Pro Text Regular / 思源黑体 Regular
- 大字号类型代码（如"ENFP"）使用超大号字体（72pt+）

---

### Phase 8: App 图标与素材生成

#### 8.1 App Icon 设计
- 1024x1024 主图标，缩放生成所有尺寸
- 设计风格：简洁现代，以"H"字母为核心元素
- 配色使用品牌紫色/绿色渐变
- 背景为圆角矩形（iOS 规范）

#### 8.2 App Store 截图
准备 5-10 张截图，展示：
1. 欢迎页 / 用户名输入
2. 答题界面（滑动量表）
3. 基础结果页（类型展示）
4. 详细报告页
5. PDF 导出预览界面
6. 社交分享卡片
7. 历史记录页

**规范**：iPhone 6.7" 和 6.1" 屏幕尺寸各一套。

---

### Phase 9: 合规与上架准备

#### 9.1 隐私政策
在阿里云服务器上部署隐私政策页面（`https://yourcompany.com/privacy`），内容需包括：
- 收集的数据类型（用户名、测试答案、购买记录）
- 数据用途（生成报告、保存历史记录）
- 数据存储（本地 SwiftData，不上传服务器）
- 用户权利（删除数据、恢复购买）
- 联系方式

#### 9.2 App 内免责声明
在欢迎页或设置中添加：
> "本测试基于荣格心理类型理论设计，仅供娱乐和自我探索参考，不构成专业心理诊断或医疗建议。与 The Myers-Briggs Company 的官方 MBTI 测评无关。"

#### 9.3 App Store 元数据
- **名称**：HBTI 16型人格测试
- **副标题**：探索你的性格类型，发现真实的自己
- **描述**：强调基于荣格理论、三套版本、详细报告、社交分享
- **关键词**：性格测试,人格测试,心理测试,16型人格,HBTI
- **类别**：生活方式 / 健康健美
- **年龄分级**：4+

#### 9.4 审核准备
- 提供演示账号（如有登录功能，本 App 不需要）
- 在描述中清楚说明哪些功能需要付费
- 确保 App 内无隐藏功能
- 测试所有内购流程（使用沙盒测试账号）

---

### Phase 10: 测试与发布

#### 10.1 测试阶段
- **单元测试**：测试计分逻辑、类型判定、报告生成
- **UI 测试**：测试答题流程、页面导航、内购流程
- **沙盒测试**：使用 TestFlight + 沙盒账号测试 IAP
- **真机测试**：在不同 iPhone 型号上测试布局适配

#### 10.2 提交审核
- 在 App Store Connect 上传构建版本
- 填写所有元数据、截图、预览视频
- 提交审核，等待苹果审核（通常 1-3 天）
- 如被拒，根据反馈修改后重新提交

#### 10.3 发布后维护
- 监控崩溃报告和用户反馈
- 定期更新题库和报告内容
- 考虑添加新功能（如双人兼容性分析、每日洞察）

---

## 五、关键文件清单（开发顺序）

| 顺序 | 文件/模块 | 说明 |
|------|----------|------|
| 1 | `questions_28.json` | 28题简版题库 |
| 2 | `questions_48.json` | 48题通用版题库 |
| 3 | `questions_93.json` | 93题完整版题库 |
| 4 | `DimensionDescriptions.json` | 四维度描述数据 |
| 5 | `CareerRecommendations.json` | 16型职业推荐 |
| 6 | `DevelopmentAdvice.json` | 16型发展建议 |
| 7 | `PersonalityType.swift` | 类型数据模型 |
| 8 | `Question.swift` / `Answer.swift` | 题目/答案模型 |
| 9 | `QuestionBankService.swift` | 题库加载服务 |
| 10 | `QuizViewModel.swift` | 答题逻辑 |
| 11 | `QuizView.swift` | 答题界面 |
| 12 | `ResultViewModel.swift` | 结果计算 |
| 13 | `ResultView.swift` | 基础结果页 |
| 14 | `StoreKitManager.swift` | 内购管理 |
| 15 | `PaywallView.swift` | 付费墙 |
| 16 | 16份 HTML 报告模板 | 详细报告 |
| 17 | `ReportView.swift` | 报告展示 |
| 18 | `PDFExportService.swift` | PDF 导出服务 |
| 19 | `PDFPreviewView.swift` | PDF 预览界面 |
| 20 | `ShareCardView.swift` | 分享卡片 |
| 21 | `HistoryView.swift` | 历史记录 |
| 22 | 题目情境插图集（30-40张） | 答题界面配图 |
| 23 | App Icon + 截图 | 上架素材 |

---

## 六、假设与决策（Assumptions & Decisions）

| # | 决策项 | 决策内容 | 依据 |
|---|--------|---------|------|
| 1 | 技术栈 | 原生 SwiftUI，iOS 17+ | SwiftUI 声明式语法最适合卡片式测验 UI，2025年已完全成熟 |
| 2 | 答题交互 | 5-7级 Likert 滑动量表 | 用户明确选择；比 AB 二选一更精确，体验更流畅（参考 16Personalities） |
| 3 | 付费模式 | 一次性购买（非消耗型 IAP） | 用户明确选择；简单直接，用户支付一次永久解锁 |
| 4 | 报告展示 | WKWebView + HTML 模板 | 报告内容复杂（多模块、图表、富文本），HTML 最灵活 |
| 5 | 题目来源 | 完全原创，基于荣格理论 | 避免 MBTI 商标侵权和版权风险；16Personalities 已验证此模式合法 |
| 6 | 数据存储 | 本地 SwiftData，不上传服务器 | 保护用户隐私，降低合规风险；不需要服务器即可运行核心功能 |
| 7 | 最低版本 | iOS 17 | 享受 `@Observable`、SwiftData、NavigationStack 等新 API |
| 8 | 品牌命名 | HBTI（汇成家首字母） | 用户要求；避免使用 "MBTI" 商标 |
| 9 | 开发账号 | Apple Developer Program（标准） | 上架 App Store 唯一合法途径；688元/年 |
| 10 | 佣金率 | 25%（中国区，2026年3月起） | 苹果官方调整；如符合小企业计划可降至 12% |

---

## 七、验证步骤（Verification）

### 7.1 开发阶段验证
- [ ] 三套题库 JSON 格式正确，题目不重复，维度分配均匀
- [ ] 答题流程流畅，滑动量表响应正常，题目切换动画平滑
- [ ] 每道题显示对应情境插图，插图与题目内容贴合
- [ ] 插图动画效果正常（淡入缩放、维度配色变化）
- [ ] 计分逻辑正确：已知答案可计算出预期人格类型
- [ ] 基础结果页正确显示类型代码和维度百分比
- [ ] 付费墙仅在 48/93 题版出现，28 题版不出现
- [ ] StoreKit 2 内购流程完整：购买 → 验证 → 解锁 → 恢复购买
- [ ] 详细报告 HTML 正确渲染，内容完整，样式美观
- [ ] PDF 导出功能正常：生成 A4 尺寸 PDF，内容完整，排版美观
- [ ] PDF 可正常保存到「文件」App，也可通过分享面板发送
- [ ] PDF 预览界面加载流畅，支持翻页浏览
- [ ] 分享卡片生成正常，图片清晰
- [ ] 历史记录正确保存和读取
- [ ] 深色模式适配正常

### 7.2 上架前验证
- [ ] 在真机上完成至少 3 次完整测试流程
- [ ] 沙盒账号测试内购购买和恢复
- [ ] 使用 TestFlight 分发测试
- [ ] App 启动时间 < 3 秒
- [ ] 内存占用正常（< 200MB）
- [ ] 无崩溃、无内存泄漏
- [ ] 所有字符串已本地化（中文）
- [ ] 隐私政策页面可正常访问
- [ ] App Store 元数据完整准确

### 7.3 审核合规检查
- [ ] App 描述中清楚标注付费内容
- [ ] 无 "MBTI" 商标使用
- [ ] 包含免责声明（非医疗诊断）
- [ ] 无第三方支付引导
- [ ] 隐私政策 URL 有效
- [ ] 未收集超出声明范围的数据

---

## 八、后续迭代方向（非本期范围）

1. **双人兼容性分析**：输入两人类型，生成关系匹配报告
2. **类型百科**：浏览 16 种类型详细信息
3. **每日洞察**：基于类型的每日小贴士推送
4. **社区功能**：用户分享结果、讨论（需 UGC 审核机制）
5. **Android 版本**：使用 Flutter 或 Kotlin 开发
6. **多语言支持**：英文版、日文版等
7. **AI 增强报告**：接入大模型生成个性化分析
