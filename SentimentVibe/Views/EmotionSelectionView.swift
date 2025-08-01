import SwiftUI

struct EmotionSelectionView: View {
    @State private var isShowingHistory = false
    @State private var isShowingFavorites = false
    @State private var isShowingBreathingExercise = false

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

                // Breathing Exercise Button
                Button(action: {
                    isShowingBreathingExercise = true
                }) {
                    HStack {
                        Image(systemName: "wind")
                        Text("Try a Breathing Exercise")
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.gradient)
                    .cornerRadius(15)
                    .padding([.horizontal, .bottom])
                }

            }
            .padding(.vertical)
        }
        .navigationTitle("Select Mood")
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
    .toolbar {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button(action: { isShowingFavorites = true }) {
                Image(systemName: "heart.fill")
            }

            Button(action: { isShowingHistory = true }) {
                Image(systemName: "list.bullet.rectangle.portrait")
            }
        }
    }
    .sheet(isPresented: $isShowingHistory) {
        MoodHistoryView()
    }
    .sheet(isPresented: $isShowingFavorites) {
        FavoritesView()
    }
    .sheet(isPresented: $isShowingBreathingExercise) {
        BreathingExerciseView()
    }
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