import SwiftUI

struct BreathingExerciseView: View {
    // Define the sequence of breathing phases with their properties
    private let phases: [(instruction: String, duration: TimeInterval, scale: CGFloat)] = [
        ("Breathe In...", 4, 1.0),
        ("Hold", 4, 1.0),
        ("Breathe Out...", 6, 0.5)
    ]

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 0.5
    @State private var instruction = "Get Ready..."
    @State private var countdown: Int = 0
    @State private var currentPhaseIndex = 0
    @State private var isRunning = false

    @State private var timeRemaining = 60 // Total duration in seconds (1 minute)
    @State private var exerciseFinished = false

    // A timer that fires every second
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background gradient for a calming effect
            RadialGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)]),
                center: .center,
                startRadius: 5,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding()

            if exerciseFinished {
                // Completion View
                VStack(spacing: 30) {
                    Text("Well Done!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.blue.opacity(0.8))
                    .padding(.horizontal, 40)
                    .padding(.vertical, 15)
                    .background(.white)
                    .clipShape(Capsule())
                }
            } else {
                // Main Exercise View
                VStack(spacing: 40) {
                    HStack {
                        Text("Guided Breathing")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.top, 20)

                    ZStack {
                        // Base circle
                        Circle()
                            .stroke(lineWidth: 10)
                            .foregroundColor(.white.opacity(0.3))

                        // Animated circle that expands and contracts
                        Circle()
                            .fill(Color.white.opacity(0.7))
                            .scaleEffect(scale)

                        // Countdown Timer Text
                        if isRunning {
                            Text("\(countdown)")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                                .transition(.opacity.animation(.easeIn))
                        }
                    }
                    .frame(width: 250, height: 250)

                    Text(instruction)
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .animation(nil, value: instruction) // Prevent text from animating

                    Spacer()

                    // Timer display at the bottom
                    Text("Time Remaining: \(timeRemaining)s")
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .background(.white.opacity(0.2))
                        .clipShape(Capsule())
                }
                .padding()
            }
        }
        .onAppear(perform: startBreathingCycle)
        .onReceive(timer) { _ in
            guard isRunning && !exerciseFinished else { return }

            // Handle total time remaining
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                isRunning = false
                exerciseFinished = true
                return
            }

            // Handle phase countdown
            if countdown > 1 {
                countdown -= 1
            } else {
                currentPhaseIndex = (currentPhaseIndex + 1) % phases.count
                setupCurrentPhase()
            }
        }
    }

    private func startBreathingCycle() {
        // Initial delay before starting the loop
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isRunning = true
            setupCurrentPhase()
        }
    }

    private func setupCurrentPhase() {
        let phase = phases[currentPhaseIndex]
        instruction = phase.instruction
        countdown = Int(phase.duration)
        
        withAnimation(.easeInOut(duration: phase.duration)) {
            scale = phase.scale
        }
    }
}

#Preview {
    BreathingExerciseView()
}
