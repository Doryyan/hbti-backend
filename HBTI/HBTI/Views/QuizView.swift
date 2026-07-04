import SwiftUI

struct QuizView: View {
    @Environment(QuizViewModel.self) private var viewModel
    @State private var sliderValue: Double = 0.5
    @State private var showResult = false
    
    var body: some View {
        ZStack {
            ColorPalette.adaptiveBackgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航栏
                QuizHeaderView()
                
                // 进度条
                ProgressBarView()
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 题目卡片区域
                if let question = viewModel.currentQuestion {
                    QuestionCardView(question: question, sliderValue: $sliderValue)
                        .padding()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if viewModel.canGoBack {
                    Button {
                        viewModel.goBack()
                        updateSliderFromCurrentAnswer()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("上一题")
                        }
                        .foregroundColor(ColorPalette.dimensionColor(.ei))
                    }
                }
            }
        }
        .onAppear {
            updateSliderFromCurrentAnswer()
        }
        .onChange(of: viewModel.currentQuestionIndex) {
            updateSliderFromCurrentAnswer()
        }
        .onChange(of: viewModel.isQuizCompleted) { _, completed in
            if completed {
                showResult = true
            }
        }
        .navigationDestination(isPresented: $showResult) {
            if let result = viewModel.testResult {
                ResultView(result: result)
                    .environment(viewModel)
            }
        }
    }
    
    private func updateSliderFromCurrentAnswer() {
        if let answer = viewModel.getCurrentAnswer() {
            sliderValue = answer
        } else {
            sliderValue = 0.5
        }
    }
}

struct QuizHeaderView: View {
    @Environment(QuizViewModel.self) private var viewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.username)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(viewModel.selectedVersion.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("第 \(viewModel.currentQuestionIndex + 1)/\(viewModel.questions.count) 题")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(ColorPalette.dimensionColor(.ei))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(ColorPalette.dimensionColor(.ei).opacity(0.1))
                .cornerRadius(20)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct ProgressBarView: View {
    @Environment(QuizViewModel.self) private var viewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(ColorPalette.primaryGradient)
                    .frame(width: geometry.size.width * viewModel.progress, height: 8)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.progress)
            }
        }
        .frame(height: 6)
    }
}

struct QuestionCardView: View {
    let question: Question
    @Binding var sliderValue: Double
    @Environment(QuizViewModel.self) private var viewModel
    @State private var illustrationScale: CGFloat = 0.8
    @State private var illustrationOpacity: Double = 0
    
