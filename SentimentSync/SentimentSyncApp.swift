import SwiftUI
import SwiftData

@main
struct SentimentSyncApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                WelcomeView()
            }
        }
        // The modelContainer sets up the database for the specified models.
        .modelContainer(for: [MoodLog.self, FavoriteItem.self])
    }
}