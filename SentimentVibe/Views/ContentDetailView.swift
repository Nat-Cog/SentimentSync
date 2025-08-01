import SwiftUI
import SafariServices

struct ContentDetailView: View {
    let item: ContentItem
    let emotion: Emotion
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with icon and type
                HStack {
                    Image(systemName: item.type.icon)
                        .font(.system(size: 24))
                        .foregroundColor(emotion.color)
                    
                    Text(item.type.rawValue.capitalized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(emotion.color)
                }
                
                // Title
                Text(item.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                // Description
                Text(item.description)
                    .font(.system(size: 18, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)
                
                // Content preview placeholder
                ZStack {
                    Rectangle()
                        .fill(emotion.color.opacity(0.1))
                        .cornerRadius(15)
                        .frame(height: 200)
                    
                    VStack {
                        Image(systemName: contentImageName())
                            .font(.system(size: 50))
                            .foregroundColor(emotion.color)
                        
                        Text("Tap to \(item.type.label)")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(emotion.color)
                            .padding(.top, 10)
                    }
                }
                .onTapGesture {
                    showSafari = true
                }
                
                // Open button
                Button(action: {
                    showSafari = true
                }) {
                    HStack {
                        Text("\(item.type.label) Now")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(emotion.color)
                    )
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle(item.type.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGray6).edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showSafari) {
            SafariView(url: URL(string: item.url) ?? URL(string: "https://www.apple.com")!)
        }
    }
    
    private func contentImageName() -> String {
        switch item.type {
        case .video:
            return "play.rectangle.fill"
        case .quote:
            return "quote.bubble.fill"
        case .song:
            return "music.note.list"
        case .article:
            return "doc.richtext.fill"
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // No update needed
    }
}

#Preview {
    let item = ContentItem(
        id: UUID(),
        title: "Happy Dance Compilation",
        description: "A compilation of uplifting dance videos to enhance your mood",
        url: "https://www.example.com/video1",
        type: .video,
        emotion: "happy"
    )
    
    return NavigationStack {
        ContentDetailView(item: item, emotion: .happy)
    }
} 