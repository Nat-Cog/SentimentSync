import Foundation

class ContentLoader {
    static func loadContent(completion: @escaping ([ContentItem]) -> Void) {
        guard let url = Bundle.main.url(forResource: "ContentData", withExtension: "json") else {
            print("ContentData.json not found")
            completion([])
            return
        }
        
        DispatchQueue.global().async {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                let items = try decoder.decode([ContentItem].self, from: data)
                DispatchQueue.main.async {
                    completion(items)
                }
            } catch {
                print("Error loading content: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
    
    static func getContent(for emotion: Emotion, from allContent: [ContentItem]) -> [ContentItem] {
        return allContent.filter { $0.emotion == emotion.rawValue }
    }
    
    static func getContentByType(for emotion: Emotion, type: ContentItem.ContentType, from allContent: [ContentItem]) -> ContentItem? {
        return allContent.first { $0.emotion == emotion.rawValue && $0.type == type }
    }
} 