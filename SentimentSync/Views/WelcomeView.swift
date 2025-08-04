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
