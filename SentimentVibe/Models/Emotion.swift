import SwiftUI

enum Emotion: String, CaseIterable, Identifiable {
    case happy
    case sad
    case angry
    case scared
    case romantic
    case relaxed
    case lost
    case stressed
    case sleepy
    
    var id: String { rawValue }
    
    var title: String {
        rawValue.capitalized
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
} 