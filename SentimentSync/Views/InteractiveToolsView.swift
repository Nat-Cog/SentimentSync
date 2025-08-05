import SwiftUI

struct InteractiveToolsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.85, green: 0.90, blue: 0.98), Color(red: 0.98, green: 0.90, blue: 0.95)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                List {
                    NavigationLink(destination: ArtAndCraftView()) {
                        ToolRow(
                            iconName: "paintpalette.fill",
                            iconColor: .orange,
                            title: "Art & Craft",
                            description: "Express yourself through drawing and colors."
                        )
                    }
                    NavigationLink(destination: JournalingView()) {
                        ToolRow(
                            iconName: "book.closed.fill",
                            iconColor: .brown,
                            title: "Journaling",
                            description: "Write down your thoughts and feelings."
                        )
                    }
                    NavigationLink(destination: MindfulColoringView()) {
                        ToolRow(
                            iconName: "eyedropper.halffull",
                            iconColor: .cyan,
                            title: "Mindful Coloring",
                            description: "Relax and focus with digital coloring pages."
                        )
                    }
                    NavigationLink(destination: MoodCanvasView()) {
                        ToolRow(
                            iconName: "sparkles",
                            iconColor: .yellow,
                            title: "Mood Canvas",
                            description: "A dynamic canvas that reflects your chosen mood."
                        )
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationTitle("Mindful Activities")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

struct ToolRow: View {
    let iconName: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(iconColor)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    InteractiveToolsView()
}