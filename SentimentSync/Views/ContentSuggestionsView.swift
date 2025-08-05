import SwiftUI

struct ContentSuggestionsView: View {
    let emotion: Emotion
    @StateObject private var viewModel = ContentViewModel()
    @State private var showEmotionSelection = false
    @State private var isMoodLogged = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Image(systemName: emotion.icon)
                        .font(.system(size: 40))
                        .foregroundColor(emotion.color)
                    
                    Text("Content for when you're feeling \(emotion.title.lowercased())")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                //If we want to guide user to a different emotion, in case of negative emotions.
//                let targetEmotion = emotion.suggestedContentEmotion
                let targetEmotion = emotion

                if viewModel.isLoading {
                    ProgressView()
                        .padding()
                } else if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                } else {
                    // Video Suggestion
                    if let video = viewModel.getContentByType(for: targetEmotion, type: .video) {
                        ContentItemCard(item: video, emotion: emotion)
                    }
                    
                    // Quote Suggestion
                    if let quote = viewModel.getContentByType(for: targetEmotion, type: .quote) {
                        ContentItemCard(item: quote, emotion: emotion)
                    }
                    
                    // Song Suggestion
                    if let song = viewModel.getContentByType(for: targetEmotion, type: .song) {
                        ContentItemCard(item: song, emotion: emotion)
                    }
                    
                    // Article Suggestion
                    if let article = viewModel.getContentByType(for: targetEmotion, type: .article) {
                        ContentItemCard(item: article, emotion: emotion)
                    }

                    // Mood Canvas Button
                    NavigationLink(destination: MoodCanvasView(selectedEmotion: emotion)) {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Visualize in Mood Canvas")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(emotion.color)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(emotion.color.opacity(0.15))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }

                    // Log mood button
                    Button(action: {
                        if !isMoodLogged {
                            PersistenceManager.shared.save(moodLog: MoodLog(emotion: emotion))
                            isMoodLogged = true
                        }
                    }) {
                        HStack {
                            Image(systemName: isMoodLogged ? "checkmark.circle.fill" : "plus.circle.fill")
                            Text(isMoodLogged ? "Mood Logged" : "Log This Mood")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(isMoodLogged ? .green : emotion.color)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isMoodLogged ? Color.green.opacity(0.15) : emotion.color.opacity(0.15))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }.disabled(isMoodLogged)

                }
                
                // Not feeling these button
                Button(action: {
                    showEmotionSelection = true
                }) {
                    Text("Not feeling these?")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(emotion.color)
                        )
                        .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 10)
            }
            .padding(.vertical)
        }
        .onAppear {
            viewModel.getContent(for: emotion)
        }
        .navigationTitle("Content Suggestions")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .navigationDestination(isPresented: $showEmotionSelection) {
            EmotionSelectionView()
                .navigationBarBackButtonHidden(true)
        }
        .refreshable {
            viewModel.refreshContent()
            viewModel.getContent(for: emotion)
        }
    }
}

struct ContentItemCard: View {
    let item: ContentItem
    let emotion: Emotion
    
    var body: some View {
        NavigationLink(destination: ContentDetailView(item: item, emotion: emotion)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: item.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(emotion.color)
                    
                    Text(item.type.rawValue.capitalized)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(emotion.color)
                    
                    Spacer()
                    
                    Text(item.type.label)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(emotion.color.opacity(0.2))
                        .foregroundColor(emotion.color)
                        .cornerRadius(15)
                }
                
                Text(item.title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(item.description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .padding(.horizontal)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NavigationStack {
        ContentSuggestionsView(emotion: .happy)
    }
} 
