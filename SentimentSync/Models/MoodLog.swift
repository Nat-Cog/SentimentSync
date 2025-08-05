import Foundation


struct MoodLog: Identifiable, Codable {
    let id: UUID
    let emotion: Emotion
    let date: Date

    init(emotion: Emotion) {
        self.id = UUID()
        self.emotion = emotion
        self.date = Date()
    }
}
