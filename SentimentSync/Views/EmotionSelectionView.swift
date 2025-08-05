import SwiftUI

struct EmotionSelectionView: View {
    @State private var isShowingBreathingExercise = false
    @State private var isShowingInteractiveTools = false
    @State private var userMoodText: String = ""
    @State private var determinedEmotion: Emotion?
    @State private var showCouldNotDetermineMoodAlert = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        // By placing the navigationDestination on a container outside the ScrollView,
        // we ensure it's always in the view hierarchy and not subject to the lazy
        // loading behavior of the ScrollView's content. This resolves the warning.
        Group {
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
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Or describe it in your own words")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)

                        HStack {
                            TextField("e.g., 'I feel a bit stressed today'", text: $userMoodText)
                                .padding(12)
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(10)
                                .onSubmit(determineMood)

                            Button(action: determineMood) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.accentColor)
                            }
                            .disabled(userMoodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                    .padding(.horizontal)

                    VStack(spacing: 15) {
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
                        }

                        // Interactive Tools Button
                        Button(action: {
                            isShowingInteractiveTools = true
                        }) {
                            HStack {
                                Image(systemName: "hands.sparkles.fill")
                                Text("Mindful Activities")
                            }
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple.gradient)
                            .cornerRadius(15)
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
                .padding(.vertical)
            }
            .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        }
        .navigationDestination(item: $determinedEmotion) { emotion in
            ContentSuggestionsView(emotion: emotion)
        }
        .alert("Couldn't Determine Mood", isPresented: $showCouldNotDetermineMoodAlert) {
            Button("OK") { }
        } message: {
            Text("We couldn't quite understand that. Please try other words, or select a mood from the options below.")
        }
        .sheet(isPresented: $isShowingBreathingExercise) {
            BreathingExerciseView()
        }
        .sheet(isPresented: $isShowingInteractiveTools) {
            InteractiveToolsView()
        }
    }

    private func determineMood() {
        guard !userMoodText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        if let emotion = Emotion.from(text: userMoodText) {
            determinedEmotion = emotion
            userMoodText = "" // Clear text field on success
        } else {
            showCouldNotDetermineMoodAlert = true
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
                .frame(height: 35, alignment: .top) // Align cells
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
