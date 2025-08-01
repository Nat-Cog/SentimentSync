import Foundation
import Combine

class ContentViewModel: ObservableObject {
    @Published var allContent: [ContentItem] = []
    @Published var contentForEmotion: [ContentItem] = []
    @Published var isLoading = false
    @Published var error: String?
    
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
    
    func getContentByType(for emotion: Emotion, type: ContentItem.ContentType) -> ContentItem? {
        return ContentLoader.getContentByType(for: emotion, type: type, from: allContent)
    }
    
    func refreshContent() {
        loadContent()
    }
} 
