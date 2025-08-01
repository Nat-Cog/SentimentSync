import SwiftUI

struct EmotionSelectionView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("How are you feeling today?")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Emotion.allCases) { emotion in
                        NavigationLink(destination: ContentSuggestionsView(emotion: emotion)) {
                            EmotionCell(emotion: emotion)
                        }
                    }
                }
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Select Mood")
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    }
}

struct EmotionCell: View {
    let emotion: Emotion
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(emotion.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: emotion.icon)
                    .font(.system(size: 32))
                    .foregroundColor(emotion.color)
            }
            
            Text(emotion.title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        EmotionSelectionView()
    }
} 