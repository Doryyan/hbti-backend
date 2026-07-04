import SwiftUI
import PDFKit

struct PDFPreviewView: View {
    let pdfData: Data
    let type: PersonalityType
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            PDFKitView(data: pdfData)
                .navigationTitle("PDF预览")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("关闭") {
                            dismiss()
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        HStack(spacing: 16) {
                            ShareLink(
                                item: pdfData,
                                preview: SharePreview("HBTI人格测试报告", image: Image(systemName: "doc.fill"))
                            ) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(ColorPalette.groupColor(type.group))
                            }
                            
                            Button {
                                savePDF()
                            } label: {
                                Image(systemName: "arrow.down.doc.fill")
                                    .foregroundColor(ColorPalette.groupColor(type.group))
                            }
                        }
                    }
                }
        }
    }
    
    private func savePDF() {
        let fileName = "HBTI_\(type.id)_报告.pdf"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try pdfData.write(to: tempURL)
            
            let documentPicker = UIDocumentPickerViewController(forExporting: [tempURL])
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(documentPicker, animated: true)
            }
        } catch {
            print("保存PDF失败: \(error)")
        }
    }
}

struct PDFKitView: UIViewRepresentable {
    let data: Data
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(data: data)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = PDFDocument(data: data)
    }
}
