import SwiftUI

struct JournalingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.brown)

            Text("Journaling Space")
                .font(.system(size: 28, weight: .bold, design: .rounded))

            Text("A private space to write down your thoughts, reflect on your day, and track your mood.\n\nComing soon!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            Spacer()
        }
        .padding()
        .navigationTitle("Journaling")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

#Preview {
    NavigationView {
        JournalingView()
    }
}