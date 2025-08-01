import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.85, green: 0.92, blue: 0.98),  // Light blue
                    Color(red: 0.96, green: 0.87, blue: 0.89)   // Light pink
                ]),
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
        .onTapGesture {
            isActive = true
        }
        .navigationDestination(isPresented: $isActive) {
            EmotionSelectionView()
                .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
    }
} 