    var illustrationImage: String {
        // EI 维度插图映射
        if question.dimension == .ei {
            switch (question.direction, question.category) {
            case (.left, .leisure):      return "illust_ei_left_reading"
            case (.left, .social):       return "illust_ei_left_observe"
            case (.left, .communication): return "illust_ei_left_thinking"
            case (.left, .work):         return "illust_ei_left_deepchat"
            case (.left, .stress):       return "illust_ei_left_reading"
            case (.left, .learning):     return "illust_ei_left_thinking"
            case (.left, .decision):     return "illust_ei_left_observe"
            case (.left, .planning):     return "illust_ei_left_thinking"
            case (.right, .social):      return "illust_ei_right_party"
            case (.right, .communication): return "illust_ei_right_speak"
            case (.right, .work):        return "illust_ei_right_teamwork"
            case (.right, .leisure):     return "illust_ei_right_socialize"
            case (.right, .stress):      return "illust_ei_right_socialize"
            case (.right, .learning):    return "illust_ei_right_speak"
            case (.right, .decision):    return "illust_ei_right_teamwork"
            case (.right, .planning):    return "illust_ei_right_plan"
            default: return question.direction == .right ? "illust_ei_right_party" : "illust_ei_left_reading"
            }
        }
        
        // SN 维度插图映射
        if question.dimension == .sn {
            switch (question.direction, question.category) {
            case (.left, .work):         return "illust_sn_left_detail"
            case (.left, .decision):     return "illust_sn_left_practical"
            case (.left, .learning):     return "illust_sn_left_routine"
            case (.left, .leisure):      return "illust_sn_left_familiar"
            case (.left, .social):       return "illust_sn_left_familiar"
            case (.left, .stress):       return "illust_sn_left_detail"
            case (.left, .communication): return "illust_sn_left_detail"
            case (.left, .planning):     return "illust_sn_left_routine"
            case (.right, .leisure):     return "illust_sn_right_imagine"
            case (.right, .learning):    return "illust_sn_right_abstract"
            case (.right, .decision):    return "illust_sn_right_innovate"
            case (.right, .work):        return "illust_sn_right_patterns"
            case (.right, .social):      return "illust_sn_right_patterns"
            case (.right, .stress):      return "illust_sn_right_imagine"
            case (.right, .communication): return "illust_sn_right_abstract"
            case (.right, .planning):    return "illust_sn_right_innovate"
            default: return question.direction == .right ? "illust_sn_right_imagine" : "illust_sn_left_detail"
            }
        }
        
        // TF 维度插图映射
        if question.dimension == .tf {
            switch (question.direction, question.category) {
            case (.left, .social):       return "illust_tf_left_care"
            case (.left, .decision):     return "illust_tf_left_harmony"
            case (.left, .communication): return "illust_tf_left_tactful"
            case (.left, .leisure):      return "illust_tf_left_empathy"
            case (.left, .work):         return "illust_tf_left_empathy"
            case (.left, .stress):       return "illust_tf_left_care"
            case (.left, .learning):     return "illust_tf_left_tactful"
            case (.left, .planning):     return "illust_tf_left_harmony"
            case (.right, .decision):    return "illust_tf_right_logic"
            case (.right, .social):      return "illust_tf_right_fair"
            case (.right, .communication): return "illust_tf_right_direct"
            case (.right, .work):        return "illust_tf_right_objective"
            case (.right, .leisure):     return "illust_tf_right_objective"
            case (.right, .stress):      return "illust_tf_right_logic"
            case (.right, .learning):    return "illust_tf_right_logic"
            case (.right, .planning):    return "illust_tf_right_fair"
            default: return question.direction == .right ? "illust_tf_right_logic" : "illust_tf_left_care"
            }
        }
        
        // JP 维度插图映射
        if question.dimension == .jp {
            switch (question.direction, question.category) {
            case (.left, .leisure):      return "illust_jp_left_casual"
            case (.left, .planning):     return "illust_jp_left_flexible"
            case (.left, .decision):     return "illust_jp_left_open"
            case (.left, .work):         return "illust_jp_left_spontaneous"
            case (.left, .social):       return "illust_jp_left_open"
            case (.left, .stress):       return "illust_jp_left_flexible"
            case (.left, .learning):     return "illust_jp_left_casual"
            case (.left, .communication): return "illust_jp_left_open"
            case (.right, .planning):    return "illust_jp_right_plan"
            case (.right, .work):        return "illust_jp_right_organized"
            case (.right, .decision):    return "illust_jp_right_goal"
            case (.right, .leisure):     return "illust_jp_right_deadline"
            case (.right, .social):      return "illust_jp_right_organized"
            case (.right, .stress):      return "illust_jp_right_deadline"
            case (.right, .learning):    return "illust_jp_right_systematic"
            case (.right, .communication): return "illust_jp_right_organized"
            default: return question.direction == .right ? "illust_jp_right_plan" : "illust_jp_left_flexible"
            }
        }
        
        return "illust_ei_left_reading"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 题目情境漫画插图
            Image(illustrationImage)
                .resizable()
                .scaledToFit()
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: ColorPalette.dimensionColor(question.dimension).opacity(0.2), radius: 12, x: 0, y: 6)
                .scaleEffect(illustrationScale)
                .opacity(illustrationOpacity)
                .padding(.top, 16)
                .padding(.horizontal, 10)
            
            // 题目文字
            Text(question.text)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            // 滑动量表
            VStack(spacing: 8) {
                LikertSlider(value: $sliderValue, dimension: question.dimension)
                    .frame(height: 60)
                
                // 维度端点说明
                HStack {
                    Text("▲ \(question.dimension.leftLabel)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.dimensionColor(question.dimension))
                    
                    Spacer()
                    
                    Text("\(question.dimension.rightLabel) ▲")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.dimensionColor(question.dimension))
                }
                .padding(.horizontal, 8)
                .padding(.top, 4)
                
                // 当前选中反馈
                Text(hbti_levelLabels[LikertSlider.currentLevelIndex(sliderValue)])
                    .font(.headline)
                    .foregroundColor(ColorPalette.dimensionColor(question.dimension))
                    .transition(.scale)
                    .id(LikertSlider.currentLevelIndex(sliderValue))
            }
            .padding()
            .background(ColorPalette.cardBackground)
            .cornerRadius(16)
            .shadow(color: ColorPalette.cardShadow, radius: 12, x: 0, y: 4)
            
            // 确认按钮
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.submitAnswer(score: sliderValue)
                }
            } label: {
                HStack {
                    Text(viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "下一题" : "查看结果")
                        .fontWeight(.semibold)
                    Image(systemName: viewModel.currentQuestionIndex < viewModel.questions.count - 1 ? "arrow.right" : "sparkles")
                }
                .font(.title3)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ColorPalette.primaryGradient)
                .cornerRadius(16)
                .shadow(color: Color(hex: "#7B68EE").opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(ColorPalette.cardBackground)
        .cornerRadius(24)
        .shadow(color: ColorPalette.cardShadow, radius: 20, x: 0, y: 8)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                illustrationScale = 1.0
                illustrationOpacity = 1.0
            }
        }
        .onDisappear {
            illustrationScale = 0.8
            illustrationOpacity = 0
        }
    }
}

