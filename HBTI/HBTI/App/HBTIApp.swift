import SwiftUI

@main
struct HBTIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var quizViewModel = QuizViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            WelcomeView()
                .environment(quizViewModel)
        }
    }
}
