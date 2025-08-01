import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let moodLogKey = "moodLogs"
    private let favoritesKey = "favoriteItems"

    private init() {}

    // MARK: - Mood Log Management

    func save(moodLog: MoodLog) {
        var allLogs = fetchMoodLogs()
        allLogs.insert(moodLog, at: 0) // Add to the top

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allLogs)
            UserDefaults.standard.set(data, forKey: moodLogKey)
        } catch {
            print("Error encoding mood logs: \(error)")
        }
    }

    func fetchMoodLogs() -> [MoodLog] {
        guard let data = UserDefaults.standard.data(forKey: moodLogKey) else { return [] }
        do {
            let decoder = JSONDecoder()
            return try decoder.decode([MoodLog].self, from: data)
        } catch {
            print("Error decoding mood logs: \(error)")
            return []
        }
    }

    func deleteMoodLogs(at offsets: IndexSet) {
        var allLogs = fetchMoodLogs()
        allLogs.remove(atOffsets: offsets)

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allLogs)
            UserDefaults.standard.set(data, forKey: moodLogKey)
        } catch {
            print("Error encoding mood logs after deletion: \(error)")
        }
    }

    // MARK: - Favorites Management

    func isFavorite(item: ContentItem) -> Bool {
        let favorites = fetchFavoriteIDs()
        return favorites.contains(item.url) // Using URL as a unique identifier
    }

    func toggleFavorite(item: ContentItem) {
        var favorites = fetchFavoriteIDs()
        if let index = favorites.firstIndex(of: item.url) {
            favorites.remove(at: index)
        } else {
            favorites.append(item.url)
        }
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }

    private func fetchFavoriteIDs() -> [String] {
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? []
    }

    func fetchFavoriteItems(completion: @escaping ([ContentItem]) -> Void) {
        let favoriteURLs = fetchFavoriteIDs()
        if favoriteURLs.isEmpty {
            completion([])
            return
        }

        ContentLoader.loadContent { allItems in
            let favoriteItems = allItems.filter { favoriteURLs.contains($0.url) }
            completion(favoriteItems)
        }
    }
}
