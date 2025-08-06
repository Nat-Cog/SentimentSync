import SwiftUI
import SwiftData


struct FavoritesView: View {
    // Query for the IDs of all favorited items, sorted by date.
    @Query(sort: \FavoriteItem.favoritedDate, order: .reverse) private var favoriteItemIDs: [FavoriteItem]
    
    @State private var favoriteItems: [ContentItem] = []
    @State private var allContent: [ContentItem] = []

    var body: some View {
        ScrollView {
            if favoriteItems.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "heart.slash.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.5))
                    Text("No Favorites Yet")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                    Text("Tap the heart on any content to save it here for later.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 20) {
                    ForEach(favoriteItems) { item in
                        // The ContentItemCard needs an Emotion object. We can create it from the string.
                        if let emotion = Emotion(rawValue: item.emotion) {
                            ContentItemCard(item: item, emotion: emotion)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Favorites")
        .onAppear(perform: loadAllContent)
        .onChange(of: favoriteItemIDs) { _, _ in
            // React to changes in the favorites list.
            updateFavoriteItems()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
        )
    }

    private func loadAllContent() {
        // Load the static content only once.
        guard allContent.isEmpty else { return }
        ContentLoader.loadContent { items in
            self.allContent = items
            updateFavoriteItems()
        }
    }
    
    private func updateFavoriteItems() {
        let idSet = Set(favoriteItemIDs.map { $0.contentId })
        self.favoriteItems = allContent.filter { idSet.contains($0.id.uuidString) }
    }
}

#Preview {
    // This preview won't show data unless you inject a mock persistence layer.
    // For now, it will show the empty state.
    FavoritesView()
}
