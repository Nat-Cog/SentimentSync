import Foundation
import SwiftData

@Model
final class FavoriteItem {
    // Using the content item's UUID string as the unique ID
    @Attribute(.unique) var contentId: String
    var favoritedDate: Date

    init(contentId: String) {
        self.contentId = contentId
        self.favoritedDate = .now
    }
}