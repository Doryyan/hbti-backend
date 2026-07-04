import SwiftUI
import WebKit

struct ReportView: View {
    let result: TestResult
    let type: PersonalityType
    @State private var showPDFPreview = false
    @State private var pdfData: Data?
    
    var body: some View {
        ZStack {
            ColorPalette.adaptiveBackgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 报告头部
                    ReportHeaderView(result: result, type: type)
                    
                    // 各模块报告
                    DimensionDetailView(scores: result.dimensionScores)
                    CareerView(type: type)
                    RelationshipView(type: type)
                    DevelopmentView(type: type)
                    CompatibilityView(type: type)
                    
                    // PDF导出按钮
                    Button {
                        generatePDF()
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("导出PDF报告")
                                .fontWeight(.semibold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ColorPalette.groupColor(type.group))
                        .cornerRadius(16)
                        .shadow(color: ColorPalette.groupColor(type.group).opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("详细报告")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPDFPreview) {
            if let data = pdfData {
                PDFPreviewView(pdfData: data, type: type)
            }
        }
    }
    
    private func generatePDF() {
        let service = PDFExportService()
        pdfData = service.generatePDF(from: result, type: type)
        if pdfData != nil {
            showPDFPreview = true
        }
    }
}

struct ReportHeaderView: View {
    let result: TestResult
    let type: PersonalityType
    
    var body: some View {
        VStack(spacing: 16) {
            Text(result.typeCode)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(ColorPalette.groupColor(type.group))
            
            Text(type.name)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(ColorPalette.groupColor(type.group))
            
            Text(type.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                VStack {
                    Text("人群占比")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(type.populationPercentage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack {
                    Text("族群")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(type.group.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                }
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct DimensionDetailView: View {
    let scores: [DimensionScore]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("四维深度解析")
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(scores) { score in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("\(score.dimension.description) · \(score.dominantLabel)")
                            .font(.headline)
                            .foregroundColor(ColorPalette.dimensionColor(score.dimension))
                        
                        Spacer()
                        
                        Text("\(Int(score.dominantSide == .left ? score.leftPercentage : score.rightPercentage))%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.dimensionColor(score.dimension))
                    }
                    
                    Text(dimensionDetailText(for: score))
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(ColorPalette.dimensionColor(score.dimension).opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func dimensionDetailText(for score: DimensionScore) -> String {
        switch score.dimension {
        case .ei:
            return score.dominantSide == .right
                ? "你倾向于从外部世界获取能量。社交互动让你感到充实和兴奋，你喜欢与人交流、分享想法，在人群中能找到归属感和活力。"
                : "你倾向于从内心世界获取能量。独处让你感到平静和充电，你喜欢深度思考、自我反省，在安静的环境中能找到内心的平衡。"
        case .sn:
            return score.dominantSide == .right
                ? "你倾向于关注整体模式和未来可能性。你对抽象概念和理论充满兴趣，善于发现事物之间的潜在联系，喜欢探索未知的领域。"
                : "你倾向于关注具体细节和实际经验。你对事实和数据敏感，重视实际可行的解决方案，喜欢处理看得见摸得着的具体问题。"
        case .tf:
            return score.dominantSide == .right
                ? "你倾向于用逻辑和客观分析做决策。你重视公平和效率，善于理性分析问题，在处理事情时优先考虑客观标准和逻辑一致性。"
                : "你倾向于用价值观和情感做决策。你重视人际和谐，善于理解他人感受，在处理事情时会考虑对他人的影响和情感因素。"
        case .jp:
            return score.dominantSide == .right
                ? "你倾向于有组织、有计划的生活方式。你喜欢提前规划、设定目标，重视结构和秩序，在明确的方向中感到安心和高效。"
                : "你倾向于灵活、开放的生活方式。你喜欢保持选择的开放性，重视适应能力，在自由灵活的环境中感到舒适和自在。"
        }
    }
}

struct CareerView: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("职业推荐")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("基于你的性格类型，以下是最适合你的职业方向：")
                .font(.body)
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: 8) {
                ForEach(type.careerPaths, id: \.self) { career in
                    Text(career)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ColorPalette.groupColor(type.group).opacity(0.12))
                        .cornerRadius(16)
                }
            }
            
            Text("工作风格")
                .font(.headline)
                .padding(.top, 8)
            
            Text("你在团队中通常扮演\(type.group == .analyst ? "战略分析" : type.group == .diplomat ? "协调引领" : type.group == .sentinel ? "执行维护" : "灵活应变")的角色。你\(type.strengths.first?.lowercased() ?? "")的工作方式使你能够在\(type.careerPaths.first ?? "相关领域")中发挥优势。")
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct RelationshipView: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("人际关系")
                .font(.title3)
                .fontWeight(.bold)
            
            Text(type.relationshipStyle)
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Text("沟通风格")
                .font(.headline)
                .padding(.top, 8)
            
            Text("你倾向于\(type.group == .analyst || type.group == .sentinel ? "直接、明确地表达观点" : "温和、体贴地与人交流")。在冲突中，你更倾向于\(type.group == .diplomat || type.group == .sentinel ? "寻求和谐与妥协" : "坚持原则和逻辑")。")
                .font(.body)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct DevelopmentView: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("发展建议")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("压力触发因素")
                .font(.headline)
            
            FlowLayout(spacing: 8) {
                ForEach(type.stressTriggers, id: \.self) { trigger in
                    Text(trigger)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.12))
                        .cornerRadius(12)
                }
            }
            
            Text("成长建议")
                .font(.headline)
                .padding(.top, 8)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(type.growthAdvice.enumerated()), id: \.offset) { index, advice in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(ColorPalette.groupColor(type.group))
                            .clipShape(Circle())
                        
                        Text(advice)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct CompatibilityView: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("类型兼容性")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("高兼容类型")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(type.compatibleTypes, id: \.self) { code in
                    if let compatibleType = PersonalityType.allTypes.first(where: { $0.id == code }) {
                        VStack(spacing: 4) {
                            Text(code)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.groupColor(compatibleType.group))
                            Text(compatibleType.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(ColorPalette.groupColor(compatibleType.group).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
            
            Text("需要注意的类型")
                .font(.headline)
                .padding(.top, 8)
            
            HStack(spacing: 8) {
                ForEach(type.challengingTypes, id: \.self) { code in
                    if let challengingType = PersonalityType.allTypes.first(where: { $0.id == code }) {
                        VStack(spacing: 4) {
                            Text(code)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(ColorPalette.groupColor(challengingType.group))
                            Text(challengingType.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(ColorPalette.groupColor(challengingType.group).opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
        .padding(.horizontal)
    }
}