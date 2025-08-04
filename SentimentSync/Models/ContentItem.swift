import Foundation

enum ContentType: String, Codable, Hashable {
    case video, quote, song, article

    var icon: String {
        switch self {
        case .video: return "play.rectangle.fill"
        case .quote: return "quote.bubble.fill"
        case .song: return "music.note.list"
        case .article: return "doc.richtext.fill"
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

struct ContentItem: Codable, Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let url: String
    let type: ContentType
    let emotion: String // Corresponds to the rawValue of the Emotion enum
}