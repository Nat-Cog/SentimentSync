import Foundation
import SwiftData

@Model
final class MoodLog {
    var emotion: Emotion
    var date: Date

    init(emotion: Emotion, date: Date = .now) {
        self.emotion = emotion
        self.date = date
    }
}