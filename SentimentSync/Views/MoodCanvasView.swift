import SwiftUI

struct MoodCanvasView: View {
    @State private var selectedEmotion: Emotion = .happy
    
    // Initializer to allow pre-selecting an emotion
    init(selectedEmotion: Emotion = .happy) {
        _selectedEmotion = State(initialValue: selectedEmotion)
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
            particleAnimation
            overlayContent
        }
        .navigationTitle("Mood Canvas")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - View Components

    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [selectedEmotion.color.opacity(0.7), .black]),
            startPoint: .top,
            endPoint: .bottom
        )
        .animation(.easeInOut(duration: 1.5), value: selectedEmotion)
        .ignoresSafeArea()
    }

    private var particleAnimation: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                
                for i in 0..<30 {
                    let x = (sin(Double(i) * 0.5 + time * self.speed(for: selectedEmotion).x) + 1) / 2 * size.width
                    let y = (cos(Double(i) * 0.3 + time * self.speed(for: selectedEmotion).y) + 1) / 2 * size.height
                    let particleSize = self.size(for: selectedEmotion)
                    
                    let particlePath = Path(ellipseIn: CGRect(x: x, y: y, width: particleSize, height: particleSize))
                    context.fill(particlePath, with: .color(.white.opacity(0.6)))
                }
            }
        }
        .ignoresSafeArea()
    }

    private var overlayContent: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 8) {
                Text(selectedEmotion.title)
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .transition(.opacity.combined(with: .scale))
                    .id(selectedEmotion.title) // Use .id to trigger transition on change
                
                Text("Watch the canvas reflect your mood.")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            
            Spacer()

            Picker("Select a Mood", selection: $selectedEmotion) {
                ForEach(Emotion.allCases) { emotion in
                    Image(systemName: emotion.icon).tag(emotion)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(.thinMaterial)
            .clipShape(Capsule())
            .padding()
        }
    }

    // Helper functions to define mood-based animation properties
    private func speed(for emotion: Emotion) -> (x: Double, y: Double) {
        switch emotion {
        case .happy: return (0.8, 0.6)
        case .sad: return (0.1, 0.2)
        case .angry: return (2.5, 2.0)
        case .scared: return (1.5, 1.8)
        case .romantic: return (0.4, 0.3)
        case .relaxed: return (0.2, 0.2)
        case .lost: return (0.3, 0.4)
        case .stressed: return (1.8, 1.5)
        case .sleepy: return (0.1, 0.1)
        }
    }

    private func size(for emotion: Emotion) -> CGFloat {
        switch emotion {
        case .happy: return 30
        case .sad: return 15
        case .angry: return 10
        case .scared: return 8
        case .romantic: return 40
        case .relaxed: return 50
        case .lost: return 20
        case .stressed: return 12
        case .sleepy: return 60
        }
    }
}

#Preview {
    NavigationView {
        MoodCanvasView()
    }
}