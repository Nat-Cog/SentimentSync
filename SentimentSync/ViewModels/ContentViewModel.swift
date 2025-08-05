import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var allContent: [ContentItem] = []
    @Published var contentForEmotion: [ContentItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
    // Cache of the last returned items to avoid duplicates
    private var lastReturnedItems: [ContentType: ContentItem] = [:]
    
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
        // Always get a fresh random selection
        return ContentLoader.getContentByType(for: emotion, type: type, from: allContent)
    }
    
    func refreshContent() {
        // Force a refresh by clearing content caches
        contentForEmotion = []
        lastReturnedItems = [:]
        
        // No need to reload all content from JSON again, as we just want new random selections
        // from the existing content pool
    }
} 
