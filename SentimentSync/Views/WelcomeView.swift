import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isActive = true
            }
        }
        .navigationDestination(isPresented: $isActive) {
            MainTabView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
} 
