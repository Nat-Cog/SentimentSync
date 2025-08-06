import SwiftUI
import SafariServices


struct ContentDetailView: View {
    let item: ContentItem
    let emotion: Emotion
    @State private var showSafari = false
    @State private var isFavorite = false
    private var contentURL: URL? { URL(string: item.url) }

    var body: some View {
        ScrollView {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            // Use a switch to provide a custom view for each content type
            switch item.type {
            case .quote:
                QuoteDetailView(item: item, emotion: emotion)
            default:
                ExternalContentDetailView(item: item, emotion: emotion, showSafari: $showSafari)
            }
        }
        .navigationTitle(item.type.rawValue.capitalized)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    PersistenceManager.shared.toggleFavorite(item: item)
                    isFavorite.toggle()
                }) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? emotion.color : emotion.color.opacity(0.5))
                }
            }
        }
        .sheet(isPresented: $showSafari) {
            if let url = contentURL {
                SafariView(url: url)
            }
        }
        .onAppear {
            isFavorite = PersistenceManager.shared.isFavorite(item: item)
        }
    }
}

/// A view specialized for displaying quotes beautifully.
struct QuoteDetailView: View {
    let item: ContentItem
    let emotion: Emotion

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            Spacer()
            
            Image(systemName: "quote.opening")
                .font(.system(size: 40))
                .foregroundColor(emotion.color.opacity(0.5))

            Text(item.title)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("— \(item.description)")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
            
            Image(systemName: "quote.closing")
                .font(.system(size: 40))
                .foregroundColor(emotion.color.opacity(0.5))
            
            Spacer()
        }
        .padding()
    }
}

/// A view for content that links to an external URL (videos, articles, songs).
struct ExternalContentDetailView: View {
    let item: ContentItem
    let emotion: Emotion
    @Binding var showSafari: Bool
    private var contentURL: URL? { URL(string: item.url) }

    var body: some View {
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
                .padding(.bottom, 10)
            
            // Interactive preview card
            Button(action: {
                if contentURL != nil {
                    showSafari = true
                }
            }) {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [emotion.color.opacity(0.6), emotion.color.opacity(0.9)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    
                    VStack(spacing: 15) {
                        Image(systemName: item.type.icon)
                            .font(.system(size: 60))
                        Text("Tap to \(item.type.label)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(.white)
                }
                .frame(height: 220)
                .cornerRadius(20)
                .shadow(color: emotion.color.opacity(0.4), radius: 8, y: 4)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(contentURL == nil)
        }
        .padding()
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
