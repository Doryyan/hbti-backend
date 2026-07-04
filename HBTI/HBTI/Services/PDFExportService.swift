import UIKit
import PDFKit

class PDFExportService {
    
    func generatePDF(from result: TestResult, type: PersonalityType) -> Data {
        let pageWidth: CGFloat = 595.2
        let pageHeight: CGFloat = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        
        let data = renderer.pdfData { context in
            // 封面
            drawCoverPage(context: context, pageRect: pageRect, result: result, type: type)
            
            // 第2页：四维解析
            context.beginPage()
            drawDimensionPage(context: context, pageRect: pageRect, result: result, type: type)
            
            // 第3页：类型总览
            context.beginPage()
            drawTypeOverviewPage(context: context, pageRect: pageRect, type: type)
            
            // 第4页：职业推荐
            context.beginPage()
            drawCareerPage(context: context, pageRect: pageRect, type: type)
            
            // 第5页：人际关系
            context.beginPage()
            drawRelationshipPage(context: context, pageRect: pageRect, type: type)
            
            // 第6页：发展建议
            context.beginPage()
            drawDevelopmentPage(context: context, pageRect: pageRect, type: type)
            
            // 第7页：类型兼容性
            context.beginPage()
            drawCompatibilityPage(context: context, pageRect: pageRect, type: type)
            
            // 封底
            context.beginPage()
            drawBackCover(context: context, pageRect: pageRect, type: type)
        }
        
        return data
    }
    
