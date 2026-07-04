import SwiftUI
import UIKit

struct ColorPalette {
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#7B68EE"), Color(hex: "#3CB371")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "#F8F5FF"), Color(hex: "#F0FFF4")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    /// 暗黑模式自适应背景渐变
    static let adaptiveBackgroundGradient: LinearGradient = {
        LinearGradient(
            colors: [
                Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark
                    ? UIColor(hex: "#1a1a2e")
                    : UIColor(hex: "#F8F5FF")
                }),
                Color(UIColor { traitCollection in
                    traitCollection.userInterfaceStyle == .dark
                    ? UIColor(hex: "#16213e")
                    : UIColor(hex: "#F0FFF4")
                })
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }()
    
    /// 卡片背景色，暗黑模式自动适配
    static var cardBackground: Color {
        Color(.secondarySystemBackground)
    }
    
    /// 卡片阴影，暗黑模式下减弱
    static var cardShadow: Color {
        Color(.black).opacity(
            UITraitCollection.current.userInterfaceStyle == .dark ? 0.3 : 0.08
        )
    }
    
    static func dimensionColor(_ dimension: PersonalityDimension) -> Color {
        Color(hex: dimension.colorHex)
    }
    
    static func groupColor(_ group: TypeGroup) -> Color {
        Color(hex: group.colorHex)
    }
    
    static func groupSecondaryColor(_ group: TypeGroup) -> Color {
        Color(hex: group.secondaryColorHex)
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
