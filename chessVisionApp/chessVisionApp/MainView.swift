import SwiftUI
struct MainView: View {
    var body: some View {
        TabView {
            VStack {
                PopularView()
                Spacer() 
            }
            .tabItem {
                Image("pawn")
                Text("POPULAR")
            }
            
            VStack {
                AllView()
                Spacer()
            }
            .tabItem {
                Image("knight")
                Text("All")
            }
            
            VStack {
                QuizView()
                Spacer()
            }
            .tabItem {
                Image("king")
                Text("QUIZ")
            }
        }
}
}
#Preview {
MainView()
}
