import Foundation

enum TypeGroup: String, Codable, CaseIterable {
    case analyst = "分析家"
    case diplomat = "外交家"
    case sentinel = "守护者"
    case explorer = "探险家"
    
    var colorHex: String {
        switch self {
        case .analyst: return "#7B68EE"
        case .diplomat: return "#3CB371"
        case .sentinel: return "#4169E1"
        case .explorer: return "#DAA520"
        }
    }
    
    var secondaryColorHex: String {
        switch self {
        case .analyst: return "#E6E0FA"
        case .diplomat: return "#E0F5E9"
        case .sentinel: return "#E0E8FA"
        case .explorer: return "#FFF8DC"
        }
    }
    
    var description: String {
        switch self {
        case .analyst: return "理性与策略的思考者"
        case .diplomat: return "理想与共情的引领者"
        case .sentinel: return "秩序与责任的维护者"
        case .explorer: return "灵活与务实的行动者"
        }
    }
}

struct PersonalityType: Identifiable, Codable {
    let id: String
    let name: String
    let group: TypeGroup
    let description: String
    let strengths: [String]
    let weaknesses: [String]
    let populationPercentage: String
    let keyTraits: [String]
    let careerPaths: [String]
    let relationshipStyle: String
    let stressTriggers: [String]
    let growthAdvice: [String]
    let compatibleTypes: [String]
    let challengingTypes: [String]
}

