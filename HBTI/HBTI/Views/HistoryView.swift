import SwiftUI

struct HistoryView: View {
    @State private var results: [TestResult] = []
    @State private var showDeleteAlert = false
    @State private var selectedResult: TestResult?
    @State private var showResultDetail = false
    
    var body: some View {
        List {
            if results.isEmpty {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("暂无测试记录")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("完成测试后，你的结果将显示在这里")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                }
            } else {
                ForEach(results) { result in
                    HistoryRow(result: result)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                deleteResult(result)
                            } label: {
                                Label("删除", systemImage: "trash")
                            }
                        }
                        .onTapGesture {
                            selectedResult = result
                            showResultDetail = true
                        }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("测试历史")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadResults()
        }
        .navigationDestination(isPresented: $showResultDetail) {
            if let result = selectedResult {
                ResultView(result: result)
            }
        }
    }
    
    private func loadResults() {
        results = PersistenceManager.shared.getTestResults()
    }
    
    private func deleteResult(_ result: TestResult) {
        PersistenceManager.shared.deleteTestResult(result.id)
        loadResults()
    }
}

struct HistoryRow: View {
    let result: TestResult
    
    var personalityType: PersonalityType? {
        result.personalityType
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // 类型代码
            if let type = personalityType {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(ColorPalette.groupColor(type.group).opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Text(result.typeCode)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(ColorPalette.groupColor(type.group))
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text("?")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if let type = personalityType {
                        Text(type.name)
                            .font(.headline)
                            .foregroundColor(ColorPalette.groupColor(type.group))
                    } else {
                        Text("未知类型")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if result.isDetailedReportUnlocked || PersistenceManager.shared.isProductUnlocked(result.testVersion.productID ?? "") {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text("\(result.username) · \(result.testVersion.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(formatDate(result.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 HH:mm"
        return formatter.string(from: date)
    }
}
