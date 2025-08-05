import Foundation

class PersistenceManager {
    static let shared = PersistenceManager()
    private let moodLogKey = "moodLogs"
    private let favoritesKey = "favoriteItems"

    private init() {}
    
    /// Returns the URL for the mood logs JSON file in the app's documents directory.
    private var moodLogFileURL: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory.")
            return nil
        }
        return documentsDirectory.appendingPathComponent("mood-logs.json")
    }

    // MARK: - Mood Log Management

    func save(moodLog: MoodLog) {
        var allLogs = fetchMoodLogs()
        allLogs.insert(moodLog, at: 0) // Add to the top

        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(allLogs)
            if let url = moodLogFileURL {
                try data.write(to: url, options: [.atomicWrite])
            }
        } catch {
            print("Error encoding mood logs: \(error)")
        }
    }

    func fetchMoodLogs() -> [MoodLog] {
        guard let url = moodLogFileURL,
              let data = try? Data(contentsOf: url) else { return [] }
              
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
            if let url = moodLogFileURL {
                try data.write(to: url, options: [.atomicWrite])
            }
        } catch {
            print("Error encoding mood logs after deletion: \(error)")
        }
    }

    // MARK: - Favorites Management

    func isFavorite(item: ContentItem) -> Bool {
        let favorites = fetchFavoriteIDs()
        return favorites.contains(item.id.uuidString) // Using the unique ID
    }

    func toggleFavorite(item: ContentItem) {
        var favorites = fetchFavoriteIDs()
        if let index = favorites.firstIndex(of: item.id.uuidString) {
            favorites.remove(at: index)
        } else {
            favorites.append(item.id.uuidString)
        }
        UserDefaults.standard.set(favorites, forKey: favoritesKey)
    }

    private func fetchFavoriteIDs() -> [String] {
        // Using the unique ID as a string
        return UserDefaults.standard.stringArray(forKey: favoritesKey) ?? [] 
    }

    func fetchFavoriteItems(completion: @escaping ([ContentItem]) -> Void) {
        let favoriteIDs = fetchFavoriteIDs()
        if favoriteIDs.isEmpty {
            completion([])
            return
        }

        ContentLoader.loadContent { allItems in
            let favoriteItems = allItems.filter { favoriteIDs.contains($0.id.uuidString) }
            completion(favoriteItems)
        }
    }
}
