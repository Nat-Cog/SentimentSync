import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                EmotionSelectionView()
            }
            .tabItem {
                Label("Mood", systemImage: "face.smiling")
            }
            .tag(0)

            FavoritesView()
                .tabItem {
                    Label("Favorites", systemImage: "heart.fill")
                }
                .tag(1)

            MoodHistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.bar.xaxis")
                }
                .tag(2)
        }
    }
}

#Preview {
    MainTabView()
}