extension PersonalityType {
    static let allTypes: [PersonalityType] = [
        // 分析家 (Analysts) - NT
        PersonalityType(
            id: "INTJ",
            name: "建筑师",
            group: .analyst,
            description: "富有想象力和战略思维的思想家，一切皆在计划之中。",
            strengths: ["独立自主", "富有远见", "意志坚定", "好奇心强", "能力出众"],
            weaknesses: ["过于完美主义", "可能显得傲慢", "对情感不敏感", "不耐烦", "社交困难"],
            populationPercentage: "2.1%",
            keyTraits: ["战略性", "独立", "理性", "目标导向", "高标准"],
            careerPaths: ["战略顾问", "软件架构师", "投资分析师", "科研工作者", "项目经理", "法官", "系统分析师"],
            relationshipStyle: "追求深度而有意义的连接，重视智识交流，对伴侣忠诚度极高但表达含蓄",
            stressTriggers: ["缺乏效率的环境", "情绪化的冲突", "计划被打乱", "被质疑能力", "社交过度"],
            growthAdvice: [
                "练习表达情感和赞赏",
                "接受不完美的解决方案",
                "倾听他人的情感需求",
                "在决策中考虑团队感受"
            ],
            compatibleTypes: ["ENTP", "ENFP", "INTP", "INFJ"],
            challengingTypes: ["ESFP", "ISFP", "ESTP"]
        ),
        PersonalityType(
            id: "INTP",
            name: "逻辑学家",
            group: .analyst,
            description: "具有创造力的发明家，对知识有着止不住的渴望。",
            strengths: ["分析能力强", "客观公正", "富有创造力", "思想开放", "求知欲旺盛"],
            weaknesses: ["社交疏离", "过度怀疑", "缺乏执行力", "容易分心", "情感迟钝"],
            populationPercentage: "3.3%",
            keyTraits: ["逻辑性", "好奇", "独立", "抽象思维", "灵活"],
            careerPaths: ["软件工程师", "数据科学家", "研究员", "哲学家", "系统设计师", "技术作家"],
            relationshipStyle: "重视智力刺激，需要大量个人空间，对伴侣忠诚但表达方式独特",
            stressTriggers: ["例行公事", "情感压力", "社交期望", "被限制自由", "无聊的任务"],
            growthAdvice: [
                "设定实际可行的目标",
                "学习情感表达技巧",
                "建立稳定的日常习惯",
                "接受社交的必要性"
            ],
            compatibleTypes: ["ENTJ", "ENFP", "INTJ", "INFJ"],
            challengingTypes: ["ESFJ", "ISFJ", "ESTJ"]
        ),
        PersonalityType(
            id: "ENTJ",
            name: "指挥官",
            group: .analyst,
            description: "大胆、富有想象力且意志强大的领导者，总能找到或创造解决方法。",
            strengths: ["领导力强", "高效果断", "战略思维", "自信坚定", "目标导向"],
            weaknesses: ["过于强势", "缺乏耐心", "情感迟钝", "工作狂倾向", "不容异议"],
            populationPercentage: "1.8%",
            keyTraits: ["领导力", "果断", "雄心勃勃", "效率", "战略眼光"],
            careerPaths: ["企业高管", "创业家", "管理顾问", "律师", "投资银行家", "政治领袖"],
            relationshipStyle: "追求有挑战性的伴侣，重视共同成长，但可能忽视情感细节",
            stressTriggers: ["效率低下", "失去控制", "情感冲突", "无能的团队成员", "目标受阻"],
            growthAdvice: [
                "倾听他人的感受和观点",
                "给予团队更多自主空间",
                "平衡工作与生活",
                "练习情感共鸣"
            ],
            compatibleTypes: ["INTP", "INFJ", "ENFP", "INTJ"],
            challengingTypes: ["ISFP", "INFP", "ISFJ"]
        ),
        PersonalityType(
            id: "ENTP",
            name: "辩论家",
            group: .analyst,
            description: "聪明好奇的思想者，无法抵挡智力挑战的诱惑。",
            strengths: ["思维敏捷", "创意无限", "口才出众", "适应力强", "知识渊博"],
            weaknesses: ["容易厌倦", "好辩", "执行力弱", "可能伤人", "缺乏专注"],
            populationPercentage: "3.2%",
            keyTraits: ["机智", "创新", "自信", "辩论", "灵活"],
            careerPaths: ["创业者", "律师", "创意总监", "产品经理", "记者", "公关专家"],
            relationshipStyle: "追求刺激和智力碰撞，需要自由空间，对沉闷关系难以忍受",
            stressTriggers: ["单调重复", "被限制", "例行公事", "情感纠缠", "缺乏挑战"],
            growthAdvice: [
                "学会坚持到底",
                "注意言辞对他人的影响",
                "培养情感深度",
                "建立长期承诺"
            ],
            compatibleTypes: ["INTJ", "INFJ", "ENFP", "INTP"],
            challengingTypes: ["ISFJ", "ESFJ", "ISTJ"]
        ),
        
        // 外交家 (Diplomats) - NF
        PersonalityType(
            id: "INFJ",
            name: "提倡者",
            group: .diplomat,
            description: "安静而神秘，同时鼓舞人心且不知疲倦的理想主义者。",
            strengths: ["洞察力强", "富有同情心", "有创造力", "决断力", "理想主义"],
            weaknesses: ["过于敏感", "容易 burnout", "难以表达", "完美主义", "社交疲惫"],
            populationPercentage: "1.5%",
            keyTraits: ["理想主义", "直觉", "共情", "坚定", "深度"],
            careerPaths: ["心理咨询师", "作家", "教师", "社会工作者", "人力资源", "非营利组织管理者"],
            relationshipStyle: "追求灵魂深处的连接，极其忠诚，对伴侣有很高的道德期望",
            stressTriggers: ["价值观冲突", "被误解", "过度社交", "不和谐的环境", "缺乏意义"],
            growthAdvice: [
                "设立情感边界",
                "接受他人的不完美",
                "学会说\"不\"",
                "关注当下而非完美"
            ],
            compatibleTypes: ["ENFP", "ENTP", "INTJ", "INFP"],
            challengingTypes: ["ESTP", "ESTJ", "ISTP"]
        ),
        PersonalityType(
            id: "INFP",
            name: "调停者",
            group: .diplomat,
            description: "诗意、善良的利他主义者，总是热情地为正义事业服务。",
            strengths: ["富有同理心", "创造力强", "思想开放", "忠诚", "理想主义"],
            weaknesses: ["过于理想化", "自我批评", "难以决策", "社交回避", "情感脆弱"],
            populationPercentage: "4.4%",
            keyTraits: ["理想主义", "共情", "创造力", "敏感", "内省"],
            careerPaths: ["作家", "艺术家", "心理咨询师", "教师", "编辑", "社会工作者", "音乐家"],
            relationshipStyle: "寻找灵魂伴侣式的连接，极其忠诚，重视真实性和价值观契合",
            stressTriggers: ["价值观被侵犯", "批评", "冲突", "被迫社交", "缺乏创作空间"],
            growthAdvice: [
                "接受现实的不完美",
                "建立更实际的期望",
                "练习表达需求",
                "培养行动力"
            ],
            compatibleTypes: ["ENFJ", "ENTJ", "INFJ", "ENFP"],
            challengingTypes: ["ESTJ", "ESTP", "ISTJ"]
        ),
        PersonalityType(
            id: "ENFJ",
            name: "主人公",
            group: .diplomat,
            description: "富有魅力、鼓舞人心的领导者，有能力使听众为之着迷。",
            strengths: ["领导力强", "同理心", "沟通力", "组织力", "鼓舞人心"],
            weaknesses: ["过度付出", "对批评敏感", "寻求认可", "理想化他人", "忽视自我"],
            populationPercentage: "2.5%",
            keyTraits: ["领导力", "共情", "魅力", "理想主义", "责任"],
            careerPaths: ["教师", "培训师", "人力资源", "咨询顾问", "公关经理", "非营利组织领导"],
            relationshipStyle: "热情而投入的伴侣，重视情感交流，但需要被欣赏和认可",
            stressTriggers: ["人际关系冲突", "被忽视", "辜负他人期望", "孤独", "缺乏目标"],
            growthAdvice: [
                "学会照顾自己的需求",
                "接受不是所有人都会喜欢你",
                "设立健康的边界",
                "避免过度理想化"
            ],
            compatibleTypes: ["INFP", "ISFP", "INFJ", "ENFP"],
            challengingTypes: ["ISTP", "ESTP", "ISTJ"]
        ),
        PersonalityType(
            id: "ENFP",
            name: "竞选者",
            group: .diplomat,
            description: "热情、有创造力、爱社交的自由精神，总能找到微笑的理由。",
            strengths: ["热情洋溢", "创意无限", "社交能力强", "乐观向上", "适应力强"],
            weaknesses: ["容易分心", "执行力弱", "过度承诺", "情绪波动", "难以专注"],
            populationPercentage: "8.1%",
            keyTraits: ["热情", "创造力", "社交", "乐观", "自由"],
            careerPaths: ["创意总监", "记者", "演员", "咨询顾问", "教师", "市场营销", "活动策划"],
            relationshipStyle: "充满热情和创意的伴侣，需要新鲜感和成长空间，害怕被束缚",
            stressTriggers: ["被限制自由", "单调乏味", "缺乏认可", "细节工作", "孤独"],
            growthAdvice: [
                "学会专注和坚持",
                "管理时间和承诺",
                "接受常规的必要性",
                "培养情感深度"
            ],
            compatibleTypes: ["INFJ", "INTJ", "ENFJ", "INFP"],
            challengingTypes: ["ISTJ", "ESTJ", "ISFJ"]
        ),
        
        // 守护者 (Sentinels) - SJ
        PersonalityType(
            id: "ISTJ",
            name: "物流师",
            group: .sentinel,
            description: "实际且注重事实的个人，其可靠性是不容置疑的。",
            strengths: ["诚实可靠", "责任心强", "组织力强", "务实", "忠诚"],
            weaknesses: ["过于固执", "情感迟钝", "不善变通", "对自己太苛刻", "社交保守"],
            populationPercentage: "11.6%",
            keyTraits: ["可靠", "务实", "有条理", "传统", "责任"],
            careerPaths: ["会计师", "审计师", "律师", "项目经理", "军官", "管理员", "工程师"],
            relationshipStyle: "忠诚稳定的伴侣，重视承诺和传统，表达方式务实而非浪漫",
            stressTriggers: ["规则被打破", "混乱无序", "情感冲突", "不确定性", "被质疑可靠性"],
            growthAdvice: [
                "学会灵活变通",
                "表达情感需求",
                "接受变化的存在",
                "放松对自己和他人的要求"
            ],
            compatibleTypes: ["ESFJ", "ESTJ", "ISFJ", "ESTP"],
            challengingTypes: ["ENFP", "INFP", "ENTP"]
        ),
        PersonalityType(
            id: "ISFJ",
            name: "守卫者",
            group: .sentinel,
            description: "非常专注而温暖的守护者，时刻准备着保护所爱之人。",
            strengths: ["富有同情心", "耐心", "可靠", "观察入微", "奉献"],
            weaknesses: ["过于谦虚", "回避冲突", "容易 overload", "对变化抗拒", "自我牺牲"],
            populationPercentage: "13.8%",
            keyTraits: ["温暖", "可靠", "细致", "奉献", "传统"],
            careerPaths: ["护士", "教师", "社工", "行政助理", "图书管理员", "客户服务", "人力资源"],
            relationshipStyle: "温暖体贴的伴侣，默默付出，需要被感激和认可",
            stressTriggers: ["被利用", "冲突", "变化", "批评", "忽视付出"],
            growthAdvice: [
                "学会表达自己的需求",
                "设立边界",
                "接受帮助",
                "不要过度自我牺牲"
            ],
            compatibleTypes: ["ESFJ", "ESTJ", "ISTJ", "ISFP"],
            challengingTypes: ["ENTP", "ENFP", "ENTJ"]
        ),
        PersonalityType(
            id: "ESTJ",
            name: "总经理",
            group: .sentinel,
            description: "出色的管理者，在管理事务或人员方面无与伦比。",
            strengths: ["组织力强", "果断", "忠诚", "直率", "高效"],
            weaknesses: ["过于固执", "不擅倾听", "情感迟钝", "缺乏耐心", "控制欲强"],
            populationPercentage: "8.7%",
            keyTraits: ["领导力", "务实", "组织", "传统", "效率"],
            careerPaths: ["管理者", "军官", "法官", "项目经理", "财务总监", "行政主管", "警官"],
            relationshipStyle: "可靠负责的伴侣，重视传统和家庭，表达方式直接",
            stressTriggers: ["效率低下", "不遵守规则", "情感化", "失控", "被质疑权威"],
            growthAdvice: [
                "倾听他人的感受",
                "接受不同的方法",
                "表达欣赏和情感",
                "给予他人自主空间"
            ],
            compatibleTypes: ["ISFJ", "ISTJ", "ESFJ", "ESTP"],
            challengingTypes: ["INFP", "INTP", "INFJ"]
        ),
        PersonalityType(
            id: "ESFJ",
            name: "执政官",
            group: .sentinel,
            description: "极有同情心、爱社交、受欢迎的人，总是热心提供帮助。",
            strengths: ["热心助人", "社交能力强", "忠诚", "有组织", "务实"],
            weaknesses: ["过于在意他人看法", "难以拒绝", "对批评敏感", "回避冲突", "控制欲"],
            populationPercentage: "12.3%",
            keyTraits: ["温暖", "社交", "责任", "传统", "合作"],
            careerPaths: ["教师", "护士", "人力资源", "活动策划", "销售", "社工", "客户服务"],
            relationshipStyle: "关爱备至的伴侣，重视家庭和社交，需要被需要和认可",
            stressTriggers: ["被排斥", "冲突", "不被认可", "家庭问题", "社交尴尬"],
            growthAdvice: [
                "学会说\"不\"",
                "不要过度在意他人看法",
                "接受冲突的存在",
                "关注自己的需求"
            ],
            compatibleTypes: ["ISFJ", "ISTJ", "ESFP", "ESTJ"],
            challengingTypes: ["INTP", "INTJ", "INFP"]
        ),
        
        // 探险家 (Explorers) - SP
        PersonalityType(
            id: "ISTP",
            name: "鉴赏家",
            group: .explorer,
            description: "大胆而实际的实验家，擅长使用各种工具。",
            strengths: ["动手能力强", "冷静理性", "适应力强", "务实", "独立"],
            weaknesses: ["情感疏离", "容易厌倦", "风险倾向", "不善承诺", "孤独"],
            populationPercentage: "5.4%",
            keyTraits: ["务实", "灵活", "独立", "冷静", "好奇"],
            careerPaths: ["工程师", "飞行员", "消防员", "运动员", "法医", "技术专家", "外科医生"],
            relationshipStyle: "独立自由的伴侣，需要空间，表达方式低调但忠诚",
            stressTriggers: ["被束缚", "情感压力", "例行公事", "社交期望", "长期承诺"],
            growthAdvice: [
                "培养情感表达",
                "建立长期承诺",
                "考虑他人感受",
                "避免不必要的风险"
            ],
            compatibleTypes: ["ESFJ", "ESTJ", "ISFJ", "ESTP"],
            challengingTypes: ["ENFJ", "INFJ", "ENFP"]
        ),
        PersonalityType(
            id: "ISFP",
            name: "探险家",
            group: .explorer,
            description: "灵活而有魅力的艺术家，时刻准备着探索和体验新鲜事物。",
            strengths: ["艺术感知", "温和友善", "适应力强", "观察入微", "忠诚"],
            weaknesses: ["难以规划", "对批评敏感", "回避冲突", "容易压力", "不善于表达"],
            populationPercentage: "8.8%",
            keyTraits: ["艺术", "温和", "灵活", "敏感", "当下"],
            careerPaths: ["艺术家", "设计师", "摄影师", "护士", "厨师", "音乐家", "兽医"],
            relationshipStyle: "温柔敏感的伴侣，重视和谐，需要被理解和接纳",
            stressTriggers: ["冲突", "被批评", "压力", "严格的规则", "缺乏创作空间"],
            growthAdvice: [
                "学会面对冲突",
                "建立长期目标",
                "表达自己的需求",
                "接受批评作为成长"
            ],
            compatibleTypes: ["ESFJ", "ESTJ", "ISFJ", "ESFP"],
            challengingTypes: ["ENTJ", "ENTP", "ESTJ"]
        ),
        PersonalityType(
            id: "ESTP",
            name: "企业家",
            group: .explorer,
            description: "聪明、精力充沛、善于感知的人，真心享受生活在边缘。",
            strengths: ["行动力强", "适应力", "务实", "社交", "乐观"],
            weaknesses: ["冲动", "容易厌倦", "风险倾向", "不耐常规", "情感浅薄"],
            populationPercentage: "4.3%",
            keyTraits: ["活力", "务实", "社交", "冒险", "当下"],
            careerPaths: ["销售", "创业者", "运动员", "急救人员", "营销", "警察", "厨师"],
            relationshipStyle: "充满刺激的伴侣，需要新鲜感，表达方式直接热情",
            stressTriggers: ["单调", "被限制", "理论讨论", "情感深度", "长期规划"],
            growthAdvice: [
                "学会深思熟虑",
                "建立长期承诺",
                "培养情感深度",
                "考虑后果"
            ],
            compatibleTypes: ["ISFJ", "ISTJ", "ESFJ", "ESTJ"],
            challengingTypes: ["INFJ", "INFP", "INTJ"]
        ),
        PersonalityType(
            id: "ESFP",
            name: "表演者",
            group: .explorer,
            description: "自发的、精力充沛的、热情的表演者——生活对他们而言永远不会无聊。",
            strengths: ["热情活力", "社交能力强", "务实", "观察入微", "乐观"],
            weaknesses: ["容易分心", "回避冲突", "敏感", "不善规划", "寻求刺激"],
            populationPercentage: "8.5%",
            keyTraits: ["活力", "社交", "乐观", "当下", "热情"],
            careerPaths: ["演员", "销售", "活动策划", "公关", "幼教", "导游", "主持人"],
            relationshipStyle: "热情有趣的伴侣，喜欢一起享受当下，需要关注和乐趣",
            stressTriggers: ["孤独", "无聊", "批评", "长期规划", "抽象理论"],
            growthAdvice: [
                "学会专注",
                "建立长期规划",
                "处理冲突而非回避",
                "培养独处能力"
            ],
            compatibleTypes: ["ISFJ", "ISTJ", "ESFJ", "ESTP"],
            challengingTypes: ["INTJ", "INFJ", "INTP"]
        )
    ]
}