private let hbti_levelLabels = ["非常不符", "不太符", "一般", "比较符", "非常符"]
private let hbti_levelLabelsFull = ["非常不符合", "不太符合", "一般", "比较符合", "非常符合"]

struct LikertSlider: View {
    @Binding var value: Double
    let dimension: PersonalityDimension
    @State private var isDragging = false
    
    
    
    static func currentLevelIndex(_ value: Double) -> Int {
        return Int(round(value * 4))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let trackHeight: CGFloat = 10
            let knobSize: CGFloat = 32
            let stepWidth = width / CGFloat(hbti_levelLabels.count - 1)
            let dimColor = ColorPalette.dimensionColor(dimension)
            
            VStack(spacing: 0) {
                Spacer()
                
                // 轨道 + 滑块
                ZStack(alignment: .leading) {
                    // 轨道背景 — 毛玻璃质感
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(.ultraThinMaterial)
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(Color.gray.opacity(0.1))
                    
                    // 段落分隔线 — 5个停靠点位置
                    ForEach(0..<hbti_levelLabels.count, id: \.self) { index in
                        let x = CGFloat(index) * stepWidth
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 2, height: trackHeight - 4)
                            .position(x: x, y: trackHeight / 2)
                    }
                    
                    // 填充轨道 — 渐变 + 发光
                    RoundedRectangle(cornerRadius: trackHeight / 2)
                        .fill(
                            LinearGradient(
                                colors: [
                                    dimColor.opacity(0.15),
                                    dimColor.opacity(0.6),
                                    dimColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, CGFloat(value) * width), height: trackHeight)
                        .shadow(color: dimColor.opacity(0.3), radius: 6, x: 0, y: 0)
                    
                    // 滑块 — 玻璃拟态风格
                    ZStack {
                        // 外层发光
                        Circle()
                            .fill(dimColor.opacity(0.15))
                            .frame(width: knobSize + 16, height: knobSize + 16)
                            .blur(radius: 8)
                        
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: knobSize, height: knobSize)
                            .shadow(color: dimColor.opacity(0.3), radius: 6, x: 0, y: 2)
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [dimColor.opacity(0.6), dimColor],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 2.5
                                    )
                            )
                            .overlay(
                                Text("\(Self.currentLevelIndex(value) + 1)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(dimColor)
                            )
                    }
                    .position(x: CGFloat(value) * width, y: trackHeight / 2)
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isDragging)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { gesture in
                                isDragging = true
                                let newValue = max(0, min(1, gesture.location.x / width))
                                let previousLevel = Self.currentLevelIndex(value)
                                value = snapToStep(newValue)
                                let newLevel = Self.currentLevelIndex(value)
                                if newLevel != previousLevel {
                                    generateHaptic()
                                }
                            }
                            .onEnded { _ in
                                isDragging = false
                            }
                    )
                }
                .frame(height: trackHeight + 4)
                
                // 停靠点 — 带脉冲动画的圆点
                HStack(spacing: 0) {
                    ForEach(0..<hbti_levelLabels.count, id: \.self) { index in
                        let isSelected = index == Self.currentLevelIndex(value)
                        
                        ZStack {
                            // 脉冲光环（选中时）
                            Circle()
                                .fill(dimColor.opacity(0.12))
                                .frame(width: isSelected ? 24 : 0, height: isSelected ? 24 : 0)
                                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isSelected)
                            
                            // 外圈
                            Circle()
                                .stroke(
                                    isSelected ? dimColor : dimColor.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1
                                )
                                .frame(width: isSelected ? 16 : 12, height: isSelected ? 16 : 12)
                            
                            // 内点
                            Circle()
                                .fill(
                                    isSelected
                                    ? dimColor
                                    : dimColor.opacity(0.15)
                                )
                                .frame(width: isSelected ? 6 : 4, height: isSelected ? 6 : 4)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
                
                // 标签行 — 每个标签精确定位在停靠点正下方
                ZStack(alignment: .leading) {
                    ForEach(0..<hbti_levelLabels.count, id: \.self) { index in
                        let x = CGFloat(index) * stepWidth
                        let isSelected = index == Self.currentLevelIndex(value)
                        
                        Text(hbti_levelLabels[index])
                             .font(.system(size: 7))
                             .foregroundColor(
                                 isSelected
                                 ? dimColor
                                 : .secondary.opacity(0.35)
                             )
                             .fixedSize()
                             .position(x: x, y: 8)
                     }
                 }
                .frame(height: 18)
                .padding(.top, 4)
                
                Spacer()
            }
        }
    }
    
    private func snapToStep(_ rawValue: Double) -> Double {
        let step = 1.0 / Double(hbti_levelLabels.count - 1)
        let index = round(rawValue / step)
        return Double(index * step)
    }
    
    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}