    private func drawCoverPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, result: TestResult, type: PersonalityType) {
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        // 背景渐变
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: [groupColor.withAlphaComponent(0.15).cgColor,
                                          UIColor.white.cgColor] as CFArray,
                                  locations: [0.0, 1.0])!
        context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: pageRect.height), options: [])
        
        // 标题
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: groupColor
        ]
        let title = "HBTI 人格测试报告"
        title.draw(at: CGPoint(x: 60, y: 80), withAttributes: titleAttributes)
        
        // 类型代码
        let codeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 72, weight: .bold),
            .foregroundColor: groupColor
        ]
        let code = result.typeCode
        let codeSize = code.size(withAttributes: codeAttributes)
        code.draw(at: CGPoint(x: (pageRect.width - codeSize.width) / 2, y: 200), withAttributes: codeAttributes)
        
        // 类型名称
        let nameAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .medium),
            .foregroundColor: groupColor
        ]
        let name = "— \(type.name) —"
        let nameSize = name.size(withAttributes: nameAttributes)
        name.draw(at: CGPoint(x: (pageRect.width - nameSize.width) / 2, y: 300), withAttributes: nameAttributes)
        
        // 描述
        let descAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        let desc = type.description
        let descRect = CGRect(x: 80, y: 360, width: pageRect.width - 160, height: 60)
        desc.draw(in: descRect, withAttributes: descAttributes)
        
        // 用户信息
        let infoAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let info = "测试者：\(result.username)    日期：\(formatDate(result.timestamp))"
        info.draw(at: CGPoint(x: 60, y: pageRect.height - 120), withAttributes: infoAttributes)
        
        // 底部品牌
        let brandAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: groupColor
        ]
        let brand = "HBTI 16型人格测试"
        let brandSize = brand.size(withAttributes: brandAttributes)
        brand.draw(at: CGPoint(x: (pageRect.width - brandSize.width) / 2, y: pageRect.height - 80), withAttributes: brandAttributes)
    }
    
    private func drawDimensionPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, result: TestResult, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "四维深度解析", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        for score in result.dimensionScores {
            let dimColor = UIColor(ColorPalette.dimensionColor(score.dimension))
            
            // 维度标题
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: dimColor
            ]
            let title = "\(score.dimension.description) · \(score.dominantLabel) (\(Int(score.dominantSide == .left ? score.leftPercentage : score.rightPercentage))%)"
            title.draw(at: CGPoint(x: 60, y: yOffset), withAttributes: titleAttributes)
            
            yOffset += 25
            
            // 进度条背景
            let barRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 12)
            let barPath = UIBezierPath(roundedRect: barRect, cornerRadius: 6)
            UIColor.lightGray.withAlphaComponent(0.3).setFill()
            barPath.fill()
            
            // 进度条填充
            let fillWidth = barRect.width * CGFloat(score.dominantSide == .left ? score.leftPercentage : score.rightPercentage) / 100
            let fillRect = CGRect(x: 60, y: yOffset, width: fillWidth, height: 12)
            let fillPath = UIBezierPath(roundedRect: fillRect, cornerRadius: 6)
            dimColor.setFill()
            fillPath.fill()
            
            yOffset += 25
            
            // 描述文字
            let descAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            let desc = dimensionDescription(for: score)
            let descRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 50)
            desc.draw(in: descRect, withAttributes: descAttributes)
            
            yOffset += 60
        }
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 2, type: type)
    }
    
    private func drawTypeOverviewPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "类型总览", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        // 核心特质
        let traitsTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: groupColor
        ]
        "核心特质".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: traitsTitleAttributes)
        yOffset += 30
        
        let traitAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let traits = type.keyTraits.joined(separator: " · ")
        let traitsRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 30)
        traits.draw(in: traitsRect, withAttributes: traitAttributes)
        yOffset += 40
        
        // 优势
        let strengthTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.systemGreen
        ]
        "优势".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: strengthTitleAttributes)
        yOffset += 30
        
        for (index, strength) in type.strengths.enumerated() {
            let text = "\(index + 1). \(strength)"
            let strengthAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            text.draw(at: CGPoint(x: 60, y: yOffset), withAttributes: strengthAttributes)
            yOffset += 20
        }
        
        yOffset += 20
        
        // 盲点
        let weaknessTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.systemOrange
        ]
        "盲点".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: weaknessTitleAttributes)
        yOffset += 30
        
        for (index, weakness) in type.weaknesses.enumerated() {
            let text = "\(index + 1). \(weakness)"
            let weaknessAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            text.draw(at: CGPoint(x: 60, y: yOffset), withAttributes: weaknessAttributes)
            yOffset += 20
        }
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 3, type: type)
    }
    
    private func drawCareerPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "职业推荐", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let descAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        let desc = "基于你的性格类型，以下是最适合你的职业方向："
        desc.draw(at: CGPoint(x: 60, y: yOffset), withAttributes: descAttributes)
        yOffset += 30
        
        for career in type.careerPaths {
            let rect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 30)
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
            groupColor.withAlphaComponent(0.1).setFill()
            path.fill()
            
            let careerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: groupColor
            ]
            career.draw(at: CGPoint(x: 75, y: yOffset + 7), withAttributes: careerAttributes)
            
            yOffset += 38
        }
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 4, type: type)
    }
    
    private func drawRelationshipPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "人际关系", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        
        let relationshipText = type.relationshipStyle
        let relationshipRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 100)
        relationshipText.draw(in: relationshipRect, withAttributes: textAttributes)
        yOffset += 120
        
        let commTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: groupColor
        ]
        "沟通风格".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: commTitleAttributes)
        yOffset += 30
        
        let commStyle = type.group == .analyst || type.group == .sentinel ? "直接、明确地表达观点" : "温和、体贴地与人交流"
        let conflictStyle = type.group == .diplomat || type.group == .sentinel ? "寻求和谐与妥协" : "坚持原则和逻辑"
        let commText = "你倾向于\(commStyle)。在冲突中，你更倾向于\(conflictStyle)。"
        let commRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 60)
        commText.draw(in: commRect, withAttributes: textAttributes)
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 5, type: type)
    }
    
    private func drawDevelopmentPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "发展建议", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let stressTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.systemOrange
        ]
        "压力触发因素".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: stressTitleAttributes)
        yOffset += 30
        
        let stressAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.darkGray
        ]
        let stressText = type.stressTriggers.joined(separator: " · ")
        let stressRect = CGRect(x: 60, y: yOffset, width: pageRect.width - 120, height: 40)
        stressText.draw(in: stressRect, withAttributes: stressAttributes)
        yOffset += 50
        
        let growthTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: groupColor
        ]
        "成长建议".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: growthTitleAttributes)
        yOffset += 30
        
        for (index, advice) in type.growthAdvice.enumerated() {
            let circleRect = CGRect(x: 60, y: yOffset, width: 20, height: 20)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            groupColor.setFill()
            circlePath.fill()
            
            let numAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            "\(index + 1)".draw(at: CGPoint(x: 66, y: yOffset + 3), withAttributes: numAttributes)
            
            let adviceAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11),
                .foregroundColor: UIColor.darkGray
            ]
            let adviceRect = CGRect(x: 88, y: yOffset, width: pageRect.width - 148, height: 40)
            advice.draw(in: adviceRect, withAttributes: adviceAttributes)
            
            yOffset += 45
        }
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 6, type: type)
    }
    
    private func drawCompatibilityPage(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        drawPageHeader(context: context, pageRect: pageRect, title: "类型兼容性", type: type)
        
        var yOffset: CGFloat = 100
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let compatibleTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.systemGreen
        ]
        "高兼容类型".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: compatibleTitleAttributes)
        yOffset += 35
        
        for code in type.compatibleTypes {
            if let compatibleType = PersonalityType.allTypes.first(where: { $0.id == code }) {
                let compatColor = UIColor(ColorPalette.groupColor(compatibleType.group))
                let rect = CGRect(x: 60, y: yOffset, width: 120, height: 50)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                compatColor.withAlphaComponent(0.15).setFill()
                path.fill()
                
                let codeAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: compatColor
                ]
                code.draw(at: CGPoint(x: 75, y: yOffset + 8), withAttributes: codeAttributes)
                
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
                compatibleType.name.draw(at: CGPoint(x: 75, y: yOffset + 26), withAttributes: nameAttributes)
                
                yOffset += 60
            }
        }
        
        yOffset += 20
        
        let challengingTitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .bold),
            .foregroundColor: UIColor.systemOrange
        ]
        "需要注意的类型".draw(at: CGPoint(x: 60, y: yOffset), withAttributes: challengingTitleAttributes)
        yOffset += 35
        
        for code in type.challengingTypes {
            if let challengingType = PersonalityType.allTypes.first(where: { $0.id == code }) {
                let challengeColor = UIColor(ColorPalette.groupColor(challengingType.group))
                let rect = CGRect(x: 60, y: yOffset, width: 120, height: 50)
                let path = UIBezierPath(roundedRect: rect, cornerRadius: 8)
                challengeColor.withAlphaComponent(0.15).setFill()
                path.fill()
                
                let codeAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14, weight: .bold),
                    .foregroundColor: challengeColor
                ]
                code.draw(at: CGPoint(x: 75, y: yOffset + 8), withAttributes: codeAttributes)
                
                let nameAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 10),
                    .foregroundColor: UIColor.darkGray
                ]
                challengingType.name.draw(at: CGPoint(x: 75, y: yOffset + 26), withAttributes: nameAttributes)
                
                yOffset += 60
            }
        }
        
        drawPageFooter(context: context, pageRect: pageRect, pageNum: 7, type: type)
    }
    
    private func drawBackCover(context: UIGraphicsPDFRendererContext, pageRect: CGRect, type: PersonalityType) {
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                  colors: [groupColor.withAlphaComponent(0.1).cgColor,
                                          UIColor.white.cgColor] as CFArray,
                                  locations: [0.0, 1.0])!
        context.cgContext.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: pageRect.height), options: [])
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: groupColor
        ]
        let title = "HBTI 16型人格测试"
        let titleSize = title.size(withAttributes: titleAttributes)
        title.draw(at: CGPoint(x: (pageRect.width - titleSize.width) / 2, y: pageRect.height / 2 - 50), withAttributes: titleAttributes)
        
        let descAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let desc = "探索你的性格类型，发现真实的自己"
        let descSize = desc.size(withAttributes: descAttributes)
        desc.draw(at: CGPoint(x: (pageRect.width - descSize.width) / 2, y: pageRect.height / 2), withAttributes: descAttributes)
        
        let disclaimerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.lightGray
        ]
        let disclaimer = "本测试基于荣格心理类型理论设计，仅供娱乐和自我探索参考，不构成专业心理诊断。"
        let disclaimerRect = CGRect(x: 60, y: pageRect.height - 100, width: pageRect.width - 120, height: 40)
        disclaimer.draw(in: disclaimerRect, withAttributes: disclaimerAttributes)
        
        let contactAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        let contact = "联系我们：support@hcjworld.com"
        let contactSize = contact.size(withAttributes: contactAttributes)
        contact.draw(at: CGPoint(x: (pageRect.width - contactSize.width) / 2, y: pageRect.height - 50), withAttributes: contactAttributes)
    }
    
    private func drawPageHeader(context: UIGraphicsPDFRendererContext, pageRect: CGRect, title: String, type: PersonalityType) {
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let lineRect = CGRect(x: 60, y: 50, width: pageRect.width - 120, height: 1)
        let linePath = UIBezierPath(rect: lineRect)
        groupColor.withAlphaComponent(0.3).setFill()
        linePath.fill()
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: groupColor
        ]
        title.draw(at: CGPoint(x: 60, y: 60), withAttributes: titleAttributes)
        
        let typeAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.gray
        ]
        let typeText = type.id
        typeText.draw(at: CGPoint(x: pageRect.width - 100, y: 65), withAttributes: typeAttributes)
    }
    
    private func drawPageFooter(context: UIGraphicsPDFRendererContext, pageRect: CGRect, pageNum: Int, type: PersonalityType) {
        let groupColor = UIColor(ColorPalette.groupColor(type.group))
        
        let lineRect = CGRect(x: 60, y: pageRect.height - 50, width: pageRect.width - 120, height: 1)
        let linePath = UIBezierPath(rect: lineRect)
        groupColor.withAlphaComponent(0.2).setFill()
        linePath.fill()
        
        let pageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.gray
        ]
        let pageText = "\(pageNum)"
        let pageSize = pageText.size(withAttributes: pageAttributes)
        pageText.draw(at: CGPoint(x: (pageRect.width - pageSize.width) / 2, y: pageRect.height - 35), withAttributes: pageAttributes)
        
        let brandAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9),
            .foregroundColor: UIColor.lightGray
        ]
        "HBTI".draw(at: CGPoint(x: 60, y: pageRect.height - 35), withAttributes: brandAttributes)
    }
    
    private func dimensionDescription(for score: DimensionScore) -> String {
        switch score.dimension {
        case .ei:
            return score.dominantSide == .right
                ? "你倾向于从外部世界获取能量。社交互动让你感到充实和兴奋。"
                : "你倾向于从内心世界获取能量。独处让你感到平静和充电。"
        case .sn:
            return score.dominantSide == .right
                ? "你倾向于关注整体模式和未来可能性。"
                : "你倾向于关注具体细节和实际经验。"
        case .tf:
            return score.dominantSide == .right
                ? "你倾向于用逻辑和客观分析做决策。"
                : "你倾向于用价值观和情感做决策。"
        case .jp:
            return score.dominantSide == .right
                ? "你倾向于有组织、有计划的生活方式。"
                : "你倾向于灵活、开放的生活方式。"
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        return formatter.string(from: date)
    }
}
