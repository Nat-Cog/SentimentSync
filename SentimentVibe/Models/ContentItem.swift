import Foundation

struct ContentItem: Identifiable, Codable {
    var id = UUID()
    let title: String
    let description: String
    let url: String
    let type: ContentType
    let emotion: String
    
    enum ContentType: String, Codable {
        case video
        case quote
        case song
        case article
        
        var icon: String {
            switch self {
            case .video: return "play.rectangle"
            case .quote: return "quote.bubble"
            case .song: return "music.note"
            case .article: return "doc.text"
            }
        }
        
        var label: String {
            switch self {
            case .video: return "Watch"
            case .quote: return "Read"
            case .song: return "Listen"
            case .article: return "Read"
            }
        }
    }
} 