import SwiftUI
import CoreImage

struct ShareCardView: View {
    let result: TestResult
    @Environment(\.dismiss) private var dismiss
    @State private var cardImage: UIImage?
    
    var personalityType: PersonalityType? {
        result.personalityType
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if let type = personalityType {
                    // 分享卡片预览
                    ShareCardContent(result: result, type: type)
                        .frame(width: 350, height: 500)
                        .background(ColorPalette.cardBackground)
                        .cornerRadius(20)
                        .shadow(radius: 10)
                        .padding()
                    
                    // 分享按钮
                    Button {
                        shareCard()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("分享卡片")
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
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("分享结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .background(ColorPalette.groupSecondaryColor(personalityType?.group ?? .analyst))
        }
    }
    
    private func shareCard() {
        guard let type = personalityType else { return }
        
        let cardView = ShareCardContent(result: result, type: type)
            .frame(width: 350, height: 500)
        
        let renderer = ImageRenderer(content: cardView)
        renderer.scale = 3.0
        
        if let image = renderer.uiImage {
            let activityItems: [Any] = [image, "我在HBTI人格测试中测出了\(result.typeCode)（\(type.name)），快来看看你的类型吧！"]
            let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
}

struct ShareCardContent: View {
    let result: TestResult
    let type: PersonalityType
    
    var body: some View {
        VStack(spacing: 16) {
            // 顶部品牌
            HStack {
                Text("HBTI")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorPalette.groupColor(type.group))
                Spacer()
                Text("16型人格测试")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // 类型代码
            Text(result.typeCode)
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(ColorPalette.groupColor(type.group))
            
            Text(type.name)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(ColorPalette.groupColor(type.group))
            
            // 维度百分比
            HStack(spacing: 12) {
                ForEach(result.dimensionScores) { score in
                    VStack(spacing: 4) {
                        Text(score.dominantCode)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(ColorPalette.dimensionColor(score.dimension))
                        
                        Text("\(Int(score.dominantSide == .left ? score.leftPercentage : score.rightPercentage))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(width: 40)
                }
            }
            
            // 关键词
            FlowLayout(spacing: 6) {
                ForEach(type.keyTraits.prefix(4), id: \.self) { trait in
                    Text(trait)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(ColorPalette.groupColor(type.group).opacity(0.15))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
            
            // 描述
            Text(type.description)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
                .lineLimit(2)
            
            Spacer()
            
            // 底部
            Text("扫码测一测你的人格类型")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            HStack {
                if let qrImage = generateQRCode(from: "https://hbti.app/download") {
                    Image(uiImage: qrImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .cornerRadius(6)
                } else {
                    Image(systemName: "qrcode")
                        .font(.system(size: 40))
                        .foregroundColor(ColorPalette.groupColor(type.group))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("HBTI 16型人格测试")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("探索真实的自己")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom)
        }
    }
}
    /// 生成真实二维码
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let outputImage = filter.outputImage else { return nil }
        let transform = CGAffineTransform(scaleX: 6, y: 6)
        let scaledImage = outputImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
