import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var allContent: [ContentItem] = []
    @Published var contentForEmotion: [ContentItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Cache of selected items for each emotion and type
    private var cachedItems: [String: [ContentType: ContentItem]] = [:]
    
    init() {
        loadContent()
    }
    
    func loadContent() {
        isLoading = true
        error = nil

        ContentLoader.loadContent { [weak self] items in
            guard let self = self else { return }
            self.allContent = items
            self.isLoading = false
            
            if items.isEmpty {
                self.error = "No content available"
            }
        }
    }
    
    func getContent(for emotion: Emotion) {
        contentForEmotion = ContentLoader.getContent(for: emotion, from: allContent)
    }
    
    func getContentByType(for emotion: Emotion, type: ContentType) -> ContentItem? {
        let emotionKey = emotion.rawValue
        
        // If we haven't cached this emotion yet, initialize its cache
        if cachedItems[emotionKey] == nil {
            cachedItems[emotionKey] = [:]
        }
        
        // If we already have a cached item for this emotion and type, return it
        if let cachedItem = cachedItems[emotionKey]?[type] {
            return cachedItem
        }
        
        // Otherwise, get a random item and cache it
        if let newItem = ContentLoader.getContentByType(for: emotion, type: type, from: allContent) {
            cachedItems[emotionKey]?[type] = newItem
            return newItem
        }
        
        return nil
    }
    
    func refreshContent() {
        // Clear the cache to get fresh random selections
        cachedItems = [:]
        contentForEmotion = []
    }
} 
