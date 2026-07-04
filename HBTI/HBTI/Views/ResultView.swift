import SwiftUI

struct ResultView: View {
    let result: TestResult
    @Environment(QuizViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false
    @State private var showDetailedReport = false
    @State private var showShareCard = false
    @State private var showHistory = false
    @State private var animateLetters = false
    @State private var animateBars = false
    
    var personalityType: PersonalityType? {
        result.personalityType
    }
    
    var body: some View {
        ZStack {
            if let type = personalityType {
                ColorPalette.adaptiveBackgroundGradient
                    .ignoresSafeArea()
            } else {
                ColorPalette.adaptiveBackgroundGradient
                    .ignoresSafeArea()
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // 类型展示区域
                    TypeHeroView(result: result, animateLetters: animateLetters)
                        .padding(.top, 20)
                    
                    // 维度分析
                    DimensionAnalysisView(scores: result.dimensionScores, animateBars: animateBars)
                        .padding(.horizontal)
                    
                    // 类型描述
                    if let type = personalityType {
                        TypeDescriptionCard(type: type)
                            .padding(.horizontal)
                    }
                    
                    // 优势与成长
                    if let type = personalityType {
                        StrengthWeaknessCard(type: type)
                            .padding(.horizontal)
                    }
                    
                    // 操作按钮
                    ActionButtonsView(
                        result: result,
                        showDetailedReport: $showDetailedReport,
                        showPaywall: $showPaywall,
                        showShareCard: $showShareCard
                    )
                    .padding(.horizontal)
                    
                    // 底部按钮
                    HStack(spacing: 16) {
                        Button {
                            viewModel.startQuiz(username: result.username, version: result.testVersion)
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("再测一次")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(ColorPalette.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                        
                        NavigationLink {
                            HistoryView()
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("历史记录")
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(ColorPalette.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShareCard = true
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(personalityType.map { ColorPalette.groupColor($0.group) } ?? .primary)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateLetters = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                animateBars = true
            }
        }
        .sheet(isPresented: $showShareCard) {
            ShareCardView(result: result)
        }
        .navigationDestination(isPresented: $showDetailedReport) {
            if let type = personalityType {
                ReportView(result: result, type: type)
            }
        }
        .navigationDestination(isPresented: $showPaywall) {
            PaywallView(result: result)
        }
    }
}

struct TypeHeroView: View {
    let result: TestResult
    let animateLetters: Bool
    
    var personalityType: PersonalityType? {
        result.personalityType
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 类型代码大字
            HStack(spacing: 8) {
                ForEach(Array(result.typeCode.enumerated()), id: \.offset) { index, letter in
                    Text(String(letter))
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            personalityType.map {
                                ColorPalette.groupColor($0.group)
                            } ?? Color.primary
                        )
                        .opacity(animateLetters ? 1 : 0)
                        .offset(y: animateLetters ? 0 : 30)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.1),
                            value: animateLetters
                        )
                }
            }
            
            if let type = personalityType {
                // 类型名称
                Text("— \(type.name) —")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(ColorPalette.groupColor(type.group))
                    .opacity(animateLetters ? 1 : 0)
                    .animation(.easeIn.delay(0.5), value: animateLetters)
                
                // 族群标签
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    Text(type.group.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(ColorPalette.groupColor(type.group))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(ColorPalette.groupColor(type.group).opacity(0.15))
                .cornerRadius(20)
                .opacity(animateLetters ? 1 : 0)
                .animation(.easeIn.delay(0.6), value: animateLetters)
                
                // 简短描述
                Text(type.description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
                    .opacity(animateLetters ? 1 : 0)
                    .animation(.easeIn.delay(0.7), value: animateLetters)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(ColorPalette.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 8)
        .padding(.horizontal)
    }
}

struct DimensionAnalysisView: View {
    let scores: [DimensionScore]
    let animateBars: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("四维解析")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(scores) { score in
                DimensionBarView(score: score, animate: animateBars)
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct DimensionBarView: View {
    let score: DimensionScore
    let animate: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(score.dimension.leftLabel)
                    .font(.caption)
                    .foregroundColor(score.dominantSide == .left ? ColorPalette.dimensionColor(score.dimension) : .secondary)
                    .fontWeight(score.dominantSide == .left ? .bold : .regular)
                
                Spacer()
                
                Text(score.dimension.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(score.dimension.rightLabel)
                    .font(.caption)
                    .foregroundColor(score.dominantSide == .right ? ColorPalette.dimensionColor(score.dimension) : .secondary)
                    .fontWeight(score.dominantSide == .right ? .bold : .regular)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.15))
                        .frame(height: 16)
                    
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                score.dominantSide == .left
                                ? ColorPalette.dimensionColor(score.dimension)
                                : ColorPalette.dimensionColor(score.dimension).opacity(0.4)
                            )
                            .frame(width: animate ? geometry.size.width * CGFloat(score.leftPercentage / 100) : 0, height: 16)
                            .animation(.easeInOut(duration: 1.0).delay(0.2), value: animate)
                        
                        Spacer(minLength: 0)
                    }
                    
                    // 中心标记
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 2, height: 16)
                        .position(x: geometry.size.width / 2, y: 8)
                }
            }
            .frame(height: 16)
            
            HStack {
                Text("\(Int(score.leftPercentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(Int(score.rightPercentage))%")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TypeDescriptionCard: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("核心特质")
                .font(.headline)
                .foregroundColor(.primary)
            
            FlowLayout(spacing: 8) {
                ForEach(type.keyTraits, id: \.self) { trait in
                    Text(trait)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ColorPalette.groupColor(type.group).opacity(0.12))
                        .cornerRadius(16)
                }
            }
            
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("人群占比")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(type.populationPercentage)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
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
    }
}

struct StrengthWeaknessCard: View {
    let type: PersonalityType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("优势与成长")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(alignment: .top, spacing: 12) {
                // 优势列
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                            .foregroundColor(.green)
                        Text("优势")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(type.strengths, id: \.self) { strength in
                        Text(strength)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                // 成长空间列
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("成长空间")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }
                    
                    ForEach(type.weaknesses, id: \.self) { weakness in
                        Text(weakness)
                            .font(.caption)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding()
        .background(ColorPalette.cardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

struct ActionButtonsView: View {
    let result: TestResult
    @Binding var showDetailedReport: Bool
    @Binding var showPaywall: Bool
    @Binding var showShareCard: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            if result.isDetailedReportUnlocked || PersistenceManager.shared.isProductUnlocked(result.testVersion.productID ?? "") {
                Button {
                    showDetailedReport = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("查看详细报告")
                            .fontWeight(.semibold)
                    }
                    .font(.title3)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ColorPalette.primaryGradient)
                    .cornerRadius(16)
                    .shadow(color: Color(hex: "#7B68EE").opacity(0.4), radius: 12, x: 0, y: 6)
                }
            } else {
                Button {
                    showPaywall = true
                } label: {
                    VStack(spacing: 4) {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("解锁详细报告")
                                .fontWeight(.semibold)
                        }
                        .font(.title3)
                        
                        Text("¥\(String(format: "%.1f", result.testVersion.price ?? 0)) 永久解锁")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
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
            }
            
            Button {
                showShareCard = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("分享结果")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorPalette.dimensionColor(.ei))
                .frame(maxWidth: .infinity)
                .padding()
                .background(ColorPalette.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ColorPalette.dimensionColor(.ei).opacity(0.3), lineWidth: 1)
                )
            }
        }
    }
}

// 流式布局辅助视图
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }
                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
