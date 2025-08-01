import SwiftUI

struct WelcomeView: View {
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Welcome Back")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
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
