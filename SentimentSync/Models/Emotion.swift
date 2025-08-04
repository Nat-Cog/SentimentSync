import SwiftUI

enum Emotion: String, CaseIterable, Codable, Identifiable {
    case happy, sad, angry, scared, romantic, relaxed, lost, stressed, sleepy

    var id: String { self.rawValue }

    var title: String {
        return self.rawValue.prefix(1).uppercased() + self.rawValue.dropFirst()
    }

    var icon: String {
        switch self {
        case .happy: return "face.smiling"
        case .sad: return "cloud.rain"
        case .angry: return "flame"
        case .scared: return "exclamationmark.triangle"
        case .romantic: return "heart"
        case .relaxed: return "leaf"
        case .lost: return "map"
        case .stressed: return "bolt"
        case .sleepy: return "moon.zzz"
        }
    }

    var color: Color {
        switch self {
        case .happy: return .yellow
        case .sad: return .blue
        case .angry: return .red
        case .scared: return .purple
        case .romantic: return .pink
        case .relaxed: return .green
        case .lost: return .gray
        case .stressed: return .orange
        case .sleepy: return .indigo
        }
    }

    /// Determines the most appropriate emotion category for content suggestions
    /// to ensure a positive impact on the user's mood.
    var suggestedContentEmotion: Emotion {
        switch self {
        case .sad, .lost:
            return .happy // Suggest uplifting content
        case .angry, .scared, .stressed:
            return .relaxed // Suggest calming content
        case .relaxed:
            // Per feedback, if already relaxed, suggest happy content instead of more relaxation.
            return .happy
        case .happy, .romantic, .sleepy:
            return self // For these, the content should match the mood
        }
    }

    static func from(text: String) -> Emotion? {
        let lowercasedText = text.lowercased()

        // Simple keyword matching. More sophisticated logic could be used here.
        if lowercasedText.contains("happy") || lowercasedText.contains("joy") || lowercasedText.contains("excited") || lowercasedText.contains("good") {
            return .happy
        }
        if lowercasedText.contains("sad") || lowercasedText.contains("down") || lowercasedText.contains("blue") || lowercasedText.contains("unhappy") {
            return .sad
        }
        if lowercasedText.contains("angry") || lowercasedText.contains("mad") || lowercasedText.contains("furious") || lowercasedText.contains("pissed") {
            return .angry
        }
        if lowercasedText.contains("scared") || lowercasedText.contains("afraid") || lowercasedText.contains("anxious") || lowercasedText.contains("worried") {
            return .scared
        }
        if lowercasedText.contains("love") || lowercasedText.contains("romantic") {
            return .romantic
        }
        if lowercasedText.contains("relaxed") || lowercasedText.contains("calm") || lowercasedText.contains("peaceful") {
            return .relaxed
        }
        if lowercasedText.contains("lost") || lowercasedText.contains("confused") || lowercasedText.contains("unsure") {
            return .lost
        }
        if lowercasedText.contains("stressed") || lowercasedText.contains("overwhelmed") || lowercasedText.contains("burnt out") {
            return .stressed
        }
        if lowercasedText.contains("sleepy") || lowercasedText.contains("tired") || lowercasedText.contains("exhausted") {
            return .sleepy
        }

        return nil
    }
}
